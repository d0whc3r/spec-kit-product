# Humanization Guide

The product commands read this guide while they generate `product/00-info.md`,
`10-spec.md`, `20-plan.md`, and `30-design.md`. Apply it whether you are writing
a document from scratch or polishing one. This is the single source for the
writing practices; the style rules restated inside each command are the enforced
minimum, and this guide is the full practice.

## The one rule that governs the rest

Humanization is subordinate to the style rules in each command and to
`product/checklist.md`. The checklist requires an exact shape: canonical
section order, a Job-to-Be-Done sentence in Ulwick form, Gherkin scenarios with
exactly one Given, When, and Then line, one north-star metric, bullets of
twelve words or fewer, and every `[NEEDS CLARIFICATION]` marker preserved
verbatim. If a more human phrasing would break any of those, it is wrong.

Humanize the prose; leave the scaffolding alone:

| Humanize freely (prose)                   | Do not restructure (gated shape)                        |
| ----------------------------------------- | ------------------------------------------------------- |
| Overview, Headline, the Problem narrative | The `When ... I want to ... so I can ...` JTBD sentence |
| Architecture overview prose               | `**Given** / **When** / **Then**` scenario lines        |
| Risk descriptions, decision rationale     | Section headings and their canonical order              |
| Any free paragraph                        | Metric definitions, `[NEEDS CLARIFICATION]` markers     |

You can improve a bullet's wording. You cannot grow it past twelve words, merge
mandated sections, or soften a clarification marker out of existence.

## What "human" means here, and what it does not

The goal is prose that reads like a person wrote it, not text engineered to
fool a detector. Detector-bypass writing is longer, hedgier, and chattier; that
fights these documents, which want short sentences and no filler. Do not add
words to sound human.

Human, for a product document, means:

- **Varied cadence.** Real writing mixes a four-word sentence with a
  twenty-word one. Generated text marches at a uniform fifteen. Break the
  march.
- **Concrete over abstract.** "Admins wait for the invoice to learn what they
  owe" beats "users lack visibility into billing outcomes."
- **No scaffolding.** Drop "Furthermore", "It is worth noting", "In essence",
  "This document will", and the "not just X, but Y" shape. They are connective
  tissue a person would not type.
- **Broken parallelism.** Three bullets that all open with "If" or all open
  with the same noun read like a generated list. Vary the openers and shapes.
- **One voice.** Pick "you" or "the admin" and hold it.

Fewer words, not more. The naturalness comes from rhythm and specificity, never
from padding.

## 1. Banned phrases

These never appear in a generated product document. This is the full list. The
fixed subset each command also enforces is "The enforced minimum" below. The
mechanical entries are exact phrases a tool can flag; the rest need a careful
read.

| Banned                         | Why it reads as a tell               | Use instead                   |
| ------------------------------ | ------------------------------------ | ----------------------------- |
| delve                          | Nobody says it out loud              | look at, dig into             |
| tapestry                       | Decoration, carries no meaning       | (delete the sentence)         |
| in essence                     | Filler before a restatement          | (delete; state it once)       |
| navigate the landscape         | Abstract throat-clearing             | name the actual thing         |
| seamless, seamlessly           | Marketing, unmeasurable              | (delete or name the gain)     |
| intuitive                      | Asserts what the reader should judge | describe the behavior         |
| leverage (as a verb)           | Corporate for "use"                  | use                           |
| robust (without a number)      | Sounds strong, says nothing          | give the actual guarantee     |
| it is worth noting             | Filler before a point                | (delete; make the point)      |
| it should be noted             | Same                                 | (delete)                      |
| as previously mentioned        | The reader remembers                 | (delete)                      |
| furthermore, moreover          | Essay connective tissue              | (start the sentence plainly)  |
| additionally                   | Same                                 | also, or just continue        |
| cutting-edge, state-of-the-art | Marketing                            | (delete)                      |
| game-changer, revolutionary    | Marketing                            | (delete)                      |
| unlock, unleash, empower       | Marketing verbs                      | name the concrete capability  |
| at the end of the day          | Filler                               | (delete)                      |
| crucial, vital, essential      | Inflation without a stake            | say why it matters, or cut it |

The em dash deserves its own note: never use it. Replace it with a comma,
colon, semicolon, parentheses, or a sentence break. A hyphen is fine.

When the fix is "delete the sentence", check that the surrounding paragraph
still stands. It usually reads better with the filler gone and nothing added.

## The enforced minimum

The table above is the full practice. A fixed subset of it is the enforced
minimum: every product command carries the two blocks below, so the rule
applies even when this guide has not been read. These are the hard-enforced
phrases. Never emit them, in any document.

