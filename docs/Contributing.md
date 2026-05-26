# Contributing

The full developer guide lives at [CONTRIBUTING.md](../CONTRIBUTING.md) in
the repo root. This page summarises the most common contributor flows.

## Set up

```bash
git clone https://github.com/d0whc3r/spec-kit-product.git
cd spec-kit-product
specify extension add --dev "$(pwd)"
```

The CLI installs the extension under `.specify/extensions/product/` of the
target project and registers it. Re-run after each manifest change.

## Iterating on a slash command

The command is a markdown prompt at `commands/speckit.product.<verb>.md`.

1. Edit the prompt.
2. Re-run the dev install if you changed the manifest.
3. Invoke the command against a feature in this repo or another Spec Kit
   project.
4. Walk the generated artifact through the relevant section of
   `product/checklist.md`. Any failed Required item is an iteration signal.
5. Repeat until first generation passes the checklist on a representative
   spec.

## Iterating on a template

`templates/product-*-template.md` and `templates/product-checklist-template.md`.
Keep them in sync with the contracts under `specs/001-product-spec-extension/contracts/`.
The contract files are the reviewable source of truth; the runtime files
are deployed copies.

## Local pipeline checks

Before opening a PR:

```bash
bash .github/scripts/validate-manifest.sh
bash .github/scripts/lint-content.sh
```

To exercise the build path (requires `zip`, `unzip`, and `jq`):

```bash
bash .github/scripts/build-zip.sh
ls dist/
```

## Releasing

Releases are automatic. The `release` workflow at
`.github/workflows/release.yml` runs `pnpx semantic-release` on every push
to `main`. Conventional Commits drive the next version, changelog, and tag.

1. Write commits using [Conventional Commits](https://www.conventionalcommits.org/):
   `fix:` bumps a patch, `feat:` bumps a minor, `feat!:` or `BREAKING CHANGE:`
   in the body bumps a major. `chore:`, `docs:`, `refactor:`, `test:`, `ci:`
   do not trigger a release.
2. Land your work on `main` with CI green. The release workflow fires on push.
3. `semantic-release` runs the plugin chain in `.releaserc.json`: determine
   the next version, prepend release notes to `CHANGELOG.md`, run
   `.github/scripts/semantic-release-prepare.sh` to bump `extension.yml`,
   `catalog.json`, and the README install URL, build the zip, commit
   `chore(release): catalog v<version>` as the release bot, tag `v<version>`,
   and publish a GitHub Release with `product-<version>.zip` attached.
4. If no commits since the last tag qualify, semantic-release exits cleanly
   and nothing is released.

Rehearse the version decision locally without publishing:

```bash
pnpm install
pnpx semantic-release --dry-run
```

Re-tagging an already-released version is not supported. Push a qualifying
commit so the next patch version is cut.

## Style coupling

If you change a style rule, update **all** of these in the same commit:

1. The relevant `templates/product-*-template.md`.
2. `templates/product-checklist-template.md`.
3. The relevant command body under `commands/speckit.product.*.md`.
4. `.github/scripts/lint-content.sh`.

This is enforced by review, not by the pipeline. See [Style Guide](Style-Guide.md).

## Adding a new command

Adding `/speckit.product.<verb>` is a five-file change minimum (per the
constitution §V agent boundaries):

1. `commands/speckit.product.<verb>.md` (canonical command).
2. `templates/product-<verb>-template.md` (output template).
3. `templates/product-checklist-template.md` (add the new section).
4. `extension.yml` `provides.commands` (add entry).
5. `catalog.json` `provides.commands` count.
6. All four manifests under `.specify/integrations/`.
7. Every mirror under `.claude/skills/` and `.github/agents/` and
   `.github/prompts/`.

Renaming or removing a command is a breaking change. Commit prefix must be
`feat!:` or the message must contain `BREAKING CHANGE:`.

## Reporting issues

| You want to           | Use                                                                                                    |
| --------------------- | ------------------------------------------------------------------------------------------------------ |
| Report a bug          | [Bug report](https://github.com/d0whc3r/spec-kit-product/issues/new?template=bug_report.yml)           |
| Request a feature     | [Feature request](https://github.com/d0whc3r/spec-kit-product/issues/new?template=feature_request.yml) |
| Propose a new command | [New command](https://github.com/d0whc3r/spec-kit-product/issues/new?template=new_command.yml)         |
| Doc problem           | [Docs issue](https://github.com/d0whc3r/spec-kit-product/issues/new?template=docs.yml)                 |
| Security              | [Private advisory](https://github.com/d0whc3r/spec-kit-product/security/advisories/new)                |
