# Style Guide

Every artifact this extension generates obeys the same voice rules. The
shared `product/checklist.md` lets you verify them after generation.

This page uses the slash-command names, such as `/speckit.product.brief`. Skills agents, such as Claude Code, use hyphens instead: `/speckit-product-brief`.

## The rules

1. **One output language.**
   The commands accept a source in any language. They write in the dominant
   language of the source prose, or in the language you pass with
   `--lang <language>`. Code, identifiers, file names, product names, and
   `[NEEDS CLARIFICATION]` markers stay as they are. Headings, labels, and
   Gherkin keywords are translated. The rules below apply in every language;
   `templates/humanization-guide.md` says how to adapt the English ones.

2. **No em dash character.**
   The em dash character (U+2014) is banned in generated output, in every
   language. This includes the Chinese dash, which is two em dashes. Use a
   period, a semicolon, or a comma. This is the single strongest "AI tell" cue
   we filter against.

3. **Gherkin scenarios have exactly three lines.**
   One `Given`, one `When`, one `Then`. Each line is a full sentence
   starting with the keyword. No `And` lines, no multi-line preambles, no
   list under a `Then`.

4. **Mandatory sections appear in canonical order.**
   Each command has a fixed section order documented in [Commands](Commands.md).
   Reordering, renaming, or merging mandatory sections is a checklist failure.

5. **Optional sections appear only when the source has relevant content.**
   Empty optional sections are removed entirely, not left as stubs.

6. **No implementation detail.**
   No framework names, programming languages, API names, data stores, file
   paths, code, or schemas in `product/00-info.md`, `product/10-spec.md`, or
   `product/20-plan.md`. The exception is `product/30-design.md`, which is
   written for engineers and may reference component names and module
   boundaries at a conceptual level (still no runnable code).

7. **No AI tell filler phrases.**
   Words and phrases like "delve", "tapestry", "in essence", "seamless",
   "navigate the complexities of", "leverage" (as a verb), "in today's
   landscape", "robust", "cutting edge" are blocked. In another language,
   their direct translations are blocked too. The voice should read as if a
   senior PM wrote it.

8. **Short bullets.**
   Twelve words or fewer per bullet, ideally one short sentence ending with
   a period. Chinese and Japanese have no spaces between words, so a bullet
   there holds 24 characters or fewer.

9. **Diagrams and optional sections earn their place.**
   `/speckit.product.plan` and `/speckit.product.design` embed Mermaid diagrams
   by default, but a diagram or optional section appears only when it shows
   structure the prose cannot convey at a glance. One that would restate a list,
   duplicate another view, or collapse to a trivial shape is omitted. See
   [Diagrams](Diagrams.md) for the full rule.

10. **Answer first.**
    The first sentence of each document's opening section (Overview, Headline, or Summary) says what the feature is and what it does for whom. Each paragraph opens with its point. A reader who stops after the first lines still has the main idea.

11. **Short sentences and scannable structure.**
    No prose sentence runs past 25 words (50 characters in Chinese and Japanese). Items in one list share one grammatical form, use case titles are verb phrases, and a table never leaves a cell empty.

## Why these rules

Generated product artifacts are read by people who do not have time to
filter through LLM filler. Every rule above closes a specific failure mode
we hit in the prototype phase:

- Em dashes look generated even when content is good.
- Multi-line Gherkin drifts into implementation detail and loses its value
  as a customer-observable spec.
- Optional empty sections waste reader attention.
- "Robust", "seamless", "leverage" carry no information.
- A diagram that only repeats the prose is noise, not signal. The value gate
  keeps the output lean and the diagrams meaningful.
- Readers scan, and many stop after the first lines. A document that opens with background loses them before the point.

The structure rules (10 and 11) come from the inverted pyramid ([NN/g](https://www.nngroup.com/articles/inverted-pyramid/)), [BLUF](<https://en.wikipedia.org/wiki/BLUF_(communication)>), the [Wikipedia lead section](https://en.wikipedia.org/wiki/Wikipedia:Manual_of_Style/Lead_section) guideline, the Microsoft Style Guide on [scannable content](https://learn.microsoft.com/en-us/style-guide/scannable-content/), [Diátaxis reference](https://diataxis.fr/reference/), and [progressive disclosure](https://deviq.com/principles/progressive-disclosure/). The humanization guide in `templates/humanization-guide.md` holds the full practice.

## Surfacing clarifications instead of resolving them

If `spec.md` contains `[NEEDS CLARIFICATION]` markers, the commands surface
them as open product questions in the output. They are never silently
resolved.
