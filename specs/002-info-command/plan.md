# Implementation Plan: Product Info Command

**Branch**: `002-info-command` | **Date**: 2026-05-04 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-info-command/spec.md`

## Summary

Extend the existing `product` extension with a second user-facing command, `/speckit-product-info`, that derives a short, stakeholder-readable `product-info.md` from the same `spec.md` already consumed by `/speckit-product-spec`. The new command is a smaller sibling of `/speckit-product-spec`. It produces a single-page summary that answers "what is changing and why", and nothing more. The artifact is intentionally simple and basic, so a non-technical reader can understand the proposed change in under a minute and decide whether the full spec or the full product-spec is worth their time.

The command reuses the extension's existing scripts, refusal codes, atomic-write rules, idempotence rules, packaging conventions, and writing rules. Output style follows the same hard rules already enforced for `product-spec.md`: English only, no em dash, plain English, active voice, full sentences, no implementation detail, and no AI-tell filler such as "delve", "tapestry", or "in essence". The simple pattern for the body is fixed at four sections (Headline, What is changing, Why now, Out of scope), each one short and self-contained, plus an optional Open questions block for surfaced clarification markers.

Distribution piggybacks on the existing release pipeline. The new command file and the new template are added to the canonical extension source at the repository root (`commands/`, `templates/`), the manifest is updated to advertise the new command, the manifest validator is updated to require the new files, and the content linter is updated to enforce the writing rules on the new template. No new release pipeline, no new extension, no new top-level Spec Kit command.

## Technical Context

**Language/Version**: Markdown command files (slash commands), Bash 4 plus, PowerShell 5 plus. No new runtime. Existing pipeline in YAML (GitHub Actions) plus existing validation and lint scripts updated in place.
**Primary Dependencies**: Spec Kit (greater than or equal to 0.2.0), Git (optional at install time, required for release), the host AI assistant (Claude Code, Copilot, etc.) for natural language generation, GitHub (release hosting). All already in use by the `product` extension.
**Storage**: Plain files inside the existing `product/` subfolder of the feature directory (`product/product-info.md`). The folder is created by the command if it does not exist. Distribution artifacts live in the same GitHub Releases used by `/speckit-product-spec`.
**Testing**: Manual smoke test against a known good `spec.md`; checklist-based acceptance review of generated output (a paired `product/info-checklist.md` is NOT introduced in v1, see Structure Decision item 6); pipeline self-tests (manifest validation including the new file list, content lint including the new template, tag-version match) on every tag push.
**Target Platform**: Any environment where Spec Kit runs (macOS, Linux, Windows). Cross-platform via the existing parallel Bash and PowerShell helper scripts. Pipeline still runs on `ubuntu-latest`.
**Project Type**: Spec Kit extension (markdown command files plus shared shell helpers plus templates) packaged as a GitHub release zip. Same project type as the existing `product` extension.
**Performance Goals**: First generation under 60 seconds wall-clock (per SC-001). End-to-end install still under 3 minutes (inherited from `/speckit-product-spec`). Catalog still updated within 5 minutes of release.
**Constraints**: No new runtime dependencies. No new lifecycle hooks in v1 (per Assumptions in spec). Output language matches source spec language. The version in `extension.yml` MUST equal the git tag without the `v` prefix. The new command MUST NOT modify `spec.md`, `plan.md`, `tasks.md`, `product-spec.md`, or any sibling feature.
**Scale/Scope**: One additional command, one additional template, one updated manifest, one updated validator, one updated linter, one updated README. No new pipeline file. No new catalog entry (the catalog points at the extension as a whole, not per command).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The project constitution at `.specify/memory/constitution.md` is still the unmodified template (placeholders, no ratified principles). There are no concrete principles to gate against. **Result: PASS** by default. If the constitution is ratified later, this plan must be re-checked against it before implementation.

## Writing rules for the generated product-info.md

These rules are inherited verbatim from `/speckit-product-spec` and pinned here so that the command body, the template, and the linter can enforce them consistently. The user explicitly asked for human, 100 percent natural prose, with no AI tells.

1. **English only.** All output is in English. The output language matches the source `spec.md`. If `spec.md` is not in English, the command refuses with `E_LANGUAGE` rather than translating.
2. **No em dash.** The character `—` MUST NOT appear in `product-info.md`. Use commas, parentheses, colons, semicolons, or sentence breaks. Hyphens (`-`) are allowed.
3. **Plain English.** Active voice, short sentences, human tone.
4. **No AI tells.** The following words and phrases are banned: "delve", "tapestry", "in essence", "navigate the landscape", "leverage" (as a verb on its own without a concrete object), "robust" (without a measurable target), "seamless", "intuitive". The list mirrors the existing rule for `/speckit-product-spec` and is enforced in the same place.
5. **No implementation detail.** No frameworks, languages, APIs, data stores, code, or file paths. The single allowed file path is the link to `../spec.md` in the metadata block.
6. **Bullets are short. Prose is full sentences.**

## Simple pattern for product-info.md

The body of `product-info.md` is fixed at four mandatory sections, plus header metadata, plus an optional Open questions block. The pattern is deliberately simple: a reader who has never seen the project can understand the change in under a minute, and a writer who is not a product manager can fill it in without referring to a longer style guide.

```text
# Product Info: [FEATURE NAME]

