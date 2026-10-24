# Getting Started

Five minutes from zero to a generated product artifact.

## Prerequisites

- Spec Kit `>= 0.12.17` initialized in your project. Verify with:
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

Install a release from its download URL:

```bash
specify extension add product --from \
  https://github.com/d0whc3r/spec-kit-product/releases/download/v2.2.0/product-2.2.0.zip
```

Spec Kit shows the source URL and asks you to confirm. Change the version in the URL to pin a different release.

Spec Kit lists the extension in its community catalog. To see the entry, run:

```bash
specify extension search product
specify extension info product
```

Install by name (`specify extension add product`) does not work. Spec Kit lists community extensions in a discovery-only catalog and does not install from it. Spec Kit also advises against setting that catalog to `install_allowed`. See [Troubleshooting](Troubleshooting.md#installation-errors).

To update later, run the install command with a newer release URL and add `--force`:

```bash
specify extension add product --from <newer-release-zip-url> --force
```

Confirm install:

```bash
cat .specify/extensions/.registry        # 'product' entry should be present
ls .specify/extensions/product           # extension files present
```

After install, the commands are available in your host agent. Their names depend on how the agent loads Spec Kit commands:

| Host agent                                           | Command                  |
| ---------------------------------------------------- | ------------------------ |
| Agents that load commands as files                   | `/speckit.product.brief` |
| Skills-based agents, such as Claude Code and Copilot | `/speckit-product-brief` |
| Codex with skills                                    | `$speckit-product-brief` |

These docs use the dot form, `/speckit.product.brief`. The same rule applies to `plan`, `design`, and the core commands, for example `/speckit-specify`.

## Step 2: Create a feature

If you do not already have a feature, run the Spec Kit core command first:

```text
/speckit.specify
```

Fill in the generated `spec.md`. Replace every `[PLACEHOLDER]` with real
content. The product commands refuse to run on an unfilled spec.

## Step 3: Generate your first artifacts

Run `/speckit.product.brief` first. It reads the active feature's `spec.md` and
generates the two entry artifacts in a single pass:

```text
/speckit.product.brief
```

This writes:

- `specs/<feature-dir>/product/00-info.md`, the one-page non-technical digest.
- `specs/<feature-dir>/product/10-spec.md`, the full product spec following
  Working Backwards (PRFAQ), Jobs to Be Done, Gherkin BDD, and Lean PRD
  conventions.
- `specs/<feature-dir>/product/checklist.md`.

Open `00-info.md` first. It is one rendered page or less, written for any
stakeholder, with no implementation detail. Then read `10-spec.md` for the
structured detail. Walk the relevant sections of `product/checklist.md` after
generation; any failed Required item means the output should be regenerated. If
something looks wrong, edit `spec.md` and rerun the command. The extension never
modifies the source.

## Step 4: Generate plan and design artifacts

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
/speckit.product.brief --feature-dir specs/002-some-other-feature
```

## What next

- Skim [Commands](Commands.md) for the full reference of each command.
- Read [Examples](Examples.md) to see a real `spec.md` and the four artifacts
  it produces.
- Read [Style Guide](Style-Guide.md) to understand the voice rules.
- When something refuses to run, jump to [Troubleshooting](Troubleshooting.md).
