#!/usr/bin/env bash
# Pipeline: lint extension content (markdown templates and command body).
#
# Paths are relative to the repo root, which is the extension root in the
# canonical layout.
#
# Checks:
#   1. templates/product-spec-template.md contains no em dash.
#   2. The template contains every canonical section heading in canonical order.
#   3. commands/speckit.product.spec.md references both templates by
#      relative path.
#   4. (Optional) markdownlint pass via markdownlint-cli2 if installed.

set -e

FAIL=0
TEMPLATE="templates/product-spec-template.md"
CHECKLIST="templates/product-checklist-template.md"
COMMAND="commands/speckit.product.spec.md"

if [ ! -f "$TEMPLATE" ]; then
    echo "[lint-content] FAIL: $TEMPLATE missing" >&2
    exit 1
fi

# 1. No em dash in the template.
if grep -q "—" "$TEMPLATE"; then
    echo "[lint-content] FAIL: em dash found in $TEMPLATE" >&2
    grep -n "—" "$TEMPLATE" >&2
    FAIL=1
fi

# 2. Canonical headings, in order.
HEADINGS=(
    "## 1. Headline"
    "## 2. Target Users and Personas"
    "## 3. Problem Statement (Job to Be Done)"
    "## 4. Value Proposition"
    "## 5. Scope"
    "## 6. Out of Scope"
    "## 7. Use Cases"
    "## 8. Success Metrics"
    "## 9. Risks and Open Product Questions"
)

LAST_LINE=0
for h in "${HEADINGS[@]}"; do
    LINE=$(grep -nF "$h" "$TEMPLATE" | head -n 1 | cut -d: -f1)
    if [ -z "$LINE" ]; then
        echo "[lint-content] FAIL: missing canonical heading: $h" >&2
        FAIL=1
        continue
    fi
    if [ "$LINE" -le "$LAST_LINE" ]; then
        echo "[lint-content] FAIL: heading out of canonical order: $h (line $LINE, previous at $LAST_LINE)" >&2
        FAIL=1
    fi
    LAST_LINE="$LINE"
done

# 3. Command references both templates.
if ! grep -q "templates/product-spec-template.md" "$COMMAND"; then
    echo "[lint-content] FAIL: $COMMAND does not reference templates/product-spec-template.md" >&2
    FAIL=1
fi
if ! grep -q "templates/product-checklist-template.md" "$COMMAND"; then
    echo "[lint-content] FAIL: $COMMAND does not reference templates/product-checklist-template.md" >&2
    FAIL=1
fi

# 4. Optional markdownlint pass.
if command -v markdownlint-cli2 >/dev/null 2>&1; then
    if ! markdownlint-cli2 'commands/**/*.md' 'templates/**/*.md' 'README.md' 'CHANGELOG.md' >&2; then
        echo "[lint-content] FAIL: markdownlint-cli2 reported issues" >&2
        FAIL=1
    fi
elif command -v markdownlint >/dev/null 2>&1; then
    if ! markdownlint 'commands/**/*.md' 'templates/**/*.md' 'README.md' 'CHANGELOG.md' >&2; then
        echo "[lint-content] FAIL: markdownlint reported issues" >&2
        FAIL=1
    fi
fi

if [ "$FAIL" -ne 0 ]; then
    exit 1
fi

echo "[lint-content] OK"
