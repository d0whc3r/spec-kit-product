# Feature Specification: Product Plan Command

**Feature Branch**: `003-product-plan-command`
**Created**: 2026-05-04
**Status**: Draft
**Input**: User description: "vamos a definir un nuevo command para la serie de commands que estamos haciendo para la extension actual. el command sera el /speckit.product.plan que al igual que el spec o el info sera un command para extraer una versión simplificada encarada a producto del plan que se genera para la spec en curso. este documento sera adaptado y siguiendo metodologias para tener un plan de implementación de alto nivel sin entrar en muchos detalles, si que tendra definiciones tecnicas pero más a 'grosso modo'. busca tecnicas, metodologias, etc que sean utiles para definir este documento"

## Overview

The existing `product` extension ships `/speckit.product.spec` (full PRFAQ-style product document) and `/speckit.product.info` (single-page context summary). Both derive from `spec.md`. This feature extends the same extension with a third sibling command, `/speckit.product.plan`, that derives a high-level, product-oriented implementation plan (`product/plan.md`) from the engineering `plan.md` already produced by `/speckit.plan`.

The generated artifact targets product managers, engineering leads, and technical stakeholders who need to understand how a feature will be built and in what phases, without reading the full engineering plan. It answers "how are we going to build this, roughly?" using structured methodologies: Shape Up appetite framing for phases, C4-inspired component identification (context and container layers only), Architecture Decision Record (ADR) summaries for key technical choices, and a phased NOW/NEXT/LATER delivery view. Technical terms are used but always accompanied by a plain-language gloss. No code, no file paths, no detailed task breakdowns.

Scope is purely additive within the existing `product` extension. The new command mirrors the conventions, scripts, refusal codes, idempotence rules, and packaging of its siblings. It does not modify any other Spec Kit command, does not introduce a new extension, and does not change `plan.md` or `spec.md`.

## Clarifications

### Session 2026-05-04

- Q: How should `E_PLACEHOLDERS` detection work for `plan.md`? → A: Define an explicit list of placeholder strings drawn from the Spec Kit plan template, mirroring the sibling command pattern.
- Q: How should `spec.md` be used as input? → A: Read `spec.md` when it exists and use it as supplementary context (personas, problem statement, Why Now framing); proceed silently if absent.
- Q: How should the command handle sections when the source `plan.md` has no relevant content? → A: Classify sections as mandatory (Summary, Delivery Phases, Out of Scope - always present) or optional (Component Overview, Key Technical Decisions, Risks, Open Questions - omitted entirely when source has no content).
- Q: How should SC-002 (jargon clarity) be made testable? → A: Add a banned-jargon list to the writing rules mirroring the AI-tell phrase list; SC-002 passes when no term from the list appears unglossed in the output.
- Q: How should the command handle a sparse but valid `plan.md` (no phases, decisions, or components)? → A: Proceed with generation and emit a non-blocking console notice informing the user that the source plan is sparse and output coverage is limited.

### Session 2026-05-04 (continued)

- Q: When must a banned-jargon term be glossed - on first use only, or every occurrence? → A: Gloss on first use only; subsequent occurrences of the same term in the same document may appear unglossed.
- Q: Which AI-tell phrases are banned from the generated output? → A: Inherit the sibling command list verbatim: "delve", "tapestry", "in essence", "navigate the landscape", "leverage" (standalone verb), "robust" (without measurable target), "seamless", "intuitive".
- Q: Should the FR-003 placeholder list be derived from the actual Spec Kit plan template? → A: Yes; the real placeholder strings found in `.specify/templates/plan-template.md` are: `[FEATURE]`, `[DATE]`, `[###-feature-name]`, `[link]`, and `[Extract from feature spec: primary requirement + technical approach from research]`.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Generate a high-level product plan from an existing engineering plan (Priority: P1)

A product manager or engineering lead has a feature with a populated `plan.md` and wants to share a readable, product-oriented summary of the implementation approach with technical stakeholders who are not the primary authors. They run `/speckit.product.plan` and receive `product/plan.md` under the feature directory.

