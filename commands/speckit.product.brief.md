---
description: "Generate product/00-info.md and product/10-spec.md together from the current feature's spec.md, then update the shared quality checklist"
---

# Generate Product Brief

Derive two stakeholder-facing artifacts in a single pass from the populated `spec.md` of the active feature, then auto-validate and update the `## Info` and `## Spec` sections of the shared `product/checklist.md`. The two artifacts are companions: `product/00-info.md` is the one-page plain-language digest that answers "what is changing and why" for a non-technical reader, and `product/10-spec.md` is the structured product spec a stakeholder reads after the digest. The spec is not fully legible without the info, so the two are generated together. The artifacts follow Amazon Working Backwards (PRFAQ), Jobs to Be Done (Ulwick), Gherkin BDD, and Lean PRD conventions, in plain English, with strict style rules.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty). The user MAY pass `--feature-dir <path>` to override the pointer in `.specify/feature.json`.

## Inputs

The command reads (does not modify):

- `.specify/feature.json` to locate the active feature directory.
- `<feature-dir>/spec.md` as the source spec.

The command writes:

- `<feature-dir>/product/00-info.md`
- `<feature-dir>/product/10-spec.md`
- `<feature-dir>/product/checklist.md` (creates if absent; otherwise updates only the `## Info` and `## Spec` sections, preserving all other sections)

The only files this command writes are under `${FEATURE_DIR}/product/`. All other spec-kit artifacts are treated as read-only; see the "Source files are READ-ONLY" guard at the end of this document.

## Templates

The command MUST read the following templates from the installed extension and use them verbatim as the structural skeleton of the corresponding output. Do NOT invent additional sections. Do NOT reorder sections.

