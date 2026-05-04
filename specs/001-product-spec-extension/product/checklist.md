# Product Spec Quality Checklist: Product Spec Extension for Spec Kit

**Source Spec**: [spec.md](../spec.md)
**Product Spec**: [product-spec.md](./product-spec.md)
**Created**: 2026-05-04

## Structure

- [ ] Section 1, Headline, is present and contains a one paragraph customer facing summary.
- [ ] Section 2, Target Users and Personas, is present and lists at least one persona.
- [ ] Section 3, Problem Statement, is present and contains a Job to Be Done in the form "When ..., I want to ..., so I can ...".
- [ ] Section 4, Value Proposition, is present.
- [ ] Section 5, Scope, is present and lists at least one included capability.
- [ ] Section 6, Out of Scope, is present and lists at least one excluded capability.
- [ ] Section 7, Use Cases, is present and contains at least one scenario.
- [ ] Section 8, Success Metrics, is present and contains exactly one north star metric and at least one supporting metric.
- [ ] Section 9, Risks and Open Product Questions, is present.
- [ ] Sections appear in the canonical order (1 through 9, then optional 10 and 11 if present).

## Style

- [ ] The document is written entirely in English.
- [ ] The document contains no em dash character.
- [ ] Every Use Case scenario contains exactly one Given line, one When line, and one Then line.
- [ ] Every Given, When, and Then line is a full sentence beginning with the keyword.
- [ ] Bullets are short. Prose is in full sentences.
- [ ] Voice is active and human. There are no AI tells (no "delve", no "tapestry", no "in essence").

## Content

- [ ] No implementation detail appears in the document (no frameworks, languages, APIs, data stores, code, or file paths other than the cross link to `spec.md`).
- [ ] The Job to Be Done uses an action verb and does not name a solution.
- [ ] Each Use Case scenario describes behavior, not implementation.
- [ ] Each metric in Section 8 is measurable and technology agnostic.
- [ ] Every `[NEEDS CLARIFICATION]` marker present in the source spec is surfaced in Section 9 as an open product question, not silently resolved.
- [ ] The header contains a working link back to the source spec at `./spec.md`.

## Optional sections

- [ ] If Section 10, Positioning, is present, it follows the "For ... who ... this product is a ... that ... unlike ... this product ..." structure.
- [ ] If Section 11, Go to Market and Rollout, is present, it lists audience, channel and message, rollout sequence, and launch readiness signal.

## Notes

- A failure in any Required item must be fixed before the product spec is shared with stakeholders.
- Optional section items only apply if that section is present in the document.
