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
INFO_TEMPLATE="templates/product-info-template.md"
INFO_COMMAND="commands/speckit.product.info.md"

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

# --- product-info-template.md checks ---

if [ ! -f "$INFO_TEMPLATE" ]; then
    echo "[lint-content] FAIL: $INFO_TEMPLATE missing" >&2
    exit 1
fi

# 5. No em dash in the info template.
if grep -q "—" "$INFO_TEMPLATE"; then
    echo "[lint-content] FAIL: em dash found in $INFO_TEMPLATE" >&2
    grep -n "—" "$INFO_TEMPLATE" >&2
    FAIL=1
fi

# 6. Canonical headings in order for product-info-template.md.
INFO_HEADINGS=(
    "## 1. Headline"
    "## 2. What is Changing"
    "## 3. Out of Scope"
)

LAST_LINE=0
for h in "${INFO_HEADINGS[@]}"; do
    LINE=$(grep -nF "$h" "$INFO_TEMPLATE" | head -n 1 | cut -d: -f1)
    if [ -z "$LINE" ]; then
        echo "[lint-content] FAIL: missing canonical heading in $INFO_TEMPLATE: $h" >&2
        FAIL=1
        continue
    fi
    if [ "$LINE" -le "$LAST_LINE" ]; then
        echo "[lint-content] FAIL: heading out of canonical order in $INFO_TEMPLATE: $h (line $LINE, previous at $LAST_LINE)" >&2
        FAIL=1
    fi
    LAST_LINE="$LINE"
done

# Optional Section 4 (Risks) must appear after Section 3 if present.
RISKS_LINE=$(grep -nF "## 4. Risks" "$INFO_TEMPLATE" | head -n 1 | cut -d: -f1)
if [ -n "$RISKS_LINE" ] && [ "$RISKS_LINE" -le "$LAST_LINE" ]; then
    echo "[lint-content] FAIL: ## 4. Risks is out of order in $INFO_TEMPLATE (line $RISKS_LINE, previous at $LAST_LINE)" >&2
    FAIL=1
fi
[ -n "$RISKS_LINE" ] && LAST_LINE="$RISKS_LINE"

# Optional Section 5 (Open Questions) must appear last if present.
OPT_LINE=$(grep -nF "## 5. Open Questions" "$INFO_TEMPLATE" | head -n 1 | cut -d: -f1)
if [ -n "$OPT_LINE" ] && [ "$OPT_LINE" -le "$LAST_LINE" ]; then
    echo "[lint-content] FAIL: ## 5. Open Questions is out of order in $INFO_TEMPLATE (line $OPT_LINE, previous at $LAST_LINE)" >&2
    FAIL=1
fi

# 7. Info command references the info template.
if [ ! -f "$INFO_COMMAND" ]; then
    echo "[lint-content] FAIL: $INFO_COMMAND missing" >&2
    FAIL=1
elif ! grep -q "templates/product-info-template.md" "$INFO_COMMAND"; then
    echo "[lint-content] FAIL: $INFO_COMMAND does not reference templates/product-info-template.md" >&2
    FAIL=1
fi

# 8. No banned AI-tell phrases in the info template.
BANNED_PHRASES=("delve" "tapestry" "in essence" "navigate the landscape" "seamless" "intuitive")
for phrase in "${BANNED_PHRASES[@]}"; do
    if grep -qi "$phrase" "$INFO_TEMPLATE"; then
        echo "[lint-content] FAIL: banned phrase \"$phrase\" found in $INFO_TEMPLATE" >&2
        FAIL=1
    fi
done

if [ "$FAIL" -ne 0 ]; then
    exit 1
fi

# --- product-plan-template.md checks ---

PLAN_TEMPLATE="templates/product-plan-template.md"
PLAN_COMMAND="commands/speckit.product.plan.md"

if [ ! -f "$PLAN_TEMPLATE" ]; then
    echo "[lint-content] FAIL: $PLAN_TEMPLATE missing" >&2
    exit 1
fi

# 9. No em dash in the plan template.
if grep -q "—" "$PLAN_TEMPLATE"; then
    echo "[lint-content] FAIL: em dash found in $PLAN_TEMPLATE" >&2
    grep -n "—" "$PLAN_TEMPLATE" >&2
    FAIL=1
fi

# 10. Canonical section headings in order for product-plan-template.md.
#     Mandatory sections first (1-3), then optional (4-7).
PLAN_HEADINGS=(
    "## 1. Summary"
    "## 2. Delivery Phases"
    "## 3. Out of Scope"
)

LAST_LINE=0
for h in "${PLAN_HEADINGS[@]}"; do
    LINE=$(grep -nF "$h" "$PLAN_TEMPLATE" | head -n 1 | cut -d: -f1)
    if [ -z "$LINE" ]; then
        echo "[lint-content] FAIL: missing mandatory heading in $PLAN_TEMPLATE: $h" >&2
        FAIL=1
        continue
    fi
    if [ "$LINE" -le "$LAST_LINE" ]; then
        echo "[lint-content] FAIL: heading out of canonical order in $PLAN_TEMPLATE: $h (line $LINE, previous at $LAST_LINE)" >&2
        FAIL=1
    fi
    LAST_LINE="$LINE"
done

# Optional sections 4-7 must appear after mandatory sections and in order.
PLAN_OPTIONAL_HEADINGS=(
    "## 4. Component Overview"
    "## 5. Key Technical Decisions"
    "## 6. Risks"
    "## 7. Open Questions"
)
for h in "${PLAN_OPTIONAL_HEADINGS[@]}"; do
    LINE=$(grep -nF "$h" "$PLAN_TEMPLATE" | head -n 1 | cut -d: -f1)
    if [ -n "$LINE" ] && [ "$LINE" -le "$LAST_LINE" ]; then
        echo "[lint-content] FAIL: optional heading out of order in $PLAN_TEMPLATE: $h (line $LINE, previous at $LAST_LINE)" >&2
        FAIL=1
    fi
    [ -n "$LINE" ] && LAST_LINE="$LINE"
done

# 11. Plan command references the plan template.
if [ ! -f "$PLAN_COMMAND" ]; then
    echo "[lint-content] FAIL: $PLAN_COMMAND missing" >&2
    FAIL=1
elif ! grep -q "templates/product-plan-template.md" "$PLAN_COMMAND"; then
    echo "[lint-content] FAIL: $PLAN_COMMAND does not reference templates/product-plan-template.md" >&2
    FAIL=1
fi

# 12. No banned AI-tell phrases in the plan template guidance text.
BANNED_PHRASES=("delve" "tapestry" "in essence" "navigate the landscape" "seamless" "intuitive")
for phrase in "${BANNED_PHRASES[@]}"; do
    if grep -qi "$phrase" "$PLAN_TEMPLATE"; then
        echo "[lint-content] FAIL: banned phrase \"$phrase\" found in $PLAN_TEMPLATE" >&2
        FAIL=1
    fi
done

if [ "$FAIL" -ne 0 ]; then
    exit 1
fi

echo "[lint-content] OK"
