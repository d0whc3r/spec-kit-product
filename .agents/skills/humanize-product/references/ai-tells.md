# AI Tells and Rewrite Patterns

The catalog of what makes a generated product document read like a model wrote
it, with concrete fixes. The product commands reference this file instead of
each carrying their own copy. The detector in `scripts/humanize_lint.sh`
enforces the mechanical entries; the rest are judgment calls.

## Contents

1. Banned phrases (the AI-tell banlist)
2. Sentence-level tells
3. Structural tells
4. Cadence and rhythm
5. Per-document guidance (which sections to humanize)

## 1. Banned phrases

These never appear in a generated product document. The detector matches them
case-insensitively. This is the union of the banlists that the four product
commands had each been carrying separately, plus the common offenders they
missed.

| Banned | Why it reads as a tell | Use instead |
| --- | --- | --- |
| delve | Nobody says it out loud | look at, dig into |
| tapestry | Decoration, carries no meaning | (delete the sentence) |
| in essence | Filler before a restatement | (delete; just state it once) |
| navigate the landscape | Abstract throat-clearing | name the actual thing |
| seamless, seamlessly | Marketing, unmeasurable | (delete or name the gain) |
| intuitive | Asserts what the reader should judge | describe the behavior |
| leverage (as a verb) | Corporate for "use" | use |
| robust (without a number) | Sounds strong, says nothing | give the actual guarantee |
| it is worth noting | Filler before a point | (delete; just make the point) |
| it should be noted | Same | (delete) |
| as previously mentioned | The reader remembers | (delete) |
| furthermore, moreover | Essay connective tissue | (start the sentence plainly) |
| additionally | Same | also, or just continue |
| cutting-edge, state-of-the-art | Marketing | (delete) |
| game-changer, revolutionary | Marketing | (delete) |
| unlock, unleash, empower | Marketing verbs | name the concrete capability |
| at the end of the day | Filler | (delete) |
| crucial, vital, essential | Inflation without a stake | say why it matters, or cut it |

When the fix is "delete the sentence", check that the surrounding paragraph
still stands. Often it reads better with the filler gone and nothing added.

## 2. Sentence-level tells

**The "not just X, but Y" construction.** A model favorite. "This is not just a
dashboard, it is a financial planning tool." Cut it to the claim you can
support: "The dashboard projects the end-of-period bill." If you cannot support
the bigger claim, you were inflating.

**Hedging stacks.** "This may potentially help reduce some costs in certain
cases." Each hedge is a word that weakens an instruction. If the behavior is
conditional, name the condition. If it is not, state it plainly.

**The rule of three, every time.** "Faster, cheaper, and more reliable."
"Plan, usage, and projection." A real writer uses a triad sometimes. A model
uses it constantly. When you notice a third item added only for rhythm, drop it.

**Restating the heading.** Under `## Value Proposition`, a sentence that opens
"The value proposition of this product is..." wastes the reader's time. The
heading already said it. Start with the substance.

**Future tense for current behavior.** "The command will write `00-info.md`."
It writes it. Present tense. Future tense reads like a plan, not a description.

## 3. Structural tells

These survive a phrase-level check and are the strongest signal that a list was
generated. The detector flags consecutive bullets that share an opening word;
the rest you catch by eye.

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
short bullet with a longer one. Let one carry a clause and the next be three
words.

**Listicle-itis.** Prose broken into bullets that did not need to be a list.
Three short related statements often read better as two sentences. Bullets are
for genuinely parallel items, not for chopping a paragraph.

**Symmetric paragraphs.** Every paragraph the same length, each opening with the
subject, each closing with a summary clause. Real sections are lopsided. One
paragraph runs long because the idea needed it; the next is a single line.

## 4. Cadence and rhythm

This is the part a phrase list cannot catch and the part that matters most.

Model prose holds a steady sentence length, usually twelve to eighteen words,
sentence after sentence. Human prose does not. It lands a short sentence after
a long one. It opens with a subordinate clause once, then with the subject
three times, then with a question.

The fix is mechanical to start: after a long sentence, write a short one. Read
the paragraph and find the two sentences that are the same length and the same
shape, and change one of them. You are not adding words. You are redistributing
them.

The detector flags any sentence over twenty-five words, which is usually a §III
violation anyway. It cannot flag the deeper problem, a paragraph of sentences
that are all the same. That one is on you.

## 5. Per-document guidance

Which sections are free prose to humanize, and which are gated shape to leave
structurally alone. Humanize the wording inside a gated line, but never change
its required form.

### product/00-info.md

Plain-language summary for a non-technical reader. Almost all prose.

- **Humanize:** Overview, Headline, Risks. These are the heart of the document
  and the most likely to read flat.
- **Watch:** "What is Changing" and "Out of Scope" are bullet lists prone to
  parallel openers and uniform shape. This is exactly where the rewrite earns
  its keep.

### product/10-spec.md

Working Backwards, Jobs to Be Done, Gherkin, Lean PRD. The most gated document.

- **Humanize:** Headline, Problem Statement narrative around the JTBD sentence,
  Value Proposition, Risk descriptions.
- **Leave the shape:** the `When ... I want to ... so I can ...` sentence keeps
  its exact form; every `**Given** / **When** / **Then**` line keeps one each
  and its keyword and period; the north-star and supporting metrics keep their
  structure; `[NEEDS CLARIFICATION]` markers stay verbatim in Risks and Open
  Product Questions.

### product/20-plan.md

Goals, scope, phase breakdown, architecture overview, condensed decisions,
risks. Technical terms appear but are glossed in plain English on first use.

- **Humanize:** the architecture overview prose, decision rationale, risk
  descriptions, phase descriptions.
- **Leave the shape:** phase ordering and declared dependencies, the
  goals/scope boundary, any Mermaid block (humanize a node label only if it
  stays short and keeps the diagram valid and free of em dashes).

### product/30-design.md

Technical design for tech leads and senior developers. The most technical, so
the temptation to slip into marketing or vagueness is highest.

- **Humanize:** the architectural approach narrative, the rationale behind each
  decision, risk and trade-off descriptions.
- **Leave the shape:** the NFR table if present, component descriptions'
  structure, Mermaid blocks (same diagram rule as the plan).

## A worked example

Before, a generated Headline paragraph:

> In essence, this product is a powerful and intuitive solution that empowers
> organization admins to seamlessly navigate their billing landscape.
> Furthermore, it leverages real-time data to deliver robust projections.

Every clause is a tell: "in essence", "powerful", "intuitive", "empowers",
"seamlessly", "navigate the landscape", "furthermore", "leverages", "robust".

After:

> Organization admins open the dashboard and see where this period's bill is
> heading. It projects the end-of-period total from usage so far, and warns
> them before an overage instead of after the invoice.

Shorter, concrete, varied cadence, and every claim traces to the source spec.
That is the target.
