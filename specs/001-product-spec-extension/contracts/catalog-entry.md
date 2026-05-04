# Contract: Catalog Entry (`catalog.json`)

This contract pins the schema and update rules for the `catalog.json` file that lives at the repository root and that powers catalog-driven installs (`specify extension add product` without `--from`).

## File Location

`catalog.json` at the repository root.

## Single-Entry Catalog

This file describes exactly one extension: this one. The Spec Kit catalog mechanism aggregates many such files across repositories, so each repo only owns its own entry.

## Schema

```json
{
  "name": "Product Spec Extension",
  "id": "product",
  "description": "Generates a product oriented spec from an existing technical spec.md, following Working Backwards, Jobs to Be Done, Gherkin BDD, and Lean PRD conventions.",
  "author": "<author or org>",
  "version": "<extension.yml version, e.g. 1.0.0>",
  "download_url": "https://github.com/<owner>/<repo>/releases/download/v<version>/product-<version>.zip",
  "repository": "https://github.com/<owner>/<repo>",
  "license": "MIT",
  "requires": {
    "speckit_version": ">=0.2.0"
  },
  "tags": ["product", "spec", "documentation", "prd"],
  "verified": false,
  "created_at": "<ISO-8601 timestamp of the first published release>",
  "updated_at": "<ISO-8601 timestamp of the latest published release>"
}
```

## Field Rules

| Field | Source | Updated when |
|-------|--------|--------------|
| `name` | static, set once at v1.0.0 | never (cosmetic) |
| `id` | must equal `extension.id` from `extension.yml` (`product`) | never (any change is a new extension) |
| `description` | static, may be revised in a minor release | manually, in the same commit that adjusts the README |
| `author` | static | manually |
| `version` | `extension.version` from the released `extension.yml` | every release (pipeline) |
| `download_url` | constructed from owner, repo, and version | every release (pipeline) |
| `repository` | static | manually |
| `license` | matches the LICENSE file | manually |
| `requires.speckit_version` | matches `requires.speckit_version` in `extension.yml` | every release (pipeline) |
| `tags` | static, may be revised in a minor release | manually |
| `verified` | always `false` for community-published catalog entries | only by Spec Kit maintainers |
| `created_at` | ISO-8601 UTC, set once on first release | first release only |
| `updated_at` | ISO-8601 UTC, current time at release | every release (pipeline) |

## Pipeline Update Rules

On every successful release, the pipeline MUST:

1. Read `version` and `requires.speckit_version` from the released `extension.yml`.
2. Set `catalog.json#version` to the manifest version.
3. Set `catalog.json#download_url` to `https://github.com/<owner>/<repo>/releases/download/v<version>/product-<version>.zip`.
4. Set `catalog.json#requires.speckit_version` to the manifest value.
5. Set `catalog.json#updated_at` to the current ISO-8601 UTC timestamp.
6. If `catalog.json#created_at` is empty or missing, set it to the same timestamp.
7. Commit the updated `catalog.json` back to the default branch with a non-recursive commit message (e.g. `chore(release): catalog v<version>`), authored by the pipeline bot.

The commit MUST NOT trigger a recursive release run. The pipeline guards against this by ignoring commits whose author matches the release bot.

## Manual Edits

`catalog.json` may be edited manually only for fields the pipeline does not own (`name`, `description`, `author`, `repository`, `license`, `tags`). Manual edits to pipeline-owned fields are reverted on the next release.

## Validation

A pre-merge check (see `release-pipeline.md`, "PR validation" job) MUST verify that any pull request modifying `catalog.json` does not change pipeline-owned fields. This prevents drift between the manifest and the catalog.
