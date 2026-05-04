# Contract: Release Pipeline

This contract pins the trigger, gates, and outputs of the release pipeline. The implementation lives at `.github/workflows/release.yml` and uses GitHub Actions, but any compliant CI provider could substitute as long as the gates and outputs match.

## Triggers

### Tag-driven release (primary)

- **Event**: `push` of a tag matching `v*.*.*` (e.g. `v1.0.0`, `v2.3.1`).
- **Action**: run the full release pipeline (validate, build, publish, update catalog).

### Pull request validation (gate)

- **Event**: `pull_request` targeting the default branch.
- **Action**: run only the validation jobs (no build, no publish, no commit). Fails the PR if validation fails.

### Manual rerun

- **Event**: `workflow_dispatch`.
- **Action**: same as tag-driven release, but only when invoked by a maintainer. Useful for retrying a failed release without retagging.

## Jobs (Sequential, Fail-Closed)

Each job is a hard gate. Failure of any job aborts the pipeline; no later job runs and no release is published.

### Job 1: validate-manifest

**Purpose**: catch tag-version mismatches and malformed manifests before anything else runs.

**Steps**:

1. Check out the tagged commit.
2. Parse `extension/extension.yml` as YAML.
3. Assert `extension.id == "product"`.
4. Extract `extension.version`. Compare against `${{ github.ref_name }}` with the leading `v` stripped. Fail on mismatch with the message `version mismatch: tag <tag>, manifest <version>`.
5. Validate the manifest against the documented Spec Kit schema (schema URL pinned in the workflow).
6. Assert that every required file listed in `package-layout.md` exists at the expected path inside `extension/`.

### Job 2: validate-catalog (PR validation only)

**Purpose**: prevent drift between manifest and catalog by blocking manual edits to pipeline-owned fields.

**Steps**:

1. Check out the PR head.
2. Diff `catalog.json` against the base branch.
3. Fail if the diff touches any of: `version`, `download_url`, `requires.speckit_version`, `updated_at`, `created_at`.
4. Fail if `catalog.json#id` is changed at all (id changes are always breaking).

This job runs only on `pull_request` events. On tag push, the catalog is updated by Job 5 instead.

### Job 3: lint-content

**Purpose**: enforce the style contract on the deliverable templates.

**Steps**:

1. Check that `extension/templates/product-spec-template.md` contains no em dash (`—`) outside of fenced code blocks that explicitly explain the rule.
2. Check that `extension/templates/product-spec-template.md` contains the canonical section headings in the canonical order (per `product-spec-template.md` contract).
3. Check that the slash command file `extension/commands/speckit.product.spec.md` references both templates by relative path.
4. Run a markdown lint pass (e.g. `markdownlint-cli2`) on all `*.md` inside `extension/` to catch broken links and malformed lists.

### Job 4: build-zip

**Purpose**: produce the deterministic release zip per `package-layout.md`.

**Steps**:

1. Compute `<version>` from `extension/extension.yml`.
2. Build `product-<version>.zip` from the `extension/` subtree, with files at the zip root, alphabetical entry order, file timestamps fixed to the tagged commit's timestamp.
3. Re-run the validation from `package-layout.md` *against the zip itself* (not the source tree), to catch any packaging bug. Fail on any missing or extra file.
4. Upload the zip as a workflow artifact for the next job.

### Job 5: publish-release

**Purpose**: create the GitHub Release and attach the zip.

**Steps**:

1. Download the zip from Job 4.
2. Create or update the GitHub Release at the tag, with title `v<version>` and body sourced from the corresponding `CHANGELOG.md` section.
3. Upload `product-<version>.zip` as the sole release asset.
4. Capture the asset URL for Job 6.

### Job 6: update-catalog

**Purpose**: keep `catalog.json` in sync with the just-published release, per `catalog-entry.md`.

**Steps**:

1. Check out the default branch.
2. Update `catalog.json` fields per the rules in `catalog-entry.md` (`version`, `download_url`, `requires.speckit_version`, `updated_at`; set `created_at` if empty).
3. Commit with message `chore(release): catalog v<version>` authored by the release bot identity.
4. Push to the default branch.
5. The push must NOT retrigger the release workflow (the release workflow ignores commits authored by the release bot).

## Outputs

A successful run produces, in order:

1. A GitHub Release at the pushed tag, with title `v<version>`.
2. A single release asset: `product-<version>.zip` matching `package-layout.md`.
3. A commit on the default branch updating `catalog.json` per `catalog-entry.md`.
4. A workflow log retained per the repo's default retention policy, sufficient to diagnose failures.

## SLO Targets

- A successful release publishes the zip within 5 minutes of tag push (per SC-010 dependency).
- The catalog commit lands on the default branch within 5 minutes of the release being published (per SC-010).

## Failure Mode Behavior

- If any job fails, the workflow stops. No partial release is left behind. No catalog update is committed.
- If Job 5 succeeds but Job 6 fails (release published, catalog not updated), the maintainer reruns the workflow via `workflow_dispatch`. Job 6 is idempotent: it always sets the catalog to the latest released version.
- The release zip and the GitHub Release itself are immutable once published. Re-tagging an already-released version is forbidden; the pipeline rejects it and instructs the maintainer to bump the version.

## Out of Scope for v1

- Automated publishing to external registries (npm, PyPI, etc.). The extension is shipped as a zip, not a package on a third-party registry.
- Cross-platform binary signing.
- Multi-channel releases (stable, beta, nightly). v1 ships only stable releases tagged `vX.Y.Z`.
