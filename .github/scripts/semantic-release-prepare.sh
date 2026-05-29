#!/usr/bin/env bash
# Called by semantic-release @exec prepareCmd.
# Updates extension.yml + package.json versions, builds the zip, and updates catalog.json.
#
# Usage: semantic-release-prepare.sh <version>

set -e

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
    echo "[semantic-release-prepare] FAIL: version argument required" >&2
    exit 1
fi

REPO="${GITHUB_REPOSITORY:-}"
if [ -z "$REPO" ]; then
    echo "[semantic-release-prepare] FAIL: GITHUB_REPOSITORY not set" >&2
    exit 1
fi

DOWNLOAD_URL="https://github.com/${REPO}/releases/download/v${VERSION}/product-${VERSION}.zip"

# Update extension.yml version field
sed -i "s/^  version:.*/  version: \"${VERSION}\"/" extension.yml
echo "[semantic-release-prepare] OK: extension.yml version → ${VERSION}"

# Update package.json version field (keeps it in sync with the extension)
pnpm pkg set version="${VERSION}"
echo "[semantic-release-prepare] OK: package.json version → ${VERSION}"

# Bump every pinned release URL across README + wiki + website.
# Matches https://github.com/<owner>/<repo>/releases/download/vX.Y.Z/product-X.Y.Z.zip
# regardless of file or surrounding context.
URL_PATTERN='https://github\.com/[^/]+/[^/]+/releases/download/v[0-9]+\.[0-9]+\.[0-9]+/product-[0-9]+\.[0-9]+\.[0-9]+\.zip'
for f in README.md docs/Getting-Started.md docs/FAQ.md docs/Troubleshooting.md web/index.html; do
    if grep -qE "$URL_PATTERN" "$f"; then
        sed -i -E "s|${URL_PATTERN}|${DOWNLOAD_URL}|g" "$f"
        echo "[semantic-release-prepare] OK: ${f} direct-install URL → ${DOWNLOAD_URL}"
    else
        echo "[semantic-release-prepare] WARN: ${f} no pinned URL found, skipped" >&2
    fi
done

# Bump the version badge shown in the website header.
# Matches <span class="brand-version">vX.Y.Z</span> regardless of surrounding whitespace.
BADGE_PATTERN='(<span class="brand-version">v)[0-9]+\.[0-9]+\.[0-9]+(</span>)'
if grep -qE "$BADGE_PATTERN" web/index.html; then
    sed -i -E "s|${BADGE_PATTERN}|\1${VERSION}\2|g" web/index.html
    echo "[semantic-release-prepare] OK: web/index.html header badge → v${VERSION}"
else
    echo "[semantic-release-prepare] WARN: web/index.html no header version badge found, skipped" >&2
fi

# Build deterministic zip (reads version from the now-updated extension.yml)
bash .github/scripts/build-zip.sh

# Update catalog.json
bash .github/scripts/update-catalog.sh "${VERSION}" "${DOWNLOAD_URL}"
