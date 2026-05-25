# Product Spec Extension for Spec Kit

A Spec Kit extension that derives four stakeholder-facing artifacts from a technical `spec.md` and `plan.md`. Output follows Amazon Working Backwards (PRFAQ), Jobs to Be Done (Ulwick), Gherkin BDD, and Lean PRD conventions, in plain English, with a strict no em dash style.

## Overview

`/speckit-specify` and `/speckit-plan` produce `spec.md` and `plan.md` that engineers can act on. Product, design, and leadership often need the same information in a different shape: a headline, a Job to Be Done, scope and out of scope, Gherkin scenarios, delivery phases, and technical decisions explained in plain language. This extension generates four audience-specific artifacts from those source files, each with an auto-validated quality checklist.

| Command                   | Reads                        | Writes                 | Audience                       |
| ------------------------- | ---------------------------- | ---------------------- | ------------------------------ |
| `/speckit.product.info`   | `spec.md`                    | `product/00-info.md`   | Any stakeholder, non-technical |
| `/speckit.product.spec`   | `spec.md`                    | `product/10-spec.md`   | Product managers, leadership   |
| `/speckit.product.plan`   | `plan.md`, `spec.md`         | `product/20-plan.md`   | PMs, engineering leads         |
| `/speckit.product.design` | `plan.md`, `spec.md`, others | `product/30-design.md` | Tech leads, senior developers  |

All four commands also update their respective section of the shared `product/checklist.md`.

See [WORKFLOW.md](WORKFLOW.md) for the full input/output flow and recommended order.

## Source of Truth Contract

`spec.md` and `plan.md` are the canonical artifacts for a feature. Everything under `product/` is a derived view, regenerated on demand. No command modifies the source files. If a source file changes, regenerate the corresponding artifact by rerunning the command and choosing overwrite.

`[NEEDS CLARIFICATION]` markers in `spec.md` are surfaced as open product questions in the generated output, never silently resolved.

## Install

There are three install paths, in order of recommendation.

### Path 1: Catalog (recommended once a release exists)

```bash
specify extension add product
```

This resolves the latest release zip from the catalog at `https://github.com/d0whc3r/spec-kit-product/blob/main/catalog.json` and installs it into `.specify/extensions/product/`.

### Path 2: Direct release URL

```bash
specify extension add product --from https://github.com/d0whc3r/spec-kit-product/releases/download/v0.1.1/product-0.1.1.zip
```

Use this when you need a specific version, or before the catalog has been updated.

### Path 3: Developer install (local clone)

```bash
git clone https://github.com/d0whc3r/spec-kit-product.git
cd spec-kit-product
specify extension add --dev "$(pwd)"
```

The repo root IS the extension root in the canonical Spec Kit layout, so `--dev` points directly at the cloned directory. Use this when you are iterating on the extension itself, or when you need to run the command before any release exists. The CLI registers the extension under `.specify/extensions/product/` of the target project and adds an entry under `.specify/extensions/.registry`.

### Manual copy fallback (advanced)

If you cannot use the CLI, unpack the release zip and copy its contents into `.specify/extensions/product/` in your project. Then add a `product` entry to `.specify/extensions/.registry` matching the schema used by other installed extensions. The CLI install path is preferred; this is a break glass option.

## Invoke

After install, all four commands are available. Each reads the active feature pointer at `.specify/feature.json` and writes into the `product/` subfolder of that feature directory.

```text
/speckit.product.info
/speckit.product.spec
/speckit.product.plan
/speckit.product.design
```

To target a specific feature directory, pass `--feature-dir`:

```text
/speckit.product.spec --feature-dir specs/<feature-dir>
```

All generated artifacts live under a single `product/` subfolder so they can be read, exported, and shared as a self-contained bundle without dragging engineering scaffolding along. If an output file already exists, the command prompts for overwrite or abort.

## Style Rules (Summary)

The generated artifacts enforce:

