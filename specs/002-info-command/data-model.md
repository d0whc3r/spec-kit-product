# Phase 1 Data Model: Product Info Command

This is a content-extension feature. There are no database entities and no service-level state machines. The "data model" is the set of files and manifest fields the feature reads, writes, and updates, plus the authoritative shape of the `product-info.md` artifact.

## Entities

### Product Info Document (`product-info.md`)

- **What it is**: A short, stakeholder-readable markdown file that records, in plain language, what is changing for the user and why.
- **Location**: `<feature-dir>/product/product-info.md`. The `product/` subfolder is shared with `product-spec.md` and `checklist.md`.
- **Lifecycle**: Created by `/speckit-product-info`. Overwritten only with explicit user confirmation. Never modified by any other Spec Kit command.
- **Fields (header metadata)**:
  - `Feature` (string): the feature directory name, e.g. `002-info-command`. Drawn from the resolved `FEATURE_DIR`.
  - `Source Spec` (markdown link): `[spec.md](../spec.md)`. Fixed format. The only file path allowed in the body of the document.
  - `Created` (date): today's date in `YYYY-MM-DD`. The only field permitted to vary between two consecutive idempotent runs.
  - `Status` (enum): `Draft`. No other value in v1.
- **Fields (body sections)**:
  - `Headline` (paragraph): one paragraph, two to four sentences, plain English.
  - `What is Changing` (bullets or paragraph): two to five bullets or a single short paragraph.
  - `Why Now` (paragraph): two to four short sentences.
  - `Out of Scope` (bullets): one or more short bullets, each one sentence with a one-phrase reason.
  - `Open Questions` (bullets, optional): present only when the source `spec.md` contained `[NEEDS CLARIFICATION]` markers AND the user confirmed at the prompt.
- **Validation rules**:
  - The four mandatory sections MUST be present in canonical order.
  - The optional section MUST appear last when present.
  - The body MUST NOT contain the em dash character `—`.
  - The body MUST NOT contain banned AI-tell phrases (see writing rules in `plan.md`).
  - The body MUST NOT contain implementation detail.
  - The header MUST contain a working `[spec.md](../spec.md)` link.

### Product Info Template (`product-info-template.md`)

- **What it is**: The canonical structural skeleton of the Product Info Document. Read verbatim by the command body.
- **Location**: `templates/product-info-template.md` (repo root in canonical layout, zip root after package).
- **Lifecycle**: Authored once during this feature, updated only when the document shape itself changes.
- **Validation rules** (enforced by `lint-content.sh`):
  - Contains every canonical heading in canonical order.
  - Contains zero em dashes.
  - Contains zero banned AI-tell phrases.

### Command Manifest Entry

- **What it is**: A second entry in `extension.yml` under `provides.commands`, advertising the new command to Spec Kit's installer.
- **Location**: `extension.yml` at the repo root.
- **Fields**:
  - `name`: `speckit.product.info`
  - `file`: `commands/speckit.product.info.md`
  - `description`: a one-line summary of what the command produces.
- **Validation rules** (enforced by `validate-manifest.sh`):
  - The file referenced by `file` exists and is non-empty.
  - The manifest still parses as YAML.
  - `extension.id` remains `product`.
  - `extension.version` still equals the git tag without the leading `v`.

## Relationships

```text
spec.md  (existing, never modified by either command)
   │
   │ read by
   ▼
/speckit-product-info  ────►  product/product-info.md  (NEW artifact, this feature)
   │
   │ shares
   ▼
/speckit-product-spec  ────►  product/product-spec.md  (existing, unchanged)
                              product/checklist.md     (existing, unchanged)
```

The two commands are siblings. Neither reads the other's output. Both write into the same `product/` subfolder and create that folder on demand.

## State transitions

`product-info.md` has only two states from the user's perspective:

- **Absent**: no file at `<feature-dir>/product/product-info.md`. Running the command transitions to *Draft*.
- **Draft**: file exists, header `Status` is `Draft`. Running the command again prompts for overwrite. Choosing "no" leaves state unchanged. Choosing "yes" replaces the file content byte for byte (only the `Created` date may differ).

There is no "Approved", "Published", or "Archived" state in v1. Adding such a state would introduce a workflow that does not exist for `product-spec.md` either.

## Volume and scale

- One `product-info.md` per feature directory. A repository typically holds 10 to 100 feature directories over its lifetime. Total volume is trivial.
- Generation is interactive, on-demand, one feature at a time. No batch mode in v1.
