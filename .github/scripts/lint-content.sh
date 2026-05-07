#!/usr/bin/env bash
# Pipeline: lint extension content (markdown templates and command body).
#
# Paths are relative to the repo root, which is the extension root in the
# canonical layout.
#
# Checks (per template: spec, info, plan, design):
#   - No em dash.
#   - Canonical section headings present and in order.
#   - Corresponding command file references the template by relative path.
#   - No banned AI-tell phrases.
#   (Optional) markdownlint pass via markdownlint-cli2 if installed.

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
    "## Headline"
    "## Target Users and Personas"
    "## Problem Statement (Job to Be Done)"
    "## Value Proposition"
    "## Scope"
    "## Out of Scope"
    "## Use Cases"
    "## Success Metrics"
    "## Risks and Open Product Questions"
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

# 3b. No banned AI-tell phrases in the spec template.
BANNED_PHRASES=("delve" "tapestry" "in essence" "navigate the landscape" "seamless" "intuitive")
for phrase in "${BANNED_PHRASES[@]}"; do
    if grep -qi "$phrase" "$TEMPLATE"; then
        echo "[lint-content] FAIL: banned phrase \"$phrase\" found in $TEMPLATE" >&2
        FAIL=1
    fi
done

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
    "## Headline"
    "## What is Changing"
    "## Out of Scope"
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

# Optional sections (Risks, Open Questions) must appear after mandatory sections and in order.
RISKS_LINE=$(grep -nF "## Risks" "$INFO_TEMPLATE" | head -n 1 | cut -d: -f1)
if [ -n "$RISKS_LINE" ] && [ "$RISKS_LINE" -le "$LAST_LINE" ]; then
    echo "[lint-content] FAIL: ## Risks is out of order in $INFO_TEMPLATE (line $RISKS_LINE, previous at $LAST_LINE)" >&2
    FAIL=1
fi
[ -n "$RISKS_LINE" ] && LAST_LINE="$RISKS_LINE"

OPT_LINE=$(grep -nF "## Open Questions" "$INFO_TEMPLATE" | head -n 1 | cut -d: -f1)
if [ -n "$OPT_LINE" ] && [ "$OPT_LINE" -le "$LAST_LINE" ]; then
    echo "[lint-content] FAIL: ## Open Questions is out of order in $INFO_TEMPLATE (line $OPT_LINE, previous at $LAST_LINE)" >&2
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
#     Mandatory sections first, then optional.
PLAN_HEADINGS=(
    "## Summary"
    "## Out of Scope"
    "## Delivery Phases"
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

# Optional sections must appear after mandatory sections and in order.
PLAN_OPTIONAL_HEADINGS=(
    "## Key Decisions"
    "## Risks and Mitigations"
    "## Open Questions"
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

# --- product-design-template.md checks ---

DESIGN_TEMPLATE="templates/product-design-template.md"
DESIGN_COMMAND="commands/speckit.product.design.md"

if [ ! -f "$DESIGN_TEMPLATE" ]; then
    echo "[lint-content] FAIL: $DESIGN_TEMPLATE missing" >&2
    exit 1
fi

# 13. No em dash in the design template.
if grep -q "—" "$DESIGN_TEMPLATE"; then
    echo "[lint-content] FAIL: em dash found in $DESIGN_TEMPLATE" >&2
    grep -n "—" "$DESIGN_TEMPLATE" >&2
    FAIL=1
fi

# 14. Canonical section headings in order for product-design-template.md.
DESIGN_HEADINGS=(
    "## Summary"
    "## Technical Context"
    "## Architectural Approach"
    "## Affected Modules"
    "## Data Design"
    "## API Design"
    "## Spec Coverage"
    "## Key Technical Decisions"
    "## Testing Strategy"
    "## Rollout and Migration"
)

LAST_LINE=0
for h in "${DESIGN_HEADINGS[@]}"; do
    LINE=$(grep -nF "$h" "$DESIGN_TEMPLATE" | head -n 1 | cut -d: -f1)
    if [ -z "$LINE" ]; then
        echo "[lint-content] FAIL: missing mandatory heading in $DESIGN_TEMPLATE: $h" >&2
        FAIL=1
        continue
    fi
    if [ "$LINE" -le "$LAST_LINE" ]; then
        echo "[lint-content] FAIL: heading out of canonical order in $DESIGN_TEMPLATE: $h (line $LINE, previous at $LAST_LINE)" >&2
        FAIL=1
    fi
    LAST_LINE="$LINE"
done

# Optional sections must appear after mandatory sections.
DESIGN_OPTIONAL_HEADINGS=(
    "## Risks and Mitigations"
    "## Open Questions"
)
for h in "${DESIGN_OPTIONAL_HEADINGS[@]}"; do
    LINE=$(grep -nF "$h" "$DESIGN_TEMPLATE" | head -n 1 | cut -d: -f1)
    if [ -n "$LINE" ] && [ "$LINE" -le "$LAST_LINE" ]; then
        echo "[lint-content] FAIL: optional heading out of order in $DESIGN_TEMPLATE: $h (line $LINE, previous at $LAST_LINE)" >&2
        FAIL=1
    fi
    [ -n "$LINE" ] && LAST_LINE="$LINE"
done

# 15. Design command references the design template.
if [ ! -f "$DESIGN_COMMAND" ]; then
    echo "[lint-content] FAIL: $DESIGN_COMMAND missing" >&2
    FAIL=1
elif ! grep -q "templates/product-design-template.md" "$DESIGN_COMMAND"; then
    echo "[lint-content] FAIL: $DESIGN_COMMAND does not reference templates/product-design-template.md" >&2
    FAIL=1
fi

# 16. No banned AI-tell phrases in the design template.
BANNED_PHRASES=("delve" "tapestry" "in essence" "navigate the landscape" "seamless" "intuitive")
for phrase in "${BANNED_PHRASES[@]}"; do
    if grep -qi "$phrase" "$DESIGN_TEMPLATE"; then
        echo "[lint-content] FAIL: banned phrase \"$phrase\" found in $DESIGN_TEMPLATE" >&2
        FAIL=1
    fi
done

if [ "$FAIL" -ne 0 ]; then
    exit 1
fi

echo "[lint-content] OK"
