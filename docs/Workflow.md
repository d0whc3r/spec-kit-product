# Workflow

How input flows into the three commands, what each one writes, and the order
to run them in.

## Input and output flow

```
Spec Kit core               This extension
───────────────             ─────────────────────────────────────────────

/speckit.specify ──→ spec.md ──→ /speckit.product.brief  ┬─→ product/00-info.md
                                                         └─→ product/10-spec.md

/speckit.plan ──→ plan.md ──→ /speckit.product.plan      → product/20-plan.md
                         └──→ /speckit.product.design    → product/30-design.md
                                       ↑
                         tasks.md ─────┘ (optional)
                         data-model.md ─┘ (optional)

All three also write to:   product/checklist.md
```

## Recommended order

Stop at the level of detail your audience needs. You do not need to run all
three for every feature.

```
1. /speckit.specify         (core)      creates spec.md
2. /speckit.product.brief               stakeholder digest + full product spec
   ── run /speckit.plan (core) before continuing ──
3. /speckit.product.plan                product-oriented delivery view
4. /speckit.product.design              technical design for engineers
```

`brief` needs only `spec.md`. `plan` and `design` need `plan.md`,
so run `/speckit.plan` from Spec Kit core first.

## The `product/` folder

All generated artifacts live in `product/` inside the feature directory:

```
specs/<feature-dir>/
├── spec.md                  source of truth, never modified
├── plan.md                  source of truth, never modified
├── tasks.md                 optional input to /speckit.product.design
├── data-model.md            optional input to /speckit.product.design
└── product/
    ├── 00-info.md           from /speckit.product.brief
    ├── 10-spec.md           from /speckit.product.brief
    ├── 20-plan.md           from /speckit.product.plan
    ├── 30-design.md         from /speckit.product.design
    └── checklist.md         shared, updated by all three
```

No two commands write to the same output file. Each updates a different
section of `checklist.md`, preserving the rest.

## Regenerating after the source changes

The product artifacts are derived views. When `spec.md` or `plan.md` changes:

1. Decide which derived artifacts the change affects.
2. Rerun the matching command.
3. Choose overwrite at the prompt.
4. Walk the relevant `checklist.md` section. Any failed Required item means
   regenerate again.

The source files are never touched by this extension.

## Sharing the output

The `product/` folder is self-contained. Zip it, attach it to a doc, copy
it into a Confluence page, paste the rendered markdown into a slide deck.
No engineering scaffolding needs to travel with it.

If a stakeholder asks for a PDF, you can render the markdown with any
standard tool (`pandoc`, `make-pdf`, or any markdown-to-PDF service). The
voice rules (plain English, no em dash, no implementation detail) make the
output safe to hand to non-technical readers as is.
