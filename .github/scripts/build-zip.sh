#!/usr/bin/env bash
# Pipeline: build the deterministic release zip.
#
# Reads version from extension.yml at the repo root. Produces
# dist/product-<version>.zip from the repo root, with files at the zip root,
# alphabetical entry order, and file timestamps fixed to the tagged commit's
# timestamp (or SOURCE_DATE_EPOCH if set).
#
# .extensionignore at the repo root governs which files are excluded from the
# zip. Files NOT matched by the ignore patterns are included (subject to the
# allowlist safety check below).
#
# After build, unpacks the zip into a temp dir and re-runs validate-manifest.sh
# against the unpacked tree, to catch packaging bugs that source validation
# would not catch.

set -e

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(CDPATH="" cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

if [ ! -f extension.yml ]; then
    echo "[build-zip] FAIL: extension.yml not found at repo root" >&2
    exit 1
fi

VERSION=$(awk '/^extension:/{f=1; next} f && /^[a-z]/{f=0} f && /^[[:space:]]+version:/{ sub(/^[[:space:]]+version:[[:space:]]*/, ""); gsub(/"/,""); print; exit }' extension.yml)
if [ -z "$VERSION" ]; then
    echo "[build-zip] FAIL: could not read extension.version" >&2
    exit 1
fi

# Determine reproducible timestamp.
# Priority: SOURCE_DATE_EPOCH (set by pipeline from tag commit) > current commit > now.
if [ -n "${SOURCE_DATE_EPOCH:-}" ]; then
    TS_EPOCH="$SOURCE_DATE_EPOCH"
elif git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    TS_EPOCH=$(git log -1 --format=%ct 2>/dev/null || date +%s)
else
    TS_EPOCH=$(date +%s)
fi

# zip's --mtime expects ISO 8601; use date conversion that works on GNU and BSD.
if date -u -d "@$TS_EPOCH" +%Y-%m-%dT%H:%M:%S >/dev/null 2>&1; then
    TS_ISO=$(date -u -d "@$TS_EPOCH" +%Y-%m-%dT%H:%M:%S)
else
    TS_ISO=$(date -u -r "$TS_EPOCH" +%Y-%m-%dT%H:%M:%S)
fi

mkdir -p dist
ZIP_PATH="dist/product-${VERSION}.zip"
rm -f "$ZIP_PATH"

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

IGNORE_FILE="$REPO_ROOT/.extensionignore"
_should_ignore() {
    local rel="$1"
    [ ! -f "$IGNORE_FILE" ] && return 1
    while IFS= read -r pat || [ -n "$pat" ]; do
        case "$pat" in ''|\#*) continue ;; esac
        case "$pat" in
            */)
                local dir="${pat%/}"
                case "$rel" in
                    "$dir"/*|*/"$dir"/*) return 0 ;;
                esac
                ;;
            */*)
                # shellcheck disable=SC2254
                case "$rel" in $pat) return 0 ;; esac
                ;;
            *)
                local base="${rel##*/}"
                # shellcheck disable=SC2254
                case "$base" in $pat) return 0 ;; esac
                ;;
        esac
    done < "$IGNORE_FILE"
    return 1
}

# Walk the repo root, copy non-ignored files into stage.
( cd "$REPO_ROOT" && find . -type f -print0 | sort -z | while IFS= read -r -d '' f; do
    rel="${f#./}"
    case "$rel" in
        .git/*) continue ;;
    esac
    if _should_ignore "$rel"; then
        echo "[build-zip] skip: $rel"
        continue
    fi
    mkdir -p "$STAGE/$(dirname "$rel")"
    cp "$rel" "$STAGE/$rel"
done )

find "$STAGE" -exec touch -d "$TS_ISO" {} +

( cd "$STAGE" && find . -type f | LC_ALL=C sort | sed 's|^\./||' | zip -X -q "$REPO_ROOT/$ZIP_PATH" -@ )

if [ ! -f "$ZIP_PATH" ]; then
    echo "[build-zip] FAIL: zip not produced at $ZIP_PATH" >&2
    exit 1
fi

# Re-validate against the unpacked zip.
VERIFY=$(mktemp -d)
trap 'rm -rf "$STAGE" "$VERIFY"' EXIT
( cd "$VERIFY" && unzip -q "$REPO_ROOT/$ZIP_PATH" )

"$SCRIPT_DIR/validate-manifest.sh" --root "$VERIFY"

# Allowlist safety net: the zip MUST contain only files that belong to the
# extension's runtime surface. If something slips past .extensionignore, fail.
ALLOWED='^(extension\.yml|README\.md|LICENSE|CHANGELOG\.md|commands/.*|templates/.*)$'
EXTRA=$(cd "$VERIFY" && find . -type f | sed 's|^\./||' | grep -Ev "$ALLOWED" || true)
if [ -n "$EXTRA" ]; then
    echo "[build-zip] FAIL: zip contains files outside the allowlist:" >&2
    echo "$EXTRA" >&2
    exit 1
fi

echo "[build-zip] OK: $ZIP_PATH (version=$VERSION, mtime=$TS_ISO UTC)"
