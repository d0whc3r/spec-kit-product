# Contributing to the Product Spec Extension

Thanks for considering a contribution. This repository hosts a single Spec Kit extension (`product`) that ships as a release zip and a catalog entry.

## Repo Layout

- `extension/` is the canonical extension source. The release pipeline zips this subtree and only this subtree.
- `catalog.json` (repo root) is the single-entry catalog file. Pipeline-owned fields (`version`, `download_url`, `requires.speckit_version`, `updated_at`, `created_at`) are updated by CI on every release; do not edit them by hand.
- `.github/workflows/release.yml` is the tag-driven release pipeline.
- `scripts/` holds repo-level pipeline helpers (`validate-manifest.sh`, `build-zip.sh`, `update-catalog.sh`, `lint-content.sh`).
- `specs/` holds the design artifacts for the extension itself (this repo dogfoods Spec Kit).
- `.specify/extensions/product` is a symlink to `extension/` so the extension is self-installed in this repo for dogfooding.

## Developer Install (Self-Dogfood)

This repo already self-installs the extension via the symlink at `.specify/extensions/product -> ../../extension`. If you clone fresh and the symlink is missing, recreate it from the repo root:

```bash
ln -s ../../extension .specify/extensions/product
```

## Iterating on the Slash Command

The slash command is a markdown prompt at `extension/commands/speckit.product.spec.md`. Edit it, then dogfood:

1. Run `/speckit-product-spec` against any feature in this repo or another Spec Kit project.
2. Walk the generated `product-spec.md` through `checklists/product.md`. Any failed Required item is an iteration signal on the prompt.
3. Repeat until the first generation passes the checklist on a representative spec.

When iterating on the templates (`extension/templates/*.md`), keep them in sync with the contracts under `specs/001-product-spec-extension/contracts/`. The contract files are the reviewable source of truth; the runtime files are deployed copies.

## Local Pipeline Checks

Before opening a PR, run:

```bash
bash scripts/validate-manifest.sh
bash scripts/lint-content.sh
```

To exercise the build path locally (requires `zip`, `unzip`, and `jq`):

```bash
bash scripts/build-zip.sh
ls dist/
```

## Cutting a Release

1. Bump `extension/extension.yml#extension.version` (semver).
2. Add a `## [X.Y.Z] - YYYY-MM-DD` section to `extension/CHANGELOG.md` with release notes.
3. Commit on the default branch.
4. Tag: `git tag vX.Y.Z && git push origin vX.Y.Z`.
5. The release pipeline runs the six gated jobs (validate, lint, build, publish, update catalog). If any gate fails, fix the underlying issue and retag with the next patch version. Re-tagging an already-released version is forbidden by the pipeline.

## Branch Naming

Use feature branches named `NNN-short-description` (sequential numbering, matching the pattern under `specs/`). The bundled `git` extension's `before_specify` hook creates these automatically when you run `/speckit-specify`.

## Style Rules for Generated Output

The extension's whole reason to exist is the canonical product spec voice. Style rules are pinned in `extension/templates/product-spec-template.md` and enforced by `scripts/lint-content.sh`:

1. English only.
2. No em dash character.
3. Each Use Case scenario has exactly one Given line, one When line, and one Then line, each a full sentence beginning with the keyword.
4. Mandatory sections in canonical order; optional sections only when populated.
5. No implementation detail.

If you change these rules, update the template, the checklist template, the command prompt, and the lint script in the same commit.

## Reporting Issues

Open a GitHub issue with: the extension version (`grep version extension/extension.yml`), the Spec Kit version, the slash command invocation, and the resulting refusal code or the diff between actual and expected output.
