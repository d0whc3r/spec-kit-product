# Architecture

How the extension is structured and how it ships.

## What the extension is

The extension has no runtime of its own: no daemon, no compiled code, no
subprocess. It ships as a release zip containing markdown prompts
(`commands/`), output templates (`templates/`), and YAML manifests
(`extension.yml`, `catalog.json`). At runtime the Spec Kit assistant
resolves a slash command, follows the prompt body, and constrains the
output to the template shape. The whole extension is text.

## Repository layout

The repo root IS the extension root, per the canonical Spec Kit extension
layout. The release pipeline packages the repo root into a zip, excluding
everything listed in `.extensionignore`.

```
spec-kit-product/
├── extension.yml                 manifest read by Spec Kit on install
├── catalog.json                  single-entry catalog the CLI resolves
├── commands/                     canonical slash command bodies
│   ├── speckit.product.info.md
│   ├── speckit.product.spec.md
│   ├── speckit.product.plan.md
│   └── speckit.product.design.md
├── templates/                    canonical output templates
│   ├── product-info-template.md
│   ├── product-spec-template.md
│   ├── product-plan-template.md
│   ├── product-design-template.md
│   └── product-checklist-template.md
├── .github/workflows/            release + wiki-sync pipelines
├── .github/scripts/              pipeline helpers
└── docs/                         the wiki source
```

`commands/speckit.<area>.<verb>.md` is canonical. Adding, renaming, or
removing one is a coordinated change: see [Contributing](Contributing.md)
for the full file list a new command must touch.

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

## Release pipeline

`.github/workflows/release.yml` runs `pnpx semantic-release` on every push
to `main`. Conventional Commits drive the next version, changelog, and tag.
The plugin chain is configured in `.releaserc.json`. The flow:

```
push to main
    ↓
release workflow fires (validate manifest, lint content, run semantic-release)
    ↓
semantic-release determines next version from Conventional Commits
    ↓
release-notes-generator + @semantic-release/changelog prepend to CHANGELOG.md
    ↓
@semantic-release/exec → semantic-release-prepare.sh
    bumps extension.yml, catalog.json (download_url + version + updated_at),
    refreshes README direct-install URL, builds dist/product-<version>.zip
    ↓
@semantic-release/git commits chore(release): catalog v<version>
    as github-actions[bot] with CHANGELOG.md, extension.yml, catalog.json, README.md
    ↓
@semantic-release/github creates tag v<version>, publishes Release,
    attaches product-<version>.zip
    ↓
release.yml step → publish-wiki action
    syncs docs/ to the GitHub wiki
    ↓
release.yml step → submit-catalog-update.sh
    files [Extension Submission] issue at github/spec-kit
    (skipped when UPSTREAM_SUBMIT_TOKEN is unset)
```

The catalog submission runs inline in `release.yml` rather than from a
`release: published` workflow because semantic-release creates the release
with the default `GITHUB_TOKEN`, which does not trigger downstream
workflows. `submit-catalog.yml` remains as a `workflow_dispatch`-only
fallback for manual reruns.

The pipeline-owned fields in `catalog.json` (`version`, `download_url`,
`requires.speckit_version`, `updated_at`, `created_at`) are updated by CI
on every release. Do not edit them by hand.

See [Contributing](Contributing.md) for the full release procedure.

## Constitution

The repo dogfoods Spec Kit. The constitution at
`.specify/memory/constitution.md` defines the rules every command must
obey. The most load-bearing ones:

- **§III Style**: no em dash, plain English, PRFAQ + JTBD + Gherkin + Lean
  PRD conventions, `[NEEDS CLARIFICATION]` markers preserved.
- **§Governance**: renames and removals are breaking changes.

If you change a style rule, update the templates, the checklist template,
the relevant command prompt, and the lint script in the same commit.
