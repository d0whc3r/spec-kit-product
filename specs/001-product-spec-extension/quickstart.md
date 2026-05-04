# Quickstart: Product Spec Extension

**Feature**: 001-product-spec-extension
**Audience**: a Spec Kit user (product manager, product owner, founder, designer) who wants to generate a product oriented spec from an existing technical `spec.md`.

This quickstart is the smallest path from "extension not installed" to "first product spec in hand".

## Prerequisites

- A Spec Kit project (the project root contains a `.specify/` directory).
- A feature directory under `specs/` that already has a populated `spec.md`, produced by `/speckit-specify`.
- An AI assistant that runs Spec Kit slash commands (Claude Code, Copilot, or equivalent).

## Install

Three install paths are supported. All three drop the extension under `.specify/extensions/product/` and register it in `.specify/extensions/.registry`.

### Path 1: Direct URL (recommended for most users)

```bash
specify extension add product --from https://github.com/<owner>/<repo>/releases/download/v<version>/product-<version>.zip
```

Replace `<owner>`, `<repo>`, and `<version>` with the values from the latest release. The URL is also visible in the GitHub Release page as the asset download.

### Path 2: Catalog-driven (when the catalog is in scope)

```bash
specify extension add product
```

This resolves the entry from `catalog.json`, downloads the same release zip referenced in `download_url`, and installs identically to Path 1.

### Path 3: Developer install (for contributors)

```bash
specify extension add --dev <local-path-to-extension/>
```

This is the path to use when iterating on the extension itself. It bypasses the release flow and uses the source tree in place.

After any of the three paths, open the project in your AI assistant. The new slash command, `/speckit-product-spec`, will be discoverable.

## First Run

1. Open the feature directory you want a product spec for, or set `feature_directory` in `.specify/feature.json` to that directory.
2. In your AI assistant, run the command:

   ```text
   /speckit-product-spec
   ```

3. If the source spec contains `[NEEDS CLARIFICATION]` markers, you will see a warning that lists each one and asks you to confirm. On confirm, those markers are surfaced as open product questions inside the generated artifact.
4. If a `product-spec.md` already exists for this feature, you will be asked to choose **overwrite** or **abort**. Merge or refresh is not available in v1.
5. On success, you have two new files in your feature directory:

   - `product-spec.md`, the generated product spec.
   - `checklists/product.md`, the quality checklist for that spec.

## What You Get

The generated `product-spec.md` follows a fixed structure, in this order:

1. Headline (one customer facing paragraph).
2. Target users and personas.
3. Problem statement, in Jobs to Be Done form.
4. Value proposition.
5. Scope.
6. Out of Scope.
7. Use cases, with Given, When, Then scenarios (one full sentence per keyword).
8. Success metrics (one north star, plus supporting metrics).
9. Risks and open product questions.
10. Positioning (optional).
11. Go to market and rollout (optional).

Every spec follows the same structure, in the same order, in English, with no em dash and in plain human voice. That is the point: a reader who has read one product spec from this extension can read any of them without reorientation.

## Validating the Output

1. Open `checklists/product.md` next to the generated spec.
2. Walk the list. Tick each item that holds. The checklist is grouped into Structure, Style, and Content, plus an Optional sections block.
3. If any Required item fails, edit the spec by hand or rerun the command after fixing the source spec. Required items must all be ticked before the product spec is shared with stakeholders.

## Refresh and Sync (deferred)

The extension does not yet detect drift between `spec.md` and `product-spec.md`. If you change the source spec, regenerate the product spec by running the command again and choosing overwrite. A future release (per User Story 3) will introduce a per section diff and merge flow.

## Troubleshooting

- **The command says it cannot find a feature directory**: check that `.specify/feature.json` exists and that its `feature_directory` value points at a directory that exists. Fix one of the two, or pass `--feature-dir` explicitly.
- **The command refuses because of placeholders**: open `spec.md` and finish filling it out. Specifically, search for unfilled bracketed text from the original Spec Kit template.
- **The command refuses because the language is not English**: this v1 only supports English source specs. Translate `spec.md` to English first, then rerun.
- **The output contains an em dash or feels AI generated**: file an issue with the offending excerpt. The style rules are enforced by the template and the command prompt; any violation is a defect in the prompt or template, not an expected variation.
