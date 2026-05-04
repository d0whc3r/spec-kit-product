---
description: "Task list for the product plan command implementation"
---

# Tasks: Product Plan Command

**Input**: Design documents from `specs/003-product-plan-command/`
**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, contracts/ ✓, quickstart.md ✓

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to ([US1], [US2], [US3])

---

## Phase 1: Setup

**Purpose**: Confirm structural parity with sibling commands before writing any new files.

- [X] T001 Review commands/speckit.product.spec.md and commands/speckit.product.info.md to confirm the execution step structure, refusal format, overwrite check format, and template reference pattern to be mirrored in the new command

---

## Phase 2: User Story 1 - Generate a high-level product plan from an existing engineering plan (Priority: P1)

**Goal**: The command reads `plan.md` (and optional `spec.md`) and writes `<feature-dir>/product/plan.md` using the product plan template.

**Independent Test**: Take the populated `specs/003-product-plan-command/plan.md` from this feature. Run `/speckit.product.plan`. Verify that `product/plan.md` is written, contains the three mandatory sections (Summary, Delivery Phases, Out of Scope), uses plain language with technical terms glossed on first use, and that `plan.md` and `spec.md` are untouched.

- [X] T002 [P] [US1] Write templates/product-plan-template.md following the section inventory table and the full template source in specs/003-product-plan-command/contracts/product-plan-template.md. Mandatory sections: Summary, Delivery Phases (NOW/NEXT/LATER), Out of Scope. Optional sections: Component Overview, Key Technical Decisions, Risks, Open Questions. Include guidance blockquotes in each section. No em dash anywhere. Canonical heading order must match the section inventory exactly.

- [X] T003 [US1] Write commands/speckit.product.plan.md following the 8-step execution flow in specs/003-product-plan-command/contracts/command-contract.md. Steps 1-4: resolve feature dir via cross-platform helper scripts, verify plan.md (E_NO_PLAN / E_PLACEHOLDERS / E_LANGUAGE), load spec.md silently when present, check for sparse plan and emit the non-blocking notice. Steps 5-8: overwrite check (E_USER_ABORT on non-affirmative), generate product/plan.md using templates/product-plan-template.md as the structural skeleton, write output to `<feature-dir>/product/plan.md`, confirm written path. Apply all writing rules from specs/003-product-plan-command/contracts/command-contract.md. Reference the template at `templates/product-plan-template.md` (relative to extension root). Mirror the frontmatter, $ARGUMENTS block, Inputs, Templates, and Execution sections from sibling commands (T001 reference).

- [X] T004 [US1] Update extension.yml: add a new entry under `provides.commands` for `speckit.product.plan` pointing to `commands/speckit.product.plan.md`, update `extension.version` from `0.2.0` to `0.3.0`, and update the `description` field to mention all three commands.

**Checkpoint**: At this point US1 is fully functional. The command can be run against any feature with a populated plan.md and produce a valid product/plan.md.

---

## Phase 3: User Story 2 - Use the product plan in cross-functional reviews (Priority: P2)

**Goal**: The generated artifact is readable and complete for a technical stakeholder who did not author the feature. No implementation aside from acceptance review.

**Independent Test**: Open the product/plan.md generated in the US1 checkpoint. Without reading any other file, a reviewer should be able to identify the main delivery phases, the key technical decisions, and the primary risk in under five minutes.

- [X] T005 [US2] Acceptance review: using the product/plan.md generated from the US1 checkpoint, verify (a) all mandatory sections (Summary, Delivery Phases, Out of Scope) are present and populated, (b) each technical term from the banned-jargon list that appears is glossed on its first occurrence only, (c) no AI-tell phrases ("delve", "tapestry", "in essence", "navigate the landscape", "leverage" standalone, "robust" unmeasured, "seamless", "intuitive") appear anywhere, (d) no em dash appears, (e) no code or file paths appear except the `../plan.md` metadata link, (f) every phase present in the source plan.md has a corresponding entry in the generated Delivery Phases section (SC-003 - 100% phase coverage), and (g) after generation, product/spec.md (if present), product/info.md (if present), and tasks.md all have unchanged modification times (FR-008 immutability check). Record wall-clock time from command invocation to file-written confirmation and confirm it is under 90 seconds (SC-005). Fix any violations in commands/speckit.product.plan.md or templates/product-plan-template.md.

**Checkpoint**: At this point US2 is satisfied. The artifact holds up as a standalone communication tool.

---

## Phase 4: User Story 3 - Refuse cleanly when prerequisites are not met (Priority: P3)