**Why this priority**: This is the core value of the command. Without it, the only options are reading the dense engineering `plan.md` directly or inferring implementation intent from the product spec. Neither answers "how are we building this?" at the right level for cross-functional reviews.

**Independent Test**: Pick a feature that already has a populated `plan.md`. Run `/speckit.product.plan`. Verify that `product/plan.md` is written, contains all mandatory sections (Summary, Delivery Phases, Out of Scope), uses plain language with technical terms glossed on first use, and that `plan.md` and `spec.md` remain untouched.

**Acceptance Scenarios**:

1. **Given** a feature directory with a populated `plan.md` and no existing `product/plan.md`, **When** the user runs `/speckit.product.plan`, **Then** the command resolves the feature directory via `.specify/feature.json` or `--feature-dir`, creates `<feature-dir>/product/` if missing, and writes `product/plan.md` populated from `plan.md`.
2. **Given** the same feature already has `product/spec.md` and `product/info.md`, **When** the user runs `/speckit.product.plan`, **Then** `product/plan.md` is written alongside the existing files and none of them are modified.
3. **Given** `product/plan.md` already exists, **When** the user runs `/speckit.product.plan` again, **Then** the command prints the existing path and asks "Overwrite? (yes/no)"; on a non-affirmative answer the command aborts with `E_USER_ABORT` and writes nothing.
4. **Given** `plan.md` contains open questions or marked assumptions, **When** the user runs `/speckit.product.plan`, **Then** those open items are surfaced in a dedicated section of `product/plan.md` rather than being silently resolved.

---

### User Story 2 - Use the product plan in cross-functional reviews and stakeholder communication (Priority: P2)

An engineering lead wants to present the implementation approach in a sprint kickoff or architecture review without projecting the raw engineering plan. They open `product/plan.md` and find a structured, phase-gated document they can walk through with product and business stakeholders.

**Why this priority**: Extends the value of the artifact beyond generation. The document must hold up as a standalone communication tool, not just a generated summary.

**Independent Test**: Open the generated `product/plan.md` and verify that a reader with general technical awareness (but not the feature author) can identify: what the three largest pieces of work are, which phase they belong to, and what the biggest open risk is - all without reading any other file.

**Acceptance Scenarios**:

1. **Given** a generated `product/plan.md`, **When** a technical stakeholder who did not author the feature opens it, **Then** they can identify the main delivery phases, the key technical decisions, and the primary risk in under five minutes.
2. **Given** a generated `product/plan.md`, **When** a product manager opens it, **Then** they can understand each technical decision in plain language via the accompanying gloss, without needing engineering-specific knowledge.

---

### User Story 3 - Refuse to run when prerequisites are not met (Priority: P3)

The command refuses cleanly and uses the same error codes as its siblings when inputs are missing or invalid, so users get consistent, predictable feedback across the product extension.

**Why this priority**: Necessary for trust and consistency but generates no new value on its own; it makes the P1 and P2 paths safe.

**Independent Test**: Run the command when `plan.md` does not exist, when `plan.md` still contains template placeholders, and when the working directory has no `.specify/` ancestor. Verify each case produces the corresponding refusal line and writes nothing.

**Acceptance Scenarios**:

1. **Given** the working directory has no `.specify/` ancestor, **When** the user runs `/speckit.product.plan`, **Then** the command refuses with `E_NO_PROJECT` and writes nothing.
2. **Given** the feature directory exists but has no `plan.md`, **When** the user runs `/speckit.product.plan`, **Then** the command refuses with `E_NO_PLAN` and instructs the user to run `/speckit.plan` first.
3. **Given** `plan.md` still contains literal template placeholders (e.g., `[FEATURE]`, `[DATE]`), **When** the user runs `/speckit.product.plan`, **Then** the command refuses with `E_PLACEHOLDERS`, lists each detected placeholder, and writes nothing.
4. **Given** `plan.md` is not written in English, **When** the user runs `/speckit.product.plan`, **Then** the command refuses with `E_LANGUAGE` naming the detected language and writes nothing.

