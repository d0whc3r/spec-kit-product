#!/usr/bin/env bash
# Pipeline: build the deterministic release zip.
#
# Reads version from extension/extension.yml. Produces dist/product-<version>.zip
# from the extension/ subtree, with files at the zip root, alphabetical entry
# order, and file timestamps fixed to the tagged commit's timestamp (or
# SOURCE_DATE_EPOCH if set).
#
# After build, unpacks the zip into a temp dir and re-runs validate-manifest.sh
# against the unpacked tree, to catch packaging bugs that source validation
# would not catch.

set -e

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(CDPATH="" cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

if [ ! -f extension/extension.yml ]; then
    echo "[build-zip] FAIL: extension/extension.yml not found" >&2
    exit 1
fi

VERSION=$(awk '/^extension:/{f=1; next} f && /^[a-z]/{f=0} f && /^[[:space:]]+version:/{ sub(/^[[:space:]]+version:[[:space:]]*/, ""); gsub(/"/,""); print; exit }' extension/extension.yml)
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

# Stage to a temp dir so file mtimes are uniform and the zip root is the
# extension subtree (not extension/ itself).
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

# Build the list of patterns to skip from extension/.extensionignore (if present).
# Format: one glob per line, '#' comments, blank lines ignored. Patterns match
# paths relative to extension/ (the zip root).
IGNORE_FILE="$REPO_ROOT/extension/.extensionignore"
_should_ignore() {
    local rel="$1"
    [ ! -f "$IGNORE_FILE" ] && return 1
    while IFS= read -r pat || [ -n "$pat" ]; do
        case "$pat" in ''|\#*) continue ;; esac
        # Directory pattern: foo/  -> match foo/ prefix anywhere
        case "$pat" in
            */)
                local dir="${pat%/}"
                case "$rel" in
                    "$dir"/*|*/"$dir"/*) return 0 ;;
                esac
                ;;
            */*)
                # Path-anchored glob.
                # shellcheck disable=SC2254
                case "$rel" in $pat) return 0 ;; esac
                ;;
            *)
                # Bare glob: match against basename anywhere in the tree.
                local base="${rel##*/}"
                # shellcheck disable=SC2254
                case "$base" in $pat) return 0 ;; esac
                ;;
        esac
    done < "$IGNORE_FILE"
    return 1
}

# Copy extension/ contents (not the directory itself) into stage, honoring
# .extensionignore.
( cd extension && find . -type f -print0 | sort -z | while IFS= read -r -d '' f; do
    rel="${f#./}"
    if _should_ignore "$rel"; then
        echo "[build-zip] skip: $rel"
        continue
    fi
    mkdir -p "$STAGE/$(dirname "$rel")"
    cp "$rel" "$STAGE/$rel"
done )

# Normalise mtimes.
find "$STAGE" -exec touch -d "$TS_ISO" {} +

# Build zip with deterministic ordering. -X drops extra fields (uid/gid).
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

# Allowlist check: the zip MUST contain only files that belong to the extension.
ALLOWED='^(extension\.yml|README\.md|LICENSE|CHANGELOG\.md|commands/.*|templates/.*|scripts/(bash|powershell)/.*)$'
EXTRA=$(cd "$VERIFY" && find . -type f | sed 's|^\./||' | grep -Ev "$ALLOWED" || true)
if [ -n "$EXTRA" ]; then
    echo "[build-zip] FAIL: zip contains files outside the allowlist:" >&2
    echo "$EXTRA" >&2
    exit 1
fi

echo "[build-zip] OK: $ZIP_PATH (version=$VERSION, mtime=$TS_ISO UTC)"
