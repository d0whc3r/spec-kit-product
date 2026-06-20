# How to Use the Product Spec Extension

This document explains how to install the extension, what each command needs as input, what it produces as output, and in what order to run them.

---

## Prerequisites

- Spec Kit `>=0.2.0` initialized in your project (`specify init`).
- A feature directory under `specs/` created by `/speckit.specify`.
- The feature's `spec.md` filled in (no unfilled `[PLACEHOLDER]` markers).

---

## Install

Install directly from the latest release. This needs no catalog setup and is the recommended path:

```bash
specify extension add product --from https://github.com/d0whc3r/spec-kit-product/releases/download/v0.10.1/product-0.10.1.zip
```

Change the version in the URL to pin a different release.

Prefer to install and update by name with `specify extension add product`? That resolves the extension from Spec Kit's community catalog, which ships as discovery only (`install_allowed: false`). Approve it once, then add and update by name:

```bash
specify extension catalog add https://raw.githubusercontent.com/github/spec-kit/main/extensions/catalog.community.json --name community --install-allowed
specify extension add product
specify extension update product
```

If `specify extension add product` fails with `installation is not allowed from that catalog`, that is why.

After install, four slash commands become available in your assistant.

---

## The Four Commands

| Command                   | Reads                                                                                         | Writes                                         | Audience                                           |
| ------------------------- | --------------------------------------------------------------------------------------------- | ---------------------------------------------- | -------------------------------------------------- |
| `/speckit.product.info`   | `spec.md`                                                                                     | `product/00-info.md`, `product/checklist.md`   | Any stakeholder, non-technical                     |
| `/speckit.product.spec`   | `spec.md`                                                                                     | `product/10-spec.md`, `product/checklist.md`   | Product managers, leadership                       |
| `/speckit.product.plan`   | `plan.md` (required), `spec.md` (supplementary)                                               | `product/20-plan.md`, `product/checklist.md`   | PMs, engineering leads, cross-functional reviewers |
| `/speckit.product.design` | `plan.md` (required), `spec.md` (required), `tasks.md` (optional), `data-model.md` (optional) | `product/30-design.md`, `product/checklist.md` | Tech leads, senior developers                      |

None of the commands modify `spec.md`, `plan.md`, `tasks.md`, or any other source file. All output lands under `product/` inside the active feature directory. All four commands update `product/checklist.md`: the first command to run creates it; subsequent commands update only their own section, preserving the rest.

---

## Input and Output Flow

```
Spec Kit core commands                This extension
─────────────────────                 ─────────────────────────────────────────────

/speckit.specify ──→ spec.md ──→ /speckit.product.info   → product/00-info.md
                             └─→ /speckit.product.spec   → product/10-spec.md
                                                                       │
/speckit.plan ──→ plan.md ──→ /speckit.product.plan   → product/20-plan.md
                         └──→ /speckit.product.design → product/30-design.md
                                       ↑
                         tasks.md ─────┘ (optional)
                         data-model.md ─┘ (optional)

All four commands also write to:   product/checklist.md
```

---

## Recommended Order

Run the commands in this sequence as the feature matures. You do not need to run all four - stop at the level of detail your audience needs.

```
1. /speckit.specify         (core) - creates spec.md, run this first
2. /speckit.product.info    - quick stakeholder summary to validate direction early
3. /speckit.product.spec    - full product spec once direction is confirmed
   ── run /speckit.plan (core) before continuing ──
4. /speckit.product.plan    - product-oriented delivery view for PMs and leads
5. /speckit.product.design  - technical design document for engineers
```

`/speckit.product.info` and `/speckit.product.spec` both read only `spec.md` and can be run before any engineering plan exists. `/speckit.product.plan` and `/speckit.product.design` require `plan.md`, so run `/speckit.plan` (Spec Kit core) first.

---

## Command Details

### `/speckit.product.info`

Short, non-technical summary of what is changing and why. One page or less. Run this early to align stakeholders before committing to full spec work.

**Reads**: `spec.md`
**Writes**: `product/00-info.md`, `product/checklist.md`

```text
/speckit.product.info
# or target a specific feature:
/speckit.product.info --feature-dir specs/<feature-dir>
```

Output sections:

1. **Overview** - two to three sentences on what the feature is and why it exists.
2. **Headline** - who this is for and what is changing, in plain language.
3. **What is Changing** - two to five customer-observable bullets.
4. **Out of Scope** - what is deliberately excluded.
5. **Risks** _(optional)_ - appears when the spec has concrete risk signals.
6. **Key Decisions** _(optional)_ - appears when `spec.md` has a `## Clarifications` section or `[NEEDS CLARIFICATION]` markers. Surfaces resolved decisions and flags still-open questions.
7. **References** _(optional)_ - external links worth surfacing to non-technical readers.