**Feature**: [###-feature-name]
**Source Spec**: [spec.md](../spec.md)
**Created**: YYYY-MM-DD
**Status**: Draft

## 1. Headline
One paragraph, two to four sentences, in plain language. State who this is for, what is changing for them, and the new outcome they can reach. No internal jargon, no feature lists, no implementation detail.

## 2. What is Changing
Two to five short bullet points or one short paragraph. State, in customer observable language, what is different after this ships compared to today. Each point is a single sentence ending with a period.

## 3. Why Now
Two to four short sentences. State the trigger (what changed in the user's world, the market, or the company) that makes this the right thing to address now rather than later.

## 4. Out of Scope
A short scannable list of what is explicitly not included, even though a reasonable reader might expect it. Always populate it. If it feels empty, think harder. Each item is one short sentence with a one phrase reason.

## 5. Open Questions (optional)
Included if and only if the source spec contains [NEEDS CLARIFICATION] markers and the user confirmed at the prompt. Each marker becomes one bullet, surfaced verbatim or rephrased to a single sentence question. Never silently resolved.
```

The pattern is shipped as `templates/product-info-template.md`. The command body reads it verbatim and substitutes the bracketed placeholders. The command MUST NOT invent additional sections or reorder existing ones, matching the rule already in place for `/speckit-product-spec`.

## Project Structure

### Documentation (this feature)

```text
specs/002-info-command/
├── plan.md                              # This file
├── spec.md                              # Already created by /speckit-specify
├── research.md                          # Phase 0 output (created below)
├── data-model.md                        # Phase 1 output (created below)
├── quickstart.md                        # Phase 1 output (created below)
├── contracts/                           # Phase 1 output
│   ├── command-contract.md              # /speckit-product-info command contract
│   └── product-info-template.md         # Canonical template (THE deliverable)
├── checklists/
│   └── requirements.md                  # Already created by /speckit-specify
└── tasks.md                             # Phase 2 output (created later by /speckit-tasks)
```

### Source Code (repository root)

The repository continues to play two roles. It is the source of truth for the `product` extension, and it dogfoods the extension on its own specs. This feature only adds files inside the layout that already exists; it does not introduce a new top-level directory.

```text
extension.yml                            # Updated: advertise speckit.product.info under provides.commands
README.md                                # Updated: install and invoke instructions for the new command
CHANGELOG.md                             # Updated on release: new entry for the version that ships /speckit-product-info

commands/
├── speckit.product.spec.md              # Existing, unchanged
└── speckit.product.info.md              # NEW: command body for /speckit-product-info

templates/
├── product-spec-template.md             # Existing, unchanged
├── product-checklist-template.md        # Existing, unchanged
└── product-info-template.md             # NEW: canonical four-section skeleton

scripts/
├── bash/
│   └── resolve-feature-dir.sh           # Existing, reused as is
└── powershell/
    └── resolve-feature-dir.ps1          # Existing, reused as is

.github/
├── scripts/
│   ├── validate-manifest.sh             # Updated: add new required files to the REQUIRED list
│   ├── lint-content.sh                  # Updated: also lint the new template (no em dash, headings in order)
│   ├── build-zip.sh                     # Existing, unchanged (allowlist already covers commands/* and templates/*)
│   ├── bump-version.sh                  # Existing, unchanged
│   └── update-catalog.sh                # Existing, unchanged
└── workflows/
    ├── release.yml                      # Existing, unchanged
    └── prepare-release.yml              # Existing, unchanged

.extensionignore                         # Existing, unchanged (already excludes specs/, .github/, etc.)

catalog.json                             # Existing, unchanged at the schema level (version field auto-bumped on release)
```

**Structure Decision**:

1. **No new top-level directory.** The `product` extension already has a single canonical layout (commands, templates, scripts at the repo root). The new command and the new template fit into that layout with zero structural change. This was the explicit instruction from the user during clarification: follow the same scheme as `/speckit-product-spec`.

2. **No new pipeline.** The release pipeline already zips the repo root (minus `.extensionignore` exclusions), validates the manifest, lints content, and publishes the zip plus an updated `catalog.json`. Adding the new command file and the new template to the validator's REQUIRED list and the linter's TEMPLATE list is the only pipeline-side change. The build-zip allowlist (`commands/.*`, `templates/.*`) already covers the new files.

3. **No new helper scripts.** `resolve-feature-dir.sh` and `resolve-feature-dir.ps1` are already designed to be feature-directory resolvers, not command-specific. The new command body calls them with the same arguments and reads the same stdout payload as `/speckit-product-spec`. This matches FR-002 in the spec.

4. **Manifest update is the only public surface change.** `extension.yml` gains a second entry under `provides.commands` with name `speckit.product.info` and file `commands/speckit.product.info.md`. The `version` field is bumped (minor version, since this is a new user-facing command) by the existing `bump-version.sh` flow.

5. **Documentation update is the only README change.** The README's "Commands" or equivalent section gains a short paragraph for `/speckit-product-info`. The install command does not change.

6. **No paired checklist template in v1.** `/speckit-product-spec` ships with a paired `product-checklist-template.md` because the product spec is a long, stakeholder-facing document with many quality gates. `product-info.md` is one page. A separate quality checklist would weigh more than the artifact it audits. The five quality bullets that matter (four mandatory sections present, no em dash, no AI-tell filler, no implementation detail, header link to `../spec.md` valid) are enforced by the linter on the template and by the command body on the generated file. If reviewers later report this is insufficient, a `product-info-checklist-template.md` can be added in a follow-up release without breaking anything shipped here.

7. **No new lifecycle hooks in v1.** `.specify/extensions.yml` is not modified by this feature. `/speckit-product-spec` itself does not register hooks today, so adding hooks just for `/speckit-product-info` would be inconsistent. A user who wants automatic commits around the new command can register hooks manually after install. This matches the assumption in the spec.

## Complexity Tracking

No constitution violations. No new directories. No new pipeline. No new helper scripts. No new external dependencies. No table needed.
