#!/usr/bin/env bash
# Render a ready-to-paste [Extension Submission] issue for github/spec-kit as
# a markdown document. The release pipeline uploads it as an artifact so a
# maintainer can file the issue manually — automatic `gh issue create` against
# the upstream repo proved unreliable.
#
# Flow:
#   1. Look up the current entry in upstream catalog.community.json.
#      - present → title: "[Extension]: Update <name> to vX.Y.Z"
#      - absent  → title: "[Extension]: Add <name>"
#   2. Render manual steps + the issue title + the issue body from catalog.json.
#   3. Write the document to OUTPUT_FILE.
#
# Env:
#   UPSTREAM_REPO  Defaults to github/spec-kit.
#   OUTPUT_FILE    Where to write the document. Defaults to
#                  "upstream-catalog-issue-v<version>.md" in the cwd.
#
# Run locally:
#   The release pipeline sets VERSION and GITHUB_REPOSITORY for you. Locally,
#   VERSION defaults to catalog.json .version and GITHUB_REPOSITORY is derived
#   from the `origin` git remote, so this just works:
#       bash .github/scripts/submit-catalog-update.sh        # or: pnpm run catalog:issue
#   The rendered document lands at upstream-catalog-issue-v<version>.md.
#
# Usage:
#   submit-catalog-update.sh [version] [release_type] [git_tag]
#   version defaults to catalog.json .version; release_type to "release";
#   git_tag to "v<version>".

set -euo pipefail

if [ ! -f catalog.json ]; then
    echo "[submit-catalog-update] FAIL: catalog.json not found (run from repo root)" >&2
    exit 1
fi

VERSION="${1:-$(jq -r .version catalog.json)}"
RELEASE_TYPE="${2:-release}"
GIT_TAG="${3:-v${VERSION}}"
UPSTREAM_REPO="${UPSTREAM_REPO:-github/spec-kit}"

if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
    echo "Usage: $0 [version] [release_type] [git_tag]" >&2
    exit 1
fi

# In CI, GitHub sets GITHUB_REPOSITORY. Locally, derive owner/repo from the
# origin remote (handles both git@host:owner/repo.git and https URLs).
if [ -z "${GITHUB_REPOSITORY:-}" ]; then
    remote_url=$(git remote get-url origin 2>/dev/null || echo "")
    if [ -n "$remote_url" ]; then
        GITHUB_REPOSITORY=$(printf '%s' "$remote_url" | sed -E 's#\.git$##; s#^.*[:/]([^/]+/[^/]+)$#\1#')
    fi
fi

if [ -z "${GITHUB_REPOSITORY:-}" ]; then
    echo "[submit-catalog-update] FAIL: GITHUB_REPOSITORY not set and no git remote 'origin' found" >&2
    exit 1
fi

DOWNLOAD_URL="https://github.com/${GITHUB_REPOSITORY}/releases/download/${GIT_TAG}/product-${VERSION}.zip"
OUTPUT_FILE="${OUTPUT_FILE:-upstream-catalog-issue-v${VERSION}.md}"

for tool in jq curl; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "[submit-catalog-update] FAIL: $tool is required" >&2
        exit 1
    fi
done

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

