# Feature Specification: Product Info Command

**Feature Branch**: `002-info-command`
**Created**: 2026-05-04
**Status**: Draft
**Input**: User description: "vamos a añadir un command igual que tenemos el de spec para crear un 'info' o summary. que sera una explicación basica de lo que va el cambio y porque lo necesitamos hacer, algo simple y basico para dar contexto a lo que seria el spec y el plan"

## Overview

The existing `product` extension ships `/speckit-product-spec`, which derives a full PRFAQ-style stakeholder document (`product-spec.md`) from `spec.md`. That artifact is comprehensive but heavy: it is too much when a contributor or stakeholder only needs a one-page answer to "what is changing and why". This feature extends the same `product` extension with a new sibling command, `/speckit-product-info`, that derives a much shorter context summary (`product-info.md`) from the same `spec.md`. The summary is intentionally simple and basic: it gives non-technical readers enough context to evaluate the proposed change before they (or downstream commands) engage with the full spec or plan.

Scope is purely additive within the existing `product` extension. The new command mirrors the structure, conventions, scripts, refusal codes, idempotence rules, and packaging of `/speckit-product-spec`. It does not modify any other Spec Kit command, does not introduce a new extension, and does not change `spec.md`.

## Clarifications

### Session 2026-05-04

- Q: Final command name and packaging model. → A: This is an extension of the existing `product` extension. Command name is `/speckit-product-info`. It mirrors the structure used by `/speckit-product-spec` (templates, scripts, hook protocol, refusal codes). Output filename is `product-info.md` and lives under the same `product/` subfolder of the feature directory.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Generate a one-page context summary from an existing spec (Priority: P1)

A contributor has a populated `spec.md` for a feature and wants a short, stakeholder-readable explanation of what is changing and why, without committing to the full PRFAQ-style `product-spec.md`. They run `/speckit-product-info` and receive `product-info.md` under the feature's `product/` subfolder.

**Why this priority**: This is the core value of the command. Without it, the only options today are (a) read the engineering-flavored `spec.md` directly or (b) generate the heavier `product-spec.md`. There is nothing in between.

**Independent Test**: Pick a feature that already has a populated `spec.md`. Run `/speckit-product-info`. Verify a single `product-info.md` is written under `<feature-dir>/product/`, contains the four mandatory sections (Summary, Problem, Why now, Out of scope), is one rendered page or less, contains no implementation detail, and `spec.md` is untouched.

**Acceptance Scenarios**:

1. **Given** a feature directory with a populated `spec.md` and no existing `product/product-info.md`, **When** the user runs `/speckit-product-info`, **Then** the command resolves the feature directory the same way `/speckit-product-spec` does (via `.specify/feature.json` or `--feature-dir`), creates `<feature-dir>/product/` if missing, and writes `product-info.md` populated from `spec.md`.
2. **Given** the same feature already has `<feature-dir>/product/product-spec.md`, **When** the user runs `/speckit-product-info`, **Then** `product-info.md` is written alongside `product-spec.md` in the same `product/` subfolder, and `product-spec.md` is not modified.
3. **Given** `<feature-dir>/product/product-info.md` already exists, **When** the user runs `/speckit-product-info` again, **Then** the command prints the existing path and asks "Overwrite? (yes/no)"; on a non-affirmative answer the command aborts with `E_USER_ABORT` and writes nothing.
4. **Given** `spec.md` contains one or more `[NEEDS CLARIFICATION: ...]` markers, **When** the user runs `/speckit-product-info`, **Then** the command surfaces each marker, asks the user whether to carry them into `product-info.md` as open questions, and either includes them as a bulleted "Open questions" subsection or aborts (matching the existing `/speckit-product-spec` behavior).

### User Story 2 - Use the info doc as a stakeholder conversation starter (Priority: P2)

A product or engineering lead wants to share the proposed change with non-technical stakeholders to validate direction before producing the full `product-spec.md`. They open `product-info.md` and the document is short, plain-language, and free of implementation jargon.

**Why this priority**: Drives adoption from people who would otherwise skip the product extension entirely for early-stage discussions. Lower than P1 because the artifact is still useful even if the only consumer is a later AI run of `/speckit-product-spec`.

**Independent Test**: Open the generated `product-info.md` and verify it reads as one or two coherent paragraphs of natural language, with no code, no API names, no framework names, and no requirement IDs.

