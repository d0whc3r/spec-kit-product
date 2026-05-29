# Style Guide

Every artifact this extension generates obeys the same voice rules. The
shared `product/checklist.md` lets you verify them after generation.

## The rules

1. **English only.**
   v1 ships English templates. The command refuses to run if the source file
   is detected as non-English.

2. **No em dash character.**
   The em dash (`—`, U+2014) is banned in generated output. Use a period or
   a semicolon or a comma. This is the single strongest "AI tell" cue we
   filter against.

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
   landscape", "robust", "cutting edge" are blocked. The voice should read
   as if a senior PM wrote it.

8. **Short bullets.**
   Twelve words or fewer per bullet, ideally one short sentence ending with
   a period.

## Why these rules

Generated product artifacts are read by people who do not have time to
filter through LLM filler. Every rule above closes a specific failure mode
we hit in the prototype phase:

- Em dashes look generated even when content is good.
- Multi-line Gherkin drifts into implementation detail and loses its value
  as a customer-observable spec.
- Optional empty sections waste reader attention.
- "Robust", "seamless", "leverage" carry no information.

## Surfacing clarifications instead of resolving them

If `spec.md` contains `[NEEDS CLARIFICATION]` markers, the commands surface
them as open product questions in the output. They are never silently
resolved.
