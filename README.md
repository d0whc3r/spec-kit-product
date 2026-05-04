# Product Spec Extension for Spec Kit

A Spec Kit extension that turns a technical `spec.md` into a stakeholder facing `product/spec.md`. Output follows Amazon Working Backwards (PRFAQ), Jobs to Be Done (Ulwick), Gherkin BDD, and Lean PRD conventions, in plain English, with a strict no em dash style.

## Overview

`/speckit-specify` produces a `spec.md` that engineers can act on. Product, design, and leadership often need a different shape of the same information: a headline, a Job to Be Done, scope and out of scope, a small number of Gherkin scenarios, and measurable success metrics. This extension generates that artifact in one step, plus a quality checklist that verifies the result against the canonical structure and style.

## Source of Truth Contract

`spec.md` is the canonical artifact for the feature. `product/spec.md` is a derived view, regenerated on demand. The command never modifies `spec.md`. If `spec.md` changes, regenerate `product/spec.md` by running the command again and choosing overwrite.

`[NEEDS CLARIFICATION]` markers in `spec.md` are surfaced as open product questions in the generated `product/spec.md`, never silently resolved.

## Install

There are three install paths, in order of recommendation.

### Path 1: Catalog (recommended once a release exists)

```bash
specify extension add product
```

This resolves the latest release zip from the catalog at `https://github.com/d0whc3r/spec-kit-product/blob/main/catalog.json` and installs it into `.specify/extensions/product/`.

### Path 2: Direct release URL

```bash
specify extension add product --from https://github.com/d0whc3r/spec-kit-product/releases/download/v<version>/product-<version>.zip
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

After install, the slash command is available as:

```text
/speckit-product-spec
```

Run it from any working directory inside a Spec Kit project. The command reads the active feature pointer at `.specify/feature.json` and writes:

- `<feature-dir>/product/spec.md`
- `<feature-dir>/product/checklist.md`

All generated artifacts live under a single `product/` subfolder so they can be read, exported, and shared as a self-contained bundle without dragging engineering scaffolding along.

If `product/spec.md` already exists, the command prompts for overwrite or abort. There is no merge in v1.

## Style Rules (Summary)

The generated `product/spec.md` enforces:

1. English only.
2. No em dash character.
3. Each Use Case scenario has exactly one Given line, one When line, and one Then line, each a full sentence beginning with the keyword.
4. All mandatory sections (1 through 9) appear in the canonical order.
5. No implementation detail (no frameworks, languages, APIs, data stores, code, or file paths beyond the link to `spec.md`).

The paired `product/checklist.md` verifies all of the above.

## Troubleshooting

- **"feature directory not found"**: ensure `.specify/feature.json` exists and points to a real directory under `specs/`. Run `/speckit-specify` first if you have not yet created a feature.
- **"spec.md still contains template placeholders"**: open `spec.md` and replace bracketed placeholders such as `[FEATURE NAME]` with concrete content. The command refuses to run on an unfilled spec.
- **"detected non English content in spec.md"**: v1 is English only. Translate `spec.md` to English and rerun.
- **"product/spec.md already exists"**: choose overwrite to regenerate, or abort to keep the existing file untouched.
- **The slash command does not appear**: confirm `.specify/extensions/.registry` lists `product` and that the extension files are present under `.specify/extensions/product/`. Restart your assistant if needed.

---

## /speckit-product-info

`/speckit-product-info` is a sibling command to `/speckit-product-spec`. It derives a short, stakeholder-readable `product/info.md` from the same `spec.md`. The output is one rendered page or less, in plain English, with no implementation detail, and answers "what is changing and why" for a non-technical reader.

### Prerequisites

- Spec Kit `>=0.2.0` initialized in the current project.
- The `product` extension installed at version `>=0.2.0`.
- A feature directory under `specs/` with a populated `spec.md` (run `/speckit-specify` first if needed).

### Install or upgrade

```bash
specify extension add product
# upgrade:
specify extension upgrade product
```

After the install, both `/speckit-product-spec` and `/speckit-product-info` are available.

### Invoke

```text
/speckit-product-info
```

Run it from any working directory inside a Spec Kit project. To target a specific feature, pass the override:

```text
/speckit-product-info --feature-dir specs/<feature-dir>
```

The command writes:

- `<feature-dir>/product/info.md`

The `product/` subfolder is created if it does not exist.

### Output

The generated file contains four mandatory sections in canonical order:

1. **Headline** — one paragraph stating who this is for and what is changing.
2. **What is Changing** — two to five short bullets in customer-observable language.
3. **Why Now** — two to four short sentences explaining the trigger.
4. **Out of Scope** — a short scannable list of what is deliberately excluded.

An optional **Open Questions** section (Section 5) appears if the source spec contained `[NEEDS CLARIFICATION]` markers and the user confirmed at the prompt.

`/speckit-product-info` and `/speckit-product-spec` are siblings. They both read the same `spec.md` and write into the same `product/` subfolder. Neither modifies the other's output. A common pattern is to run `/speckit-product-info` early to validate direction with stakeholders, then run `/speckit-product-spec` once direction is confirmed.

### Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `[product-info] E_NO_PROJECT: ...` | Running outside a Spec Kit project. | `cd` into a project with `.specify/`, or run `specify init` first. |
| `[product-info] E_NO_POINTER: ...` | No active feature recorded and `--feature-dir` not passed. | Run `/speckit-specify` first, or pass `--feature-dir <path>`. |
| `[product-info] E_NO_SPEC: ...` | Feature directory has no `spec.md`. | Run `/speckit-specify` to create one. |
| `[product-info] E_PLACEHOLDERS: ...` | `spec.md` still contains unfilled template scaffolding. | Open `spec.md` and replace the listed placeholders with real content. |
| `[product-info] E_LANGUAGE: ...` | `spec.md` is not in English. | Translate `spec.md` to English first. The command does not auto-translate. |
| `[product-info] E_USER_ABORT: ...` | You answered "no" at the overwrite or clarification prompt. | Re-run when ready. |

## Related Files

- `commands/speckit.product.spec.md`: the `/speckit-product-spec` slash command body.
- `commands/speckit.product.info.md`: the `/speckit-product-info` slash command body.
- `templates/product-spec-template.md`: the canonical output template for `/speckit-product-spec`.
- `templates/product-checklist-template.md`: the canonical quality checklist template.
- `templates/product-info-template.md`: the canonical output template for `/speckit-product-info`.
- `scripts/bash/resolve-feature-dir.sh` and `scripts/powershell/resolve-feature-dir.ps1`: cross-platform feature directory resolver.

## License

MIT. See `LICENSE`.