Numbered style rule (the command's "Plain English" rule):

`3. **Plain English.** Active voice, short sentences, human tone. Do not use AI-tell phrases: "delve", "tapestry", "in essence", "navigate the landscape", "seamless", "intuitive", "leverage" (as a standalone verb), "robust" (without a measurable target), "it is worth noting", "it should be noted", "as previously mentioned".`

Validation row (the command's "No AI tells" auto-check):

`File does not contain: "delve", "tapestry", "in essence", "navigate the landscape", "seamless", "intuitive", "leverage" (as a standalone verb), "robust" (without a measurable target), "it is worth noting", "it should be noted", "as previously mentioned" (case-insensitive)`

## 2. Sentence-level tells

**The "not just X, but Y" shape.** A generation favorite. "This is not just a
dashboard, it is a financial planning tool." Cut it to the claim you can
support: "The dashboard projects the end-of-period bill." If you cannot support
the bigger claim, you were inflating.

**Hedging stacks.** "This may potentially help reduce some costs in certain
cases." Each hedge weakens the statement. If the behavior is conditional, name
the condition. If it is not, state it plainly. A single conditional "may" in a
risk is fine; a stack of hedges is not.

**The rule of three, every time.** "Faster, cheaper, and more reliable."
A person uses a triad sometimes; generated text uses it constantly. When a
third item is there only for rhythm, drop it.

**Restating the heading.** Under `## Overview`, a sentence that opens
"The overview of this feature is..." wastes the reader's time. Start
with the substance.

**Future tense for current behavior.** "The command will write the file." It
writes it. Use present tense.

## 3. Structural tells

These survive a phrase check and are the strongest signal that a list was
generated.

**Parallel openers.** Three or more bullets that begin with the same word.

Before:

```
- Admins see their current plan and usage in one place.
- Admins can be alerted before a projected overage.
- Admins can review and export past invoices.
```

After (vary the opening, keep each bullet at twelve words or fewer):

```
- One screen shows the current plan and this period's usage.
- An alert fires before a projected overage, not after the invoice.
- Past invoices export to CSV for the finance team.
```

**Uniform bullet length and shape.** When every bullet is a flat declarative of
the same length, the list reads mechanical even with varied openers. Mix a
short bullet with a longer one.

**Listicle-itis.** Prose broken into bullets that did not need to be a list.
Three short related statements often read better as two sentences. Bullets are
for genuinely parallel items.

**Symmetric paragraphs.** Every paragraph the same length, each opening with the
subject. Real sections are lopsided. One paragraph runs long because the idea
needed it; the next is a single line.

## 4. Cadence and rhythm

This is the part a phrase list cannot catch and the part that matters most.

Generated prose holds a steady sentence length, usually twelve to eighteen
words, sentence after sentence. Human prose does not. It lands a short sentence
after a long one. It opens with a subordinate clause once, then with the
subject three times, then with a question.

The fix is mechanical to start: after a long sentence, write a short one. Find
the two sentences in a paragraph that are the same length and the same shape,
and change one of them. You are not adding words; you are redistributing them.
Keep any single sentence under twenty-five words, which the style rules want
anyway.

## 5. Per-document guidance

Which sections are free prose to humanize, and which are gated shape to leave
structurally alone. Improve the wording inside a gated line, but never change
its required form.

### product/00-info.md

Plain-language summary for a non-technical reader. Almost all prose. The
one-page digest: scope and risks are owned by the spec, plan, and design docs,
so this document never carries an Out of Scope or Risks section.

- **Humanize:** Overview, the Key Decisions rationale.
- **Watch:** "What is Changing" is a bullet list prone to parallel openers and
  uniform shape. This is where the work earns its keep.

### product/10-spec.md

Working Backwards, Jobs to Be Done, Gherkin, Lean PRD. The most gated document.

- **Humanize:** Headline, the Problem narrative around the JTBD
  sentence and the Risk descriptions.
- **Leave the shape:** the `When ... I want to ... so I can ...` sentence; every
  `**Given** / **When** / **Then**` line keeps one each, its keyword, and its
  period; metric structure; `[NEEDS CLARIFICATION]` markers verbatim.

### product/20-plan.md

Delivery plan: goals and non-goals, phase breakdown, delivery risks. Technical
terms appear but are glossed in plain English on first use. Architecture,
principles, and design decisions are owned by the design doc, so they do not
appear here.

- **Humanize:** the summary approach paragraph, risk descriptions, phase
  descriptions.
- **Leave the shape:** phase ordering and declared dependencies, the
  goals/non-goals boundary, any Mermaid block (improve a node label only if it stays
  short, keeps the diagram valid, and uses no em dash).

### product/30-design.md

Technical design for tech leads and senior developers. The temptation to slip
into marketing or vagueness is highest here.

- **Humanize:** the architectural approach narrative, the rationale behind each
  decision, risk and trade-off descriptions.
- **Leave the shape:** the NFR table if present, component-description
  structure, Mermaid blocks (same rule as the plan).

## A worked example

Before:

> In essence, this product is a powerful and intuitive solution that empowers
> organization admins to seamlessly navigate their billing landscape.
> Furthermore, it leverages real-time data to deliver robust projections.

Every clause is a tell.

After:

> Organization admins open the dashboard and see where this period's bill is
> heading. It projects the end-of-period total from usage so far, and warns
> them before an overage instead of after the invoice.

Shorter, concrete, varied cadence, and every claim traces to the source spec.
That is the target.
