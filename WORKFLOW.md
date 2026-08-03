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
specify extension add product --from https://github.com/d0whc3r/spec-kit-product/releases/download/v1.0.1/product-1.0.1.zip
```

Change the version in the URL to pin a different release.

Prefer to install and update by name with `specify extension add product`? That resolves the extension from Spec Kit's community catalog, which ships as discovery only (`install_allowed: false`). Approve it once, then add and update by name:

```bash
specify extension catalog add https://raw.githubusercontent.com/github/spec-kit/main/extensions/catalog.community.json --name community --install-allowed
specify extension add product
specify extension update product
```

If `specify extension add product` fails with `installation is not allowed from that catalog`, that is why.

After install, three slash commands become available in your assistant.

---

## The Commands

| Command                   | Reads                                                                                         | Writes                                                             | Audience                                           |
| ------------------------- | --------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ | -------------------------------------------------- |
| `/speckit.product.brief`  | `spec.md`                                                                                     | `product/00-info.md`, `product/10-spec.md`, `product/checklist.md` | Any stakeholder, PMs, leadership                   |
| `/speckit.product.plan`   | `plan.md` (required), `spec.md` (supplementary)                                               | `product/20-plan.md`, `product/checklist.md`                       | PMs, engineering leads, cross-functional reviewers |
| `/speckit.product.design` | `plan.md` (required), `spec.md` (required), `tasks.md` (optional), `data-model.md` (optional) | `product/30-design.md`, `product/checklist.md`                     | Tech leads, senior developers                      |

None of the commands modify `spec.md`, `plan.md`, `tasks.md`, or any other source file. All output lands under `product/` inside the active feature directory. All three commands update `product/checklist.md`: the first command to run creates it; subsequent commands update only their own sections, preserving the rest.

---

## Input and Output Flow

```
Spec Kit core commands                This extension
─────────────────────                 ─────────────────────────────────────────────

/speckit.specify ──→ spec.md ──→ /speckit.product.brief  ┬─→ product/00-info.md
                                                         └─→ product/10-spec.md

/speckit.plan ──→ plan.md ──→ /speckit.product.plan   → product/20-plan.md
                         └──→ /speckit.product.design → product/30-design.md
                                       ↑
                         tasks.md ─────┘ (optional)
                         data-model.md ─┘ (optional)

All three commands also write to:  product/checklist.md
```

---

## Recommended Order

Run the commands in this sequence as the feature matures. You do not need to run all three - stop at the level of detail your audience needs.

```
1. /speckit.specify         (core) - creates spec.md, run this first
2. /speckit.product.brief   - stakeholder digest + full product spec
   ── run /speckit.plan (core) before continuing ──
3. /speckit.product.plan    - product-oriented delivery view for PMs and leads
4. /speckit.product.design  - technical design document for engineers
```

`/speckit.product.brief` reads only `spec.md` and can be run before any engineering plan exists. `/speckit.product.plan` and `/speckit.product.design` require `plan.md`, so run `/speckit.plan` (Spec Kit core) first.

---

## Command Details

### `/speckit.product.brief`

Generates the two entry artifacts in a single pass: the one-page non-technical digest (`product/00-info.md`) and the structured product spec (`product/10-spec.md`). The spec is not fully legible without the info, so the two are generated together. Run this first, before any engineering plan exists.

**Reads**: `spec.md`
**Writes**: `product/00-info.md`, `product/10-spec.md`, `product/checklist.md`

```text
/speckit.product.brief
# or target a specific feature:
/speckit.product.brief --feature-dir specs/<feature-dir>
```

`product/00-info.md` output sections:

1. **Overview** - two to four sentences on what the feature is and why it exists.
2. **What is Changing** - two to five customer-observable bullets.
3. **Key Decisions** _(optional)_ - appears when `spec.md` has a `## Clarifications` section or `[NEEDS CLARIFICATION]` markers. Surfaces resolved decisions and flags still-open questions.
4. **References** _(optional)_ - external links worth surfacing to non-technical readers.

The info doc is the one-page digest. Scope and risks are owned by the spec, plan, and design docs, so it never carries an Out of Scope or Risks section.

`product/10-spec.md` output sections (mandatory unless marked optional):

1. **Headline** - press-release voice, merging the customer, the new outcome, and the value versus the status quo.
2. **Glossary** _(optional)_ - domain terms that need plain-language definitions for non-technical readers.
3. **Users** - named roles and what each cares about.
4. **Problem (Job to Be Done)** - Ulwick format: "When..., I want to..., so I can...".
5. **Assumptions** _(optional)_ - conditions believed true but not yet confirmed.
6. **Scope** - finite list of included capabilities.
7. **Use Cases** - Gherkin scenarios (Given/When/Then), customer-observable behavior only.
8. **Success Metrics** - one north star metric and at least one supporting metric, both tech-agnostic.
9. **Risks and Open Questions** - risks and any `[NEEDS CLARIFICATION]` markers surfaced from `spec.md`.
10. **Positioning** _(optional)_ - for features with external users or competing alternatives.
11. **Go to Market and Rollout** _(optional)_ - when a launch motion exists.