**Acceptance Scenarios**:

1. **Given** a generated `product-info.md`, **When** a non-technical reader opens it, **Then** they can answer "what is changing?" and "why does it matter?" without consulting any other file.

### User Story 3 - Refuse to run when prerequisites are not met (Priority: P3)

The command refuses cleanly and uses the same error codes as `/speckit-product-spec` when its inputs are missing or invalid, so users get consistent, predictable feedback across the product extension.

**Why this priority**: Important for trust and consistency, but does not generate new value on its own; it makes the P1 path safe.

**Independent Test**: Run the command from outside a Spec Kit project, with a missing `spec.md`, with a `spec.md` still containing template placeholders, and with a non-English `spec.md`. Verify each case produces the corresponding refusal line and writes nothing.

**Acceptance Scenarios**:

1. **Given** the working directory has no `.specify/` ancestor, **When** the user runs `/speckit-product-info`, **Then** the command refuses with `E_NO_PROJECT` and writes nothing.
2. **Given** the feature directory exists but has no `spec.md`, **When** the user runs `/speckit-product-info`, **Then** the command refuses with `E_NO_SPEC` and instructs the user to run `/speckit-specify` first.
3. **Given** `spec.md` still contains literal Spec Kit template placeholders (e.g. `[FEATURE NAME]`), **When** the user runs `/speckit-product-info`, **Then** the command refuses with `E_PLACEHOLDERS` (one line per detected placeholder).
4. **Given** `spec.md` is not in English, **When** the user runs `/speckit-product-info`, **Then** the command refuses with `E_LANGUAGE` and does not auto-translate.

### Edge Cases