**Goal**: All four refusal conditions produce a single-line refusal with no file written, matching the behavior of sibling commands.

**Independent Test**: Run the command in each of the four error conditions below. Each must print exactly one refusal line and write nothing to disk.

- [X] T006 [P] [US3] Verify E_NO_PROJECT: run /speckit.product.plan from a directory with no .specify/ ancestor. Confirm the output is a single refusal line containing "E_NO_PROJECT" and that no file is written.

- [X] T007 [P] [US3] Verify E_NO_PLAN: run /speckit.product.plan against a feature directory that contains .specify/feature.json but no plan.md. Confirm the output is a single refusal line containing "E_NO_PLAN" and includes an instruction to run /speckit.plan first. No file written.

- [X] T008 [P] [US3] Verify E_PLACEHOLDERS: run /speckit.product.plan against a feature directory whose plan.md contains each of the five placeholder strings: `[FEATURE]`, `[DATE]`, `[###-feature-name]`, `[link]`, `[Extract from feature spec: primary requirement + technical approach from research]`. Confirm the output lists each detected placeholder on its own line under "E_PLACEHOLDERS" and writes nothing.

- [X] T009 [P] [US3] Verify E_LANGUAGE: run /speckit.product.plan against a feature directory whose plan.md is written in a non-English language (e.g. Spanish). Confirm the output is a single refusal line containing "E_LANGUAGE" naming the detected language. No file written.

- [X] T010 [P] [US3] Verify E_USER_ABORT: run /speckit.product.plan when product/plan.md already exists and decline the overwrite prompt ("no"). Confirm the command aborts with "E_USER_ABORT" and the existing product/plan.md is unchanged.

**Checkpoint**: At this point US3 is satisfied. All four refusal conditions plus E_USER_ABORT are exercised and confirmed.

---

## Phase 5: Polish and Cross-Cutting Concerns

**Purpose**: Update pipeline scripts so the new files are covered by existing CI checks. Update README.

- [X] T011 [P] Update .github/scripts/validate-manifest.sh: add `"$ROOT/commands/speckit.product.plan.md"` and `"$ROOT/templates/product-plan-template.md"` to the REQUIRED array alongside the existing entries. After updating, perform a timed clean install of the updated extension zip and confirm it completes in under 3 minutes (SC-006).

- [X] T012 [P] Update .github/scripts/lint-content.sh: add checks for the new plan template and command file mirroring the existing info-template checks. Specifically: (a) no em dash in templates/product-plan-template.md, (b) canonical section headings in the correct order (Summary, Delivery Phases, Out of Scope, then optional sections), (c) commands/speckit.product.plan.md references templates/product-plan-template.md, (d) no AI-tell phrases in templates/product-plan-template.md guidance text.

- [X] T013 [P] Update README.md: add a short section describing /speckit.product.plan alongside the existing /speckit.product.spec and /speckit.product.info entries. Include: what the command does, what it reads, what it writes, and the four error codes.

---

## Dependencies

```
T001
  └── T002 (review before writing)
  └── T003 (review before writing)

T002 → T003 (template must exist before command references it)
T003 → T004 (command file must exist before manifest entry is added)
T003 → T005 (command must be complete before acceptance review)
T003 → T006..T010 (command must be complete before refusal tests)

T004 → T011 (manifest updated before validator update)
T002 → T012 (template complete before lint checks added)
T003 → T013 (command complete before README written)
```

## Parallel Execution Opportunities

**After T001 is done (T002 can start; T004 must wait for T003)**:
- T002 (write template) and T003 (write command) can begin once T001 is done
- T004 (update extension.yml) depends on T003 (command file must exist before manifest references it)

**After T003 and T005 are done (US3 verification tasks run in parallel)**:
- T006, T007, T008, T009, T010 all test different conditions against different fixture inputs

**After US1-US3 complete (Polish tasks run in parallel)**:
- T011, T012, T013 all touch different files

## Implementation Strategy

**MVP scope = US1 only (T001 → T002 → T003 → T004)**

Once T004 is complete, the command is installable and can generate product/plan.md from any feature with a populated plan.md. US2 (T005) adds a review pass to validate communication quality. US3 (T006-T010) confirms the refusal conditions work as specified. The Polish phase (T011-T013) ensures CI gates cover the new files and the README reflects the new command.

**Total tasks**: 13
**US1 tasks**: 4 (T001-T004)
**US2 tasks**: 1 (T005)
**US3 tasks**: 5 (T006-T010)
**Polish tasks**: 3 (T011-T013)
