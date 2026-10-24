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
- **Distinct openers, same form.** Three bullets that all open with "If" or with the same noun read like a generated list, and the repeated word hides what makes each bullet different. Open each bullet with its distinguishing words. Keep one grammatical form across the list, so the reader can compare items at a glance.
- **One voice.** Pick "you" or "the admin" and hold it.

Fewer words, not more. The naturalness comes from rhythm and specificity, never
from padding.

## Structure: answer first, then detail

Readers decide in the first lines whether a document matters to them, and many stop there. The rules below make sure a reader who stops early still leaves with the point. They work inside the template: never rename, reorder, or merge its sections to apply them.

**Lead with the answer.** The first sentence of the opening section (Overview, Headline, or Summary) says what the feature is and what it does for whom. Background, the problem today, and the reasons come after it, never before it.

Before:

> For organization admins, the bill is a black box until the invoice arrives, which means surprise charges and support tickets.

After:

> The billing dashboard shows organization admins what this period will cost before the invoice arrives.

**Make the opening section stand alone.** A reader who reads only the opening section knows what changes, for whom, and why it matters. It summarizes the document: each of its facts appears again later with more detail, and the body never holds a headline fact the opening section left out. Do not tease ("one change stands out") without saying what it is.

**Put the point of each paragraph first.** The first sentence carries the claim, and the next sentences support it. A reader who scans only first sentences still follows the argument.

**Front-load every line.** Start each sentence, bullet, table cell, and composed heading with the words that carry the information. When sibling bullets open with the same word ("Admins see...", "Admins can..."), that word tells the reader nothing; open each one with what makes it different.

**Order by importance.** Inside a list, a table, or a section, put first what the broadest reader needs most, and leave fine detail for last. Sequences are the exception: phases, steps, and rollout stages keep their order.

**Keep paragraphs and sentences short.** A paragraph holds one idea in three to five sentences; a one-sentence paragraph is fine now and then. No sentence runs past 25 words. The Job to Be Done sentence and the Positioning statement are exempt, because their form is fixed.

**Use lists for parallel items only.**

- Number a list only when order matters, as in a sequence or a ranking.
- Aim for two to seven items. When the source gives more, merge related items or split the list under two short bold labels. Never drop an item to hit the number.
- Give every item in a list the same grammatical form: all full sentences, or all noun phrases. Vary the words and the length, not the form.
- Make the items distinct and complete: no two items say the same thing, and together they cover what the heading names.

**Use tables for items with two or more attributes.**

- A list of similar items stays a list. A table earns its place only when each row has two or more attributes to compare.
- The leftmost column names the row: the module, the quality attribute, or the use case.
- Keep each cell to one short line, and move explanation into the prose around the table.
- Never leave a cell empty, and never fill it with a dash. Write "None" or "Not applicable".

**Write composed headings as summaries.** Template headings are fixed. Headings you write (use case titles, phase names, decision titles, risk titles) are short, start with the keyword, and tell the reader what sits under them. Siblings share one form: use case titles are verb phrases in the user's words ("Export past invoices"), and decision and risk titles are noun phrases. Use sentence case and no end period. Never skip a heading level.

**Disclose detail progressively.** Each document runs from summary to detail, and the template order already does that. Keep detail out of the opening section: no lists of components, endpoints, or fields in the first paragraph. The four documents form one ladder: `00-info.md` says what changes and why, `10-spec.md` says for whom and how success is measured, `20-plan.md` says in what order, and `30-design.md` says how. State each fact in the document that owns it; the others summarize it or leave it out. One diagram shows one level of detail, so do not mix services and functions in one flowchart.

**Keep reference parts plain.** In `30-design.md`, the tables, data model blocks, and API shapes are reference material. State their facts in a fixed pattern, with no rationale, opinion, or selling. Rationale belongs in Architectural Approach and Key Technical Decisions. Order rows the way the system is built: Affected Modules follows the layers of the architecture diagram, top to bottom.

**Use bold for labels only.** Bold marks run-in labels (`**Why now**:`) and defined terms. Do not bold words inside a sentence for emphasis.

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

Numbered style rule (the command's "Plain language" rule):

`3. **Plain language.** Active voice, short sentences, human tone. Do not use AI-tell phrases: "delve", "tapestry", "in essence", "navigate the landscape", "seamless", "intuitive", "leverage" (as a standalone verb), "robust" (without a measurable target), "it is worth noting", "it should be noted", "as previously mentioned".`

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

After (each bullet opens with what makes it different; all stay full sentences of twelve words or fewer):

```
- One screen shows the current plan and this period's usage.
- An alert fires before a projected overage, not after the invoice.
- Past invoices export to CSV for the finance team.
```

**Uniform bullet length.** When every bullet has the same length, the list reads mechanical even with varied openers. Let the content set the length, so a short bullet can sit next to a longer one. Vary length, never grammatical form: a list of full sentences stays a list of full sentences.

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
Keep every sentence at 25 words or fewer; the style rules enforce it.

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
terms appear but are glossed in plain language on first use. Architecture,
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

## 6. Writing in other languages

The commands write in the output language: the language the user names, or else the dominant language of the source prose. Every rule in this guide holds in that language. This section says how to apply the rules that assume English.

These rules hold in every language: answer first, one idea per sentence, short sentences, active voice, concrete subjects, no filler, no stacked hedges, varied cadence, and no em dash.

- **Banned phrases.** The lists above are English. In another language, avoid their direct translations and the same kinds of filler and marketing words, for example 值得注意的是, 无缝, and 赋能 in Chinese, or "cabe destacar" and "sin fisuras" in Spanish.
- **Length.** In a language that puts spaces between words, count words as written. In Chinese and Japanese, count characters instead, at two characters for each English word: at most 50 characters in a sentence and 24 in a bullet. Punctuation does not count.
- **Punctuation.** Use the marks of the language. Chinese and Japanese use full-width marks (，。：；？！（）). Spanish opens a question or an exclamation with ¿ or ¡. French puts a space before ; : ! ? and inside « ». A rule that says a sentence ends with a period means the sentence-ending mark of the language, such as 。.
- **Em dash.** The ban holds in every language. It covers the Chinese dash, which is two em dashes, and the em dash that Spanish uses for asides. Use a comma, a colon, or parentheses.
- **Fixed forms.** Translate the template headings and labels, and keep their order and structure. Each Gherkin scenario keeps one line each for Given, When, and Then, with the official Gherkin keywords of the language: 假如, 当, 那么 in Chinese; Dado, Cuando, Entonces in Spanish; Soit, Quand, Alors in French. The Job to Be Done keeps its three parts in order with natural connectors, for example 当……时，我想要……，以便…….
- **Right-to-left languages.** In Arabic, Hebrew, or Persian, keep the Markdown syntax as it is. Start each heading, bullet, and table cell with a word in the document language, not with a Latin name or a number. Viewers that set the direction from the first letter, such as GitHub, then align the line to the right.
- **Kept as written.** Code, identifiers, file names, paths, product names, quoted UI text, `[NEEDS CLARIFICATION: ...]` markers, and `YYYY-MM-DD` dates stay as they are in the source. In a Mermaid diagram, ids stay short ASCII words, and a label with non-ASCII text goes in double quotes.
- **Mixed sources.** A source can mix languages, for example Chinese prose with English headings and technical terms. Write each document in one language. Keep a technical term in English when the source uses it untranslated, and gloss it on first use when a reader may not know it.

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
