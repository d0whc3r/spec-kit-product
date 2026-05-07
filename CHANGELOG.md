# Changelog

All notable changes to the Product Spec Extension are documented in this file.

The format follows Keep a Changelog. The project adheres to Semantic Versioning.

## [Unreleased]

### Added

- (none yet)

## [0.0.5] - 2026-05-07

### Added

- `speckit.product.spec` command: derives a product-oriented `product/10-spec.md` from `spec.md` following Amazon Working Backwards (PRFAQ), Jobs to Be Done, Gherkin BDD, and Lean PRD conventions.
- `speckit.product.info` command: derives a short stakeholder-readable `product/00-info.md` from `spec.md` in plain English (Headline, What is Changing, Why Now, Out of Scope).
- `speckit.product.plan` command: derives a high-level product-oriented `product/20-plan.md` from `plan.md` using phase-based breakdown, C4 component descriptions, condensed ADR summaries, and risk-and-mitigation pairs.
- `speckit.product.design` command: derives a technical design document `product/30-design.md` from `plan.md` and `spec.md` covering architectural approach, module boundaries, data model and API shapes, spec coverage mapping, and rollout plan.
- Shared `product/checklist.md` updated incrementally by each command; each command writes only its own section.
- Artifact filenames use ordering prefixes (`00-`, `10-`, `20-`, `30-`) for consistent sort order in the `product/` subfolder.
- GitHub Actions release pipeline: validates manifest, lints content, builds deterministic release zip, publishes GitHub Release, and updates `catalog.json`.
