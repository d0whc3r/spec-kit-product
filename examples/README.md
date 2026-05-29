# Examples

Real, end to end examples generated with Spec Kit core and this extension. Each
example folder holds the **inputs** (`spec.md`, `plan.md`, and the artifacts
`/speckit.plan` produces) and the **outputs** the four `/speckit.product.*`
commands wrote under `product/`. Nothing here is hand written: every file was
produced by running the commands below on a real feature description.

Use these to see exactly what each command reads and what it generates before
you run it on your own feature.

## Layout

```
examples/
└── api-rate-limiting/          one worked feature
    ├── spec.md                 /speckit.specify        (read by info, spec, plan, design)
    ├── plan.md                 /speckit.plan           (read by plan, design)
    ├── research.md             /speckit.plan, Phase 0
    ├── data-model.md           /speckit.plan, Phase 1  (read by design)
    ├── quickstart.md           /speckit.plan, Phase 1
    └── product/                this extension's output
        ├── 00-info.md          /speckit.product.info
        ├── 10-spec.md          /speckit.product.spec
        ├── 20-plan.md          /speckit.product.plan
        ├── 30-design.md        /speckit.product.design
        └── checklist.md        shared, updated by all four
```

## Which inputs each command reads

| Command                   | Reads                                          | Writes                 |
| ------------------------- | ---------------------------------------------- | ---------------------- |
| `/speckit.product.info`   | `spec.md`                                      | `product/00-info.md`   |
| `/speckit.product.spec`   | `spec.md`                                      | `product/10-spec.md`   |
| `/speckit.product.plan`   | `plan.md`, `spec.md`                           | `product/20-plan.md`   |
| `/speckit.product.design` | `plan.md`, `spec.md`, `data-model.md` (if any) | `product/30-design.md` |

`info` and `spec` only need the Spec Kit `spec.md`. `plan` and `design` also
need the engineering `plan.md`, and `design` additionally grounds its Data
Design section in `data-model.md` when one exists.

## How this example was generated

Run these in a Spec Kit project with the extension installed (see the repo
[README](../README.md) for install). Copy the generated files from
`specs/<NNN-feature>/` into the matching folder here.

```bash
# 1. Create the feature spec (Spec Kit core).
/speckit.specify Add per-tenant API rate limiting so each customer organization has a configurable monthly request quota and a per-minute burst limit, returns clear 429 responses with a Retry-After header, shows current usage in the dashboard, and lets admins raise a tenant's limit without a deploy.

# 2. Fill any [NEEDS CLARIFICATION] markers and bracketed placeholders in the
#    generated spec.md, then produce the engineering plan and its artifacts
#    (plan.md, research.md, data-model.md, quickstart.md, contracts/).
/speckit.plan

# 3. Generate the four product artifacts.
/speckit.product.info
/speckit.product.spec
/speckit.product.plan
/speckit.product.design
```

Then copy the results:

```bash
mkdir -p examples/api-rate-limiting/product
cp specs/<NNN-feature>/{spec.md,plan.md,research.md,data-model.md,quickstart.md} \
   examples/api-rate-limiting/
cp specs/<NNN-feature>/product/*.md examples/api-rate-limiting/product/
```
