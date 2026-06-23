# Product Spec: [FEATURE NAME]

**Feature**: [FEATURE NAME]
**Created**: [DATE]
**Status**: Draft

> Authoring note (not emitted in the generated document): write every prose section to follow the humanization guide at `templates/humanization-guide.md` - plain English, varied cadence, no AI-tell phrases, no em dash.

## Headline

> One paragraph, three to four sentences. Name who it is for, the problem they have today, what changes, and why that beats the status quo. No internal jargon, no feature lists.

[Paragraph. Lead with one sentence a customer would repeat to a friend, then state the change against what they do today.]

## Glossary _(optional)_

> Only when the spec uses domain or technical terms a non-technical stakeholder may not know. One plain sentence each. Omit when there is no vocabulary gap.

- **[Term]**: [Plain-language definition in one sentence.]
- **[Term]**: [Plain-language definition in one sentence.]

## Users

> Who this serves. One line each: who they are and the single thing they care about most.

- **[Persona name]**: [Who they are. What they care about most.]
- **[Persona name]**: [Who they are. What they care about most.]

## Problem (Job to Be Done)

> Ulwick job statement: action verb, no solution named. Then one line on why now.

> When [situation], I want to [motivation], so I can [expected outcome].

**Why now**: [The concrete trigger that makes this the moment, or "No time-sensitive trigger; this is a standing need."]

## Assumptions _(optional)_

> Only when the feature rests on conditions believed true but not confirmed. One sentence each, with what would invalidate it. Omit when none.

- [Assumption in one sentence. What would invalidate it.]
- [Assumption in one sentence. What would invalidate it.]

## Scope

> Two short lists. Out of scope is the highest-leverage part; always populate it. If it feels empty, think harder.

**In scope**:

- [Capability included.]
- [Capability included.]

**Out of scope**:

- [Capability excluded, with one short reason.]
- [Capability excluded, with one short reason.]

## Use Cases

> Gherkin Given/When/Then: one of each per scenario, full sentences, behavior not implementation. Aim for fewer than six.

### Use Case 1: [Short title in plain language]

**Given** [one sentence describing the starting context].
**When** [one sentence describing the action the user takes].
**Then** [one sentence describing the outcome the user observes].

### Use Case 2: [Short title in plain language]

**Given** [one sentence describing the starting context].
**When** [one sentence describing the action the user takes].
**Then** [one sentence describing the outcome the user observes].

## Success Metrics

> One north star, one or more supporting. Each measurable and technology agnostic.

**North star**:

- **[Metric name]**: [Definition, target value, and the time window measured.]

**Supporting**:

- **[Metric name]**: [Definition. Target.]
- **[Metric name]**: [Definition. Target.]

## Risks and Open Questions

> Product and adoption risks, plus product questions the team has not answered. This is the home for product-level risk; delivery risks live in the plan and technical risks in the design doc. Every `[NEEDS CLARIFICATION]` marker from the source spec appears here, never silently resolved.

**Risks**:

- [Risk in one sentence. Why it matters.]
- [Risk in one sentence. Why it matters.]

**Open questions**:

- [Question in one sentence.]
- [Question in one sentence.]

## Positioning _(optional)_

> Only when the product has external users or competes with alternatives. Internal tools omit it.

**For** [target customer]
**who** [statement of need or opportunity]
**this product is a** [product category]
**that** [key benefit, compelling reason to use]
**unlike** [primary alternative]
**this product** [primary point of differentiation].

## Go to Market and Rollout _(optional)_

> Only when there is a launch motion. Internal tools or background features omit it.

- **First release audience**: [Who gets it first. Why.]
- **Channel and message**: [How users hear about it. The one-sentence message.]
- **Rollout sequence**: [Stage one, stage two, stage three.]
- **Launch readiness signal**: [The single observable condition that says we are ready to ship.]
