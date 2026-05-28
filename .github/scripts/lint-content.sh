#!/usr/bin/env bash
# Pipeline: lint extension content (markdown templates and command bodies).
#
# Paths are relative to the repo root, which is the extension root in the
# canonical layout.
#
# Per template (spec, info, plan, design):
#   - No em dash.
#   - Canonical mandatory section headings present and in order.
#   - Optional section headings (when present) appear after mandatory ones
#     and in declared order. Optional headings may be suffixed with
#     " _(optional)_" in the template.
#   - The corresponding command file references the template (and any
#     declared extra references such as the checklist template).
#   - No banned AI-tell phrases.
#
# Also runs an optional oxfmt --check pass when oxfmt is installed.

set -euo pipefail

FAIL=0
BANNED_PHRASES=("delve" "tapestry" "in essence" "navigate the landscape")

# find_heading <file> <heading-text-without-prefix>
# Prints the 1-based line number of the first line equal to "## <heading>"
# or "## <heading> _(optional)_". Empty output means not found.
find_heading() {
    awk -v h="$2" '
        $0 == "## " h || $0 == "## " h " _(optional)_" { print NR; exit }
    ' "$1"
}

# check_headings <file> <last_line_var> <required: required|optional> <heading...>
# Updates $last_line_var (by name) with the latest line number seen.
check_headings() {
    local file="$1"
    local -n last_ref="$2"
    local mode="$3"
    shift 3
    local h line
    for h in "$@"; do
        line=$(find_heading "$file" "$h")
        if [ -z "$line" ]; then
            if [ "$mode" = "required" ]; then
                echo "[lint-content] FAIL: missing mandatory heading in $file: ## $h" >&2
                FAIL=1
            fi
            continue
        fi
        if [ "$line" -le "$last_ref" ]; then
            echo "[lint-content] FAIL: heading out of canonical order in $file: ## $h (line $line, previous at $last_ref)" >&2
            FAIL=1
        fi
        last_ref="$line"
    done
}

# check_em_dash <file>
check_em_dash() {
    if grep -q "—" "$1"; then
        echo "[lint-content] FAIL: em dash found in $1" >&2
        grep -n "—" "$1" >&2 || true
        FAIL=1
    fi
}

# check_banned <file>
check_banned() {
    local phrase
    for phrase in "${BANNED_PHRASES[@]}"; do
        if grep -qi "$phrase" "$1"; then
            echo "[lint-content] FAIL: banned phrase \"$phrase\" found in $1" >&2
            FAIL=1
        fi
    done
}

# check_command_refs <command-file> <ref...>
check_command_refs() {
    local command="$1"; shift
    if [ ! -f "$command" ]; then
        echo "[lint-content] FAIL: $command missing" >&2
        FAIL=1
        return
    fi
    local ref
    for ref in "$@"; do
        if ! grep -q -- "$ref" "$command"; then
            echo "[lint-content] FAIL: $command does not reference $ref" >&2
            FAIL=1
        fi
    done
}

# Template definitions: mandatory and optional headings are passed as bash
# arrays via nameref, so no quoting fragility around CSV strings.

lint_template() {
    local template="$1"
    local command="$2"
    local -n mandatory_ref="$3"
    local -n optional_ref="$4"
    local -n extra_refs_ref="$5"

    if [ ! -f "$template" ]; then
        echo "[lint-content] FAIL: $template missing" >&2
        FAIL=1
        return
    fi

    check_em_dash "$template"

    local last=0
    check_headings "$template" last required "${mandatory_ref[@]}"
    if [ "${#optional_ref[@]}" -gt 0 ]; then
        check_headings "$template" last optional "${optional_ref[@]}"
    fi

    check_command_refs "$command" "$template" "${extra_refs_ref[@]}"
    check_banned "$template"
}

# --- product-spec-template.md ---
SPEC_MANDATORY=(
    "Headline"
    "Target Users and Personas"
    "Problem Statement (Job to Be Done)"
    "Value Proposition"
    "Scope"
    "Out of Scope"
    "Use Cases"
    "Success Metrics"
    "Risks and Open Product Questions"
)
SPEC_OPTIONAL=()
SPEC_EXTRA_REFS=("templates/product-checklist-template.md")
lint_template \
    "templates/product-spec-template.md" \
    "commands/speckit.product.spec.md" \
    SPEC_MANDATORY SPEC_OPTIONAL SPEC_EXTRA_REFS

# --- product-info-template.md ---
INFO_MANDATORY=(
    "Overview"
    "Headline"
    "What is Changing"
    "Out of Scope"
)
INFO_OPTIONAL=(
    "Risks"
    "Key Decisions"
    "References"
)
INFO_EXTRA_REFS=("templates/product-checklist-template.md")
lint_template \
    "templates/product-info-template.md" \
    "commands/speckit.product.info.md" \
    INFO_MANDATORY INFO_OPTIONAL INFO_EXTRA_REFS

# --- product-plan-template.md ---
# Note: "Build Overview" and "Key Principles" are conditional and appear between
# mandatory headings (Out of Scope and Delivery Phases). The check_headings
# helper validates one ordered pass, so these two interleaved optionals are not
# in PLAN_OPTIONAL; they carry the _(optional)_ marker in the template itself.
PLAN_MANDATORY=(
    "Summary"
    "Feature Context"
    "Goals"
    "Out of Scope"
    "Delivery Phases"
)
PLAN_OPTIONAL=(
    "Key Decisions"
    "Risks and Mitigations"
    "Divergences and Edge Cases"
    "Validation"
    "Open Questions"
)
PLAN_EXTRA_REFS=("templates/product-checklist-template.md")
lint_template \
    "templates/product-plan-template.md" \
    "commands/speckit.product.plan.md" \
    PLAN_MANDATORY PLAN_OPTIONAL PLAN_EXTRA_REFS

# --- product-design-template.md ---
# Note: "Data Design", "API Design", "Spec Coverage", and "Key Technical
# Decisions" are conditional and appear between mandatory headings (Affected
# Modules and Testing Strategy). They are not in DESIGN_OPTIONAL for the same
# reason as the plan template's interleaved optionals; they carry the
# _(optional)_ marker in the template itself.
DESIGN_MANDATORY=(
    "Summary"
    "Technical Context"
    "Architectural Approach"
    "Affected Modules"
    "Testing Strategy"
    "Rollout and Migration"
)
DESIGN_OPTIONAL=(
    "Risks and Mitigations"
    "Open Questions"
)
DESIGN_EXTRA_REFS=("templates/product-checklist-template.md")
lint_template \
    "templates/product-design-template.md" \
    "commands/speckit.product.design.md" \
    DESIGN_MANDATORY DESIGN_OPTIONAL DESIGN_EXTRA_REFS

# --- optional oxfmt pass ---
if command -v oxfmt >/dev/null 2>&1; then
    if ! oxfmt --check 'commands/**/*.md' 'templates/**/*.md' 'README.md' >&2; then
        echo "[lint-content] FAIL: oxfmt reported unformatted markdown files" >&2
        FAIL=1
    fi
fi

if [ "$FAIL" -ne 0 ]; then
    exit 1
fi

echo "[lint-content] OK"