The checklist validates mandatory sections, Gherkin scenario shape, style rules (no em dash, English only, no implementation detail), and section order. Walk the checklist after generation - any failed Required item means regenerate.

If `product/00-info.md` or `product/10-spec.md` already exists, the command prompts for overwrite or abort.

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

1. **Summary** - one paragraph on the main approach and how the work is structured. No code, no time estimates.
2. **Goals and Non-Goals** - delivery outcomes that mark this build done, and deliberate delivery exclusions with a one-phrase reason each.
3. **Delivery Phases** - numbered phases in source order. Each phase lists its outcomes, with a `Depends on` line when it needs a prior phase. No time estimates, no temporal bands.
4. **Risks and Mitigations** _(optional)_ - delivery risks with probability, impact, and mitigation each.
5. **Divergences and Edge Cases** _(optional)_ - scenarios that deviate from the normal flow.
6. **Validation** _(optional)_ - observable conditions a reviewer can verify after shipping.
7. **Open Questions** _(optional)_ - open delivery questions, as single-sentence questions.

Technical terms are glossed in plain English on first use. Architecture, design principles, and key technical decisions are owned by the design doc; the problem and audience by the spec. No code, no file paths.

Mermaid diagrams are embedded by default, and each one appears only when it earns its place: it shows how parts connect, the order or dependencies between steps, or transitions between states, and prose conveys that poorly. The plan gets a dependency `flowchart` under Delivery Phases when two or more phases have dependencies that branch. Diagrams are reserved for flows, never for fixed charts like a matrix or quadrant.

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

1. **Summary** - what is being built technically and the key architectural approach, then three fields: current state, affected layers, and non-measurable constraints.
2. **Non-Functional Requirements** _(conditional)_ - measurable quality targets mapped to ISO 25010 categories, with how each is verified. Present when the source states measurable targets.
3. **Architectural Approach** - how the solution fits the existing architecture, components added/changed/removed.
4. **Affected Modules** - table: module name, change type (adds/modifies/removes/uses), responsibility.
5. **Data Design** _(conditional)_ - entity shapes and data flow. Present when any source has data model content.
6. **API Design** _(conditional)_ - request/response shapes and error cases. Present when the feature has an API surface.
7. **Spec Coverage** _(conditional)_ - table mapping each spec use case to the component that implements it. Gaps marked explicitly.
8. **Key Technical Decisions** _(optional)_ - ADR format: Context, Options considered, Decision, Consequences.
9. **Testing Strategy** - Unit, Integration, E2E/BDD, Observability bullets derived from spec use cases.
10. **Rollout and Migration** - strategy, data migration steps, rollback plan.
11. **Risks and Mitigations** _(optional)_ - technical risks with probability, impact, mitigation.
12. **Open Questions** _(optional)_ - unresolved technical decisions as single-sentence questions.

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
    ├── 00-info.md           # Stakeholder summary  (from /speckit.product.brief)
    ├── 10-spec.md           # Product spec         (from /speckit.product.brief)
    ├── 20-plan.md           # Product plan         (from /speckit.product.plan)
    ├── 30-design.md         # Technical design     (from /speckit.product.design)
    └── checklist.md         # Shared quality checklist (updated by each command)
```

`spec.md` is the canonical artifact. The files under `product/` are derived views, regenerated on demand by rerunning the command and choosing overwrite. No two commands write to the same output file. The commands update different sections of the shared `checklist.md`.

---

## Common Errors

| Code             | Cause                                                            | Fix                                                   |
| ---------------- | ---------------------------------------------------------------- | ----------------------------------------------------- |
| `E_NO_SPEC`      | No `spec.md` in the feature directory.                           | Run `/speckit.specify` to create one.                 |
| `E_NO_PLAN`      | No `plan.md` in the feature directory.                           | Run `/speckit.plan` to generate it.                   |
| `E_PLACEHOLDERS` | `spec.md` or `plan.md` still contains unfilled template markers. | Replace all `[PLACEHOLDER]` values with real content. |
| `E_LANGUAGE`     | Source files are not in English.                                 | Translate the source file to English and rerun.       |
| `E_USER_ABORT`   | You answered "no" at the overwrite prompt.                       | Rerun when ready.                                     |

Project and feature resolution failures (not inside a Spec Kit project, no active feature) come from Spec Kit core's resolver and surface verbatim before the extension runs; they carry no `E_*` code from this extension. The codes above are emitted by the product commands.
