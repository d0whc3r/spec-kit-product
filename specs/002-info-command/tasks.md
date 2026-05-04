---
description: "Task list for 002-info-command"
---

# Tasks: Product Info Command

**Input**: Design documents from `/specs/002-info-command/`
**Prerequisites**: plan.md, spec.md, data-model.md, research.md, quickstart.md, contracts/command-contract.md, contracts/product-info-template.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Exact file paths are included in every description

---

## Phase 1: Setup (Understand Existing Conventions)

**Purpose**: Read the existing `product` extension source files to extract the exact patterns the new command and template must follow. No files are created in this phase.

- [X] T001 Read `commands/speckit.product.spec.md` to extract the command file structure, help output format, refusal-code formatting (`[product-spec] <CODE>: <remediation>`), and the generation instruction patterns used for LLM-driven output
- [X] T002 [P] Read `extension.yml` to extract the `provides.commands` list structure, field names (`name`, `file`, `description`), and current extension version
- [X] T003 [P] Read `.github/scripts/validate-manifest.sh` to identify the REQUIRED file array variable name and the exact syntax used to add entries to it
- [X] T004 [P] Read `.github/scripts/lint-content.sh` to identify the template lint targets array and how new template paths are added to it

---

## Phase 2: Foundational (Blocking Prerequisite)

**Purpose**: Create the canonical template. The command file (Phase 3) references this template by path, so it must exist first.

**⚠️ CRITICAL**: Phase 3 cannot begin until this phase is complete.

- [X] T005 Create `templates/product-info-template.md` with the byte-exact canonical body defined in `specs/002-info-command/contracts/product-info-template.md` (between the two `=== TEMPLATE BODY ===` markers, markers stripped). The file must contain: header metadata block (Feature, Source Spec, Created, Status), `## 1. Headline`, `## 2. What is Changing`, `## 3. Why Now`, `## 4. Out of Scope`, and `## 5. Open Questions *(optional)*` in that order, with no em dash character anywhere

**Checkpoint**: `templates/product-info-template.md` exists and matches the canonical body. US1 implementation can now begin.

---

## Phase 3: User Story 1 - Generate a one-page context summary (Priority: P1) 🎯 MVP

**Goal**: A contributor runs `/speckit-product-info` against a populated `spec.md` and receives a short, plain-language `product-info.md` under `<feature-dir>/product/`.

**Independent Test**: Pick a feature with a populated `spec.md`. Run `/speckit-product-info`. Verify `<feature-dir>/product/product-info.md` is created with four mandatory sections (Headline, What is Changing, Why Now, Out of Scope), fits on one rendered page, contains no implementation detail (no frameworks, APIs, file paths beyond `[spec.md](../spec.md)`), and that `spec.md` is byte-identical to before the run.

### Implementation for User Story 1

- [X] T006 [US1] Create `commands/speckit.product.info.md` implementing the full 7-step execution flow from `specs/002-info-command/contracts/command-contract.md`: (1) resolve feature directory by invoking `.specify/extensions/product/scripts/bash/resolve-feature-dir.sh` (or the PowerShell equivalent) and capturing the absolute path as `FEATURE_DIR`, surfacing stderr verbatim on non-zero exit; (2) verify `<FEATURE_DIR>/spec.md` exists and is free of unfilled placeholders and is in English, refusing with the one-line format `[product-info] <CODE>: <remediation>` for E_NO_SPEC, E_PLACEHOLDERS (one line per placeholder), or E_LANGUAGE; (3) list any `[NEEDS CLARIFICATION: ...]` markers found in `spec.md` and ask `Surface these as open questions in product-info.md? (yes/no)`, aborting with E_USER_ABORT on a non-affirmative answer; (4) if `<FEATURE_DIR>/product/product-info.md` already exists, print its path and ask `product-info.md already exists. Overwrite? (yes/no)`, aborting with E_USER_ABORT on a non-affirmative answer; (5) generate `product-info.md` by reading `templates/product-info-template.md` verbatim and substituting bracketed placeholders, enforcing all six writing rules from `plan.md` (English only, no em dash `—`, plain English active voice, no AI-tell phrases `delve`/`tapestry`/`in essence`/`navigate the landscape`/`seamless`/`intuitive`/`leverage`/`robust`, no implementation detail, bullets short and prose full sentences); (6) create `<FEATURE_DIR>/product/` if missing, write atomically via temp file then rename; (7) print the status report (`Wrote: <abs-path>`, `Sections populated: 4 mandatory[, 5 (Open Questions)]`, `Open product questions surfaced: <N>`)
- [X] T007 [US1] Update `extension.yml` to add a second entry under `provides.commands` with `name: speckit.product.info`, `file: commands/speckit.product.info.md`, and a one-line `description` summarizing what the command produces; bump the minor version number consistent with adding a new user-facing command