- Product info template: `templates/product-info-template.md` (relative to this command's extension root).
- Product spec template: `templates/product-spec-template.md` (relative to this command's extension root).
- Humanization guide: `templates/humanization-guide.md` (relative to this command's extension root).
- Quality checklist template: `templates/product-checklist-template.md` (relative to this command's extension root).

When this extension is installed under `.specify/extensions/product/`, the absolute paths are:

- `.specify/extensions/product/templates/product-info-template.md`
- `.specify/extensions/product/templates/product-spec-template.md`
- `.specify/extensions/product/templates/humanization-guide.md`
- `.specify/extensions/product/templates/product-checklist-template.md`

## Execution

### Step 1: Resolve the feature directory

Run speckit's built-in resolver. If the user passed `--feature-dir <path>`, export `SPECIFY_FEATURE_DIRECTORY=<path>` in the environment first (resolve relative paths against the repo root).

- **Bash**:

  ```bash
  bash -c 'source .specify/scripts/bash/common.sh && eval "$(get_feature_paths)" && echo "$FEATURE_DIR"'
  ```

- **PowerShell**:

  ```powershell
  . .specify/scripts/powershell/common.ps1
  (Get-FeaturePathsEnv).FEATURE_DIR
  ```

Capture the output as `FEATURE_DIR`. If the command exits non-zero, surface its stderr verbatim to the user and stop.

### Step 2: Verify spec.md

Refuse to proceed when:

1. **E_NO_SPEC**: `${FEATURE_DIR}/spec.md` does not exist. Tell the user to run `/speckit.specify` first.
2. **E_PLACEHOLDERS**: `spec.md` still contains literal placeholders from the spec template. Detect these by looking for any of the following exact bracketed strings as substrings of the file (case sensitive):
   - `[FEATURE NAME]`
   - `[Brief Title]`
   - `[Describe this user journey in plain language]`
   - `[#]` (in the form `### User Story [#]`)
   - `[Describe the specific behavior in detail]`
   - `[Describe the user interaction]`
   - `[Describe what the user observes]`
   - Any line that is exactly `### User Story [#] - [Brief Title] (Priority: PX)`.

   These are unfilled template scaffolding. Refuse with a single line per detected placeholder.

   **Important distinction**: `[NEEDS CLARIFICATION: ...]` markers are NOT placeholders. They are intentional questions left by the spec author and are handled in Step 3.

3. **E_LANGUAGE**: `spec.md` is not written in English. Detect non-English content by sampling the prose paragraphs (skip code fences and metadata) and checking that the dominant language is English. If the dominant language is not English, refuse with a single line naming the detected language. Do not auto-translate.

### Step 3: Extract decisions and surface clarifications

This step gathers material shared by both artifacts. Each artifact uses it differently: the info surfaces resolved decisions in its `## Key Decisions` section and unresolved markers in its "Still open" block; the spec surfaces unresolved markers in its `## Risks and Open Questions` section.

**3a - Resolved decisions**: Scan `spec.md` for the `## Clarifications` section. If present, collect every `### Session YYYY-MM-DD` subheading and its bullet lines. Each bullet has the form `- Q: <question text> → A: <answer text>`. Parse each bullet into a `(session_date, question, answer)` triple - strip the `Q:` and `A:` prefixes. Skip lines that do not match the pattern. Store the list ordered by session date. If the section is absent or empty, store an empty list.

**3b - Unresolved questions**: Scan `spec.md` for occurrences of `[NEEDS CLARIFICATION` (case sensitive prefix). For each occurrence, capture the full marker text and its surrounding sentence as context.

If any `[NEEDS CLARIFICATION]` markers are present:

- List each marker, one per line, with file location.
- Ask the user: `Surface these as open questions in product/00-info.md and product/10-spec.md? (yes/no)`
- On `no` or any non affirmative response, abort with `E_USER_ABORT` and write nothing.
- On `yes`, store each marker as an unresolved question for use in Steps 6 and 7. Each marker MUST appear in the info "Still open" block AND in the spec "Open questions" list. Never silently resolve a marker.

If neither resolved decisions nor unresolved questions exist, the info `## Key Decisions` section will be omitted entirely and the spec `## Risks and Open Questions` will carry no open-questions block derived from markers.

### Step 4: Handle existing files in product/

Because the two artifacts are companions generated in one pass, overwrite is decided once for both.

If `${FEATURE_DIR}/product/00-info.md` and/or `${FEATURE_DIR}/product/10-spec.md` already exists:

- Print the absolute path(s) of the existing file(s).
- Ask: `One or both of product/00-info.md and product/10-spec.md already exist. Overwrite? (yes/no)`
- On `no` or any non affirmative response, abort with `E_USER_ABORT`. Do not write any files.
- On `yes`, continue. The existing file(s) will be replaced byte for byte.

If `${FEATURE_DIR}/product/` does not exist yet, create it before writing.

### Step 5: Style rules (applied to both artifacts)

Before writing either artifact, read `templates/humanization-guide.md` (relative to this command's extension root) and apply it as you compose and again during each rewrite loop: varied cadence, the full AI-tell banlist, and the structural tells it lists. The numbered rules below are the enforced minimum; the guide is the complete practice.

1. **English only.** All output is in English.
2. **No em dash.** The character `—` MUST NOT appear in the output. Use commas, parentheses, colons, semicolons, or sentence breaks. Hyphens (`-`) are allowed.
3. **Plain English.** Active voice, short sentences, human tone. Do not use AI-tell phrases: "delve", "tapestry", "in essence", "navigate the landscape", "seamless", "intuitive", "leverage" (as a standalone verb), "robust" (without a measurable target), "it is worth noting", "it should be noted", "as previously mentioned".
4. **No implementation detail.** No frameworks, languages, APIs, data stores, code, or file paths.
5. **Bullets are short. Prose is full sentences.**
6. **`_(optional)_` is a marker, not title text.** In the templates, a heading like `## Glossary _(optional)_` or `## Risks _(optional)_` uses `_(optional)_` only to flag that the section is optional. It is an authoring marker, never part of the title. When you keep the section, emit the heading clean (`## Glossary`, `## Risks`) with no `_(optional)_`. When the source has no real content that earns the section, omit the whole section, heading included. The string `_(optional)_`, and a bare `(optional)` suffix on any heading, must never appear in either generated document.

#### Header metadata (applies to both artifacts)

- `Feature` field: the H1 title of `spec.md` (the text of the first `#` heading, stripped of the `#` prefix and trimmed). If no H1 is present, use the feature directory name with any leading numeric prefix and hyphens removed (e.g., `003-my-feature` becomes `My Feature`, capitalised as title case).
- `Created` field: today's date in `YYYY-MM-DD`.
- `Status` field: `Draft`.

### Step 6: Generate product/00-info.md

Read `templates/product-info-template.md`. Replace every bracketed placeholder with concrete content drawn from `spec.md`, applying the style rules above. Apply the following section rules without exception.

#### Section rules

- **Mandatory sections (Overview, What is Changing)**: always present, in canonical order, populated. If the source spec lacks information for a mandatory section, do NOT fabricate. Populate the section with what is known, and add a precise question to the Key Decisions "Still open" block. This document is the one-page digest; scope and risks live in the spec, plan, and design docs, so info never carries an Out of Scope or Risks section.
- **Optional section (Key Decisions)**: include when the resolved decisions list OR the unresolved questions list is non-empty. Two parts:
  1. Resolved decisions: synthesize by topic, not one entry per triple. Cluster triples whose questions decide the same area (the same threshold, the same audience, the same behavior) and merge each cluster into a single entry, even when its triples come from different sessions. A triple that shares no topic with any other stays its own entry. Each entry is a bold noun-phrase title (derived from the shared topic - not any full question), followed by one sentence stating the combined decision as a positive outcome. Do not repeat questions verbatim. On the next line, cite the contributing sessions: `*Session: YYYY-MM-DD*` for one, or `*Sessions: YYYY-MM-DD, YYYY-MM-DD*` (ascending, deduplicated) when several shaped it. Never merge triples that decide genuinely different things just to shorten the list; every distinct decision survives. Write the decision as a statement ("The feature will...", "Users with X will...", "This version does not..."). If the answers provide reasoning, include it in the same sentence.
  2. "Still open" block: rendered only when there are unresolved `[NEEDS CLARIFICATION]` markers. Use a blockquote: `> **Still open**: These questions were raised but not yet resolved. They should be answered before this feature is built.` followed by one bullet per marker as a single-sentence question. Never silently resolve a marker.
     If only one of the two parts has content, include only that part. Remove the entire section if both lists are empty.
- **Optional section (References)**: include ONLY when `spec.md` cites external resources that a non-technical reader would benefit from accessing: user research reports, product briefs, customer interviews, analytics dashboards, external standards, or third-party documentation. NEVER link to spec-kit artifacts: `spec.md`, `plan.md`, `tasks.md`, `data-model.md`, `research.md`, or any file generated by this extension are inputs, not references. Each entry must be an external URL with a plain-language label. Omit the section when the source spec has no external references. This section appears last.

#### Section guidance

- **Overview**: one short paragraph, two to four sentences. State who this is for, the problem it addresses, what changes for them, and the new outcome they can reach. This is the higher-altitude digest, not a copy of the spec Headline. No jargon, no implementation detail, no feature lists.
- **What is Changing**: two to five short bullets, or one short paragraph. State customer-observable differences after the feature ships. Each bullet is a single sentence ending with a period.
- **Key Decisions (optional)**: open with one sentence: "These decisions were made while writing this spec. Review them to confirm they still reflect the right direction." Then list resolved decisions, one per topic. Merge clarifications that decide the same thing into a single entry, even across sessions, so the reader scans decisions, not raw questions. Each entry: bold noun-phrase title on its own line (e.g., `**Rollout audience**`), a single sentence that names the choice and gives the reason in plain product language, then a session citation on the next line (`*Session: YYYY-MM-DD*`, or `*Sessions: YYYY-MM-DD, YYYY-MM-DD*` when more than one session shaped it). Never merge decisions that are genuinely about different things. If unresolved questions exist, end with the "Still open" blockquote block. Do not fabricate decisions or questions.
- **References (optional)**: each entry is formatted as `- [Plain-language label]: [URL]`. Only external URLs. Never internal spec-kit files.

### Step 7: Generate product/10-spec.md

Read `templates/product-spec-template.md`. Replace every bracketed placeholder with concrete content drawn from `spec.md`, applying the style rules in Step 5. Apply the following section rules without exception.

#### Section rules

- **Mandatory sections (Headline, Users, Problem (Job to Be Done), Scope, Use Cases, Success Metrics, Risks and Open Questions)**: always present, in canonical order, populated. If the source spec lacks information for a mandatory section, do NOT fabricate. Instead, populate the section with what is known, and add a precise open question to the Risks and Open Questions section.
- **Headline**: one paragraph, three to four sentences. It merges the press-release summary with the value proposition: who it is for, the problem today, what changes, and why that beats the status quo. Do not add a separate value-proposition section.
- **Scope**: one section with two sub-lists, `**In scope**` and `**Out of scope**`, each a short bullet list. Both are always populated. Out of scope is the highest-leverage part; if it feels empty, think harder.
- **Optional section (Glossary)**: include ONLY when the spec uses domain-specific or technical terms that a non-technical stakeholder may not know. Each bullet is a term and its one-sentence plain-language definition. Place this section between Headline and Users. Omit entirely when no vocabulary gap exists.
- **Optional section (Assumptions)**: include ONLY when the source spec contains explicit assumptions about user behavior, market conditions, or technical context that stakeholders should validate. Each bullet states an assumption and the condition that would invalidate it. Place this section between Problem (Job to Be Done) and Scope. Omit when no material assumptions exist.
- **Risks and Open Questions**: this is the home for product and adoption risk plus product open questions. Delivery risks are owned by the plan and technical risks by the design doc, so keep this section product-level and do not duplicate those. Every `[NEEDS CLARIFICATION]` marker still appears here.
- **Optional sections (Positioning, Go to Market and Rollout)**: include ONLY when the source spec contains real content for them, placed last. Do not emit empty optional sections. Do not write `N/A`. Remove the entire section heading when not used.

#### Use Case rules (Use Cases section)

Each scenario MUST contain exactly three lines, in this order:

```text
**Given** [one full sentence beginning with "Given" describing the starting context].
**When** [one full sentence beginning with "When" describing the user action].
**Then** [one full sentence beginning with "Then" describing the observable outcome].
```

Each line is a single complete sentence ending with a period. Do not bullet sub conditions; if a scenario needs more, split it into two scenarios. Aim for fewer than six scenarios across the document.

Map source spec User Stories and Acceptance Scenarios into Use Cases by translating the engineering language into customer observable behavior. Drop implementation specifics.

#### Job to Be Done (Problem Statement section)

Write the primary job in the Ulwick form, exactly:

```text
When [situation], I want to [motivation], so I can [expected outcome].
```

Use an action verb. Do NOT name a solution (avoid "When I open the app", "I want to click the button"). Frame the situation, motivation, and outcome at the level the user experiences them.

#### Success Metrics

Provide exactly one north star metric and at least one supporting metric. Each metric must be measurable and technology agnostic. No system internals (no "p95 latency", no "queue depth"). Acceptable patterns: time to outcome, completion rate, satisfaction signal, retention, adoption.

### Step 8: Auto-validate and iterate (Info + Spec sections)

**Goal: all checklist items checked for both artifacts. Zero manual items if possible.**

After composing the full text of both `product/00-info.md` and `product/10-spec.md` in memory (before writing), run validation pass 1 against each. For each failing item that is auto-fixable: rewrite the affected portion of the corresponding in-memory artifact (never the source `spec.md`), then re-evaluate. Repeat until all fixable items pass (max 2 additional passes per item to prevent loops). Only classify an item as requiring manual review when rewriting cannot fix it because the criterion is inherently semantic or subjective.

#### Validation rules for `product/00-info.md` (Info section)

| Checklist item                                                    | Rule                                                                                                                                                                                                                                                                             | Auto-fixable?                                                                                    |
| ----------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| Overview present with ≥1 paragraph                                | `## Overview` heading exists; ≥1 non-empty paragraph before next `##`                                                                                                                                                                                                            | Yes                                                                                              |
| Overview ≤4 sentences                                             | Paragraph under `## Overview` contains at most 4 sentences (ends with `.`, `!`, or `?`)                                                                                                                                                                                          | Yes - condense                                                                                   |
| What is Changing present with ≥1 item                             | `## What is Changing` exists; ≥1 bullet or prose paragraph                                                                                                                                                                                                                       | Yes                                                                                              |
| No Out of Scope or Risks section                                  | `## Out of Scope` and `## Risks` headings are absent; those topics are owned by the spec, plan, and design docs                                                                                                                                                                  | Yes - remove the section, fold any unique fact into Overview or Key Decisions                    |
| Key Decisions present only when decisions or open questions exist | If `## Clarifications` in source has ≥1 parseable bullet OR source has ≥1 unresolved `[NEEDS CLARIFICATION]` marker (and user confirmed): section present. Otherwise: section absent                                                                                             | Yes - add or remove section                                                                      |
| Every clarification covered, none dropped                         | Each parseable `## Clarifications` bullet maps to at least one Key Decisions entry; entries may merge several bullets, so entry count ≤ bullet count, but no decision is lost                                                                                                    | Yes - add a missing decision or fold it into the right entry                                     |
| Related clarifications merged into one entry                      | Bullets that decide the same area (same threshold, audience, or behavior) appear as one synthesized entry, not several near-duplicate entries; merge holds even across sessions                                                                                                  | Yes - merge near-duplicate entries                                                               |
| No unrelated decisions merged                                     | No single entry combines clarifications about clearly different decision areas                                                                                                                                                                                                   | No - semantic; flag for manual review                                                            |
| Each decision cites its sessions                                  | Every entry ends with `*Session: YYYY-MM-DD*` (one) or `*Sessions: <dates>*` (several, ascending and deduplicated); every cited date is a real `### Session` date in source                                                                                                      | Yes - fix the citation                                                                           |
| Still open block present only when unresolved markers exist       | "Still open" blockquote present iff user confirmed ≥1 `[NEEDS CLARIFICATION]` marker                                                                                                                                                                                             | Yes - add or remove block                                                                        |
| Still open count matches confirmed markers                        | Bullet count in "Still open" equals count of confirmed `[NEEDS CLARIFICATION]` markers                                                                                                                                                                                           | Yes - add missing bullets                                                                        |
| Sections in canonical order                                       | Headings appear in sequence: Overview, What is Changing, [Key Decisions], [References] - brackets indicate optional                                                                                                                                                              | Yes - reorder                                                                                    |
| Written entirely in English                                       | Dominant language of prose is English                                                                                                                                                                                                                                            | No - source was validated in Step 2                                                              |
| No em dash (`—`)                                                  | Character `—` absent from entire file                                                                                                                                                                                                                                            | Yes - replace with comma, colon, or semicolon                                                    |
| No AI tells                                                       | File does not contain: "delve", "tapestry", "in essence", "navigate the landscape", "seamless", "intuitive", "leverage" (as a standalone verb), "robust" (without a measurable target), "it is worth noting", "it should be noted", "as previously mentioned" (case-insensitive) | Yes - rewrite sentence                                                                           |
| Bullets are short (≤12 words each)                                | Every `-` line contains ≤12 words                                                                                                                                                                                                                                                | Yes - split or shorten                                                                           |
| No implementation detail                                          | File does not contain: file extensions (`.js`, `.ts`, `.py`, `.go`, `.java`, `.rb`, `.sql`), HTTP verbs (`GET`, `POST`, `PUT`, `DELETE`), code fences, database names (`PostgreSQL`, `MySQL`, `Redis`, `MongoDB`, `DynamoDB`, `S3`)                                              | Yes - remove or rephrase                                                                         |
| Header has non-placeholder Feature and Created                    | File has `Feature:` and `Created: YYYY-MM-DD` with real values                                                                                                                                                                                                                   | Yes - set from context                                                                           |
| References are external URLs only                                 | If References section present: every entry has a plain-language label and an external URL; no entry points to spec-kit artifacts (spec.md, plan.md, tasks.md, or any extension-generated file). If absent and source spec contains external hyperlinks: add the section          | Yes - remove entries pointing to internal files; remove section if no external references remain |
| No optional marker leaks into a heading                           | No heading contains `_(optional)_` or a trailing `(optional)`; the marker is a template authoring flag, not title text                                                                                                                                                           | Yes - strip the marker from the heading                                                          |

#### Validation rules for `product/10-spec.md` (Spec section)

| Checklist item                                                    | Rule                                                                                                                                                                                                                                                                             | Auto-fixable?                                                                                     |
| ----------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| Headline present, states the change vs the status quo             | `## Headline` exists; ≥1 paragraph stating the change and how it beats the status quo                                                                                                                                                                                            | Yes - add/expand                                                                                  |
| Users present with ≥1 persona                                     | `## Users` exists; ≥1 named persona or role listed                                                                                                                                                                                                                               | Yes - add placeholder persona from source spec                                                    |
| Problem Statement contains Job to Be Done                         | `## Problem (Job to Be Done)` exists; prose contains "When", "I want to", "so I can" in one sentence                                                                                                                                                                             | Yes - rewrite sentence to canonical form                                                          |
| Scope has In scope and Out of scope sub-lists                     | `## Scope` exists with In scope and Out of scope sub-lists, each ≥1 bullet                                                                                                                                                                                                       | Yes - add bullet from source spec                                                                 |
| Use Cases contains ≥1 use case                                    | `## Use Cases` exists; ≥1 `**Given**`/`**When**`/`**Then**` block present                                                                                                                                                                                                        | Yes - add scenario from source spec                                                               |
| Success Metrics has one north star + ≥1 supporting metric         | `## Success Metrics` exists; exactly one item marked or labelled as north star; ≥1 additional metric                                                                                                                                                                             | Yes - restructure list                                                                            |
| Risks and Open Questions present                                  | `## Risks and Open Questions` exists                                                                                                                                                                                                                                             | Yes - add section                                                                                 |
| Sections in canonical order                                       | H2 headings appear in canonical sequence: Headline, [Glossary], Users, Problem (Job to Be Done), [Assumptions], Scope, Use Cases, Success Metrics, Risks and Open Questions, [Positioning], [Go to Market and Rollout] - brackets indicate optional                              | Yes - reorder                                                                                     |
| Written entirely in English                                       | Dominant language of prose is English                                                                                                                                                                                                                                            | No - source spec was checked in Step 2; flag if mismatch                                          |
| No em dash (`—`)                                                  | Character `—` absent from entire file                                                                                                                                                                                                                                            | Yes - replace with comma, colon, or semicolon                                                     |
| Every use case has exactly one Given, When, Then                  | Each scenario block under `## Use Cases` has exactly one `**Given**`, one `**When**`, one `**Then**` line                                                                                                                                                                        | Yes - rewrite malformed scenarios                                                                 |
| Each Given/When/Then is a full sentence starting with the keyword | Line starts with `**Given**`/`**When**`/`**Then**` and ends with `.`                                                                                                                                                                                                             | Yes - rewrite line                                                                                |
| No implementation detail                                          | File does not contain: file extensions (`.js`, `.ts`, `.py`, `.go`, `.java`, `.rb`, `.sql`), HTTP verbs (`GET`, `POST`, `PUT`, `DELETE`), code fences (` ``` `), database names (`PostgreSQL`, `MySQL`, `Redis`, `MongoDB`, `DynamoDB`, `S3`)                                    | Yes - remove or rephrase offending lines                                                          |
| No AI tells                                                       | File does not contain: "delve", "tapestry", "in essence", "navigate the landscape", "seamless", "intuitive", "leverage" (as a standalone verb), "robust" (without a measurable target), "it is worth noting", "it should be noted", "as previously mentioned" (case-insensitive) | Yes - rewrite sentence without the phrase                                                         |
| Bullets are short (≤12 words each)                                | Every `-` line in the document contains ≤12 words                                                                                                                                                                                                                                | Yes - split or shorten bullet                                                                     |
| Job to Be Done uses an action verb                                | The word after "I want to " is a verb in base form                                                                                                                                                                                                                               | Yes - rewrite motivation clause with explicit action verb                                         |
| Header has non-placeholder Feature and Created                    | File has `Feature:` line with real text and `Created: YYYY-MM-DD` matching today                                                                                                                                                                                                 | Yes - set from context                                                                            |
| NEEDS CLARIFICATION markers surfaced                              | Count of `[NEEDS CLARIFICATION` in source `spec.md` equals count in Risks and Open Questions section; or source count is zero                                                                                                                                                    | Yes - add missing markers to Risks and Open Questions                                             |
| Positioning structure (if present)                                | Contains "For", "who", "this product is a", "that", "unlike", "this product"                                                                                                                                                                                                     | Yes - rewrite to canonical positioning sentence                                                   |
| Go to Market rollout fields (if present)                          | Contains "audience", "channel", "rollout", "launch" (case-insensitive)                                                                                                                                                                                                           | Yes - add missing fields                                                                          |
| Each Use Case describes behavior, not implementation              | No scenario under `## Use Cases` mentions: framework names, file paths, HTTP methods, database operations, or code constructs                                                                                                                                                    | Yes - rewrite offending scenario lines at customer-observable level                               |
| Each metric in Success Metrics is tech-agnostic                   | Metrics do not contain: "p95", "p99", "latency", "throughput", "queue depth", "milliseconds", "bytes", "CPU", "memory", "API response time"                                                                                                                                      | Yes - rephrase to user-facing equivalent (e.g., "time to first result", "task completion rate")   |
| Glossary present only when terms require definition               | If Glossary section present: each bullet is a bold term followed by a one-sentence plain-language definition. If absent: no domain-specific terms in the document require definition for a non-technical reader                                                                  | Yes - add missing definitions; remove section if no term gap exists                               |
| Assumptions present only when source has material assumptions     | If Assumptions section present: each bullet states one assumption with a condition that would invalidate it. If absent and source spec contains assumption markers or undeclared dependencies: add the section                                                                   | Yes - add invalidation clause to entries without one; remove section if source has no assumptions |
| No optional marker leaks into a heading                           | No heading contains `_(optional)_` or a trailing `(optional)`; the marker is a template authoring flag, not title text                                                                                                                                                           | Yes - strip the marker from the heading                                                           |

#### Iteration protocol

1. Evaluate all items against the current in-memory text of each artifact. Record which fail.
2. For each failing item that is auto-fixable: apply the fix in memory to the relevant artifact.
3. Re-evaluate all previously failing items. If any still fail, apply the fix again (max 2 additional passes per item to prevent loops).
4. After the final pass, classify remaining failures per artifact:
   - If a fix was applied but the item still fails: mark `- [ ]` in the checklist and record the specific failure reason.
   - Items that cannot be evaluated (e.g., source spec in English was already confirmed): mark `- [x]`.

### Step 9: Prepare and update product/checklist.md

If `${FEATURE_DIR}/product/checklist.md` does **not** exist:

- Read `templates/product-checklist-template.md`.
- Replace `[FEATURE NAME]` with the feature title and `[DATE]` with today's date.
- Stage the file content in memory. All four sections (`## Info`, `## Spec`, `## Plan`, `## Design`) start with the "not yet generated" placeholder state, then the `## Info` and `## Spec` sections are replaced using the results of Step 8.

If the file **already exists**, read its current content into memory. You will replace only the `## Info` section (between the `## Info` heading and the next `---` horizontal rule) and the `## Spec` section (between the `## Spec` heading and the next `---` horizontal rule) using the results of Step 8. All other sections and the `## Needs Review` section are preserved verbatim.

**Checklist structure for the `## Info` section**: replace the section content with:

```markdown
## Info (`product/00-info.md`)

**Validated**: [DATE] · [PASSED]/[TOTAL] items

- [x] ... (passing items)
- [ ] ... (failing items, if any - see ## Needs Review)
```

**Checklist structure for the `## Spec` section**: replace the section content with:

```markdown
## Spec (`product/10-spec.md`)

**Validated**: [DATE] · [PASSED]/[TOTAL] items

- [x] ... (passing items in the order they appear in the template)
- [ ] ... (failing items, if any - see ## Needs Review)
```

**`## Needs Review` section**: after updating both `## Info` and `## Spec`, rebuild the `## Needs Review` section at the bottom of the file by aggregating all `- [ ]` items from all four sections (`## Info`, `## Spec`, `## Plan`, `## Design`). Each entry must include a one-sentence explanation of what to look for. If no items remain unchecked across all sections, write:

```markdown
## Needs Review

> All items auto-validated. No manual review required.
```

### Step 10: Write files

Write `${FEATURE_DIR}/product/00-info.md`, `${FEATURE_DIR}/product/10-spec.md`, and `${FEATURE_DIR}/product/checklist.md`. All three files are written atomically (write to a temp file in the same directory, then rename) to avoid leaving partial output if the process is interrupted. Create `${FEATURE_DIR}/product/` if it does not exist.

**Source files are READ-ONLY.** The following files MUST NEVER be written, edited, or truncated - they are inputs only: `spec.md`, `plan.md`, `tasks.md`, `research.md`, `data-model.md`, `.specify/feature.json`, `.specify/extensions.yml`, and any file outside `${FEATURE_DIR}/product/`. The only files this command may write are `${FEATURE_DIR}/product/00-info.md`, `${FEATURE_DIR}/product/10-spec.md`, and `${FEATURE_DIR}/product/checklist.md`.

### Step 11: Status report

Print a short status report to the user:

```text
Wrote: <abs path>/product/00-info.md
Wrote: <abs path>/product/10-spec.md
Updated: <abs path>/product/checklist.md  §Info, §Spec
Info sections populated: Overview + What is Changing[, Key Decisions (<M> decisions[, <N> still open])][, References]
Spec sections populated: 7 mandatory[, Glossary][, Assumptions][, Positioning][, Go to Market and Rollout]
Open questions surfaced: <N>
Info checklist: <PASSED>/<TOTAL> auto-validated[, <REMAINING> need manual review]
Spec checklist: <PASSED>/<TOTAL> auto-validated[, <REMAINING> need manual review]
```

The `[, <REMAINING> need manual review]` segment is omitted for a section when all its items pass. `<M>` is the count of resolved decision entries; `<N>` is the count of unresolved questions (in the info "Still open" block and the spec "Open questions" list). The `[, Key Decisions ...]` segment is omitted when the section was not generated.

## Refusal Output Format

On any refusal, print exactly one line of the form:

```text
[product-brief] <CODE>: <human readable remediation>
```

When `E_PLACEHOLDERS` lists multiple placeholders, print one line per placeholder. Feature directory resolution failures surface speckit's own error message verbatim (no product-brief error code).

## Idempotence

Two consecutive runs against the same `spec.md`, with the user choosing overwrite on the second run, produce a `product/00-info.md` and a `product/10-spec.md` whose content is byte identical except for the `Created` fields if the date has rolled over.

The command never modifies `spec.md`.

## Error Codes

| Code           | Condition                                                                       |
| -------------- | ------------------------------------------------------------------------------- |
| E_NO_SPEC      | `spec.md` missing in the feature directory.                                     |
| E_PLACEHOLDERS | `spec.md` still contains template placeholders.                                 |
| E_LANGUAGE     | `spec.md` is not in English.                                                    |
| E_USER_ABORT   | User chose abort at the overwrite prompt or declined to surface clarifications. |