1. English only.
2. No em dash character.
3. Each Use Case scenario has exactly one Given line, one When line, and one Then line, each a full sentence beginning with the keyword.
4. Mandatory sections appear in canonical order.
5. No implementation detail (no frameworks, languages, APIs, data stores, code, or file paths).
6. No AI-tell filler phrases ("delve", "tapestry", "in essence", "seamless", etc.).
7. Bullets are short (12 words or fewer).

The shared `product/checklist.md` verifies all of the above and marks items that need manual review.

## Troubleshooting

- **"feature directory not found"**: ensure `.specify/feature.json` exists and points to a real directory under `specs/`. Run `/speckit-specify` first if you have not yet created a feature.
- **"spec.md still contains template placeholders"**: open `spec.md` and replace bracketed placeholders such as `[FEATURE NAME]` with concrete content. The command refuses to run on an unfilled spec.
- **"detected non English content"**: v1 is English only. Translate the source file to English and rerun.
- **"output file already exists"**: choose overwrite to regenerate, or abort to keep the existing file untouched.
- **The slash command does not appear**: confirm `.specify/extensions/.registry` lists `product` and that the extension files are present under `.specify/extensions/product/`. Restart your assistant if needed.

---

## /speckit.product.info

`/speckit.product.info` is a sibling command to `/speckit.product.spec`. It derives a short, stakeholder-readable `product/00-info.md` from the same `spec.md`. The output is one rendered page or less, in plain English, with no implementation detail, and answers "what is changing and why" for a non-technical reader.

### Prerequisites

- Spec Kit `>=0.2.0` initialized in the current project.
- The `product` extension installed at version `>=0.0.5`.
- A feature directory under `specs/` with a populated `spec.md` (run `/speckit-specify` first if needed).

### Install or upgrade

```bash
specify extension add product
# upgrade:
specify extension upgrade product
```

After the install, both `/speckit.product.spec` and `/speckit.product.info` are available.

### Invoke

```text
/speckit.product.info
```

Run it from any working directory inside a Spec Kit project. To target a specific feature, pass the override:

```text
/speckit.product.info --feature-dir specs/<feature-dir>
```

The command writes:

- `<feature-dir>/product/00-info.md`
- `<feature-dir>/product/checklist.md` (creates if absent; updates only the `## Info` section)

The `product/` subfolder is created if it does not exist.

### Output

The generated file contains four mandatory sections in canonical order:

1. **Overview** — two to three sentences on what the feature is and why it exists.
2. **Headline** — one paragraph stating who this is for and what is changing.
3. **What is Changing** — two to five short bullets in customer-observable language.
4. **Out of Scope** — a short scannable list of what is deliberately excluded.

Optional sections appear when the source spec has relevant content:

- **Risks** — pre-mortem analysis when the spec has concrete risk signals.
- **Key Decisions** — surfaces resolved decisions and still-open questions when `spec.md` contains a `## Clarifications` section or `[NEEDS CLARIFICATION]` markers.
- **References** — external links worth surfacing to non-technical readers.

The command writes `product/00-info.md` and updates the `## Info` section of `product/checklist.md`.

`/speckit.product.info` and `/speckit.product.spec` are siblings. They both read the same `spec.md` and write into the same `product/` subfolder. Neither modifies the other's output. A common pattern is to run `/speckit.product.info` early to validate direction with stakeholders, then run `/speckit.product.spec` once direction is confirmed.

### Troubleshooting

| Symptom                                      | Likely cause                                                       | Fix                                                                                                 |
| -------------------------------------------- | ------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------- |
| `ERROR: Failed to resolve feature directory` | Running outside a Spec Kit project, or no active feature recorded. | `cd` into a project with `.specify/`, run `/speckit-specify` first, or pass `--feature-dir <path>`. |
| `[product-info] E_NO_SPEC: ...`              | Feature directory has no `spec.md`.                                | Run `/speckit-specify` to create one.                                                               |
| `[product-info] E_PLACEHOLDERS: ...`         | `spec.md` still contains unfilled template scaffolding.            | Open `spec.md` and replace the listed placeholders with real content.                               |
| `[product-info] E_LANGUAGE: ...`             | `spec.md` is not in English.                                       | Translate `spec.md` to English first. The command does not auto-translate.                          |
| `[product-info] E_USER_ABORT: ...`           | You answered "no" at the overwrite or clarification prompt.        | Re-run when ready.                                                                                  |

