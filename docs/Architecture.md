# Architecture

How the extension works when you run a command.

## What the extension is

The extension has no runtime of its own: no daemon, no compiled code, no
subprocess. It is a set of markdown prompts and output templates that the
Spec Kit assistant reads. At runtime the assistant resolves a slash
command, follows the prompt body, and constrains the output to the
template shape. The whole extension is text.

## How the extension is invoked

```
User runs /speckit.product.spec
        ↓
The slash command resolves to commands/speckit.product.spec.md
        ↓
The prompt reads:
  .specify/feature.json              active feature pointer
  specs/<feature-dir>/spec.md        source content
        ↓
The prompt fills templates/product-spec-template.md
        ↓
Output is written to:
  specs/<feature-dir>/product/10-spec.md
  specs/<feature-dir>/product/checklist.md  (## Spec section updated)
```

The source files are never modified. The output goes under `product/` in
the same feature directory.

## Source of truth contract

`spec.md` and `plan.md` are canonical. Everything in `product/` is a
derived view, regenerated on demand by rerunning the matching command and
choosing overwrite. No command modifies the source files.

`[NEEDS CLARIFICATION]` markers in `spec.md` are surfaced as open product
questions in the generated output, never silently resolved. This is a
constitution-level rule and the checklist enforces it.

## Hooks

The extension declares three hook handlers in `extension.yml`, one per Spec
Kit hook event. Each handler runs optionally after the matching Spec Kit
core command:

| Hook            | Triggers after     | Command                 |
| --------------- | ------------------ | ----------------------- |
| `after_specify` | `/speckit.specify` | `/speckit.product.info` |
| `after_clarify` | `/speckit.clarify` | `/speckit.product.info` |
| `after_plan`    | `/speckit.plan`    | `/speckit.product.plan` |

Each hook is `optional: true`. The host agent prompts before the handler
runs and the user can decline; source files remain unchanged either way.
The hook surfaces the lightest stakeholder artifact for each event; richer
artifacts (`/speckit.product.spec`, `/speckit.product.design`) are produced
on demand by running the matching command.
