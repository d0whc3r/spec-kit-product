#!/usr/bin/env bash
# Called by semantic-release @exec prepareCmd.
# Updates extension.yml version, builds the zip, and updates catalog.json.
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

# Update README direct-install URL
sed -i "s|specify extension add product --from https://.*|specify extension add product --from ${DOWNLOAD_URL}|" README.md
echo "[semantic-release-prepare] OK: README.md direct-install URL → ${DOWNLOAD_URL}"

# Build deterministic zip (reads version from the now-updated extension.yml)
bash .github/scripts/build-zip.sh

# Update catalog.json
bash .github/scripts/update-catalog.sh "${VERSION}" "${DOWNLOAD_URL}"
