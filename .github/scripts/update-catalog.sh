#!/usr/bin/env bash
# Pipeline: update catalog.json on every successful release.
#
# Updates only pipeline-owned fields:
#   version, download_url, requires.speckit_version, updated_at
#   created_at  (only if currently empty)
#
# Leaves all other fields untouched.
#
# Usage: update-catalog.sh <version> <download_url>

set -e

VERSION="${1:-}"
DOWNLOAD_URL="${2:-}"

if [ -z "$VERSION" ] || [ -z "$DOWNLOAD_URL" ]; then
    echo "Usage: $0 <version> <download_url>" >&2
    exit 1
fi

if [ ! -f catalog.json ]; then
    echo "[update-catalog] FAIL: catalog.json not found in $(pwd)" >&2
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "[update-catalog] FAIL: jq is required" >&2
    exit 1
fi

REQ_SPECKIT=$(awk '/^requires:/{f=1; next} f && /^[a-z]/{f=0} f && /^[[:space:]]+speckit_version:/{ sub(/^[[:space:]]+speckit_version:[[:space:]]*/, ""); gsub(/"/,""); print; exit }' extension.yml)
if [ -z "$REQ_SPECKIT" ]; then
    echo "[update-catalog] FAIL: requires.speckit_version missing from extension.yml" >&2
    exit 1
fi

NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)

CURRENT_CREATED=$(jq -r '.created_at // ""' catalog.json)
if [ -z "$CURRENT_CREATED" ] || [ "$CURRENT_CREATED" = "null" ]; then
    NEW_CREATED="$NOW"
else
    NEW_CREATED="$CURRENT_CREATED"
fi

TMP=$(mktemp)
jq \
    --arg v "$VERSION" \
    --arg u "$DOWNLOAD_URL" \
    --arg s "$REQ_SPECKIT" \
    --arg now "$NOW" \
    --arg created "$NEW_CREATED" \
    '.version = $v
     | .download_url = $u
     | .requires.speckit_version = $s
     | .updated_at = $now
     | .created_at = $created' \
    catalog.json > "$TMP"

mv "$TMP" catalog.json

echo "[update-catalog] OK: version=$VERSION download_url=$DOWNLOAD_URL"
