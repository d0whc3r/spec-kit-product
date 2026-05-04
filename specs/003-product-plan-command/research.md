# Research: Product Plan Command

**Feature**: 003-product-plan-command
**Date**: 2026-05-04
**Resolved unknowns**: 4

---

## 1. Shape Up appetite framing

**Decision**: Use appetite as a short time-box label per phase (e.g., "one to two weeks", "two to three hours"), not as a date estimate.

**Rationale**: Basecamp's Shape Up methodology defines appetite as how much time a team is willing to invest - a fixed budget, not a guess. It bounds the work rather than predicting its duration. For a product plan artifact, this gives readers a quick read on the relative weight of each phase without committing to calendar dates. It also signals intent: the work is bounded, not open-ended.

**Alternatives considered**: Using story points (too developer-specific, no meaning to a product manager without team calibration) or T-shirt sizes (too vague, no grounding in real time). Appetite framing is concrete ("one to two weeks" means something to any reader) and directly maps to the engineering plan's phase scope.

**Adaptation for the template**: Each phase in the Delivery Phases section includes one appetite line. The appetite is a rough range in plain time units (hours, days, weeks). It is drawn from the engineering plan's phase scope, not invented.

---

## 2. C4 Model - container level

**Decision**: Use the C4 container level as the pattern for Component Overview. Describe each major part of the system that this feature adds, changes, or depends on, in one sentence each.

**Rationale**: The C4 model (Simon Brown) has four levels: Context (system and actors), Container (major runtime parts), Component (internal pieces), and Code (classes/functions). The context level is too coarse for an implementation plan. The component and code levels are too detailed for a product audience. The container level names the main runtime elements - scripts, files, commands, templates - with their responsibilities. This is the right level: concrete enough to understand what is being built, not so detailed that it requires engineering knowledge to follow.

**Alternatives considered**: A full deployment diagram (too visual and technical), a simple bulleted list of changed files (too close to a diff, not explanatory), or a narrative paragraph (harder to scan). The container-level table or list is fast to read and directly answerable from the engineering plan's Project Structure section.

**Adaptation for the template**: Component Overview is an optional section. It lists affected components as brief bullets: component name, one-sentence responsibility, and whether this feature adds or modifies it. No internal wiring, no class names, no function signatures.

---

## 3. ADR (Architecture Decision Record) - condensed summary

**Decision**: Condense each architecture decision to three fields: Decision (what was chosen), Why (plain-language reason, one to two sentences), Trade-off (what was accepted or given up, one sentence).

**Rationale**: Michael Nygard's original ADR format includes Title, Status, Context, Decision, and Consequences. For a product plan, the full format is too long and the Context section duplicates the Summary. The three-field condensed form preserves the most useful signal for a cross-functional reader: what was decided, why it was the right call, and what it costs. It is short enough to include for every significant decision without making the document heavy.

**Alternatives considered**: Full ADR format (too long, duplicates other sections), a simple decision list without rationale (loses the "why" which is the most valuable part for product and leadership), or deferring all decisions to the engineering plan with a cross-reference (defeats the purpose of a self-contained product artifact).

**Adaptation for the template**: Key Technical Decisions is an optional section. Each decision entry uses the three-field pattern. The section is omitted entirely when the engineering plan has no explicit design decisions.

---

## 4. NOW/NEXT/LATER delivery view

**Decision**: Structure the Delivery Phases section as three bands: NOW (current feature scope broken into phases), NEXT (the natural follow-on after this feature, not committed), and LATER (explicitly deferred work drawn from the Out of Scope list).

**Rationale**: NOW/NEXT/LATER is a simple three-horizon product roadmap framework used widely in product management to communicate sequencing without false date precision. In the context of a single-feature product plan, NOW describes the implementation phases for this feature, NEXT signals what the team expects to address afterward, and LATER surfaces the deliberate deferrals from Out of Scope. This gives the reader both the current plan and enough context about what comes next to understand the boundaries of this scope.

**Alternatives considered**: A simple numbered phase list (loses the roadmap context, NEXT and LATER are invisible), a Gantt-style timeline (too implementation-specific, requires dates), or a quarterly OKR-style table (too heavy for a single-feature plan). The three-band approach is lightweight, readable, and maps naturally to the phases already in the engineering plan.

**Adaptation for the template**: Delivery Phases uses three headings - NOW, NEXT, LATER. Each NOW phase has a name, appetite, and two to four outcome bullets. NEXT and LATER are each a short note (one to three bullets) rather than full phase descriptions.
