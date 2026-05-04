# Changelog

All notable changes to the Product Spec Extension are documented in this file.

The format follows Keep a Changelog. The project adheres to Semantic Versioning.

## [Unreleased]

### Added

- Placeholder section ready to receive v0.1.0 release notes.

## [0.1.0] - TBD

### Added

- Initial release of the `product` extension.
- `/speckit-product-spec` slash command that derives a product oriented `product-spec.md` from a populated `spec.md`.
- Canonical product spec template grounded in Working Backwards, Jobs to Be Done, Gherkin BDD, and Lean PRD.
- Canonical product spec quality checklist written to `checklists/product.md`.
- Cross platform helper scripts (Bash and PowerShell) for resolving the active feature directory.
- GitHub Actions release pipeline that validates the manifest, lints content, builds a deterministic release zip, publishes a GitHub Release, and updates `catalog.json`.
