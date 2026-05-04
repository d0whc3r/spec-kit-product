# Changelog

All notable changes to the Product Spec Extension are documented in this file.

The format follows Keep a Changelog. The project adheres to Semantic Versioning.

## [Unreleased]

### Changed

- Generated artifacts now write to `<feature-dir>/product/product-spec.md` and `<feature-dir>/product/checklist.md` instead of `<feature-dir>/product-spec.md` and `<feature-dir>/checklists/product.md`. The `product/` subfolder keeps stakeholder facing output identifiable and self contained for export and sharing.

## [0.1.0] - TBD

### Added

- Initial release of the `product` extension.
- `/speckit-product-spec` slash command that derives a product oriented `product-spec.md` from a populated `spec.md`.
- Canonical product spec template grounded in Working Backwards, Jobs to Be Done, Gherkin BDD, and Lean PRD.
- Canonical product spec quality checklist written to `product/checklist.md`.
- Cross platform helper scripts (Bash and PowerShell) for resolving the active feature directory.
- GitHub Actions release pipeline that validates the manifest, lints content, builds a deterministic release zip, publishes a GitHub Release, and updates `catalog.json`.