---

### Edge Cases

- What happens when `plan.md` exists but `spec.md` does not? The command proceeds using `plan.md` as the sole source; `spec.md` is read when present and used as supplementary context for persona, problem, and Why Now sections, but its absence produces no warning and does not block generation.
- What happens when `product/` exists but belongs to a different feature? The command resolves the feature directory from `.specify/feature.json` and scopes all writes to that directory; it never writes outside it.
- What happens when `plan.md` references external files (e.g., `data-model.md`) that do not exist? The command proceeds with what is available in `plan.md` and notes any unresolvable references in the Open Questions section.
- What happens when `plan.md` is valid (no placeholders, correct language) but contains no phases, decisions, or components? The command proceeds and writes `product/plan.md` with the mandatory sections populated on a best-effort basis; it emits a non-blocking console notice stating that the source plan is sparse and that the output may have limited coverage. No file is withheld.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST read `.specify/feature.json` (or a `--feature-dir` override) to resolve the active feature directory and refuse with `E_NO_PROJECT` if no `.specify/` ancestor is found. When `<feature-dir>/spec.md` is present, the command reads it as supplementary context for personas, problem framing, and Why Now content; if absent, the command proceeds silently using only `plan.md`.
- **FR-002**: System MUST refuse with `E_NO_PLAN` when `<feature-dir>/plan.md` does not exist, instructing the user to run `/speckit.plan` first.
- **FR-003**: System MUST refuse with `E_PLACEHOLDERS` when `plan.md` contains any of the following literal placeholder strings (case-sensitive), derived from the Spec Kit plan template at `.specify/templates/plan-template.md`: `[FEATURE]`, `[DATE]`, `[###-feature-name]`, `[link]`, `[Extract from feature spec: primary requirement + technical approach from research]`. Each detected placeholder is listed on its own line in the refusal output.
- **FR-004**: System MUST refuse with `E_LANGUAGE` when `plan.md` is not written in English.
- **FR-005**: System MUST write `<feature-dir>/product/plan.md` using the `product-plan-template.md` template as the structural skeleton, populating all sections from `plan.md`. Mandatory sections (Summary, Delivery Phases, Out of Scope) MUST always be present. Optional sections (Component Overview, Key Technical Decisions, Risks, Open Questions) MUST be omitted entirely when the source `plan.md` contains no relevant content for them; a "none identified" placeholder is not acceptable.
- **FR-006**: System MUST create `<feature-dir>/product/` if it does not already exist before writing.
- **FR-007**: System MUST check for an existing `product/plan.md` before writing and ask "Overwrite? (yes/no)"; on a non-affirmative answer, abort with `E_USER_ABORT` without writing.
- **FR-008**: System MUST NOT modify `plan.md`, `spec.md`, `tasks.md`, `product/spec.md`, `product/info.md`, or any file outside the resolved feature directory.
- **FR-009**: System MUST surface any open questions or marked assumptions found in `plan.md` in a dedicated section of `product/plan.md` rather than silently resolving them.
- **FR-010**: System MUST apply writing rules to all generated prose: no em dash, plain English, active voice, no raw code or file paths, technical terms glossed on first use. The following AI-tell phrases are banned and must not appear in `product/plan.md`: "delve", "tapestry", "in essence", "navigate the landscape", "leverage" (as a standalone verb without a concrete object), "robust" (without a measurable target), "seamless", "intuitive". This list mirrors the rule enforced by sibling commands.
- **FR-011**: System MUST use the cross-platform helper scripts (`resolve-feature-dir.sh` / `resolve-feature-dir.ps1`) for feature directory resolution, consistent with sibling commands.
- **FR-012**: System MUST accept an optional `--feature-dir <path>` argument to override the `.specify/feature.json` pointer, consistent with sibling commands.

### Key Entities

