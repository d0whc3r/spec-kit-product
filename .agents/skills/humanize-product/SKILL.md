---
name: humanize-product
description: >-
  Make the product documents that `/speckit.product.*` commands generate read
  like a person wrote them, not a model. Use this skill whenever a generated
  `product/00-info.md`, `10-spec.md`, `20-plan.md`, or `30-design.md` reads
  robotic, formulaic, or "AI-generated"; whenever the user asks to humanize,
  naturalize, de-slop, soften, or polish product prose; right after running a
  `/speckit.product.*` command when the output feels stiff; and as the single
  source of truth for the writing practices the product commands and templates
  reference. This is the canonical home for the no-em-dash rule, the AI-tell
  banlist, and the cadence guidance. Reach for it even when the user does not
  say the word "humanize" but clearly wants the product docs to sound human.
allowed-tools: Read, Edit, Bash, Grep, Glob
---

# Humanize Product Docs

The `/speckit.product.*` commands turn an engineering `spec.md` and `plan.md`
into stakeholder-facing documents. They already enforce the mechanical style
rules from `.specify/memory/constitution.md` §III: English only, no em dash,
plain English, no AI-tell filler. Those rules pass a binary check and stop
there. They do not stop a document from reading like a model produced it.

This skill is the layer above that check. It holds the practices that make the
prose sound human, and it rewrites a generated document to apply them.

## Two ways this skill is used

1. **As a rewriter.** Point it at a generated `product/*.md` and it polishes
   the prose in place: varied cadence, concrete language, no formulaic
   scaffolding, while every structural rule and checklist gate still passes.
2. **As the reference.** The product commands and templates point here for the
   AI-tell catalog and the cadence guidance instead of each restating their own
   copy. One list, no drift. See `references/ai-tells.md`.

## The one rule that governs everything else

**Humanization is subordinate to §III and to the checklist.** A product
document is gated. `product/checklist.md` requires an exact shape: canonical
section order, a Job-to-Be-Done sentence in Ulwick form, Gherkin scenarios with
exactly one Given, When, and Then line, one north-star metric, bullets of
twelve words or fewer, and every `[NEEDS CLARIFICATION]` marker preserved
verbatim. If a "more human" rewrite breaks any of those, the rewrite is wrong.

So humanize the prose, and leave the scaffolding alone:

| Humanize freely (prose) | Do not restructure (gated shape) |
| --- | --- |
| Overview, Headline, Problem Statement narrative | The `When ... I want to ... so I can ...` JTBD sentence |
| Value Proposition, architecture overview prose | `**Given** / **When** / **Then**` scenario lines |
| Risk descriptions, decision rationale | Section headings and their canonical order |
| Any free paragraph | Metric definitions, `[NEEDS CLARIFICATION]` markers |

You can still improve a bullet's wording. You cannot grow it past twelve words,
merge mandated sections, or soften a clarification marker out of existence.

## What "human" means here, and what it does not

A detector-bypass tool makes text longer, hedgier, and chattier to fool a
classifier. That is the wrong target for these documents and it fights §III,
which bans filler and rewards short sentences. Do not add words to sound human.

Human, for a product document, means:

- **Varied cadence.** Real writing mixes a four-word sentence with a
  twenty-word one. Model output marches at a uniform fifteen. Break the march.
- **Concrete over abstract.** "Admins wait for the invoice to learn what they
  owe" beats "users lack visibility into billing outcomes."
- **No scaffolding.** Drop "Furthermore", "It is worth noting", "In essence",
  "This document will", and the "not just X, but Y" construction. They are
  connective tissue a person would not bother to type.
- **Broken parallelism.** Three bullets that all open with "If" or all open
  with "Admins" read like a generated list. Vary the openers and the shapes.
- **One voice.** Pick "you" or "the admin" and hold it. Do not drift.

Fewer words, not more. The naturalness comes from rhythm and specificity, never
from padding.

## Rewrite workflow

1. **Read the target** `product/*.md` end to end. Note which sections are prose
   and which are gated shape (see the table above).
2. **Run the detector** to find the mechanical and formulaic tells:
   ```bash
   bash .agents/skills/humanize-product/scripts/humanize_lint.sh specs/<feature>/product/<file>.md
   ```
   It flags em dashes, banned AI-tell phrases, hedging, formulaic openers,
   over-long sentences, and runs of bullets that share an opening word.
3. **Rewrite the prose sections only.** Fix every detector finding. Then read
   the prose aloud in your head and break any uniform cadence. Apply the
   patterns in `references/ai-tells.md`. Respect the chosen intensity (below).
4. **Re-run the detector.** Drive the count to zero. A residual finding is
   acceptable only when fixing it would break a gated rule, and you say so.
5. **Confirm the gates still hold.** Section order intact, JTBD sentence intact,
   Gherkin lines intact, bullets still twelve words or fewer, every
   `[NEEDS CLARIFICATION]` still present. State that you checked.

A rewrite is done when the prose reads human, the detector is clean, and the
checklist would still pass. Three conditions, all required.

## Intensity

Borrowed from the `humanize` skill. Default is medium. Pass it when the user
asks, for example "humanize 30-design.md aggressively".

| Level | What it changes |
| --- | --- |
| `light` | Mechanical only: em dashes, the AI-tell banlist, obvious hedging. Leaves cadence and structure as written. Use on a doc that is already close. |
| `medium` (default) | Light, plus cadence: vary sentence length, break parallel openers, swap abstract phrasings for concrete ones. |
| `aggressive` | Medium, plus reshaping: rewrite monotonous bullet lists into mixed shapes, restructure flat paragraphs, vary every formulaic opener. Stays inside the gated shape; never invents facts to add texture. |

No level may add a claim the source document does not support. Humanizing is a
style pass, not a content pass.

## When authoring the product commands or templates

If you are editing a `commands/speckit.product.*.md` file or a
`templates/product-*.md` file and you need the writing rules, this skill is the
source. Reference `references/ai-tells.md` for the phrase catalog and the
cadence guidance rather than pasting a fresh copy into the command. Keeping one
list is the whole point: the four commands had already started to drift, each
carrying a slightly different banlist.

## Files in this skill

- `references/ai-tells.md` - the full AI-tell catalog with before/after
  rewrites, the structural tells, and per-document guidance on which sections
  are prose and which are gated. Read it before a rewrite.
- `scripts/humanize_lint.sh` - read-only detector. Run it before and after a
  rewrite. Exits 0 always and prints findings, so it never blocks a commit.
