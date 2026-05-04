# Contract: Product Spec Template

This file is the **canonical product spec template**. Every `product-spec.md` produced by `/speckit-product-spec` follows this structure exactly, in this order. Sections marked Optional may be omitted by teams who do not need them; the quality checklist will not fail an absent optional section. Mandatory sections must always be present and populated.

The template is grounded in: Amazon Working Backwards (PRFAQ) for the headline, Jobs to Be Done (Ulwick) for the problem statement, Gherkin BDD for use case scenarios, and Lean PRD for overall compactness.

> **Style rules that apply to every section**
>
> 1. Written in English.
> 2. No em dash character. Use commas, parentheses, colons, semicolons, or sentence breaks.
> 3. Plain English, active voice, short sentences.
> 4. No frameworks, languages, APIs, data stores, code, or file paths (other than the link to `spec.md` in the metadata).
> 5. Bullets are short. Prose is full sentences.

---

## Template Body

```markdown
# Product Spec: [FEATURE NAME]

**Feature**: [###-feature-name]
**Source Spec**: [spec.md](./spec.md)
**Created**: [DATE]
**Status**: Draft

## 1. Headline

> One sentence that a customer would say back to a friend, describing what this product does and why they would care.

[One paragraph, three to five sentences, in the voice of a press release summary. State the customer, the problem, and the new outcome they can now reach. No internal jargon. No feature lists.]

## 2. Target Users and Personas

[List the user types this product serves. For each, give a one line description and the single most important thing they care about.]

- **[Persona name]**: [Who they are. What they care about most.]
- **[Persona name]**: [Who they are. What they care about most.]

## 3. Problem Statement (Job to Be Done)

> Use the Ulwick job statement format. Use an action verb. Do not name a solution.

**Primary job**:

> When [situation], I want to [motivation], so I can [expected outcome].

**Why this matters now**: [Two or three sentences on what changed in the user's world, the market, or the company that makes this the right job to address now.]

## 4. Value Proposition

[Two to four sentences. State, in plain language, the change in the user's life that this product creates. Compare against the status quo (what they do today without this product). Be honest about what is new and what is just better.]

## 5. Scope

[A short, scannable list of what is included in this version. Each item is one line. The list is finite and bounded.]

- [Capability included.]
- [Capability included.]
- [Capability included.]

## 6. Out of Scope

[A short, scannable list of what is explicitly not included, even though a reasonable reader might expect it. This section is the highest leverage section in the document. Always populate it; if it feels empty, think harder.]

- [Capability deliberately excluded, with one short reason.]
- [Capability deliberately excluded, with one short reason.]

## 7. Use Cases

> Each scenario follows Gherkin Given, When, Then. One Given, one When, one Then per scenario. Each line is a full sentence starting with the keyword. Describe behavior, not implementation. Aim for fewer than ten scenarios across the whole spec.

### Use Case 1: [Short title in plain language]

**Given** [one full sentence describing the starting context the user is in].
**When** [one full sentence describing the action the user takes].
**Then** [one full sentence describing the outcome the user observes].

### Use Case 2: [Short title in plain language]

**Given** [one full sentence describing the starting context the user is in].
**When** [one full sentence describing the action the user takes].
**Then** [one full sentence describing the outcome the user observes].

### Use Case 3: [Short title in plain language]

**Given** [one full sentence describing the starting context the user is in].
**When** [one full sentence describing the action the user takes].
**Then** [one full sentence describing the outcome the user observes].

## 8. Success Metrics

> One north star metric. Two to four supporting metrics. Each metric is measurable and technology agnostic. No frameworks, no system internals.

**North star**:

- **[Metric name]**: [Definition in one sentence. Target value and the time window over which it is measured.]

**Supporting metrics**:

- **[Metric name]**: [Definition. Target.]
- **[Metric name]**: [Definition. Target.]

## 9. Risks and Open Product Questions

[A short list of the things that could go wrong, plus the open questions that the team has not yet answered. If the source spec contained `[NEEDS CLARIFICATION]` markers, each one is surfaced here as an open product question, not silently resolved.]

**Risks**:

- [Risk in one sentence. Why it matters.]
- [Risk in one sentence. Why it matters.]

**Open product questions**:

- [Question in one sentence.]
- [Question in one sentence.]

## 10. Positioning *(optional)*

> Include this section only when the product has external users or competes with alternatives. Internal tools may omit it.

**For** [target customer]
**who** [statement of need or opportunity]
**this product is a** [product category]
**that** [key benefit, compelling reason to use]
**unlike** [primary alternative]
**this product** [primary point of differentiation].

## 11. Go to Market and Rollout *(optional)*

> Include this section only when there is a launch motion. Internal tools or background features may omit it.

- **Audience for the first release**: [Who gets it first. Why.]
- **Channel and message**: [How users will hear about it. The one sentence message.]
- **Rollout sequence**: [Stage one, stage two, stage three, in plain language.]
- **Launch readiness signal**: [The single observable condition that says we are ready to ship.]

---

**End of template.**
```

---

## Notes for the Generator

- The generator must produce every Mandatory section (1 through 9) in the order shown, with stable headings.
- Optional sections (10 and 11) appear only when there is real content for them. Empty optional sections are removed from the output, not left as `N/A`.
- All bracketed placeholders in the template body are replaced with concrete content drawn from the source spec.
- If the source spec lacks the information needed to populate a mandatory section, the generator must populate that section with an open product question (in section 9) rather than fabricate content.
- The `[Source Spec]` link in the header is always present and always relative (`./spec.md`).
