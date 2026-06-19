# Product Quality Checklist: Per-Tenant API Rate Limiting

**Created**: 2026-05-31
**Legend**: `[x]` auto-validated · `[ ]` needs manual review

---

## Info (`product/00-info.md`)

**Validated**: 2026-05-31 · 18/18 items

- [x] Overview present with at least one paragraph
- [x] Overview is four sentences or fewer
- [x] What is Changing present with at least one item
- [x] Out of Scope present with at least one item
- [x] Risks present and backed by real risk signals in the spec
- [x] Key Decisions present because the spec has clarifications
- [x] Key Decisions resolved count matches source clarifications (2)
- [x] No "Still open" block, since the spec has no unresolved markers
- [x] Still-open count matches confirmed markers (zero)
- [x] Sections appear in canonical order
- [x] Written entirely in English
- [x] No em dash present
- [x] No AI-tell phrases present
- [x] Every bullet is twelve words or fewer
- [x] No implementation detail present
- [x] Header has real Feature and Created values
- [x] No References section, since the spec cites no external resources
- [x] No optional marker leaks into a heading

---

## Spec (`product/10-spec.md`)

**Validated**: 2026-05-31 · 25/25 items

- [x] Headline present, states the change versus the status quo
- [x] Glossary present, justified by domain terms (tenant, burst limit, quota)
- [x] Users present with three personas
- [x] Problem section contains a Job to Be Done statement
- [x] Job to Be Done uses an action verb ("keep")
- [x] Assumptions present, justified by explicit spec assumptions
- [x] Scope lists in-scope and out-of-scope capabilities
- [x] Use Cases contains at least one use case (5 present)
- [x] Every use case has exactly one Given, When, and Then
- [x] Each Given/When/Then is a full sentence starting with the keyword
- [x] Each use case describes behavior, not implementation
- [x] Success Metrics has one north star and three supporting metrics
- [x] Each metric is measurable and technology-agnostic
- [x] Risks and Open Questions present
- [x] Sections appear in canonical order
- [x] Positioning omitted, since the source has no positioning content
- [x] Go to Market and Rollout omitted, since the source has no launch motion
- [x] Written entirely in English
- [x] No em dash present
- [x] No implementation detail present
- [x] No AI-tell phrases present
- [x] Every bullet is twelve words or fewer
- [x] Header has real Feature and Created values
- [x] NEEDS CLARIFICATION markers surfaced (source has zero)
- [x] No optional marker leaks into a heading

---

## Plan (`product/20-plan.md`)

**Validated**: 2026-05-31 · 21/21 items

- [x] Summary present with at least one paragraph
- [x] Summary has Problem, For, Change, Quality bar, Constraints
- [x] Goals and Non-Goals present with goals and non-goals
- [x] Delivery Phases present with four phases, each with bullets
- [x] Delivery Phases contain no time estimates or temporal framing
- [x] No invented content; phases map to the source plan's prioritized stories
- [x] Key Decisions follow the mini-ADR format (Context, Options, Decision, Consequence)
- [x] Risks each have probability, impact, and mitigation
- [x] Optional sections present only when the source warrants (Divergences and Open Questions omitted)
- [x] Diagrams present where warranted (journey, two flowcharts, risk quadrant)
- [x] Mermaid blocks are valid and on-style
- [x] Each diagram earns its place under the value gate
- [x] Technical terms glossed on first use (API)
- [x] No time estimates anywhere in the document
- [x] Written entirely in English
- [x] No em dash present
- [x] No AI-tell phrases present
- [x] No code, file paths, or non-mermaid code fences
- [x] Every bullet is twelve words or fewer
- [x] No optional marker leaks into a heading
- [x] Header has real Feature, Source Plan, and Created values

---

## Design (`product/30-design.md`)

**Validated**: 2026-05-31 · 24/24 items

- [x] Summary present with at least two sentences
- [x] Summary has Current state, Affected layers, Constraints
- [x] Non-Functional Requirements present, with ISO 25010 categories and numeric targets
- [x] Architectural Approach present with four paragraphs
- [x] Affected Modules table present with ten rows
- [x] Data Design present, backed by the data-model entities
- [x] API Design present, backed by the three contract surfaces
- [x] Spec Coverage table maps every use case to a component
- [x] Spec Coverage has no unaddressed gaps
- [x] Key Technical Decisions follow Context, Options, Decision, Consequences
- [x] Risks each have probability, impact, and mitigation
- [x] Testing Strategy present with Unit, Integration, E2E/BDD, Observability
- [x] Rollout and Migration present with Strategy, Data migration, Rollback
- [x] Optional sections present only when warranted (Open Questions omitted)
- [x] Diagrams present where warranted (flowchart, ER, data flow, sequence, risk quadrant)
- [x] Mermaid blocks are valid
- [x] Each diagram earns its place under the value gate
- [x] No runnable code; only text and mermaid fenced blocks
- [x] Written entirely in English
- [x] No em dash present
- [x] No AI-tell phrases present
- [x] Every prose bullet is twelve words or fewer
- [x] No optional marker leaks into a heading
- [x] Header has real Feature and Created values

---

## Needs Review

> All items auto-validated. No manual review required.
