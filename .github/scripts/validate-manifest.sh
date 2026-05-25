#!/usr/bin/env bash
# Pipeline gate: validate the repository root extension.yml.
#
# Asserts:
#   - extension.id == "product"
#   - extension.version == ${GITHUB_REF_NAME#v}  (when GITHUB_REF_NAME is set)
#   - all required files listed in contracts/package-layout.md exist at the
#     extension root (which is the repo root in canonical layout)
#
# Exits 0 on success, non zero with a clear message on failure.
#
# Usage:
#   validate-manifest.sh                 # validates the repo root against optional GITHUB_REF_NAME
#   validate-manifest.sh --root <path>   # validates a different root (e.g. an unpacked zip)

set -euo pipefail

ROOT="."
while [ $# -gt 0 ]; do
    case "$1" in
        --root) ROOT="$2"; shift 2 ;;
        --root=*) ROOT="${1#*=}"; shift ;;
        *) echo "[validate-manifest] unknown argument: $1" >&2; exit 1 ;;
    esac
done

MANIFEST="$ROOT/extension.yml"

if [ ! -f "$MANIFEST" ]; then
    echo "[validate-manifest] FAIL: $MANIFEST not found" >&2
    exit 1
fi

_yaml_get() {
    # crude YAML reader: extract the first scalar value for a dotted key.
    # Limited to the keys this script needs.
    local key="$1"
    case "$key" in
        extension.id)
            awk '/^extension:/{f=1; next} f && /^[a-z]/{f=0} f && /^[[:space:]]+id:/{ sub(/^[[:space:]]+id:[[:space:]]*/, ""); gsub(/"/,""); print; exit }' "$MANIFEST"
            ;;
        extension.version)
            awk '/^extension:/{f=1; next} f && /^[a-z]/{f=0} f && /^[[:space:]]+version:/{ sub(/^[[:space:]]+version:[[:space:]]*/, ""); gsub(/"/,""); print; exit }' "$MANIFEST"
            ;;
        schema_version)
            awk '/^schema_version:/{ sub(/^schema_version:[[:space:]]*/, ""); gsub(/"/,""); print; exit }' "$MANIFEST"
            ;;
    esac
}

EXT_ID=$(_yaml_get extension.id)
EXT_VERSION=$(_yaml_get extension.version)
SCHEMA_VERSION=$(_yaml_get schema_version)

if [ -z "$SCHEMA_VERSION" ]; then
    echo "[validate-manifest] FAIL: schema_version missing" >&2
    exit 1
fi

if [ "$EXT_ID" != "product" ]; then
    echo "[validate-manifest] FAIL: extension.id must be \"product\", got \"$EXT_ID\"" >&2
    exit 1
fi

if [ -z "$EXT_VERSION" ]; then
    echo "[validate-manifest] FAIL: extension.version missing" >&2
    exit 1
fi

# Tag/version equality check — only when an explicit version is provided or
# the workflow is running from a version tag (refs/tags/v*).
# RELEASE_VERSION is used by prepare-release.yml because GITHUB_REF_NAME is a
# GitHub Actions built-in that cannot be overridden via step-level env:.
# GITHUB_REF is used to detect tag-driven runs in release.yml.
REF_FOR_CHECK="${RELEASE_VERSION:-${GITHUB_REF_NAME:-}}"
IS_TAG_RUN=0
if [ -n "${RELEASE_VERSION:-}" ]; then
    IS_TAG_RUN=1
elif echo "${GITHUB_REF:-}" | grep -q '^refs/tags/v'; then
    IS_TAG_RUN=1
fi

if [ "$IS_TAG_RUN" -eq 1 ]; then
    EXPECTED="${REF_FOR_CHECK#v}"
    if [ "$EXT_VERSION" != "$EXPECTED" ]; then
        echo "[validate-manifest] FAIL: version mismatch: tag $REF_FOR_CHECK, manifest $EXT_VERSION" >&2
        exit 1
    fi
fi

# Required files at the root of $ROOT (zip root or repo root).
# CHANGELOG.md lives at the repo root for release-note extraction and version
# bumps, but is excluded from the release zip via .extensionignore (matching
# the bundled `git` extension's layout). It is therefore not required here.
REQUIRED=(
    "$ROOT/extension.yml"
    "$ROOT/README.md"
    "$ROOT/LICENSE"
    "$ROOT/commands/speckit.product.spec.md"
    "$ROOT/commands/speckit.product.info.md"
    "$ROOT/commands/speckit.product.plan.md"
    "$ROOT/commands/speckit.product.design.md"
    "$ROOT/templates/product-spec-template.md"
    "$ROOT/templates/product-checklist-template.md"
    "$ROOT/templates/product-info-template.md"
    "$ROOT/templates/product-plan-template.md"
    "$ROOT/templates/product-design-template.md"
)

MISSING=0
for f in "${REQUIRED[@]}"; do
    if [ ! -f "$f" ]; then
        echo "[validate-manifest] FAIL: required file missing: $f" >&2
        MISSING=1
    elif [ ! -s "$f" ]; then
        echo "[validate-manifest] FAIL: required file empty: $f" >&2
        MISSING=1
    fi
done

if [ "$MISSING" -ne 0 ]; then
    exit 1
fi

echo "[validate-manifest] OK: id=$EXT_ID version=$EXT_VERSION root=$ROOT"