- **Engineering plan** (`plan.md`): The source artifact produced by `/speckit.plan`. Contains phases, technical context, architecture decisions, and implementation details. Read-only input.
- **Product plan** (`product/plan.md`): The generated artifact produced by this command. A high-level, stakeholder-readable implementation plan derived from the engineering plan.
- **Phase**: A bounded unit of delivery defined in the product plan. Maps to one or more phases in the engineering plan. Each phase has a name, a brief appetite description (inspired by Shape Up fixed-time framing), and a list of the main outcomes delivered, not the tasks.
- **Technical decision summary**: A distillation of an Architecture Decision Record (ADR) or key design choice from the engineering plan. Each summary states the decision, the plain-language reason, and the main trade-off accepted.
- **Component overview**: A C4-inspired, container-level description of the main system parts affected by the feature. Names components and their responsibilities in one sentence each. No internal class or function detail. Optional: omitted when the source plan contains no component or architecture information.
- **Mandatory section**: A template section that must always appear in the generated `product/plan.md` regardless of source content. Currently: Summary, Delivery Phases, and Out of Scope.
- **Optional section**: A template section that is included only when the source `plan.md` contains relevant content. Currently: Component Overview, Key Technical Decisions, Risks, Open Questions.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A technical stakeholder unfamiliar with the feature can identify the main delivery phases, key technical decisions, and primary risk from `product/plan.md` alone in under five minutes.
- **SC-002**: A product manager can understand each technical decision summary without engineering-specific knowledge. Validated by a banned-jargon check: the following terms MUST NOT appear in `product/plan.md` without a plain-language gloss in parentheses on the same line as their first occurrence: "API", "CLI", "SDK", "refactor", "idempotent", "atomic", "schema", "linter", "manifest", "hook", "pipeline". Subsequent occurrences of the same term require no gloss. The linter enforces this rule on every generated output.
- **SC-003**: The generated `product/plan.md` covers 100% of the phases present in the source `plan.md`, with no phase silently omitted.
- **SC-004**: All five refusal and abort conditions (`E_NO_PROJECT`, `E_NO_PLAN`, `E_PLACEHOLDERS`, `E_LANGUAGE`, `E_USER_ABORT`) are exercised in acceptance testing and each produces a single-line refusal or abort message with no file written.
- **SC-005**: End-to-end generation completes in under 90 seconds on a standard developer machine.
- **SC-006**: Installation of the updated extension (including the new command file, template, updated manifest, and updated validator) completes in under 3 minutes, matching the existing extension install target.

## Assumptions

- `plan.md` is written in English and follows the structure produced by `/speckit.plan`. Non-standard plan structures are handled on a best-effort basis.
- The host AI assistant has sufficient context about the engineering plan to generate accurate phase and decision summaries without additional prompting.
- No new runtime dependencies are introduced. The command reuses the existing cross-platform helper scripts.
- The product plan does not replace or supersede the engineering plan. It is a communication artifact only.
- The command operates on the same `product/` subfolder convention established by sibling commands. No new output directory is introduced.
- Version numbering of the updated extension follows the same policy as prior releases: the version in `extension.yml` must equal the git tag without the `v` prefix.
- In v1, no paired quality checklist is generated for `product/plan.md` (consistent with the `/speckit.product.info` v1 decision). This may be added in a future iteration.

## Constraints

- Output language must match the source `plan.md` language (English only in v1).
- No code, no file paths (except the link to `../plan.md` in the metadata block), and no raw implementation detail in the generated artifact.
- The following AI-tell phrases are banned from all generated prose, matching the rule enforced by sibling commands: "delve", "tapestry", "in essence", "navigate the landscape", "leverage" (as a standalone verb without a concrete object), "robust" (without a measurable target), "seamless", "intuitive".
- Technical terms from the banned-jargon list must be accompanied by a plain-language gloss in parentheses on the same line as their first occurrence in the document. Subsequent occurrences of the same term require no gloss.
- The command MUST NOT invent phases, decisions, or components not present in the source `plan.md`.
- The template structure is fixed; the command must not add, remove, or reorder sections.
