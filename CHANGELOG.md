# Changelog

## [0.0.6](https://github.com/d0whc3r/spec-kit-product/compare/v0.0.5...v0.0.6) (2026-05-07)

### Bug Fixes

* **catalog:** add missing fields required by publishing guide ([a42c7d8](https://github.com/d0whc3r/spec-kit-product/commit/a42c7d81ede4c3344aa36e368089b306fba9da64))
* **manifest:** shorten description, add homepage, remove empty hooks ([b88e0e9](https://github.com/d0whc3r/spec-kit-product/commit/b88e0e9f6de4fd4d962491d6f6195b4386837495))

## [0.0.5] - 2026-05-07

### Added

- `speckit.product.spec` command: derives a product-oriented `product/10-spec.md` from `spec.md` following Amazon Working Backwards (PRFAQ), Jobs to Be Done, Gherkin BDD, and Lean PRD conventions.
- `speckit.product.info` command: derives a short stakeholder-readable `product/00-info.md` from `spec.md` in plain English (Headline, What is Changing, Why Now, Out of Scope).
- `speckit.product.plan` command: derives a high-level product-oriented `product/20-plan.md` from `plan.md` using phase-based breakdown, C4 component descriptions, condensed ADR summaries, and risk-and-mitigation pairs.
- `speckit.product.design` command: derives a technical design document `product/30-design.md` from `plan.md` and `spec.md` covering architectural approach, module boundaries, data model and API shapes, spec coverage mapping, and rollout plan.
- Shared `product/checklist.md` updated incrementally by each command; each command writes only its own section.
- Artifact filenames use ordering prefixes (`00-`, `10-`, `20-`, `30-`) for consistent sort order in the `product/` subfolder.
- GitHub Actions release pipeline: validates manifest, lints content, builds deterministic release zip, publishes GitHub Release, and updates `catalog.json`.