- The user passes `--feature-dir <path>` to override `.specify/feature.json`. The command must honor the override exactly as `/speckit-product-spec` does and resolve all paths relative to the override.
- The `<feature-dir>/product/` subfolder does not yet exist (no prior `/speckit-product-spec` run). The command must create it before writing.
- The user runs `/speckit-product-info` and `/speckit-product-spec` against the same feature, in either order. Both files coexist under `product/`. Neither command modifies the other's output.
- The process is interrupted mid-write. Atomic write (temp file plus rename) must prevent a partial `product-info.md` from being left behind, matching the guarantee in `/speckit-product-spec` Step 7.
- Two consecutive runs against the same `spec.md`, with the user choosing overwrite on the second run, must produce a `product-info.md` whose content is byte-identical except for the `Created` field if the date has rolled over (idempotence).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A new slash command MUST be available as `/speckit-product-info`, distributed as part of the existing `product` extension (no new extension, no new release pipeline). The command file lives at `extension/commands/speckit.product.info.md` (or the equivalent path inside the extension's canonical source tree) and is shipped in the same release zip as `speckit.product.spec.md`.
- **FR-002**: The command MUST resolve the active feature directory using the same helper scripts already used by `/speckit-product-spec` (`scripts/bash/resolve-feature-dir.sh` and `scripts/powershell/resolve-feature-dir.ps1` inside the `product` extension), with the same `--feature-dir` override and the same error codes (`E_NO_PROJECT`, `E_NO_POINTER`, `E_BAD_POINTER`).
- **FR-003**: The command MUST read `<feature-dir>/spec.md` as its single source of truth and MUST NOT modify `spec.md`, `plan.md`, `tasks.md`, `.specify/feature.json`, `.specify/extensions.yml`, or any sibling feature.
- **FR-004**: The command MUST write its output to `<feature-dir>/product/product-info.md`, creating the `product/` subfolder if it does not exist. Writes MUST be atomic (write to temp file in the same directory, then rename).
- **FR-005**: The generated `product-info.md` MUST contain, in this order, the following mandatory sections: header metadata block (Feature, Source Spec link to `../spec.md`, Created date, Status), **Summary** (one paragraph describing what is changing), **Problem** (the user or business pain that motivates the change), **Why now** (why this is worth doing now versus later), and **Out of scope** (what this explicitly is not). An optional **Open questions** subsection MUST be included if and only if `[NEEDS CLARIFICATION]` markers are surfaced from `spec.md` (per FR-009).
- **FR-006**: The generated `product-info.md` MUST be deliberately short (one rendered page or less) and MUST NOT contain functional requirements, acceptance scenarios, success criteria, frameworks, languages, APIs, data stores, or other implementation detail. The single allowed file path in the output is the `[spec.md](../spec.md)` link in the header metadata.
- **FR-007**: The command MUST refuse with the same prerequisite error codes as `/speckit-product-spec`: `E_NO_SPEC` (missing `spec.md`), `E_PLACEHOLDERS` (one line per detected unfilled Spec Kit template placeholder; `[NEEDS CLARIFICATION]` markers do NOT count as placeholders), and `E_LANGUAGE` (non-English `spec.md`).
- **FR-008**: The command MUST refuse to overwrite an existing `<feature-dir>/product/product-info.md` without explicit user confirmation. On a non-affirmative response, it MUST abort with `E_USER_ABORT` and write nothing.
- **FR-009**: When `spec.md` contains `[NEEDS CLARIFICATION: ...]` markers, the command MUST list each marker, ask the user whether to surface them as open questions in `product-info.md`, and either include them as bullets under an "Open questions" subsection or abort with `E_USER_ABORT`. The command MUST NOT silently resolve a clarification marker.
- **FR-010**: Output style rules MUST mirror those enforced by `/speckit-product-spec`: English only, no em dash (`—`) anywhere in the output, plain English with active voice and short sentences, and no AI-tell filler ("delve", "tapestry", "in essence", etc.).
- **FR-011**: The command MUST be idempotent. Two consecutive runs against the same `spec.md`, with the user choosing overwrite on the second run, MUST produce a `product-info.md` whose content is byte-identical except for the `Created` field if the date has rolled over.
- **FR-012**: A canonical template `product-info-template.md` MUST be added to the `product` extension under `templates/`, alongside `product-spec-template.md` and `product-checklist-template.md`. The command MUST read this template verbatim as the structural skeleton of the output and MUST NOT invent additional sections or reorder existing ones.
- **FR-013**: The release pipeline (`.github/workflows/release.yml`) and any manifest validation script MUST recognize the new command file and template as required release artifacts, so the release zip continues to contain a complete extension after this feature ships. No new release pipeline is created.

### Key Entities *(include if feature involves data)*

- **Product Info Document (`product-info.md`)**: A short, stakeholder-readable markdown file derived from `spec.md`. Lives at `<feature-dir>/product/product-info.md`. Sibling to `product-spec.md` under the same `product/` subfolder. Records what is changing, why, why now, and what is out of scope. Never modified by any other Spec Kit command.
- **Product Info Template (`product-info-template.md`)**: The canonical structural skeleton of `product-info.md`. Lives in the `product` extension under `templates/`. Source-controlled and shipped in the release zip.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: First generation of `product-info.md` from a populated `spec.md` completes in under 60 seconds of wall-clock time on the same hardware where `/speckit-product-spec` already meets its 2-minute target.
- **SC-002**: 90% of generated `product-info.md` files fit on a single rendered page (under ~400 words) without manual editing.
- **SC-003**: A non-technical reader can answer "what is changing and why?" after reading `product-info.md` alone, without opening any other file, in 80% of generated samples reviewed.
- **SC-004**: 100% of generated `product-info.md` files pass the style rules in FR-010 on first generation: zero em dashes, English only, no implementation detail, no AI-tell filler.
- **SC-005**: Running the command against a feature that already has `product-spec.md` leaves `product-spec.md` byte-identical (no incidental modification), verified on at least one regression sample.
- **SC-006**: The release zip produced after this feature ships continues to install successfully via the documented `specify extension add product --from <zip-url>` flow, and an end-user can invoke `/speckit-product-info` immediately after install with no additional setup.

## Assumptions

- This feature is an extension of the existing `product` extension. It does not introduce a new extension, a new top-level Spec Kit command, or a new release pipeline.
- The new command follows the exact same packaging conventions, refusal-code vocabulary, idempotence rules, and atomic-write guarantees as `/speckit-product-spec`, so users get a single coherent product extension.
- The new command consumes `spec.md` as its sole source of truth. It is not an upstream artifact for `/speckit-specify`; it is a downstream sibling of `/speckit-product-spec`.
- A small template file (`product-info-template.md`) authored as part of this feature is sufficient to anchor the four-section structure. The template is source-controlled in the same repository and shipped in the same release zip.
- Hook entries for the new command (e.g. `before_product_info` / `after_product_info`) are not added to `.specify/extensions.yml` in v1, matching the absence of dedicated hooks for `/speckit-product-spec` today. They can be added later without breaking existing installs.