# Key Features come from the per-command descriptions in extension.yml (the
# canonical list; catalog.json only carries the command count). Parsed with awk
# rather than yq so the renderer needs no extra tooling in CI. One bullet per
# command, "`/<name>`: <description>".
if [ -f extension.yml ]; then
    EXT_FEATURES=$(awk '
        /^provides:/ { inprov = 1; next }
        inprov && /^[a-zA-Z]/ { inprov = 0 }
        inprov && /^[[:space:]]+commands:/ { incmds = 1; next }
        incmds && /^[[:space:]]{0,2}[a-zA-Z]/ { incmds = 0 }
        incmds && /name:/ {
            name = $0
            sub(/^.*name:[[:space:]]*/, "", name)
            gsub(/"/, "", name)
        }
        incmds && /description:/ {
            desc = $0
            sub(/^.*description:[[:space:]]*/, "", desc)
            gsub(/^"|"$/, "", desc)
            printf "- `/%s`: %s\n", name, desc
        }
    ' extension.yml)
fi
if [ -z "${EXT_FEATURES:-}" ]; then
    EXT_FEATURES="- ${EXT_CMDS} commands under \`/speckit.product.*\`. See ${EXT_DOCS}."
fi

CATALOG_URL="https://raw.githubusercontent.com/${UPSTREAM_REPO}/main/extensions/catalog.community.json"
HAS_ENTRY=$(curl -fsSL "$CATALOG_URL" | jq -r --arg id "$EXT_ID" '.extensions[$id] // empty' || echo "")

if [ -n "$HAS_ENTRY" ]; then
    ACTION="Update"
    TITLE="[Extension]: Update ${EXT_NAME} to v${VERSION}"
else
    ACTION="Add"
    TITLE="[Extension]: Add ${EXT_NAME}"
fi

NEW_ISSUE_URL="https://github.com/${UPSTREAM_REPO}/issues/new/choose"
TITLE_QUERY="${TITLE// /+}"

# Keep created_at/updated_at: the upstream catalog entries carry them and the
# submission template's example includes them, so reviewers expect them present.
PROPOSED_ENTRY=$(jq --arg v "$VERSION" --arg u "$DOWNLOAD_URL" --arg id "$EXT_ID" \
    '{($id): (. + {version: $v, download_url: $u, verified: false, downloads: 0, stars: 0})}' \
    catalog.json)

cat >"$OUTPUT_FILE" <<EOF
# Upstream catalog issue — ${ACTION} ${EXT_NAME} v${VERSION}

> Generated by the \`${EXT_REPO}\` release pipeline. File this issue manually
> on the upstream Spec Kit repo.

## How to file this issue

1. Open the new-issue page: ${NEW_ISSUE_URL}
2. Pick the **Extension Submission** template.
3. Set the issue **title** to (copy exactly):

   \`${TITLE}\`

4. Fill each form field with the matching value from the **Issue body** section
   below (each \`###\` heading maps to one form field).
5. Before submitting, check there is no open issue with the same title at
   https://github.com/${UPSTREAM_REPO}/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+${TITLE_QUERY}

---

## Issue body

> **Submission** from \`${EXT_REPO}\` release pipeline. ${ACTION} request for \`${EXT_ID}\` v${VERSION}.

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

### Required Tools (optional)

None. This extension is plain Markdown command and template text. It adds no external tool or runtime dependencies beyond Spec Kit itself.

### Number of Commands

${EXT_CMDS}

### Number of Hooks (optional)

${EXT_HOOKS}

### Tags

${EXT_TAGS}

### Key Features

${EXT_FEATURES}

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

### Testing Details

**Tested by the \`${EXT_REPO}\` release pipeline (\`${RELEASE_TYPE}\`):**

- Manifest validation (\`pnpm run validate\`) confirms \`extension.yml\` and \`catalog.json\` agree on version, command count, and hook count.
- Content lint (\`pnpm run lint:content\`) enforces the output style rules every command must follow.
- The release archive \`product-${VERSION}.zip\` is built and attached to the GitHub release at tag \`${GIT_TAG}\`.
- Install is exercised from the published download URL above.

**Test project:** the extension is dogfooded on this repository's own \`specs/*/product/\` artifacts, generated from real \`spec.md\` and \`plan.md\` files.

### Example Usage

\`\`\`bash
# Install the extension from the release archive
specify extension add ${EXT_ID} --from ${DOWNLOAD_URL}

# Generate the stakeholder summary from your spec.md
/speckit.product.info

# Generate the product spec, product plan, and technical design
/speckit.product.spec
/speckit.product.plan
/speckit.product.design
\`\`\`

### Proposed Catalog Entry

\`\`\`json
${PROPOSED_ENTRY}
\`\`\`

### Additional Context

Full user documentation lives in the project wiki and website (${EXT_DOCS}). Source repository: ${EXT_REPO}.
EOF

echo "[submit-catalog-update] OK: wrote ${ACTION} v${VERSION} document to ${OUTPUT_FILE}"
