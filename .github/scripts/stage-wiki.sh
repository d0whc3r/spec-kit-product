#!/usr/bin/env bash
#
# Stage docs/ for GitHub Wiki publication.
#
# Copies every docs/*.md to a staging directory, excludes docs/README.md
# (repo-only meta-doc), and rewrites markdown links so they resolve inside
# the wiki:
#   - [Page](Page.md)         -> [Page](Page)
#   - [Page](Page.md#anchor)  -> [Page](Page#anchor)
#   - [File](../File.md)      -> [File](https://github.com/<repo>/blob/main/File.md)
#
# Usage:
#   stage-wiki.sh [source-dir] [staging-dir]
#
# Defaults: source-dir=docs, staging-dir=.wiki-staging.
#
# Reads GITHUB_REPOSITORY for the absolute-URL rewrite. Falls back to
# `git config --get remote.origin.url` when run locally.

set -euo pipefail

SOURCE_DIR="${1:-docs}"
STAGING_DIR="${2:-.wiki-staging}"

if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "[stage-wiki] FAIL: source dir not found: $SOURCE_DIR" >&2
    exit 1
fi

# Resolve owner/repo for absolute URL rewrites.
REPO="${GITHUB_REPOSITORY:-}"
if [[ -z "$REPO" ]]; then
    REMOTE_URL="$(git config --get remote.origin.url 2>/dev/null || true)"
    # Accept git@<host>:owner/repo(.git) or https://<host>/owner/repo(.git).
    # Host can be github.com or any alias (e.g. github-private.com).
    REPO="$(echo "$REMOTE_URL" \
        | sed -E 's#^(git@[^:]+:|https?://[^/]+/)##' \
        | sed -E 's#\.git$##')"
fi
if [[ -z "$REPO" ]]; then
    echo "[stage-wiki] FAIL: cannot resolve repo (set GITHUB_REPOSITORY)" >&2
    exit 1
fi
REPO_BLOB="https://github.com/${REPO}/blob/main"

rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"
cp "$SOURCE_DIR"/*.md "$STAGING_DIR"/
rm -f "$STAGING_DIR/README.md"

for f in "$STAGING_DIR"/*.md; do
    # 1. Rewrite ../FILE to absolute repo URL (parent-dir escapes the wiki).
    sed -i.bak -E "s|\]\(\.\./([^)]+)\)|](${REPO_BLOB}/\1)|g" "$f"
    # 2. Drop .md from intra-wiki links, preserving optional #anchor.
    sed -i.bak -E 's|\]\(([A-Za-z][A-Za-z0-9_-]*)\.md(#[A-Za-z0-9_-]+)?\)|](\1\2)|g' "$f"
    rm -f "$f.bak"
done

echo "[stage-wiki] OK: $(ls "$STAGING_DIR"/*.md | wc -l | tr -d ' ') pages staged in $STAGING_DIR for $REPO"
