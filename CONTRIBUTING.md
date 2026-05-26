# Contributing to the Product Spec Extension

Thanks for considering a contribution. This repository hosts a single Spec Kit extension (`product`) that ships as a release zip and a catalog entry.

## Repo Layout

The repo root IS the extension root, per the canonical Spec Kit extension layout. The release pipeline packages the repo root into a zip, excluding everything listed in `.extensionignore`.

- `extension.yml`, `README.md`, `LICENSE`, `CHANGELOG.md` at the repo root.
- `commands/`, `templates/`, `scripts/{bash,powershell}/` at the repo root.
- `.extensionignore` lists files at the root that are NOT part of the extension (specs, CI, repo metadata).
- `catalog.json` is the single-entry catalog file. Pipeline-owned fields (`version`, `download_url`, `requires.speckit_version`, `updated_at`, `created_at`) are updated by CI on every release; do not edit them by hand.
- `.github/workflows/release.yml` is the tag-driven release pipeline.
- `.github/scripts/` holds pipeline helpers (`validate-manifest.sh`, `build-zip.sh`, `update-catalog.sh`, `lint-content.sh`).
- `specs/` holds the design artifacts for the extension itself (this repo dogfoods Spec Kit). It is excluded from the release zip.

## Developer Install (Self-Dogfood)

To dogfood the extension on this repo or any other Spec Kit project, run from the cloned repo:

```bash
specify extension add --dev "$(pwd)"
```

The CLI installs the extension under `.specify/extensions/product/` of the target project and registers it. Re-run after each manifest change.

## Iterating on the Slash Command

The slash command is a markdown prompt at `commands/speckit.product.spec.md`. Edit it, then dogfood:

1. Run `/speckit.product.spec` against any feature in this repo or another Spec Kit project.
2. Walk the generated `product/10-spec.md` through `product/checklist.md`. Any failed Required item is an iteration signal on the prompt.
3. Repeat until the first generation passes the checklist on a representative spec.

When iterating on the templates (`templates/*.md`), keep them in sync with the contracts under `specs/001-product-spec-extension/contracts/`. The contract files are the reviewable source of truth; the runtime files are deployed copies.

## Local Pipeline Checks

Before opening a PR, run:

```bash
bash .github/scripts/validate-manifest.sh
bash .github/scripts/lint-content.sh
```

To exercise the build path locally (requires `zip`, `unzip`, and `jq`):

```bash
bash .github/scripts/build-zip.sh
ls dist/
```

## Cutting a Release

Releases are automatic. The `release` workflow at `.github/workflows/release.yml` runs `pnpx semantic-release` on every push to `main`. Conventional Commits drive the next version, changelog, and tag.

1. Write commits using [Conventional Commits](https://www.conventionalcommits.org/). Examples:
   - `fix: ...` triggers a patch bump.
   - `feat: ...` triggers a minor bump.
   - `feat!: ...` or any commit body containing `BREAKING CHANGE:` triggers a major bump.
   - `chore:`, `docs:`, `refactor:`, `test:`, `ci:` do not trigger a release.
2. Land your work on `main` with CI green. The release workflow fires on push.
3. `semantic-release` runs the plugin chain in `.releaserc.json`:
   - Determine the next version from commits since the last tag.
   - Generate release notes and prepend them to `CHANGELOG.md`.
   - Run `.github/scripts/semantic-release-prepare.sh <version>` to bump `extension.yml`, refresh the README direct-install URL, and update `catalog.json`.
   - Run `.github/scripts/submit-catalog-update.sh` to optionally file an `[Extension Submission]` issue at `github/spec-kit` (see **Community Catalog Submission** below).
   - Commit `chore(release): catalog v<version>` as `github-actions[bot]` with `CHANGELOG.md`, `extension.yml`, `catalog.json`, and `README.md`.
   - Create tag `v<version>`, publish a GitHub Release, and attach `dist/product-<version>.zip`.
4. If no commits since the last tag qualify, semantic-release exits cleanly and nothing is released. Push another qualifying commit to trigger a release.
5. To rehearse the version decision locally without publishing:
   ```bash
   pnpm install
   pnpx semantic-release --dry-run
   ```

Re-tagging an already-released version is not supported. Push a qualifying commit so the next patch version is cut.

### Community Catalog Submission

The release pipeline can auto-file submission issues at `github/spec-kit` so the community catalog stays in sync with each release. This is opt-in via a repository secret.

**One-time setup:**

1. Create a [fine-grained personal access token](https://github.com/settings/personal-access-tokens/new):
   - Resource owner: `github`
   - Repository access: only `github/spec-kit`
   - Permissions: `Issues: Read and write`
2. Add it as a repository secret named `UPSTREAM_SUBMIT_TOKEN` (Settings → Secrets and variables → Actions).
3. File the **first** submission manually via the [Extension Submission form](https://github.com/github/spec-kit/issues/new?template=extension_submission.yml). The CI handles update submissions thereafter.

**What runs on each release:**

`.github/scripts/submit-catalog-update.sh` queries the upstream `catalog.community.json`. If `product` is present it files `Update Product Spec Extension to vX.Y.Z`; if absent it files `Add Product Spec Extension`. It skips silently if `UPSTREAM_SUBMIT_TOKEN` is unset or if an open issue with the same title already exists.

To rehearse locally without filing:

```bash
VERSION=<x.y.z>  # replace with the version you want to rehearse
SUBMIT_DRY_RUN=true UPSTREAM_SUBMIT_TOKEN=dummy \
  bash .github/scripts/submit-catalog-update.sh "$VERSION" patch \
    "https://github.com/d0whc3r/spec-kit-product/releases/download/v${VERSION}/product-${VERSION}.zip"
```

## Branch Naming

Use feature branches named `NNN-short-description` (sequential numbering, matching the pattern under `specs/`). The bundled `git` extension's `before_specify` hook creates these automatically when you run `/speckit-specify`.

## Style Rules for Generated Output

The extension's whole reason to exist is the canonical product spec voice. Style rules are pinned in `templates/product-spec-template.md` and enforced by `.github/scripts/lint-content.sh`:

1. English only.
2. No em dash character.
3. Each Use Case scenario has exactly one Given line, one When line, and one Then line, each a full sentence beginning with the keyword.
4. Mandatory sections in canonical order; optional sections only when populated.
5. No implementation detail.

If you change these rules, update the template, the checklist template, the command prompt, and the lint script in the same commit.

## Reporting Issues

Open a GitHub issue with: the extension version (`grep version extension.yml`), the Spec Kit version, the slash command invocation, and the resulting refusal code or the diff between actual and expected output.
