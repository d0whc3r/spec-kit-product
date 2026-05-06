# Technical Design: [FEATURE NAME]

**Feature**: [FEATURE NAME]
**Created**: [DATE]
**Status**: Draft

## Summary

[2-4 sentences. What is being built technically, which system layers are affected, and the key architectural approach. Enough for a tech lead to understand scope at a glance.]

## Technical Context

**Current state**: [One sentence describing the relevant part of the system as it exists today.]
**Affected layers**: [Comma-separated list: e.g. frontend, API layer, data layer, background jobs, infra.]
**Technical constraints**:

- [Constraint derived from plan.md or spec.md — e.g. latency budget, backward compatibility requirement, approved library policy.]
- [Constraint 2]

## Architectural Approach

[3-6 paragraphs. How the solution fits into the existing architecture. Which components are added, changed, or removed. How they connect and why this structure was chosen over alternatives. Reference component and module names. State the key design principles driving the approach. No code, no framework-specific syntax.]

## Affected Modules

| Module / Component | Change | Responsibility |
|---|---|---|
| [name] | adds / modifies / removes / uses | [One sentence: what it does and why it changes.] |
| [name] | adds / modifies / removes / uses | [One sentence.] |

## Data Design

### Data Model

[List the key entities and their main fields at shape level. Sufficient for a reviewer to understand the data contract. No full ORM schema or migration DDL. Use plain text blocks.]

```text
[Entity name]
- [field]: [type] — [purpose or constraint]
- [field]: [type]
```

### Data Flow

[How data moves through the system: what triggers creation or mutation, where it persists, what events or messages are emitted downstream.]

## API Design

[Describe endpoint or operation shapes at a conceptual level. Request and response shapes, key error cases, and important constraints. Not a full OpenAPI spec — enough for a tech lead to assess the surface area and spot design issues.]

```text
[METHOD] [/path]
  Request:  [key fields and types]
  Response: [key fields and types]
  Errors:   [HTTP status or error code] — [meaning]
```

## Spec Coverage

> Map each use case from spec.md to the component or operation that implements it. Confirms the design covers the full spec surface.

| Use Case (from spec.md) | Component / Operation | Notes |
|---|---|---|
| [Gherkin scenario title or use case ID] | [component name or endpoint] | [key constraint, edge case, or gap] |

## Key Technical Decisions

> Include one subsection per significant decision. Omit the entire section when plan.md has no explicit design choices.

### [Decision title]

**Context**: [What constraint or trade-off forced a decision.]
**Options considered**:
- [Option A — brief pros and cons]
- [Option B — brief pros and cons]

**Decision**: [What was chosen and the primary reason.]
**Consequences**:
- Positive: [What this enables or simplifies.]
- Negative: [Trade-off, future debt, or lock-in introduced.]

## Testing Strategy

- **Unit**: [Modules, functions, or classes to cover. Focus on non-trivial logic.]
- **Integration**: [Cross-component or cross-service flows that must be verified end-to-end at the service level.]
- **E2E / BDD**: [Spec scenarios to automate as priority. Reference use case IDs when available.]
- **Observability**: [Key metrics, structured log events, or traces needed to validate correctness in production.]

## Rollout and Migration

**Strategy**: [Feature flag / dark launch / gradual rollout / big bang. State which and why.]
**Data migration**: [Steps required, reversibility, and risk level. Write "None" if no migration is needed.]
**Rollback**: [How to revert if something goes wrong after deployment.]

## Risks and Mitigations *(optional)*

> Include only when plan.md or spec.md contains concrete risk signals. Omit otherwise.

**[Risk title]**
- **What could go wrong**: [One sentence including consequence.]
- **Probability**: [Low / Medium / High]
- **Impact**: [Low / Medium / High]
- **Mitigation**: [What is in place or planned to reduce this risk.]

## Open Questions *(optional)*

> Include only when unresolved technical decisions remain. Omit otherwise.

- [Technical open question, one sentence.]
