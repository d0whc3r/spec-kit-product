# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Runtime surface**: Markdown only (no executable code per constitution §I)
**Authoring tooling**: pnpm@11.1.1, oxfmt (`pnpm lint`, `pnpm fix`), semantic-release
**Command files touched**: [list under `commands/speckit.product.*.md`, or N/A]
**Template files touched**: [list under `templates/product-*-template.md`, or N/A]
**Manifests touched**: [list of `.specify/integrations/*.manifest.json` and `extension.yml`, `catalog.json`]
**Mirror surfaces touched**: [`.claude/skills/...`, `.github/agents/...`, `.github/prompts/...`]
**Project type**: Spec Kit extension (markdown)
**Style invariants**: no em dashes, plain English, PRFAQ + JTBD + Gherkin + Lean PRD conventions, `[NEEDS CLARIFICATION]` preserved

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

[Gates determined based on constitution file]

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
commands/                       Public command surface
└── speckit.product.<verb>.md   New or modified command (one file per command)

templates/                      Output templates
└── product-<artifact>-template.md   Template consumed by the command

.specify/integrations/          Integration manifests (must list every command)
├── claude.manifest.json
├── copilot.manifest.json
├── codex.manifest.json
└── speckit.manifest.json

.claude/skills/<skill-slug>/SKILL.md     Claude mirror
.github/agents/<name>.agent.md           Copilot agent mirror
.github/prompts/<name>.prompt.md         Copilot prompt mirror

extension.yml                   Extension manifest (provides.commands)
catalog.json                    Catalog entry (provides.commands count)
```

**Structure Decision**: This repository is a Spec Kit extension. New features
add or modify a command triple (command file + template + manifest entry) and
**MUST** mirror across all four agent integration surfaces. No new top-level
directories.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
