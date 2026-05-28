# Commands Reference

Four slash commands. All read from a feature directory under `specs/` and
write into `product/` inside that directory. None modify the source files.

| Command                                            | Reads                                                      | Writes                             | Audience                       |
| -------------------------------------------------- | ---------------------------------------------------------- | ---------------------------------- | ------------------------------ |
| [`/speckit.product.info`](#speckitproductinfo)     | `spec.md`                                                  | `product/00-info.md` + checklist   | Any stakeholder, non-technical |
| [`/speckit.product.spec`](#speckitproductspec)     | `spec.md`                                                  | `product/10-spec.md` + checklist   | Product managers, leadership   |
| [`/speckit.product.plan`](#speckitproductplan)     | `plan.md` (required), `spec.md` (supplementary)            | `product/20-plan.md` + checklist   | PMs, engineering leads         |
| [`/speckit.product.design`](#speckitproductdesign) | `plan.md`, `spec.md`, optional `tasks.md`, `data-model.md` | `product/30-design.md` + checklist | Tech leads, senior developers  |

Every command accepts `--feature-dir specs/<feature-dir>` to target a specific
feature directory. Without it, the active feature pointer at
`.specify/feature.json` is used.

---

## `/speckit.product.info`

Short, non-technical summary. One rendered page or less. Run this early to
align stakeholders before committing to the full spec.

**Reads**: `spec.md`
**Writes**: `product/00-info.md`, `product/checklist.md` (`## Info` section only)

### Output sections

1. **Overview** - two to three sentences on what the feature is and why.
2. **Headline** - one paragraph on who this is for and what is changing.
3. **What is Changing** - two to five customer-observable bullets.
4. **Out of Scope** - what is deliberately excluded.
5. **Risks** _(optional)_ - present when the spec has concrete risk signals.
6. **Key Decisions** _(optional)_ - present when `spec.md` has a `## Clarifications`
   section or `[NEEDS CLARIFICATION]` markers. Surfaces resolved decisions and
   flags still-open questions.
7. **References** _(optional)_ - external links worth surfacing to non-technical
   readers.

### Error codes

| Code             | Meaning                                                     |
| ---------------- | ----------------------------------------------------------- |
| `E_NO_PROJECT`   | Not inside a Spec Kit project.                              |
| `E_NO_POINTER`   | No active feature and `--feature-dir` not passed.           |
| `E_NO_SPEC`      | Feature directory has no `spec.md`.                         |
| `E_PLACEHOLDERS` | `spec.md` still contains unfilled template placeholders.    |
| `E_LANGUAGE`     | `spec.md` is not in English.                                |
| `E_USER_ABORT`   | You answered "no" at the overwrite or clarification prompt. |

---

## `/speckit.product.spec`

Full product spec following Working Backwards (PRFAQ), Jobs to Be Done,
Gherkin BDD, and Lean PRD conventions. Use once direction is confirmed.

**Reads**: `spec.md`
**Writes**: `product/10-spec.md`, `product/checklist.md` (`## Spec` section only)

### Output sections

Mandatory unless marked optional:

1. **Headline** - press release voice, customer and new outcome.
2. **Glossary** _(optional)_ - domain terms in plain language.
3. **Target Users and Personas** - named roles and what each cares about.
4. **Problem Statement** - Ulwick format: "When..., I want to..., so I can...".
5. **Assumptions** _(optional)_ - conditions believed true but not confirmed.
6. **Value Proposition** - what changes in the user's life vs the status quo.
7. **Scope** - finite list of included capabilities.
8. **Out of Scope** - explicitly excluded with a one-phrase reason each.
9. **Use Cases** - Gherkin scenarios, customer-observable only.
10. **Success Metrics** - one north star, at least one supporting, both tech-agnostic.
11. **Risks and Open Product Questions** - including any `[NEEDS CLARIFICATION]`
    markers surfaced from `spec.md`.
12. **Positioning** _(optional)_ - external users or competing alternatives.
13. **Go to Market and Rollout** _(optional)_ - when a launch motion exists.

### Error codes

Same set as `/speckit.product.info`.

---

## `/speckit.product.plan`

High-level product view of the engineering plan. Answers "how are we building
this?" for PMs, engineering leads, and cross-functional reviewers. No code,
no time estimates, no file paths.

**Reads**: `plan.md` (required), `spec.md` (supplementary)
**Writes**: `product/20-plan.md`, `product/checklist.md` (`## Plan` section only)

### Output sections

Mandatory unless marked optional:

1. **Summary** - what is being built, who it is for, the main approach.
2. **Feature Context** - Problem, For, Change, Quality bar, Constraints.
3. **Goals** - three to six concrete observable outcomes.
4. **Out of Scope** - explicitly excluded with a one-phrase reason each.
5. **Build Overview** _(optional)_ - main system parts at C4 container level.
6. **Key Principles** _(optional)_ - explicit guard rails from the plan.
7. **Delivery Phases** - numbered phases in source order, each with outcomes.
   No time estimates, no NOW/NEXT/LATER bands.
8. **Key Decisions** _(optional)_ - mini-ADR: Context, Options, Decision, Consequence.
9. **Risks and Mitigations** _(optional)_ - probability, impact, mitigation each.
10. **Divergences and Edge Cases** _(optional)_.
11. **Validation** _(optional)_ - observable post-ship conditions.
12. **Open Questions** _(optional)_.

Technical terms are glossed in plain English on first use.

### Error codes

| Code             | Meaning                                                  |
| ---------------- | -------------------------------------------------------- |
| `E_NO_PLAN`      | Feature directory has no `plan.md`.                      |
| `E_PLACEHOLDERS` | `plan.md` still contains unfilled template placeholders. |
| `E_LANGUAGE`     | `plan.md` is not in English.                             |
| `E_USER_ABORT`   | You answered "no" at the overwrite prompt.               |

Plus the project-resolution errors from `info`/`spec`.

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

1. **Summary** - what is being built technically, layers affected.
2. **Technical Context** - current state, affected layers, constraints.
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

Every command updates one section of `product/checklist.md`:

- `/speckit.product.info` writes `## Info`.
- `/speckit.product.spec` writes `## Spec`.
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
| `after_specify` | `/speckit.specify` | `/speckit.product.info`  |
| `after_clarify` | `/speckit.clarify` | `/speckit.product.info`  |
| `after_plan`    | `/speckit.plan`    | `/speckit.product.plan`  |

Each hook is `optional: true`. The host agent prompts before running and the
user can decline. Richer artifacts (`/speckit.product.spec`,
`/speckit.product.design`) are not auto-prompted; run them explicitly when
you need them.