---

### `/speckit.product.spec`

Full product spec following Working Backwards (PRFAQ), Jobs to Be Done, Gherkin BDD, and Lean PRD conventions. Use once direction is confirmed and the spec is stable.

**Reads**: `spec.md`
**Writes**: `product/10-spec.md`, `product/checklist.md`

```text
/speckit.product.spec
# or target a specific feature:
/speckit.product.spec --feature-dir specs/<feature-dir>
```

Output sections (mandatory unless marked optional):

1. **Headline** - press-release voice, customer and new outcome.
2. **Glossary** _(optional)_ - domain terms that need plain-language definitions for non-technical readers.
3. **Target Users and Personas** - named roles and what each cares about.
4. **Problem Statement** - Job to Be Done in Ulwick format: "When..., I want to..., so I can...".
5. **Assumptions** _(optional)_ - conditions believed true but not yet confirmed.
6. **Value Proposition** - what changes in the user's life, compared to the status quo.
7. **Scope** - finite list of included capabilities.
8. **Out of Scope** - explicitly excluded capabilities with a one-phrase reason each.
9. **Use Cases** - Gherkin scenarios (Given/When/Then), customer-observable behavior only.
10. **Success Metrics** - one north star metric and at least one supporting metric, both tech-agnostic.
11. **Risks and Open Product Questions** - risks and any `[NEEDS CLARIFICATION]` markers surfaced from `spec.md`.
12. **Positioning** _(optional)_ - for features with external users or competing alternatives.
13. **Go to Market and Rollout** _(optional)_ - when a launch motion exists.

The checklist validates mandatory sections, Gherkin scenario shape, style rules (no em dash, English only, no implementation detail), and section order. Walk the checklist after generation - any failed Required item means regenerate.

If `product/10-spec.md` already exists, the command prompts for overwrite or abort.

---

### `/speckit.product.plan`

High-level product view of the engineering plan. Describes what is being built and how it is structured, without time estimates or technical jargon. Intended for product managers, engineering leads, and cross-functional reviewers.

**Requires**: `plan.md` - run `/speckit.plan` first.

**Reads**: `plan.md` (required), `spec.md` (supplementary - personas, problem framing)
**Writes**: `product/20-plan.md`, `product/checklist.md`

```text
/speckit.product.plan
# or target a specific feature:
/speckit.product.plan --feature-dir specs/<feature-dir>
```

Output sections (mandatory unless marked optional):

1. **Summary** - what is being built, who it is for, the main approach. No code, no time estimates.
2. **Feature Context** - five labeled fields: Problem, For, Change, Quality bar, Constraints.
3. **Goals** - three to six concrete observable outcomes this feature delivers.
4. **Out of Scope** - explicitly excluded capabilities with a one-phrase reason each.
5. **Build Overview** _(optional)_ - how the main system parts connect, at C4 container level.
6. **Key Principles** _(optional)_ - explicit guard rails or core rules from the plan.
7. **Delivery Phases** - numbered phases in source order. Each phase lists its outcomes. No time estimates, no temporal bands.
8. **Key Decisions** _(optional)_ - mini-ADR format: Context, Options considered, Decision, Consequence. One subsection per decision.
9. **Risks and Mitigations** _(optional)_ - pre-mortem lens. Probability, Impact, Mitigation for each.
10. **Divergences and Edge Cases** _(optional)_ - scenarios that deviate from the normal flow.
11. **Validation** _(optional)_ - observable conditions a reviewer can verify after shipping.
12. **Open Questions** _(optional)_ - unresolved items from the plan, as single-sentence questions.

Technical terms are glossed in plain English on first use. No code, no file paths.

Mermaid diagrams are embedded by default, and each one appears only when it earns its place: it shows how parts connect, the order or dependencies between steps, or transitions between states, and prose conveys that poorly. The plan gets a high-level `flowchart` under Build Overview, and a dependency `flowchart` under Delivery Phases when two or more phases have dependencies that branch. Diagrams are reserved for flows, never for fixed charts like a matrix or quadrant.

---

### `/speckit.product.design`

Technical design document for tech leads and senior developers. Goes deeper than the plan: component names, module boundaries, API surface shapes, data schemas at a conceptual level. No runnable code, no full ORM definitions, no line-by-line detail.

