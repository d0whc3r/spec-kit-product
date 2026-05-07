# How to Use the Product Spec Extension

This document explains how to install the extension and how to use each command, in what context, and in what order.

---

## Prerequisites

- Spec Kit `>=0.2.0` initialized in your project (`specify init`).
- A feature directory under `specs/` created by `/speckit-specify`.
- The feature's `spec.md` filled in (no unfilled `[PLACEHOLDER]` markers).

---

## Install

```bash
specify extension add product
```

To upgrade an existing install:

```bash
specify extension upgrade product
```

To install a specific version:

```bash
specify extension add product --from https://github.com/d0whc3r/spec-kit-product/releases/download/v<version>/product-<version>.zip
```

After install, four slash commands become available in your assistant.

---

## The Four Commands

| Command | Reads | Writes | Audience |
|---------|-------|--------|----------|
| `/speckit-product-info` | `spec.md` | `product/info.md` | Any stakeholder, non-technical |
| `/speckit-product-spec` | `spec.md` | `product/10-spec.md`, `product/checklist.md` | Product managers, leadership |
| `/speckit-product-plan` | `plan.md`, `spec.md` | `product/20-plan.md`, `product/checklist.md` | PMs, engineering leads, cross-functional reviewers |
| `/speckit-product-design` | `plan.md`, `spec.md` | `product/30-design.md`, `product/checklist.md` | Tech leads, senior developers |

None of the commands modify `spec.md` or `plan.md`. All output lands under `product/` inside the active feature directory.

---

## Recommended Order

Run the commands in this sequence as the feature matures. You do not need to run all four — stop at the level of detail your audience needs.

```
1. /speckit-specify        (creates spec.md — run this first, from Spec Kit core)
2. /speckit-product-info   (validate direction with stakeholders early)
3. /speckit-product-spec   (full product spec once direction is confirmed)
   --- /speckit-plan must exist before continuing ---
4. /speckit-product-plan   (product-oriented delivery view for PMs and leads)
5. /speckit-product-design (technical design for engineers)
```

`/speckit-product-info` and `/speckit-product-spec` both read `spec.md` and can be run before any engineering plan exists. `/speckit-product-plan` and `/speckit-product-design` require `plan.md`, so run `/speckit-plan` (Spec Kit core) first.

---

## Command Details

### `/speckit-product-info`

Short, non-technical summary of what is changing and why. One page or less. Run this early to align stakeholders before committing to full spec work.

```text
/speckit-product-info
# or target a specific feature:
/speckit-product-info --feature-dir specs/<feature-dir>
```

Output sections:
1. Headline — who this is for and what is changing.
2. What is Changing — two to five customer-observable bullets.
3. Why Now — two to four sentences on the trigger.
4. Out of Scope — what is deliberately excluded.
5. Open Questions _(optional)_ — appears if `spec.md` contains `[NEEDS CLARIFICATION]` markers.

---

### `/speckit-product-spec`

Full product spec following Working Backwards (PRFAQ), Jobs to Be Done, Gherkin BDD, and Lean PRD conventions. Use once direction is confirmed and the spec is stable.

```text
/speckit-product-spec
# or target a specific feature:
/speckit-product-spec --feature-dir specs/<feature-dir>
```

Output: `product/10-spec.md` and `product/checklist.md`.

The checklist validates mandatory sections, Gherkin scenario shape, style rules (no em dash, English only, no implementation detail), and section order. Walk the checklist after generation — any failed Required item means regenerate.

If `product/10-spec.md` already exists, the command prompts for overwrite or abort.

---

### `/speckit-product-plan`

High-level product view of the engineering plan. Uses Shape Up appetite framing for phases, a NOW/NEXT/LATER delivery view, C4 container-level component descriptions, and condensed ADR summaries for key decisions. No code, no file paths, no detailed task breakdowns.

Requires `plan.md` — run `/speckit-plan` first.

```text
/speckit-product-plan
# or target a specific feature:
/speckit-product-plan --feature-dir specs/<feature-dir>
```

Output: `product/20-plan.md`. Updates the `## Plan` section of `product/checklist.md`.

---

### `/speckit-product-design`

Technical design document for tech leads and senior developers. References component names, module boundaries, API surface shapes, and data schemas at a conceptual level. No runnable code, no full ORM definitions, no line-by-line detail.

Requires `plan.md` and `spec.md`.

```text
/speckit-product-design
# or target a specific feature:
/speckit-product-design --feature-dir specs/<feature-dir>
```

Output: `product/30-design.md`. Updates the `## Design` section of `product/checklist.md`.

Output covers: architectural approach, affected modules and layers, data model and API shapes, spec coverage mapping, key technical decisions, testing strategy, and rollout plan.

---

## The `product/` Subfolder

All generated artifacts live under `product/` inside the feature directory. This keeps stakeholder-facing output self-contained and easy to share or export without dragging engineering scaffolding along.

```
specs/<feature-dir>/
├── spec.md                  # Engineering spec (source of truth, never modified)
├── plan.md                  # Engineering plan (source of truth, never modified)
├── tasks.md
└── product/
    ├── info.md              # Stakeholder summary (from /speckit-product-info)
    ├── 10-spec.md           # Product spec (from /speckit-product-spec)
    ├── 20-plan.md           # Product plan (from /speckit-product-plan)
    ├── 30-design.md         # Technical design (from /speckit-product-design)
    └── checklist.md         # Shared quality checklist (updated by each command)
```

`spec.md` is the canonical artifact. The files under `product/` are derived views, regenerated on demand by rerunning the command and choosing overwrite.

---

## Common Errors

| Code | Cause | Fix |
|------|-------|-----|
| `E_NO_PROJECT` | Not inside a Spec Kit project. | `cd` into a project with `.specify/`, or run `specify init`. |
| `E_NO_POINTER` | No active feature and `--feature-dir` not passed. | Run `/speckit-specify` first, or pass `--feature-dir`. |
| `E_NO_SPEC` | No `spec.md` in the feature directory. | Run `/speckit-specify` to create one. |
| `E_NO_PLAN` | No `plan.md` in the feature directory. | Run `/speckit-plan` to generate it. |
| `E_PLACEHOLDERS` | `spec.md` or `plan.md` still contains unfilled template markers. | Replace all `[PLACEHOLDER]` values with real content. |
| `E_LANGUAGE` | Source files are not in English. | Translate the source file to English and rerun. |
| `E_USER_ABORT` | You answered "no" at the overwrite prompt. | Rerun when ready. |