**Checkpoint**: User Story 1 is fully functional. Running `/speckit-product-info` against a populated `spec.md` produces a valid `product-info.md`. Verify independently before proceeding.

---

## Phase 4: User Story 2 - Stakeholder-readable output (Priority: P2)

**Goal**: The generated `product-info.md` reads as plain language with no code, API names, framework names, or requirement IDs, so a non-technical reader can answer "what is changing and why?" without opening any other file.

**Independent Test**: Open a generated `product-info.md` and verify: no code blocks, no framework or API names, no requirement IDs (FR-NNN, SC-NNN), no em dash character, no banned AI-tell phrases, and that the four sections together answer who/what/why/what-not in plain sentences.

### Implementation for User Story 2

- [X] T008 [P] [US2] Update `.github/scripts/lint-content.sh` to add `templates/product-info-template.md` to the set of linted templates and enforce three checks on it: (1) zero em dash characters (`—`); (2) canonical heading order — `## 1. Headline` precedes `## 2. What is Changing` precedes `## 3. Why Now` precedes `## 4. Out of Scope`, with the optional `## 5. Open Questions` appearing last if present; (3) zero occurrences of the banned AI-tell phrases (`delve`, `tapestry`, `in essence`, `navigate the landscape`, `seamless`, `intuitive`) — mirroring the existing check already applied to `product-spec-template.md`

**Checkpoint**: Running the lint script against `templates/product-info-template.md` passes with no errors.

---

## Phase 5: User Story 3 - Refuse cleanly when prerequisites are not met (Priority: P3)

**Goal**: The command refuses with consistent, actionable error codes (E_NO_PROJECT, E_NO_POINTER, E_BAD_POINTER, E_NO_SPEC, E_PLACEHOLDERS, E_LANGUAGE, E_USER_ABORT) that mirror `/speckit-product-spec`, and writes nothing on any refusal path.

**Independent Test**: Run the command from outside a Spec Kit project, with a missing `spec.md`, with a `spec.md` containing template placeholders, and with a non-English `spec.md`. Verify each case prints exactly one `[product-info] <CODE>: <remediation>` line and leaves the filesystem unchanged.

### Implementation for User Story 3

- [X] T009 [P] [US3] Update `.github/scripts/validate-manifest.sh` to add `commands/speckit.product.info.md` and `templates/product-info-template.md` to the REQUIRED file list so the release pipeline fails if either artifact is missing from the zip (mirrors how `commands/speckit.product.spec.md` and `templates/product-spec-template.md` are currently required)

**Checkpoint**: All three user stories are independently functional. Validate each independently before proceeding to polish.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Documentation and end-to-end validation that spans all user stories.

