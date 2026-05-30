---
description: "Generate a short, stakeholder-readable info.md from the current feature's spec.md and update the shared quality checklist"
---

# Generate Product Info

Derive a stakeholder-facing `product/00-info.md` from the populated `spec.md` of the active feature, then auto-validate and update the `## Info` section of the shared `product/checklist.md`. The artifact is a single-page plain-language summary that answers "what is changing and why" for a non-technical reader. It follows the same style rules as `/speckit.product.spec`: English only, no em dash, plain English, active voice, full sentences, no implementation detail, and no AI-tell filler phrases.

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
- `<feature-dir>/product/checklist.md` (creates if absent; otherwise updates only the `## Info` section, preserving all other sections)

The only files this command writes are under `${FEATURE_DIR}/product/`. All other spec-kit artifacts are treated as read-only; see the "Source files are READ-ONLY" guard at the end of this document.

## Templates

The command MUST read the following template from the installed extension and use it verbatim as the structural skeleton of the output. Do NOT invent additional sections. Do NOT reorder sections.

- Product info template: `templates/product-info-template.md` (relative to this command's extension root).

When this extension is installed under `.specify/extensions/product/`, the absolute path is:

- `.specify/extensions/product/templates/product-info-template.md`

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

   These are unfilled template scaffolding. Refuse with a single line per detected placeholder, using the refusal format below.

   **Important distinction**: `[NEEDS CLARIFICATION: ...]` markers are NOT placeholders. They are intentional questions left by the spec author and are handled in Step 3.

3. **E_LANGUAGE**: `spec.md` is not written in English. Detect non-English content by sampling the prose paragraphs (skip code fences and metadata) and checking that the dominant language is English. If the dominant language is not English, refuse with a single line naming the detected language. Do not auto-translate.

### Step 3: Extract decisions and open questions

**3a — Resolved decisions**: Scan `spec.md` for the `## Clarifications` section. If present, collect every `### Session YYYY-MM-DD` subheading and its bullet lines. Each bullet has the form `- Q: <question text> → A: <answer text>`. Parse each bullet into a `(session_date, question, answer)` triple — strip the `Q:` and `A:` prefixes. Skip lines that do not match the pattern. Store the list ordered by session date. If the section is absent or empty, store an empty list.

**3b — Unresolved questions**: Scan `spec.md` for occurrences of `[NEEDS CLARIFICATION` (case-sensitive prefix). For each occurrence, capture the full marker text and its surrounding sentence as context.

If any `[NEEDS CLARIFICATION]` markers are present:

- List each marker, one per line, with file location.
- Ask the user: `Surface these as open questions in product/00-info.md? (yes/no)`
- On `no` or any non-affirmative response, abort with `E_USER_ABORT` and write nothing.
- On `yes`, store each marker as an unresolved question for use in Step 5.

If neither resolved decisions nor unresolved questions exist, the `## Key Decisions` section will be omitted entirely.

### Step 4: Handle existing info.md in product/

If `${FEATURE_DIR}/product/00-info.md` already exists:

- Print the absolute path of the existing file.
- Ask: `product/00-info.md already exists. Overwrite? (yes/no)`
- On `no` or any non-affirmative response, abort with `E_USER_ABORT`. Do not write any files.
- On `yes`, continue. The existing `product/00-info.md` will be replaced byte for byte.

If `${FEATURE_DIR}/product/` does not exist yet, create it before writing.

### Step 5: Generate product/00-info.md

Read `templates/product-info-template.md`. Replace every bracketed placeholder with concrete content drawn from `spec.md`. Apply the following rules without exception.

#### Style rules (enforced)

1. **English only.** All output is in English.
2. **No em dash.** The character `—` MUST NOT appear in the output. Use commas, parentheses, colons, semicolons, or sentence breaks. Hyphens (`-`) are allowed.
3. **Plain English.** Active voice, short sentences, human tone. Do not use AI-tell phrases: "delve", "tapestry", "in essence", "navigate the landscape", "seamless", "intuitive", "leverage" (as a standalone verb without a concrete object), "robust" (without a measurable target).
4. **No implementation detail.** No frameworks, languages, APIs, data stores, code, or file paths.
5. **Bullets are short. Prose is full sentences.**
6. **`_(optional)_` is a marker, not title text.** In the template, a heading like `## Risks _(optional)_` uses `_(optional)_` only to flag that the section is optional. It is an authoring marker, never part of the title. When you keep the section, emit the heading clean (`## Risks`) with no `_(optional)_`. When the source has no real content that earns the section, omit the whole section, heading included. The string `_(optional)_`, and a bare `(optional)` suffix on any heading, must never appear in the generated document.

#### Section rules

- **Mandatory sections (Overview, Headline, What is Changing, Out of Scope)**: always present, in canonical order, populated. If the source spec lacks information for a mandatory section, do NOT fabricate. Populate the section with what is known, and add a precise question to the Key Decisions "Still open" block.
- **Optional section (Risks)**: include ONLY when the spec contains concrete risk signals: dependencies at risk, architectural constraints, assumptions that might be wrong, or integration points likely to break. Apply the pre-mortem lens: imagine the feature shipped and failed, then name the two to four most likely causes drawn from the spec. Do not emit generic risk platitudes. Remove the entire section when the spec has no meaningful risk signals.
- **Optional section (Key Decisions)**: include when the resolved decisions list OR the unresolved questions list is non-empty. Two parts:
  1. Resolved decisions: one entry per `(session_date, question, answer)` triple. Each entry is a bold noun-phrase title (derived from the question topic — not the full question), followed by one sentence stating the decision as a positive outcome, then `*Session: YYYY-MM-DD*` on the next line. Do not repeat the question verbatim. Write the decision as a statement ("The feature will...", "Users with X will...", "This version does not..."). If the answer provides reasoning, include it in the same sentence.
  2. "Still open" block: rendered only when there are unresolved `[NEEDS CLARIFICATION]` markers. Use a blockquote: `> **Still open**: These questions were raised but not yet resolved. They should be answered before this feature is built.` followed by one bullet per marker as a single-sentence question. Never silently resolve a marker.
     If only one of the two parts has content, include only that part. Remove the entire section if both lists are empty.
- **Optional section (References)**: include ONLY when `spec.md` cites external resources that a non-technical reader would benefit from accessing: user research reports, product briefs, customer interviews, analytics dashboards, external standards, or third-party documentation. NEVER link to spec-kit artifacts: `spec.md`, `plan.md`, `tasks.md`, `data-model.md`, `research.md`, or any file generated by this extension are inputs, not references. Each entry must be an external URL with a plain-language label. Omit the section when the source spec has no external references. This section appears last.

#### Header metadata

- `Feature` field: the H1 title of `spec.md` (the text of the first `#` heading, stripped of the `#` prefix and trimmed). If no H1 is present, use the feature directory name with any leading numeric prefix and hyphens removed (e.g., `003-my-feature` becomes `My Feature`, capitalised as title case).
- `Created` field: today's date in `YYYY-MM-DD`.
- `Status` field: `Draft`.

#### Section guidance

- **Overview**: two to three sentences. State what this feature is expected to be at a high level: the problem it addresses and the nature of the solution. This section answers "what is this feature?" not "what is changing?". No implementation detail, no change-language, no jargon.
- **Headline**: one paragraph, two to four sentences. State who this is for, what is changing for them, and the new outcome they can reach. No internal jargon, no feature lists, no implementation detail.
- **What is Changing**: two to five short bullets, or one short paragraph. State customer-observable differences after the feature ships. Each bullet is a single sentence ending with a period.
- **Out of Scope**: a short scannable list of what is explicitly not included, even though a reasonable reader might expect it. Always populate it. Each item is one short sentence with a one-phrase reason.
- **Risks (optional)**: pre-mortem analysis. Imagine the feature shipped and quietly failed six months from now. What caused it? Two to four bullets, each naming one concrete risk drawn from the spec and its consequence. Prioritise: technical or architectural impact (integration points, data model assumptions, dependency on another team's work, performance constraints), followed by delivery risks (scope creep, unclear ownership, missing prerequisite). Skip generic risks. If the spec has nothing that signals real risk, omit the section entirely.
- **Key Decisions (optional)**: open with one sentence: "These decisions were made while writing this spec. Review them to confirm they still reflect the right direction." Then list resolved decisions. Each entry: bold noun-phrase title on its own line (e.g., `**Rollout audience**`), followed by a single sentence that names the choice and gives the reason in plain product language, then `*Session: YYYY-MM-DD*`. If unresolved questions exist, end with the "Still open" blockquote block. Do not fabricate decisions or questions.
- **References (optional)**: each entry is formatted as `- [Plain-language label]: [URL]`. Only external URLs. Never internal spec-kit files.

### Step 6: Auto-validate and iterate (Info section)

**Goal: all Info checklist items checked. Zero manual items if possible.**

After composing the full text of `product/00-info.md` in memory (before writing), run validation pass 1. For each failing item that is auto-fixable: rewrite the affected portion of the in-memory artifact (never the source `spec.md`), then re-evaluate. Repeat until all fixable items pass (max 2 additional passes per item to prevent loops). Only classify an item as requiring manual review when rewriting cannot fix it because the criterion is inherently semantic or subjective.

| Checklist item                                                    | Rule                                                                                                                                                                                                                                                                    | Auto-fixable?                                                                                    |
| ----------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| Overview present with ≥1 paragraph                                | `## Overview` heading exists; ≥1 non-empty paragraph before next `##`                                                                                                                                                                                                   | Yes                                                                                              |
| Overview ≤3 sentences                                             | Paragraph under `## Overview` contains at most 3 sentences (ends with `.`, `!`, or `?`)                                                                                                                                                                                 | Yes — condense                                                                                   |
| Headline present with ≥1 paragraph                                | `## Headline` heading exists; ≥1 non-empty paragraph before next `##`                                                                                                                                                                                                   | Yes                                                                                              |
| What is Changing present with ≥1 item                             | `## What is Changing` exists; ≥1 bullet or prose paragraph                                                                                                                                                                                                              | Yes                                                                                              |
| Out of Scope present with ≥1 item                                 | `## Out of Scope` exists; ≥1 bullet                                                                                                                                                                                                                                     | Yes                                                                                              |
| Risks present only when source spec has risk signals              | If Risks section is absent and no risk signals detected in `spec.md`: pass. If present and `spec.md` has no risk signals: flag as over-generated.                                                                                                                       | Yes — remove section if no signals                                                               |
| Key Decisions present only when decisions or open questions exist | If `## Clarifications` in source has ≥1 parseable bullet OR source has ≥1 unresolved `[NEEDS CLARIFICATION]` marker (and user confirmed): section present. Otherwise: section absent                                                                                    | Yes — add or remove section                                                                      |
| Key Decisions resolved count matches source clarifications        | Number of decision entries equals parseable bullet count from `## Clarifications` in spec.md                                                                                                                                                                            | Yes — add missing entries                                                                        |
| Still open block present only when unresolved markers exist       | "Still open" blockquote present iff user confirmed ≥1 `[NEEDS CLARIFICATION]` marker                                                                                                                                                                                    | Yes — add or remove block                                                                        |
| Still open count matches confirmed markers                        | Bullet count in "Still open" equals count of confirmed `[NEEDS CLARIFICATION]` markers                                                                                                                                                                                  | Yes — add missing bullets                                                                        |
| Sections in canonical order                                       | Headings appear in sequence: Overview, Headline, What is Changing, Out of Scope, [Risks], [Key Decisions], [References] — brackets indicate optional                                                                                                                    | Yes — reorder                                                                                    |
| Written entirely in English                                       | Dominant language of prose is English                                                                                                                                                                                                                                   | No — source was validated in Step 2                                                              |
| No em dash (`—`)                                                  | Character `—` absent from entire file                                                                                                                                                                                                                                   | Yes — replace with comma, colon, or semicolon                                                    |
| No AI tells                                                       | File does not contain: "delve", "tapestry", "in essence", "navigate the landscape", "seamless", "intuitive", "leverage" (standalone), "robust" (without measurable target), "it is worth noting", "it should be noted" (case-insensitive)                               | Yes — rewrite sentence                                                                           |
| Bullets are short (≤12 words each)                                | Every `-` line contains ≤12 words                                                                                                                                                                                                                                       | Yes — split or shorten                                                                           |
| No implementation detail                                          | File does not contain: file extensions (`.js`, `.ts`, `.py`, `.go`, `.java`, `.rb`, `.sql`), HTTP verbs (`GET`, `POST`, `PUT`, `DELETE`), code fences, database names (`PostgreSQL`, `MySQL`, `Redis`, `MongoDB`, `DynamoDB`, `S3`)                                     | Yes — remove or rephrase                                                                         |
| Header has non-placeholder Feature and Created                    | File has `Feature:` and `Created: YYYY-MM-DD` with real values                                                                                                                                                                                                          | Yes — set from context                                                                           |
| References are external URLs only                                 | If References section present: every entry has a plain-language label and an external URL; no entry points to spec-kit artifacts (spec.md, plan.md, tasks.md, or any extension-generated file). If absent and source spec contains external hyperlinks: add the section | Yes — remove entries pointing to internal files; remove section if no external references remain |
| No optional marker leaks into a heading                           | No heading contains `_(optional)_` or a trailing `(optional)`; the marker is a template authoring flag, not title text                                                                                                                                                  | Yes — strip the marker from the heading                                                          |

**Checklist structure for the `## Info` section**: replace the section content with:

```markdown
## Info (`product/00-info.md`)

**Validated**: [DATE] · [PASSED]/[TOTAL] items

- [x] ... (passing items)
- [ ] ... (failing items, if any — see ## Needs Review)
```

**`## Needs Review` section**: rebuild the `## Needs Review` section at the bottom by aggregating all `- [ ]` items from all four sections (`## Info`, `## Spec`, `## Plan`, `## Design`). Each entry includes a one-sentence explanation of what to look for. If no items remain unchecked, write:

```markdown
## Needs Review

> All items auto-validated. No manual review required.
```

### Step 7: Prepare product/checklist.md

If `${FEATURE_DIR}/product/checklist.md` does **not** exist:

- Read `templates/product-checklist-template.md`.
- Replace `[FEATURE NAME]` with the feature title and `[DATE]` with today's date.
- Stage the file content in memory. All four sections (`## Info`, `## Spec`, `## Plan`, `## Design`) start with the "not yet generated" placeholder state.

If the file **already exists**, read its current content into memory. You will replace only the `## Info` section (between the `## Info` heading and the next `---` horizontal rule) using the results of Step 6. All other sections and the `## Needs Review` section are preserved verbatim.

### Step 8: Write files

Write `${FEATURE_DIR}/product/00-info.md` and `${FEATURE_DIR}/product/checklist.md` atomically (write to a temp file in the same directory, then rename) to avoid leaving partial output if the process is interrupted. Create `${FEATURE_DIR}/product/` if it does not exist.

### Step 9: Print a status report

```text
Wrote: <abs path>/product/00-info.md
Updated: <abs path>/product/checklist.md  §Info
Sections populated: Overview + Headline + What is Changing + Out of Scope[, Risks][, Key Decisions (<M> decisions[, <N> still open])][, References]
Info checklist: <PASSED>/<TOTAL> auto-validated[, <REMAINING> need manual review]
```

The `[, <REMAINING> need manual review]` segment is omitted when all info items pass. `<M>` is the count of resolved decision entries; `<N>` is the count of unresolved questions in the "Still open" block. The `[, Key Decisions ...]` segment is omitted when the section was not generated.

## Refusal Output Format

On any refusal, print exactly one line of the form:

```text
[product-info] <CODE>: <human readable remediation>
```

When `E_PLACEHOLDERS` lists multiple placeholders, print one line per placeholder.

## Error Codes

| Code           | Condition                                                                       |
| -------------- | ------------------------------------------------------------------------------- |
| E_NO_SPEC      | `spec.md` missing in the feature directory.                                     |
| E_PLACEHOLDERS | `spec.md` still contains template placeholders.                                 |
| E_LANGUAGE     | `spec.md` is not in English.                                                    |
| E_USER_ABORT   | User chose abort at the overwrite prompt or declined to surface clarifications. |

## Idempotence

Two consecutive runs against the same `spec.md`, with the user choosing overwrite on the second run, produce a `product/00-info.md` whose content is byte-identical except for the `Created` field if the date has rolled over.

**Source files are READ-ONLY.** The following files MUST NEVER be written, edited, or truncated — they are inputs only: `spec.md`, `plan.md`, `tasks.md`, `research.md`, `data-model.md`, `.specify/feature.json`, `.specify/extensions.yml`, and any file outside `${FEATURE_DIR}/product/`. The only files this command may write are `${FEATURE_DIR}/product/00-info.md` and `${FEATURE_DIR}/product/checklist.md`.