---

## /speckit.product.plan

`/speckit.product.plan` is a sibling command to `/speckit.product.spec` and `/speckit.product.info`. It reads the engineering `plan.md` produced by `/speckit-plan` and generates a high-level, product-oriented `product/plan.md` that answers "how are we building this?" for product managers, engineering leads, and cross-functional reviewers.

The output uses Shape Up appetite framing for phases, a NOW/NEXT/LATER delivery view, C4 container-level component descriptions, and condensed ADR (Architecture Decision Record) summaries for key decisions. Technical terms appear with a plain-language gloss on their first use. No code, no file paths, no detailed task breakdowns.

### Prerequisites

- Spec Kit `>=0.2.0` initialized in the current project.
- The `product` extension installed at version `>=0.0.5`.
- A feature directory under `specs/` with a populated `plan.md` (run `/speckit-plan` first if needed).

### Install or upgrade

```bash
specify extension add product
# upgrade:
specify extension upgrade product
```

After the install, `/speckit.product.spec`, `/speckit.product.info`, and `/speckit.product.plan` are all available.

### Invoke

```text
/speckit.product.plan
```

Run it from any working directory inside a Spec Kit project. To target a specific feature, pass the override:

```text
/speckit.product.plan --feature-dir specs/<feature-dir>
```

The command reads:

- `<feature-dir>/plan.md` (required)
- `<feature-dir>/spec.md` (optional, used for supplementary context)

The command writes:

- `<feature-dir>/product/20-plan.md`
- `<feature-dir>/product/checklist.md` (creates if absent; updates only the `## Plan` section)

The `product/` subfolder is created if it does not exist. `plan.md` and `spec.md` are never modified.

### Output

The generated file has mandatory sections and optional sections included only when the source plan has relevant content.

**Mandatory**:

1. **Summary** - what is being built, who it is for, and the main approach. No time estimates.
2. **Feature Context** - Problem, For, Change, Quality bar, Constraints.
3. **Goals** - three to six concrete observable outcomes.
4. **Out of Scope** - a short, scannable list of what is deliberately excluded.
5. **Delivery Phases** - numbered phases in source order, each with outcome bullets. No time estimates, no temporal bands (NOW/NEXT/LATER).

**Optional** (included only when the source plan has relevant content):

6. **Build Overview** - main system parts at C4 container level.
7. **Key Principles** - explicit guard rails or core rules from the plan.
8. **Key Decisions** - mini-ADR format: Context, Options considered, Decision, Consequence.
9. **Risks and Mitigations** - pre-mortem lens with probability, impact, mitigation.
10. **Divergences and Edge Cases** - scenarios that deviate from the normal flow.
11. **Validation** - observable conditions a reviewer can verify after shipping.
12. **Open Questions** - open items or marked assumptions from the plan.

### Error codes

| Code                     | Cause                                                              | Fix                                                                                              |
| ------------------------ | ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
| speckit resolution error | Running outside a Spec Kit project, or no active feature recorded. | `cd` into a project with `.specify/`, run `/speckit-plan` first, or pass `--feature-dir <path>`. |
| `E_NO_PLAN`              | Feature directory has no `plan.md`.                                | Run `/speckit-plan` to generate the engineering plan first.                                      |
| `E_PLACEHOLDERS`         | `plan.md` still contains unfilled template placeholders.           | Fill in or regenerate `plan.md` before running this command.                                     |
| `E_LANGUAGE`             | `plan.md` is not in English.                                       | Translate `plan.md` to English first. The command does not auto-translate.                       |
| `E_USER_ABORT`           | You answered "no" at the overwrite prompt.                         | Re-run when ready.                                                                               |

---

## /speckit.product.design

`/speckit.product.design` is a sibling command to `/speckit.product.spec`, `/speckit.product.info`, and `/speckit.product.plan`. It derives a technical design document `product/30-design.md` from `plan.md` and `spec.md`, aimed at tech leads and senior developers.

