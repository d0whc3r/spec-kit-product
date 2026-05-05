# Product Plan: [FEATURE NAME]

**Feature**: [FEATURE NAME]
**Source Plan**: [plan.md](../plan.md)
**Created**: [DATE]
**Status**: Draft

## 1. Summary

> One to two paragraphs, four to six sentences total. Three parts: why this work exists and what problem it solves, what is being built and for whom, and the high-level approach chosen. No code. No file paths. No time estimates. Technical terms glossed on first use.

[Paragraph here.]

## 2. Goals

> Three to six short bullet points. Each goal is one sentence naming a concrete outcome this feature delivers or enables when complete. Goals must be observable - a reader unfamiliar with the project should be able to tell whether each goal was met after the feature ships.

- [Concrete outcome this feature delivers, one sentence ending with a period.]
- [Concrete outcome this feature delivers, one sentence ending with a period.]
- [Concrete outcome this feature delivers, one sentence ending with a period.]

## 3. Out of Scope

> A short, scannable list of what is explicitly not included, even though a reasonable reader might expect it. Always populate this section. Each item is one short sentence with a one-phrase reason. Draw from the plan's out-of-scope or exclusions list.

- [Capability deliberately excluded, with one short reason.]
- [Capability deliberately excluded, with one short reason.]

## 4. Architecture Overview *(optional)*

> Include this section only when the source plan contains architecture, component, or structural information. Omit the entire section otherwise - do not write "none" or "N/A".
>
> Two parts: a short narrative paragraph (two to four sentences) describing how the main parts of the system connect and why the structure was chosen, followed by a component list. Each component is one bullet: name, one-sentence responsibility, and whether this feature adds, modifies, or reads from it. C4 container level only - no classes, no functions, no internal wiring.

[Narrative paragraph describing the overall structure and how the parts connect.]

- **[Component name]**: [What it does, one sentence. This feature [adds / modifies / reads from] it.]
- **[Component name]**: [What it does, one sentence. This feature [adds / modifies / reads from] it.]

## 5. Key Principles *(optional)*

> Include this section only when the source plan articulates explicit constraints, guard rails, or core rules that govern how the implementation decisions are made. Omit the entire section otherwise.
>
> Four to eight bullets. Each principle is one short imperative sentence stating the rule, followed by a one-phrase reason. Principles must be discriminating - they should actively rule out some approaches. A principle that every approach satisfies is not a principle.

- **[Principle name]**: [The rule in one sentence, followed by a one-phrase reason.]
- **[Principle name]**: [The rule in one sentence, followed by a one-phrase reason.]

## 6. Delivery Phases

> One subsection per phase from the source plan, organized as NOW / NEXT / LATER bands. Each phase has a name and two to four outcome bullets. Outcomes describe what is delivered or enabled by the phase - not the tasks to perform. No time estimates, no durations, no appetite framing, no sprint references.

### NOW

#### Phase [N]: [Phase Name]

- [What this phase delivers or enables, one sentence ending with a period.]
- [What this phase delivers or enables, one sentence ending with a period.]
- [What this phase delivers or enables, one sentence ending with a period.]

### NEXT

- [What the next planned phase delivers, one sentence.]
- [What the next planned phase delivers, one sentence.]

### LATER

- [What is deferred and why, one sentence.]

## 7. Key Technical Decisions *(optional)*

> Include this section only when the source plan contains explicit design decisions. Omit the entire section otherwise.
>
> Each decision uses the condensed ADR (Architecture Decision Record - a short log of a key design choice) format: Decision, Why, Trade-off.

### [Decision title]

**Decision**: [What was chosen, one sentence.]
**Why**: [The plain-language reason, one to two sentences.]
**Trade-off**: [What was accepted or given up, one sentence.]

---

### [Decision title]

**Decision**: [What was chosen, one sentence.]
**Why**: [The plain-language reason, one to two sentences.]
**Trade-off**: [What was accepted or given up, one sentence.]

## 8. Risks and Mitigations *(optional)*

> Include this section only when the source plan contains concrete risk signals. Apply the pre-mortem lens: imagine this feature shipped and quietly failed - what caused it? Two to four entries. Each entry names one risk and its consequence, then the concrete mitigation in place. Omit generic or speculative risks. Remove the entire section when the source plan has no meaningful risk signals.

**[Risk name]**: [What could go wrong and its consequence, one sentence.]
*Mitigation*: [What is in place to prevent or reduce the impact, one sentence.]

**[Risk name]**: [What could go wrong and its consequence, one sentence.]
*Mitigation*: [What is in place to prevent or reduce the impact, one sentence.]

## 9. Divergences and Edge Cases *(optional)*

> Include this section only when the source plan explicitly handles scenarios that deviate from the normal flow - unusual inputs, boundary conditions, failure states, or cases where the system behaves differently than a reader would expect. Omit the entire section when the plan does not describe such scenarios.
>
> Each entry is one sentence naming the scenario and one sentence stating how the system handles it. Plain language only - no error codes, no technical names for handlers or exceptions.

- **[Scenario name]**: [What the scenario is, one sentence. How the system handles it, one sentence.]
- **[Scenario name]**: [What the scenario is, one sentence. How the system handles it, one sentence.]

## 10. Validation Checks *(optional)*

> Include this section only when the source plan defines explicit acceptance criteria, observable signals, or checks that confirm the feature is working correctly. Omit the entire section when the plan does not specify validation criteria.
>
> Each item is one sentence describing a concrete, observable condition that confirms a part of the feature is correct. Written from the perspective of someone reviewing the shipped feature, not a developer running tests.

- [Observable condition that confirms a part of the feature is correct, one sentence.]
- [Observable condition that confirms a part of the feature is correct, one sentence.]

## 11. Open Questions *(optional)*

> Include this section only when the source plan contains open questions or marked assumptions. Each item becomes one bullet as a single-sentence question. Never silently resolve an open question.

- [Open question in one sentence.]
- [Open question in one sentence.]
