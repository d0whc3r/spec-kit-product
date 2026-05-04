# Product Plan: Product Plan Command

**Feature**: 003-product-plan-command
**Source Plan**: [plan.md](../plan.md)
**Created**: 2026-05-04
**Status**: Draft

## 1. Summary

The product extension currently generates two documents for stakeholders from a feature's written specification: a full product requirements document and a one-page summary. Neither covers the implementation plan. This feature adds a third command that reads the engineering plan a developer creates during feature planning and produces a high-level, product-oriented version of it. The new document answers "how are we building this?" for product managers, engineering leads, and cross-functional reviewers who need enough technical context to participate in planning sessions without reading the dense engineering plan. The implementation adds one new command file, one new structural template, and an updated extension manifest (declaration file listing components or contents) - nothing is removed or changed in existing commands.

## 2. Delivery Phases

### NOW

#### Phase 1: Template and Command File

**Appetite**: Two to three hours.

- A structural template that governs the layout and section rules of every generated product plan is written and locked.
- The new command file is written, following the same execution pattern and refusal codes used by sibling commands.
- The extension manifest is updated to register the new command, and the version increments to 0.3.0.

### NEXT

- Update the content linter (automated style and error checker) to verify that generated product plans contain no banned phrases and gloss technical terms correctly.
- Update the manifest validator to require the new command file and template in the extension package.
- Confirm the existing pipeline (automated sequence of steps) passes on a clean run with the new checks active.

### LATER

- Build and attach the release package to the version tag, update the public catalog, and update the README with a short section on the new command (deferred until the linter and validator updates are complete).
- Per-command catalog entries so individual commands can be browsed and installed independently (deferred: the catalog references the extension as a whole in this version).

## 3. Out of Scope

- New runtime dependencies: the command reuses existing resolver scripts and the host AI assistant, so no new tools or libraries are introduced.
- A new extension container: this command is a pure addition within the existing product extension.
- New pipeline (automated sequence of steps) workflow files: the existing pipeline is updated in place, not replaced.
- Non-English output in this version: the command refuses with an error if the source plan is not in English, deferring multi-language support.
- Per-command catalog entries: the public catalog points at the extension as a whole, not at individual commands.

## 4. Component Overview

- **Command file**: Defines the step-by-step execution logic and refusal conditions for the new command. This feature adds it.
- **Product plan template**: Provides the structural skeleton with mandatory and optional sections used to generate each product plan. This feature adds it.
- **Extension manifest**: Lists all commands the extension provides to the host tool. This feature modifies it to register the new command and increment the version.
- **Feature directory resolver**: Locates the active feature directory by reading the project configuration. This feature reads from it; it is unchanged.

## 5. Key Technical Decisions

### Read the engineering plan primarily, use the feature specification as optional context

**Decision**: The command reads the engineering plan as its main input and reads the feature specification when it exists as supplementary context.
**Why**: The engineering plan contains the implementation information the product plan summarises. The feature specification adds the user-facing framing (personas, problem statement, and the reason this is being built now) that engineering plans often omit. Reading both when available produces a richer Summary section without requiring extra steps from the user.
**Trade-off**: The command must produce complete mandatory sections from the engineering plan alone, without depending on the feature specification being present.

---

### Classify sections as mandatory or optional

**Decision**: Classify template sections as mandatory (Summary, Delivery Phases, Out of Scope - always present) or optional (Component Overview, Key Technical Decisions, Risks, Open Questions - omitted entirely when the source has no relevant content).
**Why**: A section containing a placeholder or "none identified" message is worse than no section for a communication artifact. Readers see a clean, complete document rather than one with visible gaps.
**Trade-off**: The command must inspect the source engineering plan before generating to determine which optional sections have content, adding a content-inspection step.

---

### Use an explicit placeholder detection list

**Decision**: Detect unfilled placeholders by checking for a fixed list of known placeholder strings drawn from the Spec Kit plan template.
**Why**: An explicit list is predictable and easy to test. It matches the approach used by sibling commands, so behavior is consistent across the extension.
**Trade-off**: If the plan template changes its placeholder strings, this detection list must be updated alongside it.

---

### Emit a non-blocking notice for sparse plans

**Decision**: When a source engineering plan has no identifiable phases, decisions, or components, proceed with generation and emit a non-blocking notice rather than refusing.
**Why**: A sparse plan still produces a valid product plan covering all mandatory sections. Refusing would block users whose features are genuinely small or early-stage.
**Trade-off**: The generated artifact may not be useful to stakeholders if the source has very little content. The notice is the only mitigation.

## 6. Risks

- If the engineering plan for a feature is minimal, the generated product plan contains only mandatory sections, which may not give stakeholders enough context for a productive review.
- The host AI assistant may apply the jargon-gloss rule inconsistently in longer documents; the content linter provides a post-generation catch but cannot correct generation in progress.
- If the product plan template is changed without updating the command body, section names or order may fall out of sync; the automated lint check for section order is the only guard.