Unlike the product-facing `product/20-plan.md`, this document references component names, module boundaries, file-level granularity, API surface shapes, and data schemas at a conceptual level. No runnable code, no full ORM definitions, no line-by-line implementation detail.

### Prerequisites

- Spec Kit `>=0.2.0` initialized in the current project.
- The `product` extension installed at version `>=0.0.5`.
- A feature directory under `specs/` with a populated `plan.md` and `spec.md` (run `/speckit-plan` and `/speckit-specify` first if needed).

### Install or upgrade

```bash
specify extension add product
# upgrade:
specify extension upgrade product
```

After the install, all four product commands are available.

### Invoke

```text
/speckit.product.design
```

Run it from any working directory inside a Spec Kit project. To target a specific feature, pass the override:

```text
/speckit.product.design --feature-dir specs/<feature-dir>
```

The command reads:

- `<feature-dir>/plan.md` (required)
- `<feature-dir>/spec.md` (required)
- `<feature-dir>/tasks.md` (optional)
- `<feature-dir>/data-model.md` (optional)

The command writes:

- `<feature-dir>/product/30-design.md`
- `<feature-dir>/product/checklist.md` (creates if absent; updates only the `## Design` section, preserving all other sections)

### Output

The generated file has mandatory sections and optional sections included only when the source files have relevant content.

**Mandatory**:

1. **Summary** - what is being built technically, layers affected, key architectural approach.
2. **Technical Context** - current state, affected layers, technical constraints.
3. **Architectural Approach** - how the solution fits the existing architecture, C4 component level.
4. **Affected Modules** - table: module, change type, responsibility.
5. **Testing Strategy** - Unit, Integration, E2E/BDD, Observability bullets.
6. **Rollout and Migration** - strategy, data migration steps, rollback plan.

**Conditional** (present when the source has the relevant content):

7. **Data Design** - entity shapes and data flow.
8. **API Design** - request/response shapes and error cases at conceptual level.
9. **Spec Coverage** - table mapping each spec use case to its implementing component; gaps marked explicitly.

**Optional**:

10. **Key Technical Decisions** - ADR format: Context, Options considered, Decision, Consequences.
11. **Risks and Mitigations** - pre-mortem lens with probability, impact, mitigation.
12. **Open Questions** - unresolved technical decisions as single-sentence questions.

### Error codes

| Code                     | Cause                                                              | Fix                                                                                              |
| ------------------------ | ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
| speckit resolution error | Running outside a Spec Kit project, or no active feature recorded. | `cd` into a project with `.specify/`, run `/speckit-plan` first, or pass `--feature-dir <path>`. |
| `E_NO_PLAN`              | Feature directory has no `plan.md`.                                | Run `/speckit-plan` to generate the engineering plan first.                                      |
| `E_NO_SPEC`              | Feature directory has no `spec.md`.                                | Run `/speckit-specify` to create one.                                                            |
| `E_PLACEHOLDERS`         | Source files still contain unfilled template placeholders.         | Fill in or regenerate the source files before running this command.                              |
| `E_LANGUAGE`             | Source files are not in English.                                   | Translate to English first. The command does not auto-translate.                                 |
| `E_USER_ABORT`           | You answered "no" at the overwrite prompt.                         | Re-run when ready.                                                                               |

---

## Related Files

- `commands/speckit.product.spec.md`: the `/speckit.product.spec` slash command body.
- `commands/speckit.product.info.md`: the `/speckit.product.info` slash command body.
- `commands/speckit.product.plan.md`: the `/speckit.product.plan` slash command body.
- `commands/speckit.product.design.md`: the `/speckit.product.design` slash command body.
- `templates/product-spec-template.md`: the canonical output template for `/speckit.product.spec`.
- `templates/product-checklist-template.md`: the canonical quality checklist template.
- `templates/product-info-template.md`: the canonical output template for `/speckit.product.info`.
- `templates/product-plan-template.md`: the canonical output template for `/speckit.product.plan`.
- `templates/product-design-template.md`: the canonical output template for `/speckit.product.design`.

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for repo layout, developer install, and the release pipeline.

## License

MIT. See `LICENSE`.
