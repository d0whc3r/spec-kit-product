#!/usr/bin/env bash
# Bump extension.yml#extension.version and promote the CHANGELOG.md
# "Unreleased" section to a versioned, dated section.
#
# Usage: bump-version.sh <new_version>
#   <new_version>: semver, no leading v (e.g. 0.1.1)
#
# After this script runs, the working tree is dirty with a coherent set of
# changes ready to commit + tag.

set -e

NEW="${1:-}"
if [ -z "$NEW" ]; then
    echo "Usage: $0 <new_version>" >&2
    exit 1
fi

# Validate semver: MAJOR.MINOR.PATCH
if ! echo "$NEW" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "[bump-version] FAIL: not a valid semver: $NEW" >&2
    exit 1
fi

if [ ! -f extension.yml ] || [ ! -f CHANGELOG.md ]; then
    echo "[bump-version] FAIL: run from the repo root (extension.yml + CHANGELOG.md required)" >&2
    exit 1
fi

# Refuse a no-op bump.
CURRENT=$(awk '/^extension:/{f=1; next} f && /^[a-z]/{f=0} f && /^[[:space:]]+version:/{ sub(/^[[:space:]]+version:[[:space:]]*/, ""); gsub(/"/,""); print; exit }' extension.yml)
if [ "$CURRENT" = "$NEW" ]; then
    echo "[bump-version] FAIL: extension.yml already at $NEW (no-op)" >&2
    exit 1
fi

DATE=$(date -u +%Y-%m-%d)

# Update extension.yml in place. Use python for a precise structural edit.
python3 - "$NEW" <<'PY'
import re, sys
new = sys.argv[1]
p = "extension.yml"
s = open(p).read()
# Match the version line under the `extension:` block.
pattern = re.compile(
    r'(^extension:\s*\n(?:[ \t]+[^\n]*\n)*?[ \t]+version:[ \t]*)"[^"]*"',
    re.MULTILINE,
)
s2, n = pattern.subn(rf'\g<1>"{new}"', s, count=1)
if n != 1:
    print("[bump-version] FAIL: extension.version line not found", file=sys.stderr)
    sys.exit(1)
open(p, "w").write(s2)
PY

# Promote CHANGELOG Unreleased -> [version] - date, with a fresh Unreleased on top.
python3 - "$NEW" "$DATE" <<'PY'
import sys
new, date = sys.argv[1], sys.argv[2]
p = "CHANGELOG.md"
s = open(p).read()
needle = "## [Unreleased]"
if needle not in s:
    print("[bump-version] FAIL: '## [Unreleased]' section not found in CHANGELOG.md", file=sys.stderr)
    sys.exit(1)
replacement = f"## [Unreleased]\n\n### Added\n\n- (none yet)\n\n## [{new}] - {date}"
s2 = s.replace(needle, replacement, 1)
open(p, "w").write(s2)
PY

echo "[bump-version] OK: extension.yml -> $NEW, CHANGELOG promoted with date $DATE"