- [X] T010 [P] Update `README.md` to add a section documenting `/speckit-product-info`: prerequisites (Spec Kit >= 0.2.0, `product` extension installed, a populated `spec.md`); install/upgrade commands; invocation syntax (plain `/speckit-product-info` and `--feature-dir <path>` override); output location (`<feature-dir>/product/product-info.md`); the four mandatory output sections in order; and the troubleshooting table from `specs/002-info-command/quickstart.md` covering E_NO_PROJECT, E_NO_POINTER, E_NO_SPEC, E_PLACEHOLDERS, E_LANGUAGE, and E_USER_ABORT
- [X] T011 Manual smoke test: invoke `/speckit-product-info` against `specs/002-info-command/spec.md` (this feature's own spec), verify `specs/002-info-command/product/product-info.md` is created containing all four mandatory sections in canonical order, is 400 words or fewer, contains no implementation detail, contains no em dash, and that `specs/002-info-command/spec.md` is byte-identical after the run; run `/speckit-product-spec` against the same spec and verify both output files coexist under `specs/002-info-command/product/` without either modifying the other

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies. All four tasks marked [P] can run in parallel.
- **Foundational (Phase 2)**: Depends on Phase 1 completion. **Blocks all user story phases.**
- **US1 (Phase 3)**: Depends on Foundational completion. T006 and T007 run sequentially (T007 version-bumps the manifest that names the file T006 creates).
- **US2 (Phase 4)**: Depends on Foundational completion (template must exist to lint it). Independent of US1 completion — T008 only touches `.github/scripts/lint-content.sh`.
- **US3 (Phase 5)**: Depends on Phase 1 completion (must read validate-manifest.sh first). Independent of US1 and US2 — T009 only touches `.github/scripts/validate-manifest.sh`.
- **Polish (Phase 6)**: T010 depends on US1 completion. T011 depends on US1 + US2 + US3 completion.

### User Story Dependencies

- **US1 (P1)**: Can start after Foundational (Phase 2). No dependency on US2 or US3.
- **US2 (P2)**: Can start after Foundational (Phase 2). No dependency on US1 or US3.
- **US3 (P3)**: Can start after Phase 1 (Setup). No dependency on US1 or US2.

### Within Each User Story

- US1: T006 (command file) must complete before T007 (manifest update references the file)
- US2: T008 is a single independent task
- US3: T009 is a single independent task

### Parallel Opportunities

- All four Setup tasks (T001-T004) run in parallel
- Once Foundational is done: US2 (T008) and US3 (T009) can run in parallel with US1 (T006-T007)
- T010 and T011 run independently (different files)

---

## Parallel Example: After Phase 2 Completes

```
Phase 2 done →
  Thread A: T006 → T007   (US1: command file + manifest)
  Thread B: T008           (US2: lint-content.sh update)
  Thread C: T009           (US3: validate-manifest.sh update)

All three threads done → T010 + T011 (Polish)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (read existing patterns)
2. Complete Phase 2: Foundational (create template — blocks everything)
3. Complete Phase 3: User Story 1 (command file + manifest)
4. **STOP and VALIDATE**: Run `/speckit-product-info` against a real `spec.md` and check output
5. Proceed to US2 and US3 only after US1 is independently verified

### Incremental Delivery

1. Setup + Foundational → Template exists, ready for command work
2. US1 complete → `/speckit-product-info` is usable end-to-end (MVP)
3. US2 complete → Linter enforces output quality on every release build
4. US3 complete → Validator blocks malformed release zips
5. Polish complete → README documents the new command, smoke test confirms all stories

---

## Notes

- No tests are generated. The spec does not request TDD; validation is manual smoke testing and pipeline self-tests (manifest validation, content lint, tag-version match) on tag push.
- [P] tasks touch different files with no shared state — they can safely run in parallel.
- [Story] labels map each task to its user story for traceability and independent delivery.
- The command file (`commands/speckit.product.info.md`) is a markdown instruction set for the host AI assistant, not a shell script. It must be written so the AI can execute the 7-step flow described in `specs/002-info-command/contracts/command-contract.md` without additional context.
- Atomic write (temp file + rename) is required for FR-004. Do not skip it.
- The `Created` date field in the output is the only field permitted to differ between two consecutive idempotent runs (FR-011).
