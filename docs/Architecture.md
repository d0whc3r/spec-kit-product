# Architecture

How the extension is structured, how it ships, and how the four agent
surfaces stay in sync.

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
├── .claude/skills/               Claude Code mirror surface
├── .github/agents/               GitHub Copilot agent mirror
├── .github/prompts/              GitHub Copilot prompt mirror
├── .specify/integrations/        per-agent manifests
│   ├── claude.manifest.json
│   ├── copilot.manifest.json
│   ├── codex.manifest.json
│   └── speckit.manifest.json
├── .github/workflows/            tag-driven release pipeline
├── .github/scripts/              pipeline helpers
└── docs/                         this wiki
```

`commands/speckit.<area>.<verb>.md` is canonical. Mirrors derive from it
and must not diverge in intent.

## Agent boundaries

This extension's command surface is mirrored across four integration
surfaces (constitution §V). Every public command exists in all four:

| Agent          | Surface                                                                | Manifest                                      |
| -------------- | ---------------------------------------------------------------------- | --------------------------------------------- |
| Claude Code    | `.claude/skills/<skill-slug>/SKILL.md`                                 | `.specify/integrations/claude.manifest.json`  |
| GitHub Copilot | `.github/agents/<name>.agent.md` and `.github/prompts/<name>.prompt.md` | `.specify/integrations/copilot.manifest.json` |
| OpenAI Codex   | manifest-only, no per-skill file                                       | `.specify/integrations/codex.manifest.json`   |
| Spec Kit core  | `commands/speckit.<area>.<verb>.md` (canonical)                        | `.specify/integrations/speckit.manifest.json` |

Rules:

1. The canonical command lives in `commands/`. Mirrors are deployed copies.
2. Adding a command requires updating the canonical file, all four
   manifests, every mirror surface, `extension.yml` `provides.commands`,
   and `catalog.json` `provides.commands` count.
3. Renaming or removing a command is a breaking change. The commit must
   start with `feat!:` or contain `BREAKING CHANGE:` per the constitution.

## How the extension is invoked

```
User types /speckit.product.spec in the host agent
        ↓
Host agent resolves the slash command to a markdown prompt
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

No subprocess, no compiled code, no daemon. The whole extension is markdown
prompts and YAML manifests. The host AI agent does all the work, guided by
the prompts and constrained by the templates.

## Source of truth contract

`spec.md` and `plan.md` are canonical. Everything in `product/` is a
derived view, regenerated on demand by rerunning the matching command and
choosing overwrite. No command modifies the source files.

`[NEEDS CLARIFICATION]` markers in `spec.md` are surfaced as open product
questions in the generated output, never silently resolved. This is a
constitution-level rule and the checklist enforces it.

## Hooks

The extension declares three Spec Kit hooks in `extension.yml`. They run
optionally after the matching Spec Kit core command:

| Hook              | Triggers after        | Suggested command         |
| ----------------- | --------------------- | ------------------------- |
| `after_specify`   | `/speckit-specify`    | `/speckit.product.spec`   |
| `after_clarify`   | `/speckit-clarify`    | `/speckit.product.spec`   |
| `after_plan`      | `/speckit-plan`       | `/speckit.product.plan`   |

All three are `optional: true`. The host agent prompts the user before
running them. Users can decline; the source files remain unchanged either
way.

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
@semantic-release/exec → submit-catalog-update.sh
    files [Extension Submission] issue at github/spec-kit
    (skipped when UPSTREAM_SUBMIT_TOKEN is unset)
    ↓
@semantic-release/git commits chore(release): catalog v<version>
    as github-actions[bot] with CHANGELOG.md, extension.yml, catalog.json, README.md
    ↓
@semantic-release/github creates tag v<version>, publishes Release,
    attaches product-<version>.zip
```

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
- **§V Agent boundaries**: every public command exists in all four
  integration surfaces, mirrors derive from the canonical file.
- **§Governance**: renames and removals are breaking changes.

If you change a style rule, update the templates, the checklist template,
the relevant command prompt, and the lint script in the same commit.
