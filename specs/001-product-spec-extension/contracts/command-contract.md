# Contract: `speckit.product.spec` Command

**Feature**: 001-product-spec-extension
**Slash form**: `/speckit-product-spec`
**Stability**: this contract is the public interface of the extension. Breaking changes require a major version bump in `extension.yml`.

## Purpose

Generate a `product-spec.md` artifact for the current feature, derived from the existing `spec.md` in the same feature directory. The artifact is shaped for product stakeholders, follows the canonical product spec template, and follows the canonical style rules (English, human voice, no em dash, Gherkin scenarios with one full sentence per Given, When, Then).

## Inputs

### Required

- A Spec Kit project (a directory containing `.specify/`).
- A `feature_directory` field in `.specify/feature.json` that points to an existing directory under `specs/`.
- A populated `spec.md` inside that feature directory.

### Optional

- A `--feature-dir <path>` argument (or equivalent) to override the pointer in `.specify/feature.json`. Useful when the pointer is missing or stale.

## Preconditions

The command refuses to run, with a clear remediation message, when any of the following is true:

1. There is no `.specify/` directory in the project root.
2. `.specify/feature.json` is missing or its `feature_directory` field points to a non existent directory, and the user did not pass `--feature-dir`.
3. `spec.md` does not exist inside the resolved feature directory.
4. `spec.md` still contains unfilled placeholders from `spec-template.md` (for example, `[FEATURE NAME]`, `[Brief Title]`, `[Describe this user journey in plain language]`). The error message lists which placeholders are present.
5. The detected language of `spec.md` is not English. The command does not auto translate; it reports the detected language and stops.

## Warnings (non blocking)

The command warns and asks the user to confirm, then proceeds, when:

1. `spec.md` contains one or more `[NEEDS CLARIFICATION]` markers. The command lists each marker. On confirmation, those markers are surfaced as open product questions in the generated product spec (per FR-018), not silently resolved.
2. A `product-spec.md` already exists in the feature directory. The user is prompted to choose **overwrite** or **abort**. Merge or refresh is out of scope for v1.

## Outputs

### On success

- `<feature-dir>/product/product-spec.md` is created or replaced, populated from the canonical product spec template.
- `<feature-dir>/product/checklist.md` is created or replaced, populated from the canonical quality checklist template.
- All generated artifacts live inside the `product/` subfolder so they ship as a self contained bundle for export and sharing.
- A short status report is printed: paths written, number of sections populated, count of open product questions surfaced.

### On refusal or warning

- No files are written.
- A clear, single line error or prompt is printed, naming the precondition that failed and the remediation.

## Idempotence

- Running the command twice in a row with no changes between runs produces the same `product-spec.md` (modulo timestamps in the header).
- The command never modifies `spec.md`. The Source Spec is read only from the extension's point of view.

## Side Effects

- Writes to `<feature-dir>/product/product-spec.md`.
- Writes to `<feature-dir>/product/checklist.md`.
- Creates `<feature-dir>/product/` if it does not exist.
- Does not touch `.specify/feature.json`, `.specify/extensions.yml`, or any file outside the feature directory.

## Error Codes (informational, for future automation)

| Code | Condition |
|------|-----------|
| E_NO_PROJECT | No `.specify/` directory found. |
| E_NO_POINTER | `.specify/feature.json` missing and `--feature-dir` not provided. |
| E_BAD_POINTER | Feature directory in pointer does not exist. |
| E_NO_SPEC | `spec.md` missing in feature directory. |
| E_PLACEHOLDERS | `spec.md` still contains template placeholders. |
| E_LANGUAGE | `spec.md` is not in English. |
| E_USER_ABORT | User chose abort at the overwrite prompt. |

## Style Contract Enforced on Output

Every generated `product-spec.md` must satisfy the following rules. The quality checklist verifies them.

1. Written entirely in English.
2. No em dash character (`—`) appears in the file.
3. Each Use Case scenario contains exactly one `Given` line, one `When` line, and one `Then` line, in that order. Each line is a full sentence beginning with the keyword.
4. The product spec contains every mandatory section listed in `product-spec-template.md`, in the order defined there.
5. The product spec contains a link back to the Source Spec (`spec.md`) in its metadata block.
6. The product spec contains no implementation detail (no frameworks, languages, APIs, data stores, code, or file paths other than the cross link to `spec.md`).
