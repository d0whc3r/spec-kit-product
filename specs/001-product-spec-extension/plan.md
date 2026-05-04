# Implementation Plan: Product Spec Extension for Spec Kit

**Branch**: `001-product-spec-extension` | **Date**: 2026-05-04 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-product-spec-extension/spec.md`

## Summary

Build a Spec Kit extension (id `product`) that takes a populated `spec.md` produced by `/speckit-specify` and generates a sibling `product-spec.md` shaped for product stakeholders, plus a quality checklist. The extension ships as a self-contained directory under `.specify/extensions/product/` and follows the layout already established by the bundled `git` extension. The product spec template is grounded in established product methodologies (Amazon Working Backwards PRFAQ, Jobs to Be Done by Ulwick, Gherkin BDD scenarios, Lean PRD), so the output is recognizable, simple, and consistent across features. Output style rules (English, human voice, no em dash, full sentences for Given, When, Then) are enforced by the template and reinforced in the command prompt.

Distribution follows the documented Spec Kit publishing flow: the extension subtree is packaged as a GitHub release zip on every tagged release, end users install via `specify extension add product --from <zip-url>` (direct URL) or `specify extension add product` (catalog-driven), and a GitHub Actions pipeline validates the manifest, enforces tag-version equality, and publishes the release plus an updated `catalog.json`.

## Technical Context

**Language/Version**: Markdown command files (slash commands), Bash 4+, PowerShell 5+. No new runtime. Release pipeline in YAML (GitHub Actions) plus a small validation script.
**Primary Dependencies**: Spec Kit (>=0.2.0), Git (optional at install time, required for release), the host AI assistant (Claude Code, Copilot, etc.) for natural language generation, GitHub (release hosting).
**Storage**: Plain files inside the feature directory (`product-spec.md`, `checklists/product.md`). Distribution artifacts live in GitHub Releases.
**Testing**: Manual smoke test against a known good `spec.md`; checklist-based acceptance review of generated output; pipeline self-tests (manifest validation, tag-version match) on every tag push.
**Target Platform**: Any environment where Spec Kit runs (macOS, Linux, Windows). Cross-platform via parallel Bash and PowerShell helper scripts. Release pipeline runs on `ubuntu-latest`.
**Project Type**: Spec Kit extension (markdown command files plus optional shell scripts plus templates) packaged as a GitHub release zip.
**Performance Goals**: First generation under 2 minutes wall-clock (per SC-001). End-to-end install under 3 minutes (per SC-008). Catalog updated within 5 minutes of release (per SC-010).
**Constraints**: No new runtime dependencies. No automatic lifecycle hooks in v1 (per FR-011). Output language matches source spec language (per FR-013). Version in `extension.yml` MUST equal the git tag without the `v` prefix.
**Scale/Scope**: One extension, one user facing command in v1 (`/speckit-product-spec`), one canonical template, one canonical quality checklist, one release pipeline, one catalog entry.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The project constitution at `.specify/memory/constitution.md` is currently the unmodified template (placeholders, no ratified principles). There are no concrete principles to gate against. **Result: PASS** by default. If the constitution is ratified later, this plan must be re-checked against it before implementation.

## Project Structure

### Documentation (this feature)

```text
specs/001-product-spec-extension/
├── plan.md                              # This file
├── research.md                          # Phase 0 output: methodology research
├── data-model.md                        # Phase 1 output: extension entities and relationships
├── quickstart.md                        # Phase 1 output: install and first run
├── contracts/                           # Phase 1 output: stable interface contracts
│   ├── command-contract.md              # /speckit-product-spec command contract
│   ├── product-spec-template.md         # canonical product spec template (THE deliverable)
│   ├── quality-checklist.md             # canonical product quality checklist
│   ├── package-layout.md                # canonical layout of the release zip
│   ├── catalog-entry.md                 # canonical catalog.json schema for this extension
│   └── release-pipeline.md              # canonical release-pipeline contract (triggers, gates, outputs)
├── checklists/
│   └── requirements.md                  # spec quality checklist (already created)
└── tasks.md                             # Phase 2 output (created later by /speckit-tasks)
```

### Source Code (repository root)

The repository has two roles. First, it is the source of truth for the extension that gets packaged and shipped. Second, it dogfoods the extension on its own specs.

```text
extension/                               # Canonical extension source (zipped on release)
├── extension.yml                        # Manifest: id, version, provides, requires, hooks (empty)
├── README.md                            # Install (user + dev), invoke, source of truth contract
├── LICENSE                              # Required by the publishing guide
├── CHANGELOG.md                         # Recommended by the publishing guide
├── commands/
│   └── speckit.product.spec.md          # The slash command body (prompt scaffolding for the AI)
├── templates/
│   ├── product-spec-template.md         # Canonical product spec output template
│   └── product-checklist-template.md    # Canonical quality checklist template
└── scripts/                             # Optional helpers
    ├── bash/
    │   └── resolve-feature-dir.sh
    └── powershell/
        └── resolve-feature-dir.ps1

catalog.json                             # Catalog entry pointing at the latest release zip

.github/
└── workflows/
    └── release.yml                      # GitHub Actions release pipeline (tag-driven)

scripts/
└── validate-manifest.sh                 # Pipeline helper: tag/version equality + required files

.specify/extensions/product/             # Optional dev-mode mirror for self-dogfooding (symlink or copy of extension/)
```

**Structure Decision**:

1. **Single source under `extension/`**. The canonical, packaged-on-release subtree is the top-level `extension/` directory. The release pipeline zips this directory and publishes it as the GitHub Release asset, exactly as Spec Kit's publishing guide expects. Required files (`extension.yml`, `README.md`, `LICENSE`) sit at the root of `extension/` so they land at the root of the zip.

2. **Layout mirrors the bundled `git` extension**. Inside `extension/`, the structure is identical to the validated layout under `.specify/extensions/git/` in this project. This avoids inventing a new convention and keeps cross-platform parity (Bash + PowerShell scripts).

3. **Two truth tiers**. The contract files under `specs/001-product-spec-extension/contracts/` (`product-spec-template.md`, `quality-checklist.md`, `package-layout.md`, `catalog-entry.md`, `release-pipeline.md`) are the version-controlled, reviewable source of truth. The files inside `extension/templates/` are the deployed runtime copies that the command actually reads. The release pipeline is responsible for keeping them in sync (or fails the build if they diverge).

4. **Dogfooding via dev install**. To use the extension on this very repo, contributors run `specify extension add --dev <path-to-extension/>` (per FR-024) or symlink `.specify/extensions/product/` to `extension/`. Either way, the canonical source stays in one place.

5. **`catalog.json` at the repo root**. A single-entry catalog file lives at the repository root. The pipeline updates `version`, `download_url`, and `updated_at` on every release.

6. **Pipeline builds an explicit release zip, not the GitHub auto-archive**. GitHub's auto-archive of a tag zips the entire repo (which includes `specs/`, `.github/`, design docs). End users running `specify extension add ... --from <auto-archive-url>` would unpack a tree where `extension.yml` is *not* at the zip root. The pipeline therefore builds a deterministic `product-<version>.zip` from the `extension/` subtree (so `extension.yml` lands at the zip root) and uploads it as a release asset. The catalog `download_url` and the README's install command point at this explicit asset URL, not the auto-archive URL. Pipeline lives in `.github/workflows/release.yml` and triggers on tag push (`v*.*.*`). Pipeline contract is pinned in `contracts/release-pipeline.md`.

## Complexity Tracking

No constitution violations. No table needed.
