# Changelog

All notable changes to the Product Spec Extension are documented in this file.

The format follows Keep a Changelog. The project adheres to Semantic Versioning.

## [Unreleased]

### Added

- (none yet)

## [0.0.3] - 2026-05-07

### Added

- (none yet)

## [0.0.2] - 2026-05-07

### Added

- (none yet)

## [0.0.1] - 2026-05-07

_No unreleased changes._

## [0.3.0] - TBD

### Added

- `/speckit-product-plan` slash command that derives a high-level, product-oriented `product/20-plan.md` from the engineering `plan.md`. Uses Shape Up appetite framing, NOW/NEXT/LATER delivery view, C4 container-level component descriptions, and condensed ADR summaries.
- `/speckit-product-design` slash command that derives a technical design document `product/30-design.md` from `plan.md` and `spec.md`, aimed at tech leads and senior developers. Covers architectural approach, affected modules and layers, data model and API shapes, spec coverage mapping, key technical decisions, testing strategy, and rollout plan.
- Generated artifact filenames now include ordering prefixes: `product/10-spec.md`, `product/20-plan.md`, `product/30-design.md` for consistent sort order across the `product/` subfolder.
- Optional sections (References, Glossary, Assumptions) in product-plan and product-design templates.

### Changed

- `product/checklist.md` is now a shared artifact updated incrementally by each command. Each command writes or updates only its own section, preserving sections owned by sibling commands.

## [0.2.0] - TBD

### Added

- `/speckit-product-info` slash command that derives a short, stakeholder-readable `product/info.md` from `spec.md`. Output is one rendered page or less in plain English, answering "what is changing and why" for a non-technical reader.
- Four mandatory sections in canonical order: Headline, What is Changing, Why Now, Out of Scope.
- Optional Open Questions section (Section 5) surfaced when `spec.md` contains `[NEEDS CLARIFICATION]` markers.

## [0.1.0] - TBD

### Added

- Initial release of the `product` extension.
- `/speckit-product-spec` slash command that derives a product-oriented `product/10-spec.md` from a populated `spec.md`. Output follows Amazon Working Backwards (PRFAQ), Jobs to Be Done (Ulwick), Gherkin BDD, and Lean PRD conventions.
- Canonical product spec template grounded in Working Backwards, Jobs to Be Done, Gherkin BDD, and Lean PRD.
- Canonical product spec quality checklist written to `product/checklist.md`.
- Cross-platform helper scripts (Bash and PowerShell) for resolving the active feature directory.
- GitHub Actions release pipeline that validates the manifest, lints content, builds a deterministic release zip, publishes a GitHub Release, and updates `catalog.json`.
