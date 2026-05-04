# Data Model: Product Plan Command

**Feature**: 003-product-plan-command
**Date**: 2026-05-04

---

## Entities

### 1. Engineering plan (`plan.md`)

- **Role**: Primary source input. Read-only.
- **Produced by**: `/speckit.plan`
- **Location**: `<feature-dir>/plan.md`
- **Fields consumed by this command**:
  - Summary section (for the product plan Summary)
  - Technical Context block (for Component Overview and the appetite/scope of each phase)
  - Phase sections (for Delivery Phases: names, scopes, outcomes)
  - Key design decisions (for Key Technical Decisions)
  - Risk register or risk notes (for Risks)
  - Open questions or marked assumptions (for Open Questions)
- **Validation**:
  - Must exist (`E_NO_PLAN`)
  - Must not contain placeholder strings from the plan template (`E_PLACEHOLDERS`): `[FEATURE]`, `[DATE]`, `[###-feature-name]`, `[link]`, `[Extract from feature spec: primary requirement + technical approach from research]`
  - Must be in English (`E_LANGUAGE`)
  - May be sparse (valid structure but minimal content); emits a non-blocking console notice in this case

---

### 2. Feature specification (`spec.md`)

- **Role**: Optional supplementary context input. Read-only.
- **Produced by**: `/speckit.specify`
- **Location**: `<feature-dir>/spec.md`
- **Fields consumed by this command**:
  - Personas / Target Users (for Component Overview audience framing, if present)
  - Problem Statement / Why Now (for the Summary Why Now framing)
  - User stories (for cross-checking phase outcomes)
- **Validation**: None. The command proceeds silently if `spec.md` is absent.

---

### 3. Product plan (`product/plan.md`)

- **Role**: Output artifact. Written by this command.
- **Location**: `<feature-dir>/product/plan.md`
- **Template**: `templates/product-plan-template.md`
- **Structure**:

| Section | Type | Always present? | Source in `plan.md` |
|---|---|---|---|
| Header metadata | Metadata | Yes | Feature name, date |
| Summary | Prose | Yes | Summary section + optional spec.md context |
| Delivery Phases (NOW/NEXT/LATER) | Structured | Yes | Phase sections |
| Out of Scope | List | Yes | Constraints / Out of Scope from engineering plan or spec |
| Component Overview | List | Optional | Technical Context / Project Structure sections |
| Key Technical Decisions | Structured | Optional | Design decisions, ADR sections |
| Risks | List | Optional | Risk register or risk notes |
| Open Questions | List | Optional | Open questions or NEEDS CLARIFICATION markers in plan.md |

- **Idempotence**: Running the command twice on an unchanged `plan.md` produces the same output (modulo the Created date).
- **Overwrite behavior**: If `product/plan.md` already exists, the command asks "Overwrite? (yes/no)" before writing. Non-affirmative answer aborts with `E_USER_ABORT`.

---

### 4. Product plan template (`templates/product-plan-template.md`)

- **Role**: Structural skeleton for the generated artifact. Read by the command at generation time.
- **Location in source**: `templates/product-plan-template.md` (repo root)
- **Location when installed**: `.specify/extensions/product/templates/product-plan-template.md`
- **Constraints**: The command must use this template verbatim as the structural skeleton. Section names and order are fixed. The command must not add, remove, or reorder sections.

---

## State transitions

```
plan.md (populated)
  └─[/speckit.product.plan]─► product/plan.md (Draft)
                                  │
                           (user edits / reviews)
                                  │
                              product/plan.md (Reviewed)
```

The command only produces the Draft state. Status transitions beyond Draft are manual.

---

## File constraints

- The command reads: `plan.md`, optionally `spec.md`, `templates/product-plan-template.md`
- The command writes: `product/plan.md` (and creates `product/` if absent)
- The command never writes: `plan.md`, `spec.md`, `tasks.md`, `product/spec.md`, `product/info.md`, `.specify/feature.json`, `.specify/extensions.yml`, or any file outside the resolved feature directory
