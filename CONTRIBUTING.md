# Contributing to the Product Spec Extension

Thanks for considering a contribution. This repository hosts a single Spec Kit extension (`product`) that ships as a release zip and a catalog entry.

## Repo Layout

The repo root IS the extension root, per the canonical Spec Kit extension layout. The release pipeline packages the repo root into a zip, excluding everything listed in `.extensionignore`.

- `extension.yml`, `README.md`, `LICENSE`, `CHANGELOG.md` at the repo root.
- `commands/`, `templates/`, `scripts/{bash,powershell}/` at the repo root.
- `.extensionignore` lists files at the root that are NOT part of the extension (specs, CI, repo metadata).
- `catalog.json` is the single-entry catalog file. Pipeline-owned fields (`version`, `download_url`, `requires.speckit_version`, `updated_at`, `created_at`) are updated by CI on every release; do not edit them by hand.
- `.github/workflows/release.yml` is the tag-driven release pipeline.
- `.github/scripts/` holds pipeline helpers (`validate-manifest.mjs`, `build-zip.mjs`, `update-catalog.sh`, `lint-content.mjs`).
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
node .github/scripts/validate-manifest.mjs
node .github/scripts/lint-content.mjs
```

To exercise the build path locally (requires `zip` and `unzip`):

```bash
node .github/scripts/build-zip.mjs
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
   - Run `.github/scripts/semantic-release-prepare.mjs <version>` to bump `extension.yml`, refresh the README direct-install URL, and update `catalog.json`.
   - Run `.github/scripts/submit-catalog-update.mjs` to render the `[Extension Submission]` document, uploaded as the `upstream-catalog-issue` artifact for manual filing at `github/spec-kit` (see **Community Catalog Submission** below).
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

The release pipeline keeps the community catalog at `github/spec-kit` in sync by preparing a submission issue for each release. Filing it is manual: automatic `gh issue create` against the upstream repo proved unreliable, so CI renders the issue as a document and you file it by hand.

**What runs on each release:**

`.github/scripts/submit-catalog-update.mjs` queries the upstream `catalog.community.json`. If `product` is present the document targets `[Extension]: Update Product Spec Extension to vX.Y.Z`; if absent it targets `[Extension]: Add Product Spec Extension`. The rendered markdown is uploaded as the `upstream-catalog-issue` workflow artifact, retained for 7 days. No token is required.

**Filing the issue:**

1. Open the finished `release` run in Actions and download the `upstream-catalog-issue` artifact.
2. Follow the **How to file this issue** steps at the top of the document: open the [Extension Submission form](https://github.com/github/spec-kit/issues/new?template=extension_submission.yml), set the title, and copy each form field from the document's **Issue body** section.

To regenerate the document for an already-released tag, run the script locally with that tag (see below). There is no manual CI trigger; the document is only produced automatically by the `release` workflow.

To rehearse locally:

```bash
VERSION=<x.y.z>  # replace with the version you want to rehearse
GITHUB_REPOSITORY=d0whc3r/spec-kit-product OUTPUT_FILE=/tmp/issue.md \
  node .github/scripts/submit-catalog-update.mjs "$VERSION" patch "v${VERSION}"
cat /tmp/issue.md
```

## Publishing the Documentation Wiki

The user-facing docs live in `docs/` and are published to the project's
GitHub Wiki. The wiki is a separate git repo at
`https://github.com/d0whc3r/spec-kit-product.wiki.git`. GitHub renders
`_Sidebar.md` and `_Footer.md` as navigation chrome, and wiki pages are
flat (no nested folders).

**Automatic sync.** `.github/workflows/sync-wiki.yml` runs
`.github/scripts/stage-wiki.mjs` to stage `docs/*.md` into `.wiki-staging/`,
then publishes that staging dir to the wiki on every push to `main` that
touches `docs/`. It can also be triggered manually from the Actions tab.

The staging script:

- Excludes `docs/README.md` (repo-only meta-doc).
- Strips `.md` from intra-wiki links (`[Commands](Commands.md)` ->
  `[Commands](Commands)`) since GitHub Wiki does not resolve the extension.
- Rewrites `../FILE.md` parent-dir links to absolute repo URLs so they keep
  working from the wiki.

To rehearse the staged output locally:

```bash
node .github/scripts/stage-wiki.mjs docs .wiki-staging
ls .wiki-staging/
```

GitHub does not create the `.wiki.git` repo until the wiki has at least one
page. Before the first sync, enable Wikis under Settings -> Features, then
create any placeholder page from the UI. After that the workflow can push
unattended.

Keep `docs/` strictly user-facing (how to use the extension and how it
works). Contributor and tooling topics belong in this file, not the wiki.
The `maintain-docs` skill under `.agents/skills/` enforces that split.

## Branch Naming

Use feature branches named `NNN-short-description` (sequential numbering, matching the pattern under `specs/`). The bundled `git` extension's `before_specify` hook creates these automatically when you run `/speckit.specify`.

## Style Rules for Generated Output

The extension's whole reason to exist is the canonical product spec voice. Style rules are pinned in `templates/product-spec-template.md` and enforced by `.github/scripts/lint-content.mjs`:

1. English only.
2. No em dash character.
3. Each Use Case scenario has exactly one Given line, one When line, and one Then line, each a full sentence beginning with the keyword.
4. Mandatory sections in canonical order; optional sections only when populated.
5. No implementation detail.

If you change these rules, update the template, the checklist template, the command prompt, and the lint script in the same commit.

The AI-tell banlist has one source: `templates/humanization-guide.md`, section "The enforced minimum". Each product command copies that subset verbatim in two places, the Plain English style rule and the "No AI tells" validation row. `lint:content` (`lintHumanization`) fails when a command drifts from the guide or its siblings, or when a command body contains an em dash. To change the banlist, edit the guide's "The enforced minimum" block and re-copy it into all four commands in the same commit.

## Reporting Issues

Open a GitHub issue with: the extension version (`grep version extension.yml`), the Spec Kit version, the slash command invocation, and the resulting refusal code or the diff between actual and expected output.
