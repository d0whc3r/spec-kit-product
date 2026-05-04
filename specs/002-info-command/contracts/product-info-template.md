# Canonical Template Contract: product-info-template.md

This is the source-of-truth shape for the `product-info.md` artifact. The runtime template at `templates/product-info-template.md` MUST be byte-identical to the canonical body below (the lines between, and including, the two `=== TEMPLATE BODY ===` markers, with the markers themselves stripped).

The release pipeline's `lint-content.sh` is updated to enforce three checks on `templates/product-info-template.md`:

1. The file contains zero em dash characters (`—`).
2. The three mandatory headings appear in canonical order: `## 1. Headline`, `## 2. What is Changing`, `## 3. Out of Scope`. The optional `## 4. Risks` heading, if present, comes after the mandatory headings. The optional `## 5. Open Questions` heading, if present, comes last.
3. The command file `commands/speckit.product.info.md` references `templates/product-info-template.md` by relative path.

Banned AI-tell phrases (full case-insensitive list, mirroring `/speckit-product-spec`): `delve`, `tapestry`, `in essence`, `navigate the landscape`, `seamless`, `intuitive`, `leverage` as a standalone verb, `robust` without a measurable target. None of these may appear in the template, and the command body MUST refuse to ship a generated `product-info.md` that contains any of them.

## Canonical body

=== TEMPLATE BODY ===

# Product Info: [FEATURE NAME]

**Feature**: [###-feature-name]
**Source Spec**: [spec.md](../spec.md)
**Created**: [DATE]
**Status**: Draft

## 1. Headline

> One paragraph, two to four sentences, in plain language. State who this is for, what is changing for them, and the new outcome they can reach. No internal jargon. No feature lists. No implementation detail.

[Paragraph here.]

## 2. What is Changing

> Two to five short bullets, or one short paragraph. Customer-observable language only. Each bullet is a single sentence ending with a period.

- [Bullet here.]
- [Bullet here.]
- [Bullet here.]

## 3. Out of Scope

> A short scannable list of what is explicitly not included, even though a reasonable reader might expect it. Always populate it. If it feels empty, think harder. Each item is one short sentence with a one-phrase reason.

- [Item deliberately excluded, with one short reason.]
- [Item deliberately excluded, with one short reason.]

## 4. Risks *(optional)*

> Pre-mortem: imagine this feature shipped and quietly failed. Two to four bullets naming the most likely causes, drawn directly from the spec. Cover technical or architectural impact where relevant. Each bullet names the risk and its consequence in one sentence. Omit this section entirely if the spec contains no meaningful risk signals.

- [Risk and its consequence in one sentence.]
- [Risk and its consequence in one sentence.]

## 5. Open Questions *(optional)*

> Include this section only when the source spec contained `[NEEDS CLARIFICATION]` markers AND the user confirmed at the prompt. Each marker becomes one bullet, surfaced as a single-sentence question. Never silently resolved.

- [Open question in one sentence.]
- [Open question in one sentence.]

=== TEMPLATE BODY ===

## Sections rules

- **Mandatory sections (1 through 3)**: always present, in canonical order, populated. If the source spec lacks information for a mandatory section, do NOT fabricate. Populate the section with what is known and add a precise question to Section 5.
- **Optional section (4 Risks)**: include ONLY when the spec contains concrete risk signals. Apply the pre-mortem lens: imagine the feature shipped and failed, then name the two to four most likely causes drawn from the spec. Do not include generic risk platitudes. Remove the entire heading when not used.
- **Optional section (5 Open Questions)**: include ONLY when at least one `[NEEDS CLARIFICATION]` marker was surfaced. Do not emit an empty Section 5. Do not write `N/A`. Remove the entire heading when not used.

## Header metadata rules

- `Feature`: the feature directory name (the segment after `specs/` in `FEATURE_DIR`).
- `Source Spec`: the literal markdown link `[spec.md](../spec.md)`.
- `Created`: today's date in `YYYY-MM-DD`.
- `Status`: `Draft`. No other value in v1.
