# Commands Reference

Three slash commands. All read from a feature directory under `specs/` and
write into `product/` inside that directory. None modify the source files.

| Command                                            | Reads                                                      | Writes                                                 | Audience                         |
| -------------------------------------------------- | ---------------------------------------------------------- | ------------------------------------------------------ | -------------------------------- |
| [`/speckit.product.brief`](#speckitproductbrief)   | `spec.md`                                                  | `product/00-info.md`, `product/10-spec.md` + checklist | Any stakeholder, PMs, leadership |
| [`/speckit.product.plan`](#speckitproductplan)     | `plan.md` (required), `spec.md` (supplementary)            | `product/20-plan.md` + checklist                       | PMs, engineering leads           |
| [`/speckit.product.design`](#speckitproductdesign) | `plan.md`, `spec.md`, optional `tasks.md`, `data-model.md` | `product/30-design.md` + checklist                     | Tech leads, senior developers    |

Every command accepts `--feature-dir specs/<feature-dir>` to target a specific
feature directory. Without it, the active feature pointer at
`.specify/feature.json` is used.

`/speckit.product.plan` and `/speckit.product.design` embed Mermaid diagrams in
their output by default. A diagram renders only when it earns its place: when it
shows structure the prose cannot convey at a glance, and is not a restatement, a
duplicate, or a trivial shape. `/speckit.product.design` can also add a
Non-Functional Requirements table on the same terms. See [Diagrams](Diagrams.md)
for the full per-section mapping and the value gate; each command below lists a
summary.

---

## `/speckit.product.brief`

Generates the two entry artifacts in a single pass: `product/00-info.md`, the
one-page non-technical digest, and `product/10-spec.md`, the structured product
spec a stakeholder reads after the digest. The spec is not fully legible without
the info, so the two are generated together. Run this first, before any
engineering plan exists.

**Reads**: `spec.md`
**Writes**: `product/00-info.md`, `product/10-spec.md`, `product/checklist.md` (`## Info` and `## Spec` sections only)

### `product/00-info.md` output sections

1. **Overview** - two to four sentences on what the feature is and why.
2. **What is Changing** - two to five customer-observable bullets.
3. **Key Decisions** _(optional)_ - present when `spec.md` has a `## Clarifications`
   section or `[NEEDS CLARIFICATION]` markers. Surfaces resolved decisions and
   flags still-open questions.
4. **References** _(optional)_ - external links worth surfacing to non-technical
   readers.

This is the one-page digest. Scope and risks are owned by the spec, plan, and
design docs, so the info doc never carries an Out of Scope or Risks section.

### `product/10-spec.md` output sections

Mandatory unless marked optional:

1. **Headline** - press release voice, merging the customer, the new outcome, and
   the value versus the status quo.
2. **Glossary** _(optional)_ - domain terms in plain language.
3. **Users** - named roles and what each cares about.
4. **Problem (Job to Be Done)** - Ulwick format: "When..., I want to..., so I can...".
5. **Assumptions** _(optional)_ - conditions believed true but not confirmed.
6. **Scope** - finite list of included capabilities.
7. **Use Cases** - Gherkin scenarios, customer-observable only.
8. **Success Metrics** - one north star, at least one supporting, both tech-agnostic.
9. **Risks and Open Questions** - including any `[NEEDS CLARIFICATION]`
   markers surfaced from `spec.md`.
10. **Positioning** _(optional)_ - external users or competing alternatives.
11. **Go to Market and Rollout** _(optional)_ - when a launch motion exists.

### Error codes

| Code             | Meaning                                                     |
| ---------------- | ----------------------------------------------------------- |
| `E_NO_SPEC`      | Feature directory has no `spec.md`.                         |
| `E_PLACEHOLDERS` | `spec.md` still contains unfilled template placeholders.    |
| `E_LANGUAGE`     | `spec.md` is not in English.                                |
| `E_USER_ABORT`   | You answered "no" at the overwrite or clarification prompt. |

Project and feature resolution failures (not inside a Spec Kit project, or no
active feature and no `--feature-dir`) come from Spec Kit core's resolver. The
command surfaces core's own error message verbatim before any of these codes
can fire.

---

## `/speckit.product.plan`

High-level product view of the engineering plan. Answers "how are we building
this?" for PMs, engineering leads, and cross-functional reviewers. No code,
no time estimates, no file paths.

**Reads**: `plan.md` (required), `spec.md` (supplementary)
**Writes**: `product/20-plan.md`, `product/checklist.md` (`## Plan` section only)

### Output sections

Mandatory unless marked optional:

1. **Summary** - one paragraph on the main approach and how the work is structured.
2. **Goals and Non-Goals** - delivery outcomes and deliberate delivery exclusions.
3. **Delivery Phases** - numbered phases in source order, each with outcomes.
   No time estimates, no NOW/NEXT/LATER bands.
4. **Risks and Mitigations** _(optional)_ - delivery risks with probability, impact, mitigation each.
5. **Divergences and Edge Cases** _(optional)_.
6. **Validation** _(optional)_ - observable post-ship conditions.
7. **Open Questions** _(optional)_ - open delivery questions.

Technical terms are glossed in plain English on first use. Architecture, design
principles, and key technical decisions are owned by the design doc; the problem
and audience by the spec. The plan does not repeat them.

Diagrams (by default, subject to the value gate): a dependency `flowchart` under
Delivery Phases when the phases branch. Diagrams are reserved for flows; labels
stay plain-language. See [Diagrams](Diagrams.md).

### Error codes

| Code             | Meaning                                                  |
| ---------------- | -------------------------------------------------------- |
| `E_NO_PLAN`      | Feature directory has no `plan.md`.                      |
| `E_PLACEHOLDERS` | `plan.md` still contains unfilled template placeholders. |
| `E_LANGUAGE`     | `plan.md` is not in English.                             |
| `E_USER_ABORT`   | You answered "no" at the overwrite prompt.               |

Spec Kit core resolution failures (no project, no active feature) surface
verbatim before these codes, as noted under `brief`.

---

## `/speckit.product.design`

Technical design document for tech leads and senior developers. Component
names, module boundaries, API surface shapes, and data schemas at a
conceptual level. No runnable code, no full ORM definitions, no line-by-line
implementation detail.

**Reads**: `plan.md` (required), `spec.md` (required), `tasks.md` (optional),
`data-model.md` (optional)
**Writes**: `product/30-design.md`, `product/checklist.md` (`## Design` section only)

### Output sections

Mandatory unless marked optional or conditional:

1. **Summary** - what is being built technically and the key architectural
   approach, then three fields: current state, affected layers, and
   non-measurable constraints.
2. **Non-Functional Requirements** _(conditional)_ - measurable quality targets
   mapped to ISO 25010 categories and how each is verified.
3. **Architectural Approach** - components added, changed, removed.
4. **Affected Modules** - table: module, change type, responsibility.
5. **Data Design** _(conditional)_ - entity shapes and data flow.
6. **API Design** _(conditional)_ - request/response shapes and error cases.
7. **Spec Coverage** _(conditional)_ - table mapping each spec use case to
   its implementing component. Gaps marked explicitly.
8. **Key Technical Decisions** _(optional)_ - ADR format.
9. **Testing Strategy** - Unit, Integration, E2E/BDD, Observability.
10. **Rollout and Migration** - strategy, data migration, rollback.
11. **Risks and Mitigations** _(optional)_.
12. **Open Questions** _(optional)_.

Diagrams (by default, subject to the value gate): a C4-level `flowchart` under
Architectural Approach (this one always renders), a data-flow diagram under Data
Design, and a `sequenceDiagram` under API Design. A `stateDiagram-v2` is added
when the source describes a lifecycle. Diagrams are reserved for flows. See
[Diagrams](Diagrams.md).

### Error codes

| Code             | Meaning                                                    |
| ---------------- | ---------------------------------------------------------- |
| `E_NO_PLAN`      | Feature directory has no `plan.md`.                        |
| `E_NO_SPEC`      | Feature directory has no `spec.md`.                        |
| `E_PLACEHOLDERS` | Source files still contain unfilled template placeholders. |
| `E_LANGUAGE`     | Source files are not in English.                           |
| `E_USER_ABORT`   | You answered "no" at the overwrite prompt.                 |

---

## The shared checklist

Each command updates its section or sections of `product/checklist.md`:

- `/speckit.product.brief` writes `## Info` and `## Spec`.
- `/speckit.product.plan` writes `## Plan`.
- `/speckit.product.design` writes `## Design`.

The first command to run creates the file. Subsequent commands preserve every
other section. Walk the checklist after each generation: any failed Required
item is a regenerate signal.

## Hooks

The extension registers three optional hook handlers, one per Spec Kit hook
event (declared in `extension.yml`). The host agent asks before running each
handler.

| Hook            | Triggers after     | Command                  |
| --------------- | ------------------ | ------------------------ |
| `after_specify` | `/speckit.specify` | `/speckit.product.brief` |
| `after_clarify` | `/speckit.clarify` | `/speckit.product.brief` |
| `after_plan`    | `/speckit.plan`    | `/speckit.product.plan`  |

Each hook is `optional: true`. The host agent prompts before running and the
user can decline. The richer artifact (`/speckit.product.design`) is not
auto-prompted; run it explicitly when you need it.
