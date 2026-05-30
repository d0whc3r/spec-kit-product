# Examples

Real, end to end examples generated with Spec Kit core and this extension. Each
example folder holds the **inputs** (`spec.md`, `plan.md`, and the artifacts
`/speckit.plan` produces) and the **outputs** the four `/speckit.product.*`
commands wrote under `product/`. Nothing here is hand written: every file was
produced by running the commands below on a real feature description.

Use these to see exactly what each command reads and what it generates before
you run it on your own feature.

## The examples

| Folder                                                                    | Feature                            | Domain                          |
| ------------------------------------------------------------------------- | ---------------------------------- | ------------------------------- |
| [`specs/001-tenant-rate-limiting/`](specs/001-tenant-rate-limiting)       | Per-tenant API rate limiting       | Infrastructure and API platform |
| [`specs/002-billing-usage-dashboard/`](specs/002-billing-usage-dashboard) | Self-serve billing usage dashboard | Customer-facing billing         |

Both folders were generated the same way (see below). They cover different
domains on purpose, so you can see how the commands behave on an API platform
feature and on a customer-facing dashboard.

## Layout

```
examples/
└── specs/
    ├── 001-tenant-rate-limiting/      per-tenant API rate limiting
    └── 002-billing-usage-dashboard/   self-serve billing usage dashboard
```

Every feature folder has the same shape:

```
<NNN-feature>/
├── spec.md                  /speckit.specify        (read by info, spec, plan, design)
├── plan.md                  /speckit.plan           (read by plan, design)
├── research.md              /speckit.plan, Phase 0
├── data-model.md            /speckit.plan, Phase 1  (read by design)
├── quickstart.md            /speckit.plan, Phase 1
├── contracts/               /speckit.plan, Phase 1  (not read by product commands)
├── checklists/
│   └── requirements.md      /speckit.specify        (not read by product commands)
└── product/                 this extension's output
    ├── 00-info.md           /speckit.product.info
    ├── 10-spec.md           /speckit.product.spec
    ├── 20-plan.md           /speckit.product.plan
    ├── 30-design.md         /speckit.product.design
    └── checklist.md         shared, updated by all four
```

The files under `contracts/` differ per feature; the rest of the shape is the
same in every example.

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

## How these examples were generated

Run these in a Spec Kit project with the extension installed (see the repo
[README](../README.md) for install). Then copy the generated
`specs/<NNN-feature>/` folder into `examples/specs/` here.

```bash
# 1. Create the feature spec (Spec Kit core).
/speckit.specify <feature description>

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

The feature description used in step 1 was:

`001-tenant-rate-limiting`

```
Add per-tenant API rate limiting so each customer organization has a configurable monthly request quota and a per-minute burst limit, returns clear 429 responses with a Retry-After header, shows current usage in the dashboard, and lets admins raise a tenant's limit without a deploy.
```

`002-billing-usage-dashboard`

```
Add a self-serve billing usage dashboard for organization admins. Admins need to see current plan, monthly usage, projected overage, invoice history, and usage by team. The dashboard should explain why charges changed and help admins avoid surprise bills. Include alerts for projected overage, exportable invoice data, and clear empty states for new customers.
```

Then copy the whole feature folder under `examples/specs/` (this pulls in the
`contracts/`, `checklists/`, and `product/` subfolders along with it):

```bash
cp -r specs/<NNN-feature> examples/specs/
```
