---
name: humanize-product
description: >-
  Make the product documents that `/speckit.product.*` commands generate read
  like a person wrote them, not a model. Use this skill whenever a generated
  `product/00-info.md`, `10-spec.md`, `20-plan.md`, or `30-design.md` reads
  robotic, formulaic, or "AI-generated"; whenever the user asks to humanize,
  naturalize, de-slop, soften, or polish product prose; right after running a
  `/speckit.product.*` command when the output feels stiff; and when authoring
  the product commands or the humanization guide. The practices themselves live
  in the shipped `templates/humanization-guide.md`; this skill is the
  contributor-side tool that applies and maintains them. Reach for it even when
  the user does not say the word "humanize" but clearly wants the product docs
  to sound human.
allowed-tools: Read, Edit, Bash, Grep, Glob
---

# Humanize Product Docs

The `/speckit.product.*` commands turn an engineering `spec.md` and `plan.md`
into stakeholder-facing documents. They already read `templates/humanization-guide.md`
during generation and apply it, so fresh output should already be reasonably
human. This skill is the contributor-side tool for the cases that need a hand:
polishing an existing document, and keeping the guide itself sharp.

## Where the practices live

The canonical writing practices, the AI-tell banlist, the cadence guidance, and
the per-document section map are all in **`templates/humanization-guide.md`**.

That location is deliberate. The release zip ships only `extension.yml`,
`README`, `LICENSE`, `commands/**`, and `templates/**` (see
`.github/scripts/build-zip.mjs`). Skills do not ship. So the guide lives under
`templates/` where it travels with the extension and is readable at runtime by
the installed commands. This skill is dev-only tooling and does not ship; it
reads the same guide so there is one source of truth.

Read `templates/humanization-guide.md` before any rewrite. Everything below is
the workflow for applying it.

## The one rule that governs everything else

Humanization is subordinate to each command's style rules and to
`product/checklist.md`. A product document is gated: canonical section order, a
Job-to-Be-Done sentence in Ulwick form, Gherkin scenarios with exactly one
Given, When, and Then line, one north-star metric, bullets of twelve words or
fewer, and every `[NEEDS CLARIFICATION]` marker preserved verbatim. If a "more
human" rewrite breaks any of those, the rewrite is wrong. The guide's
per-document section map says exactly which parts are prose to humanize and
which are gated shape to leave alone.

## Rewrite workflow

1. **Read the target** `product/*.md` end to end, and read
   `templates/humanization-guide.md`. Note which sections are prose and which
   are gated shape.
2. **Run the detector** to find the mechanical and formulaic tells:
   ```bash
   bash .agents/skills/humanize-product/scripts/humanize_lint.sh specs/<feature>/product/<file>.md
   ```
   It flags em dashes, banned AI-tell phrases, hedging, formulaic openers,
   over-long sentences, and runs of bullets that share an opening word. The
   detector mirrors the guide's mechanical entries.
3. **Rewrite the prose sections only.** Fix every detector finding, then read
   the prose in your head and break any uniform cadence, applying the guide.
   Respect the chosen intensity (below).
4. **Re-run the detector.** Drive the count to zero. A residual finding is
   acceptable only when fixing it would break a gated rule, and you say so.
5. **Confirm the gates still hold.** Section order intact, JTBD sentence intact,
   Gherkin lines intact, bullets still twelve words or fewer, every
   `[NEEDS CLARIFICATION]` still present. State that you checked.

A rewrite is done when the prose reads human, the detector is clean, and the
checklist would still pass. Three conditions, all required.

## Intensity

Default is medium. Pass it when the user asks, for example "humanize
30-design.md aggressively".

| Level | What it changes |
| --- | --- |
| `light` | Mechanical only: em dashes, the AI-tell banlist, obvious hedging. Leaves cadence and structure as written. Use on a doc that is already close. |
| `medium` (default) | Light, plus cadence: vary sentence length, break parallel openers, swap abstract phrasings for concrete ones. |
| `aggressive` | Medium, plus reshaping: rewrite monotonous bullet lists into mixed shapes, restructure flat paragraphs, vary every formulaic opener. Stays inside the gated shape; never invents facts to add texture. |

No level may add a claim the source document does not support. Humanizing is a
style pass, not a content pass.

## Maintaining the guide

When you change the writing practices, edit `templates/humanization-guide.md`.
It is the single source: the commands read it at runtime, this skill reads it,
and the per-command style-rule summaries are condensed from it. When you add or
remove a banned phrase, update the regex in `scripts/humanize_lint.sh` to match,
since the detector cannot read prose.

## Files in this skill

- `scripts/humanize_lint.sh` - read-only detector. Run it before and after a
  rewrite. Exits 0 always and prints findings, so it never blocks a commit. Its
  banlist mirrors `templates/humanization-guide.md`.
