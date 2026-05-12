# spec-kit-product Constitution

The authoritative rules for authoring, evolving, and releasing the Product Spec
Extension for Spec Kit. Every rule below traces to an existing convention in
this repository. Rules marked **NON-NEGOTIABLE** require a constitution
amendment to change.

## Core Principles

### I. Markdown-Only Extension (NON-NEGOTIABLE)

This repository ships a Spec Kit extension whose entire runtime surface is
markdown. There is no executable code beyond development tooling
(`oxfmt`, `semantic-release`). Pull requests **MUST NOT** introduce a runtime
language, build step, or compiled artifact. Tooling lives in `package.json`
and `.releaserc.json` only.

### II. Source-of-Truth Contract (NON-NEGOTIABLE)

`specs/<feature>/spec.md` and `specs/<feature>/plan.md` are canonical. Every
generated artifact in `product/` is a derived view, regenerated on demand. No
command in this extension may modify the source files. `[NEEDS CLARIFICATION]`
markers in source files are surfaced as open questions in derived output and
**MUST NEVER** be silently resolved.

### III. Style Invariants (NON-NEGOTIABLE)

All generated output and all templates obey:

- No em dashes anywhere
- Plain English, no marketing language
- Working Backwards (Amazon PRFAQ), Jobs to Be Done (Ulwick), Gherkin BDD, and
  Lean PRD conventions where the artifact calls for them
- Quality checklists are auto-validated per command and written to
  `product/checklist.md`

Style violations block release.

### IV. Command, Template, Manifest Parity

Each user-facing command exists as a triple:

1. A markdown command file at `commands/speckit.product.<verb>.md`
2. One or more templates at `templates/product-<artifact>-template.md`
3. A `provides.commands` entry in `extension.yml`

Adding, renaming, or removing a command requires updating all three plus
`catalog.json` (`provides.commands` count). CI release fails on parity drift.

### V. Multi-Agent Mirror

Every command surface is mirrored across the supported agents:

- Claude: `.claude/skills/<skill-slug>/SKILL.md` plus `.specify/integrations/claude.manifest.json`
- Copilot: `.github/agents/<name>.agent.md` and `.github/prompts/<name>.prompt.md` plus `.specify/integrations/copilot.manifest.json`
- Codex: `.specify/integrations/codex.manifest.json`
- Spec Kit core: `.specify/integrations/speckit.manifest.json`

A command is not shipped until all integration manifests list it. Manifests
are append-only between minor versions; removals require a major bump.

## Authoring Rules

### File and Directory Naming

- Commands: `speckit.<area>.<verb>.md` (lowercase, dot-separated). Examples:
  `speckit.product.spec.md`, `speckit.brownfield.scan.md`.
- Templates: `<area>-<artifact>-template.md` (kebab-case). Example:
  `product-design-template.md`.
- Skill directories: kebab-case (`speckit-product-spec`, `speckit-brownfield-bootstrap`).
- Extension subprojects: `.specify/extensions/<id>/` with `extension.yml`,
  `commands/`, optional `templates/`, `README.md`, `CHANGELOG.md`, `LICENSE`.

### Output Location Discipline

Generated artifacts for a feature go under that feature's `product/`
subfolder so the bundle is self-contained. The active feature pointer is
`.specify/feature.json`. `--feature-dir` overrides the pointer. Commands
**MUST** prompt before overwriting an existing output file.

### Reusing Existing Layout

Do not introduce new top-level directories. The canonical layout is:

```
commands/                Public command surface (.md)
templates/               Output templates (.md)
.specify/                Spec Kit configuration, extensions, integrations
.claude/                 Claude agent surface (mirror)
.github/                 Copilot agent + prompt surface (mirror), CI
extension.yml            Extension manifest
catalog.json             Public catalog entry
```

## Quality Gates

### Tooling

- Lint: `pnpm lint` (oxfmt check) **MUST** pass before commit.
- Format: `pnpm fix` (oxfmt write) is the only sanctioned formatter.
- Package manager: pnpm@11.1.1 (pinned in `package.json#packageManager`).
- Release: `semantic-release` with conventional commits; version is set by
  release automation, never hand-edited in `extension.yml` or `catalog.json`
  on a feature branch.

### Pre-Release Checklist

Before tagging a release:

1. `pnpm lint` passes
2. `extension.yml` `provides.commands` matches `commands/` directory
3. `catalog.json` `provides.commands` count matches
4. All four integration manifests list every public command
5. `CHANGELOG.md` updated by semantic-release
6. `README.md` install instructions reference the new version URL

## Governance

This constitution supersedes ad hoc conventions. Amendments require:

1. A PR that updates this file and any templates whose behavior changes
2. A `BREAKING CHANGE:` or `feat!:` commit when a NON-NEGOTIABLE rule changes
3. Migration notes in `CHANGELOG.md`

For runtime authoring guidance (style examples, JTBD framing, Gherkin
patterns), see `WORKFLOW.md` and `README.md`.

**Version**: 1.0.0 | **Ratified**: 2026-05-12 | **Last Amended**: 2026-05-12
