# Research: Product Spec Methodologies and Output Format

**Feature**: 001-product-spec-extension
**Date**: 2026-05-04
**Purpose**: Decide which established product spec methodologies and writing conventions the extension's template will follow, so every generated `product-spec.md` is consistent, recognizable, and grounded in well studied practice.

## Methodology Research

### Decision: Adopt a blend of Working Backwards (PRFAQ), Jobs to Be Done, Gherkin BDD, and Lean PRD

**Rationale**: No single framework covers all the sections a product spec needs (customer narrative, problem framing, scope discipline, testable scenarios, measurable outcomes). Each of the chosen frameworks is widely used, well documented, and recognizable on sight, so a reader who knows any one of them can navigate the document without onboarding. Blending them into a single template gives the spec a familiar shape without inventing a new format.

**Alternatives considered**:

- *A single methodology, end to end (pure PRFAQ, or pure Lean PRD)*: rejected because each one alone is incomplete. Pure PRFAQ has no formal scope or scenario section. Pure Lean PRD has no narrative customer framing. Pure JTBD is a job statement format, not a document structure.
- *Custom in house format*: rejected because the user explicitly asked for established, recognizable patterns, and a custom format burdens every reader with new conventions.
- *Opportunity Solution Tree (Teresa Torres)*: considered for the problem framing section, rejected as the primary structure because it works better as a discovery artifact than as a final spec.

### Components and where they apply

#### Working Backwards / Amazon PRFAQ

**Used for**: the opening "headline" framing of the product spec (one liner, customer benefit, evocative summary).

**What we take**: the discipline of writing the customer facing summary first, before any internal detail. The first section of the template is a short prose block in the spirit of a press release headline, sub headline, and one paragraph summary, followed by an optional internal FAQ.

**What we do not take**: we do not require a literal press release with a fictional dateline and CEO quote. That formality is useful at Amazon but adds noise for smaller teams.

**Source**: Amazon's PRFAQ process, [Working Backwards: PRFAQ Process](https://workingbackwards.com/concepts/working-backwards-pr-faq-process/), and Product School's overview, [Discover PRFAQ](https://productschool.com/blog/product-fundamentals/prfaq).

#### Jobs to Be Done (Ulwick / Christensen)

**Used for**: the problem statement section. Every product spec must include at least one job statement.

**Format adopted (Ulwick style)**:

> When [situation], I want to [motivation], so I can [expected outcome].

**Rules enforced in the template**:

- Use an action verb for the motivation (find, minimize, avoid, understand, keep).
- Do not name a solution inside the job statement (no product names, no features).
- Keep the statement stable over time. If it would change in ten years, it is too specific.

**Source**: Tony Ulwick, [Jobs to Be Done: A Framework for Customer Needs](https://jobs-to-be-done.com/jobs-to-be-done-a-framework-for-customer-needs-c883cbf61c90); Strategyn, [Jobs to Be Done: The Original Framework](https://strategyn.com/jobs-to-be-done/).

#### Gherkin BDD (Cucumber)

**Used for**: the use cases and scenarios section. Every scenario follows Given, When, Then.

**Rules enforced in the template**:

- Each scenario has exactly one `Given`, one `When`, and one `Then` line.
- Each line is one full sentence, starting with the keyword, in plain English.
- Scenarios describe behavior, not implementation. No UI element names, no API names, no internal mechanics.
- Scenarios are independent. None depends on a prior scenario's state.
- Aim for fewer than ten total scenarios per spec. Split rather than overload.

**Source**: Cucumber, [Writing Better Gherkin](https://cucumber.io/docs/bdd/better-gherkin/); Automation Panda, [BDD 101: Writing Good Gherkin](https://automationpanda.com/2017/01/30/bdd-101-writing-good-gherkin/).

#### Lean PRD

**Used for**: the structural backbone (problem, solution at a high level, why now, success metrics, scope, out of scope, risks).

**What we take**: the compactness. A Lean PRD fits on two pages. The product spec aims for a similar length (target one to three pages of prose plus scenarios), discouraging the "fill every section because it is there" failure mode.

**Source**: industry convention popularized by Spotify and similar teams. No single canonical URL, treated as a shared lean practice.

#### Success metrics framing (HEART and AARRR for inspiration)

**Used for**: the success metrics section. The template asks for one north star metric plus two to four supporting metrics, optionally grouped by HEART (Happiness, Engagement, Adoption, Retention, Task success) or AARRR (Acquisition, Activation, Retention, Referral, Revenue) where it fits.

**Rules**: every metric must be measurable and technology agnostic, matching the rule already enforced by Spec Kit's specification template.

## Style and Voice Research

### Decision: Human voice, English, no em dash, no AI tells

**Rationale**: the user explicitly asked for output that does not look AI generated. Em dashes (`—`) are one of the most common AI tells in current model output. Removing them, plus a short list of phrases to avoid, gives the document a more human cadence at near zero cost.

**Rules encoded into the command prompt and the template**:

- All output is in English. If the source spec is in another language, abort with a clear message; do not auto translate.
- No em dash anywhere. Use commas, parentheses, colons, semicolons, or sentence breaks instead.
- Avoid hedging filler ("it is worth noting", "in essence", "delve into", "tapestry").
- Prefer active voice and short sentences.
- Bullets are short. Prose is in full sentences.
- Section headings are stable and identical in every generated spec, so readers can skim across features.

### Decision: Always include both Scope and Out of Scope sections

**Rationale**: explicit non goals are the highest leverage section in any product spec. They prevent scope creep more effectively than any other artifact in the document. Both sections are mandatory in the template, even if Out of Scope is short.

## Open Decisions Resolved by Research

All Technical Context entries are resolved. No `NEEDS CLARIFICATION` markers remain after this research pass.

## Inputs Forwarded to Phase 1

- The product spec template will have a fixed, ordered list of sections (defined in `contracts/product-spec-template.md`).
- The quality checklist will mirror that section list one to one (defined in `contracts/quality-checklist.md`).
- The command prompt scaffolding will quote the style rules above verbatim, so the AI assistant cannot drift.
