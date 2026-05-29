# Getting Started

Five minutes from zero to a generated product artifact.

## Prerequisites

- Spec Kit `>= 0.2.0` initialized in your project. Verify with:
  ```bash
  specify --version
  ls .specify
  ```
- A Spec Kit-aware assistant that can resolve slash commands.
- A feature directory under `specs/` with a populated `spec.md` and (for the
  `plan` and `design` commands) a populated `plan.md`.

If you do not have a Spec Kit project yet:

```bash
specify init my-project
cd my-project
```

## Step 1: Install the extension

The recommended install resolves the latest release from the catalog:

```bash
specify extension add product
```

To pin a specific version:

```bash
specify extension add product --from \
  https://github.com/d0whc3r/spec-kit-product/releases/download/v0.5.3/product-0.5.3.zip
```

Confirm install:

```bash
cat .specify/extensions/.registry        # 'product' entry should be present
ls .specify/extensions/product           # extension files present
```

## Step 2: Create a feature

If you do not already have a feature, run the Spec Kit core command first:

```text
/speckit.specify
```

Fill in the generated `spec.md`. Replace every `[PLACEHOLDER]` with real
content. The product commands refuse to run on an unfilled spec.

## Step 3: Generate your first artifact

Run the lightest command first to validate direction:

```text
/speckit.product.info
```

This reads the active feature's `spec.md` and writes:

- `specs/<feature-dir>/product/00-info.md`
- `specs/<feature-dir>/product/checklist.md`

Open `00-info.md`. It is one rendered page or less, written for any
stakeholder, with no implementation detail. If something looks wrong, edit
`spec.md` and rerun the command. The extension never modifies the source.

## Step 4: Generate the full product spec

Once direction is confirmed, run the larger command:

```text
/speckit.product.spec
```

This writes `product/10-spec.md` following Working Backwards (PRFAQ), Jobs to
Be Done, Gherkin BDD, and Lean PRD conventions. Walk the relevant section of
`product/checklist.md` after generation. Any failed Required item means the
output should be regenerated.

## Step 5: Generate plan and design artifacts

After you have a Spec Kit `plan.md` for the feature (run `/speckit.plan` from
core), you can generate the engineering and technical views:

```text
/speckit.product.plan      # writes product/20-plan.md
/speckit.product.design    # writes product/30-design.md
```

The four files together form a self-contained `product/` bundle. Share that
folder with PMs, leadership, designers, or engineering leads without dragging
engineering scaffolding along.

## Targeting a specific feature

By default each command reads the active feature pointer at
`.specify/feature.json`. To override:

```text
/speckit.product.info --feature-dir specs/002-some-other-feature
```

## What next

- Skim [Commands](Commands.md) for the full reference of each command.
- Read [Examples](Examples.md) to see a real `spec.md` and the four artifacts
  it produces.
- Read [Style Guide](Style-Guide.md) to understand the voice rules.
- When something refuses to run, jump to [Troubleshooting](Troubleshooting.md).