**Requires**: `plan.md` and `spec.md` - run `/speckit.plan` and `/speckit.specify` first.

**Reads**: `plan.md` (required), `spec.md` (required), `tasks.md` (optional), `data-model.md` (optional)
**Writes**: `product/30-design.md`, `product/checklist.md`

```text
/speckit.product.design
# or target a specific feature:
/speckit.product.design --feature-dir specs/<feature-dir>
```

Output sections (mandatory unless marked optional):

1. **Summary** - what is being built technically, layers affected, key architectural approach.
2. **Technical Context** - current state, affected layers, non-measurable design constraints.
3. **Non-Functional Requirements** _(conditional)_ - measurable quality targets mapped to ISO 25010 categories, with how each is verified. Present when the source states measurable targets.
4. **Architectural Approach** - how the solution fits the existing architecture, components added/changed/removed.
5. **Affected Modules** - table: module name, change type (adds/modifies/removes/uses), responsibility.
6. **Data Design** _(conditional)_ - entity shapes and data flow. Present when any source has data model content.
7. **API Design** _(conditional)_ - request/response shapes and error cases. Present when the feature has an API surface.
8. **Spec Coverage** _(conditional)_ - table mapping each spec use case to the component that implements it. Gaps marked explicitly.
9. **Key Technical Decisions** _(optional)_ - ADR format: Context, Options considered, Decision, Consequences.
10. **Testing Strategy** - Unit, Integration, E2E/BDD, Observability bullets derived from spec use cases.
11. **Rollout and Migration** - strategy, data migration steps, rollback plan.
12. **Risks and Mitigations** _(optional)_ - pre-mortem lens with probability, impact, mitigation.
13. **Open Questions** _(optional)_ - unresolved technical decisions as single-sentence questions.

Mermaid diagrams are embedded by default, subject to the same value gate: a `flowchart` of how components connect (C4 level) under Architectural Approach (this one always renders), a `flowchart` or `sequenceDiagram` under Data Design when that section is present (sequence when ordering matters), and a `sequenceDiagram` under API Design when that section is present. A `stateDiagram-v2` is added when the source describes a lifecycle. Diagrams are reserved for flows, never for fixed charts like a matrix or quadrant.

---

## The `product/` Subfolder

All generated artifacts live under `product/` inside the feature directory. This keeps stakeholder-facing output self-contained and easy to share or export without dragging engineering scaffolding along.

```
specs/<feature-dir>/
├── spec.md                  # Engineering spec (source of truth, never modified)
├── plan.md                  # Engineering plan (source of truth, never modified)
├── tasks.md                 # Task breakdown (read-only input to /speckit.product.design)
└── product/
    ├── 00-info.md           # Stakeholder summary  (from /speckit.product.info)
    ├── 10-spec.md           # Product spec         (from /speckit.product.spec)
    ├── 20-plan.md           # Product plan         (from /speckit.product.plan)
    ├── 30-design.md         # Technical design     (from /speckit.product.design)
    └── checklist.md         # Shared quality checklist (updated by each command)
```

`spec.md` is the canonical artifact. The files under `product/` are derived views, regenerated on demand by rerunning the command and choosing overwrite. No two commands write to the same output file. All four update different sections of the shared `checklist.md`.

---

## Common Errors

| Code             | Cause                                                            | Fix                                                          |
| ---------------- | ---------------------------------------------------------------- | ------------------------------------------------------------ |
| `E_NO_PROJECT`   | Not inside a Spec Kit project.                                   | `cd` into a project with `.specify/`, or run `specify init`. |
| `E_NO_POINTER`   | No active feature and `--feature-dir` not passed.                | Run `/speckit.specify` first, or pass `--feature-dir`.       |
| `E_NO_SPEC`      | No `spec.md` in the feature directory.                           | Run `/speckit.specify` to create one.                        |
| `E_NO_PLAN`      | No `plan.md` in the feature directory.                           | Run `/speckit.plan` to generate it.                          |
| `E_PLACEHOLDERS` | `spec.md` or `plan.md` still contains unfilled template markers. | Replace all `[PLACEHOLDER]` values with real content.        |
| `E_LANGUAGE`     | Source files are not in English.                                 | Translate the source file to English and rerun.              |
| `E_USER_ABORT`   | You answered "no" at the overwrite prompt.                       | Rerun when ready.                                            |

`E_NO_PROJECT` and `E_NO_POINTER` are Spec Kit core resolver errors, surfaced verbatim before the extension runs. They are not extension error codes. The rest are emitted by the product commands.
