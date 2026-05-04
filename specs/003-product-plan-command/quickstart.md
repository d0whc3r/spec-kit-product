# Quick Start: Product Plan Command

**Feature**: 003-product-plan-command
**Date**: 2026-05-04

---

## What this command does

`/speckit.product.plan` reads an engineering `plan.md` and produces `product/plan.md` - a high-level, product-oriented implementation plan for product managers, engineering leads, and technical stakeholders.

The generated document answers "how are we building this?" at a level that is concrete enough to be useful in a cross-functional review, but readable without engineering-specific knowledge. It uses Shape Up appetite framing for phases, a C4-inspired component overview, condensed ADR (Architecture Decision Record) summaries for key decisions, and a NOW/NEXT/LATER delivery view.

---

## Prerequisites

Before running this command:

1. The project must be a Spec Kit project (a `.specify/` directory must exist in an ancestor folder).
2. `.specify/feature.json` must point to an existing feature directory, or you must pass `--feature-dir <path>`.
3. `<feature-dir>/plan.md` must exist and be populated (run `/speckit.plan` first if it does not).
4. `plan.md` must be in English and must not contain unfilled template placeholders.

---

## Running the command

```
/speckit.product.plan
```

Or, to override the feature pointer:

```
/speckit.product.plan --feature-dir specs/my-feature
```

---

## What happens

1. The command resolves the feature directory.
2. It validates `plan.md` (existence, no placeholders, English language).
3. If `spec.md` exists, it reads it silently for supplementary context.
4. If `product/plan.md` already exists, it asks before overwriting.
5. It generates `product/plan.md` from the `product-plan-template.md` skeleton.
6. It writes the file and prints a brief status report.

---

## Output

The command writes one file:

```
<feature-dir>/product/plan.md
```

The `product/` folder is created if it does not exist.

---

## Checking the output

Open `product/plan.md` and verify:

- The Summary paragraph makes sense to a reader who has not seen the engineering plan.
- All phases from `plan.md` are represented under NOW.
- Optional sections (Component Overview, Key Technical Decisions, Risks, Open Questions) are present only when the source had relevant content.
- No code, no file paths (except the `../plan.md` link in the header).
- Technical terms carry a plain-language gloss on first use.

---

## Error codes

| Code | Meaning | Fix |
|---|---|---|
| `E_NO_PROJECT` | No `.specify/` ancestor found | Run from inside a Spec Kit project |
| `E_NO_PLAN` | `plan.md` does not exist | Run `/speckit.plan` first |
| `E_PLACEHOLDERS` | `plan.md` has unfilled placeholders | Fill in or regenerate `plan.md` |
| `E_LANGUAGE` | `plan.md` is not in English | Provide an English plan.md |
| `E_USER_ABORT` | You answered `no` to the overwrite prompt | Re-run and answer `yes` to overwrite |

---

## Relationship to other product commands

| Command | Source | Output | Audience |
|---|---|---|---|
| `/speckit.product.spec` | `spec.md` | `product/spec.md` | Product stakeholders, leadership |
| `/speckit.product.info` | `spec.md` | `product/info.md` | Non-technical readers, quick context |
| `/speckit.product.plan` | `plan.md` (+ optional `spec.md`) | `product/plan.md` | Product managers, engineering leads, cross-functional reviews |

The three commands are independent. You can run them in any order. They share the `product/` subfolder but do not overwrite each other's files.
