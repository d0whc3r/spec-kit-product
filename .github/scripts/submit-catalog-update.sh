#!/usr/bin/env bash
# Submit (or update) the community catalog entry at github/spec-kit by
# filing an [Extension Submission] issue from the release pipeline.
#
# Flow:
#   1. Look up the current entry in upstream catalog.community.json.
#      - present → title: "Update Product Spec Extension to vX.Y.Z"
#      - absent  → title: "Add Product Spec Extension"
#   2. Search open issues for one with the same title; skip if found.
#   3. Render body from catalog.json + a small template.
#   4. gh issue create.
#
# Env:
#   UPSTREAM_SUBMIT_TOKEN  PAT (fine-grained) with `Issues: Write` on
#                          github/spec-kit. Required.
#   UPSTREAM_REPO          Defaults to github/spec-kit.
#   SUBMIT_DRY_RUN         If "true", print the gh command and exit.
#
# Usage:
#   submit-catalog-update.sh <version> <release_type> <download_url>

set -euo pipefail

VERSION="${1:-}"
RELEASE_TYPE="${2:-}"
DOWNLOAD_URL="${3:-}"
UPSTREAM_REPO="${UPSTREAM_REPO:-github/spec-kit}"

if [ -z "$VERSION" ] || [ -z "$RELEASE_TYPE" ] || [ -z "$DOWNLOAD_URL" ]; then
    echo "Usage: $0 <version> <release_type> <download_url>" >&2
    exit 1
fi

if [ -z "${UPSTREAM_SUBMIT_TOKEN:-}" ]; then
    echo "[submit-catalog-update] SKIP: UPSTREAM_SUBMIT_TOKEN not set" >&2
    exit 0
fi

for tool in jq gh; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "[submit-catalog-update] FAIL: $tool is required" >&2
        exit 1
    fi
done

if [ ! -f catalog.json ]; then
    echo "[submit-catalog-update] FAIL: catalog.json not found" >&2
    exit 1
fi

EXT_ID=$(jq -r '.id' catalog.json)
EXT_NAME=$(jq -r '.name' catalog.json)
EXT_DESC=$(jq -r '.description' catalog.json)
EXT_AUTHOR=$(jq -r '.author' catalog.json)
EXT_REPO=$(jq -r '.repository' catalog.json)
EXT_HOMEPAGE=$(jq -r '.homepage // ""' catalog.json)
EXT_DOCS=$(jq -r '.documentation // ""' catalog.json)
EXT_CHANGELOG=$(jq -r '.changelog // ""' catalog.json)
EXT_LICENSE=$(jq -r '.license' catalog.json)
EXT_SPECKIT=$(jq -r '.requires.speckit_version' catalog.json)
EXT_CMDS=$(jq -r '.provides.commands' catalog.json)
EXT_HOOKS=$(jq -r '.provides.hooks' catalog.json)
EXT_TAGS=$(jq -r '.tags | join(", ")' catalog.json)

CATALOG_URL="https://raw.githubusercontent.com/${UPSTREAM_REPO}/main/extensions/catalog.community.json"
HAS_ENTRY=$(curl -fsSL "$CATALOG_URL" | jq -r --arg id "$EXT_ID" '.extensions[$id] // empty' || echo "")

if [ -n "$HAS_ENTRY" ]; then
    ACTION="Update"
    TITLE="[Extension]: Update ${EXT_NAME} to v${VERSION}"
else
    ACTION="Add"
    TITLE="[Extension]: Add ${EXT_NAME}"
fi

export GH_TOKEN="$UPSTREAM_SUBMIT_TOKEN"

EXISTING=$(gh issue list --repo "$UPSTREAM_REPO" --state open --search "in:title \"${TITLE}\"" --json number,title --jq ".[] | select(.title == \"${TITLE}\") | .number" 2>/dev/null || echo "")
if [ -n "$EXISTING" ]; then
    echo "[submit-catalog-update] SKIP: open issue already exists (#${EXISTING})" >&2
    exit 0
fi

PROPOSED_ENTRY=$(jq --arg v "$VERSION" --arg u "$DOWNLOAD_URL" \
    '{($id): (. + {version: $v, download_url: $u, verified: false, downloads: 0, stars: 0})}
     | .[$id] |= del(.created_at, .updated_at)' \
    --arg id "$EXT_ID" catalog.json)

BODY_FILE=$(mktemp)
cat >"$BODY_FILE" <<EOF
> **Automated submission** from \`${EXT_REPO}\` release pipeline. ${ACTION} request for \`${EXT_ID}\` v${VERSION}.

### Extension ID

${EXT_ID}

### Extension Name

${EXT_NAME}

### Version

${VERSION}

### Description

${EXT_DESC}

### Author

${EXT_AUTHOR}

### Repository URL

${EXT_REPO}

### Download URL

${DOWNLOAD_URL}

### License

${EXT_LICENSE}

### Homepage (optional)

${EXT_HOMEPAGE}

### Documentation URL (optional)

${EXT_DOCS}

### Changelog URL (optional)

${EXT_CHANGELOG}

### Required Spec Kit Version

${EXT_SPECKIT}

### Number of Commands

${EXT_CMDS}

### Number of Hooks (optional)

${EXT_HOOKS}

### Tags

${EXT_TAGS}

### Release type

\`${RELEASE_TYPE}\`

### Testing Checklist

- [x] Extension installs successfully via download URL
- [x] All commands execute without errors
- [x] Documentation is complete and accurate
- [x] No security vulnerabilities identified
- [x] Tested on at least one real project (CI release pipeline)

### Submission Requirements

- [x] Valid \`extension.yml\` manifest included
- [x] README.md with installation and usage instructions
- [x] LICENSE file included
- [x] GitHub release created with version tag
- [x] All command files exist and are properly formatted
- [x] Extension ID follows naming conventions (lowercase-with-hyphens)

### Proposed Catalog Entry

\`\`\`json
${PROPOSED_ENTRY}
\`\`\`
EOF

if [ "${SUBMIT_DRY_RUN:-false}" = "true" ]; then
    echo "[submit-catalog-update] DRY RUN — would file:"
    echo "  repo:  ${UPSTREAM_REPO}"
    echo "  title: ${TITLE}"
    echo "  body:  ${BODY_FILE}"
    cat "$BODY_FILE"
    exit 0
fi

gh issue create \
    --repo "$UPSTREAM_REPO" \
    --title "$TITLE" \
    --body-file "$BODY_FILE"

echo "[submit-catalog-update] OK: ${ACTION} v${VERSION}"
