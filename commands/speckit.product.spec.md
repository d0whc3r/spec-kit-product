---
description: "Generate a product oriented spec.md and update the shared quality checklist from the current feature's spec.md"
---

# Generate Product Spec

Derive a stakeholder facing `product/10-spec.md` from the populated `spec.md` of the active feature, then auto-validate and update the `## Spec` section of the shared `product/checklist.md`. The artifact follows Amazon Working Backwards (PRFAQ), Jobs to Be Done (Ulwick), Gherkin BDD, and Lean PRD conventions, in plain English, with strict style rules.

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

- `<feature-dir>/product/10-spec.md`
- `<feature-dir>/product/checklist.md` (creates if absent; otherwise updates only the `## Spec` section, preserving all other sections)

The only files this command writes are under `${FEATURE_DIR}/product/`. All other spec-kit artifacts are treated as read-only; see the "Source files are READ-ONLY" guard at the end of this document.

## Templates

The command MUST read the following templates from the installed extension and use them verbatim as the structural skeleton of the output. Do NOT invent additional sections. Do NOT reorder sections.

- Product spec template: `templates/product-spec-template.md` (relative to this command's extension root).
- Humanization guide: `templates/humanization-guide.md` (relative to this command's extension root).
- Quality checklist template: `templates/product-checklist-template.md` (relative to this command's extension root).

When this extension is installed under `.specify/extensions/product/`, the absolute paths are:

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

3. **E_LANGUAGE**: `spec.md` is not written in English. Detect non English content by sampling the prose paragraphs (skip code fences and metadata) and checking that the dominant language is English. If the dominant language is not English, refuse with a single line naming the detected language. Do not auto translate.

### Step 3: Surface clarification markers

Scan `spec.md` for occurrences of `[NEEDS CLARIFICATION` (case sensitive prefix). For each occurrence, capture the full marker text and its surrounding sentence as context.

If any markers are present:

- List each marker, one per line, with file location.
- Ask the user: `Surface these as open product questions in product/10-spec.md? (yes/no)`
- On `no` or any non affirmative response, abort with `E_USER_ABORT` and write nothing.
- On `yes`, continue. Each marker MUST appear as a bullet under "Open product questions" in the Risks and Open Product Questions section of the generated `product/10-spec.md`. Never silently resolve a marker.

### Step 4: Handle existing spec.md in product/

If `${FEATURE_DIR}/product/10-spec.md` already exists:

- Print the absolute path of the existing file.
- Ask: `product/10-spec.md already exists. Overwrite? (yes/no)`
- On `no` or any non affirmative response, abort with `E_USER_ABORT`. Do not write any files.
- On `yes`, continue. The existing `product/10-spec.md` will be replaced byte for byte.

If `${FEATURE_DIR}/product/` does not exist yet, create it before writing.

### Step 5: Generate product/10-spec.md

Read `templates/product-spec-template.md`. Replace every bracketed placeholder with concrete content drawn from `spec.md`. Apply the following rules without exception.

#### Style rules (enforced)

Before writing, read `templates/humanization-guide.md` (relative to this command's extension root) and apply it as you compose and again during the rewrite loop: varied cadence, the full AI-tell banlist, and the structural tells it lists. The numbered rules below are the enforced minimum; the guide is the complete practice.

1. **English only.** All output is in English.
2. **No em dash.** The character `—` MUST NOT appear in the output. Use commas, parentheses, colons, semicolons, or sentence breaks. Hyphens (`-`) are allowed.
3. **Plain English.** Active voice, short sentences, human tone. Do not use AI-tell phrases: "delve", "tapestry", "in essence", "navigate the landscape", "seamless", "intuitive", "leverage" (as a standalone verb), "robust" (without a measurable target), "it is worth noting", "it should be noted", "as previously mentioned".
4. **No implementation detail.** No frameworks, languages, APIs, data stores, code, or file paths.
5. **Bullets are short. Prose is full sentences.**
6. **`_(optional)_` is a marker, not title text.** In the template, a heading like `## Glossary _(optional)_` uses `_(optional)_` only to flag that the section is optional. It is an authoring marker, never part of the title. When you keep the section, emit the heading clean (`## Glossary`) with no `_(optional)_`. When the source has no real content that earns the section, omit the whole section, heading included. The string `_(optional)_`, and a bare `(optional)` suffix on any heading, must never appear in the generated document.

#### Section rules

- **Mandatory sections (Headline, Target Users and Personas, Problem Statement, Value Proposition, Scope, Out of Scope, Use Cases, Success Metrics, Risks and Open Product Questions)**: always present, in canonical order, populated. If the source spec lacks information for a mandatory section, do NOT fabricate. Instead, populate the section with what is known, and add a precise open product question to the Risks and Open Product Questions section.
- **Optional section (Glossary)**: include ONLY when the spec uses domain-specific or technical terms that a non-technical stakeholder may not know. Each bullet is a term and its one-sentence plain-language definition. Place this section between Headline and Target Users and Personas. Omit entirely when no vocabulary gap exists.
- **Optional section (Assumptions)**: include ONLY when the source spec contains explicit assumptions about user behavior, market conditions, or technical context that stakeholders should validate. Each bullet states an assumption and the condition that would invalidate it. Place this section between Problem Statement and Value Proposition. Omit when no material assumptions exist.
- **Optional sections (Positioning, Go to Market and Rollout)**: include ONLY when the source spec contains real content for them. Do not emit empty optional sections. Do not write `N/A`. Remove the entire section heading when not used.

#### Use Case rules (Use Cases section)

Each scenario MUST contain exactly three lines, in this order:

```text
**Given** [one full sentence beginning with "Given" describing the starting context].
**When** [one full sentence beginning with "When" describing the user action].
**Then** [one full sentence beginning with "Then" describing the observable outcome].
```

Each line is a single complete sentence ending with a period. Do not bullet sub conditions; if a scenario needs more, split it into two scenarios. Aim for fewer than ten scenarios across the document.

Map source spec User Stories and Acceptance Scenarios into Use Cases by translating the engineering language into customer observable behavior. Drop implementation specifics.

#### Job to Be Done (Problem Statement section)

Write the primary job in the Ulwick form, exactly:

```text
When [situation], I want to [motivation], so I can [expected outcome].
```

Use an action verb. Do NOT name a solution (avoid "When I open the app", "I want to click the button"). Frame the situation, motivation, and outcome at the level the user experiences them.

#### Success Metrics

Provide exactly one north star metric and at least one supporting metric. Each metric must be measurable and technology agnostic. No system internals (no "p95 latency", no "queue depth"). Acceptable patterns: time to outcome, completion rate, satisfaction signal, retention, adoption.

#### Header metadata

- `Feature` field: the H1 title of `spec.md` (the text of the first `#` heading, stripped of the `#` prefix and trimmed). If no H1 is present, use the feature directory name with any leading numeric prefix and hyphens removed (e.g., `003-my-feature` becomes `My Feature`, capitalised as title case).
- `Created` field: today's date in `YYYY-MM-DD`.
- `Status` field: `Draft`.

### Step 6: Prepare product/checklist.md

If `${FEATURE_DIR}/product/checklist.md` does **not** exist:

- Read `templates/product-checklist-template.md`.
- Replace `[FEATURE NAME]` with the feature title and `[DATE]` with today's date.
- Write the file. All four sections (`## Info`, `## Spec`, `## Plan`, `## Design`) start with the "not yet generated" placeholder state.

If the file **already exists**, read its current content. You will replace only the `## Spec` section (between the `## Spec` heading and the next `---` horizontal rule) in Step 6b. All other sections and the `## Needs Review` section are preserved verbatim.

If `${FEATURE_DIR}/product/` does not exist, create it.

### Step 6b: Auto-validate and iterate (Spec section)

**Goal: all checklist items checked. Zero manual items if possible.**

After composing the full text of `product/10-spec.md` in memory (before writing), run validation pass 1. For each failing item: rewrite the affected portion of **`product/10-spec.md`** (the artifact being generated - never the source `spec.md`) in memory to fix it, then re-evaluate. Repeat until all fixable items pass. Only classify an item as requiring manual review when rewriting cannot fix it because the criterion is inherently semantic or subjective.

**Validation rules** - apply to the in-memory spec text:

| Checklist item                                                    | Rule                                                                                                                                                                                                                                                                                                      | Auto-fixable?                                                                                     |
| ----------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| Headline present with ≥1 paragraph                                | `## Headline` heading exists; ≥1 non-empty paragraph follows before next `##`                                                                                                                                                                                                                             | Yes - add/expand                                                                                  |
| Target Users and Personas present with ≥1 persona                 | `## Target Users and Personas` exists; ≥1 named persona or role listed                                                                                                                                                                                                                                    | Yes - add placeholder persona from source spec                                                    |
| Problem Statement contains Job to Be Done                         | `## Problem Statement` exists; prose contains "When", "I want to", "so I can" in one sentence                                                                                                                                                                                                             | Yes - rewrite sentence to canonical form                                                          |
| Value Proposition present                                         | `## Value Proposition` exists with ≥1 non-empty prose line                                                                                                                                                                                                                                                | Yes - add/expand                                                                                  |
| Scope lists ≥1 included capability                                | `## Scope` exists with ≥1 bullet                                                                                                                                                                                                                                                                          | Yes - add bullet from source spec                                                                 |
| Out of Scope lists ≥1 excluded capability                         | `## Out of Scope` exists with ≥1 bullet                                                                                                                                                                                                                                                                   | Yes - add bullet from source spec                                                                 |
| Use Cases contains ≥1 use case                                    | `## Use Cases` exists; ≥1 `**Given**`/`**When**`/`**Then**` block present                                                                                                                                                                                                                                 | Yes - add scenario from source spec                                                               |
| Success Metrics has one north star + ≥1 supporting metric         | `## Success Metrics` exists; exactly one item marked or labelled as north star; ≥1 additional metric                                                                                                                                                                                                      | Yes - restructure list                                                                            |
| Risks and Open Product Questions present                          | `## Risks and Open Product Questions` exists                                                                                                                                                                                                                                                              | Yes - add section                                                                                 |
| Sections in canonical order                                       | H2 headings appear in canonical sequence: Headline, [Glossary], Target Users and Personas, Problem Statement, [Assumptions], Value Proposition, Scope, Out of Scope, Use Cases, Success Metrics, Risks and Open Product Questions, [Positioning], [Go to Market and Rollout] - brackets indicate optional | Yes - reorder                                                                                     |
| Written entirely in English                                       | Dominant language of prose is English                                                                                                                                                                                                                                                                     | No - source spec was checked in Step 2; flag if mismatch                                          |
| No em dash (`—`)                                                  | Character `—` absent from entire file                                                                                                                                                                                                                                                                     | Yes - replace with comma, colon, or semicolon                                                     |
| Every use case has exactly one Given, When, Then                  | Each scenario block under `## Use Cases` has exactly one `**Given**`, one `**When**`, one `**Then**` line                                                                                                                                                                                                 | Yes - rewrite malformed scenarios                                                                 |
| Each Given/When/Then is a full sentence starting with the keyword | Line starts with `**Given**`/`**When**`/`**Then**` and ends with `.`                                                                                                                                                                                                                                      | Yes - rewrite line                                                                                |
| No implementation detail                                          | File does not contain: file extensions (`.js`, `.ts`, `.py`, `.go`, `.java`, `.rb`, `.sql`), HTTP verbs (`GET`, `POST`, `PUT`, `DELETE`), code fences (` ``` `), database names (`PostgreSQL`, `MySQL`, `Redis`, `MongoDB`, `DynamoDB`, `S3`)                                                             | Yes - remove or rephrase offending lines                                                          |
| No AI tells                                                       | File does not contain: "delve", "tapestry", "in essence", "navigate the landscape", "seamless", "intuitive", "leverage" (as a standalone verb), "robust" (without a measurable target), "it is worth noting", "it should be noted", "as previously mentioned" (case-insensitive)                          | Yes - rewrite sentence without the phrase                                                         |
| Bullets are short (≤12 words each)                                | Every `-` line in the document contains ≤12 words                                                                                                                                                                                                                                                         | Yes - split or shorten bullet                                                                     |
| Job to Be Done uses an action verb                                | The word after "I want to " is a verb in base form                                                                                                                                                                                                                                                        | Yes - rewrite motivation clause with explicit action verb                                         |
| Header has non-placeholder Feature and Created                    | File has `Feature:` line with real text and `Created: YYYY-MM-DD` matching today                                                                                                                                                                                                                          | Yes - set from context                                                                            |
| NEEDS CLARIFICATION markers surfaced                              | Count of `[NEEDS CLARIFICATION` in source `spec.md` equals count in Risks and Open Product Questions section; or source count is zero                                                                                                                                                                     | Yes - add missing markers to Risks and Open Product Questions                                     |
| Positioning structure (if present)                                | Contains "For", "who", "this product is a", "that", "unlike", "this product"                                                                                                                                                                                                                              | Yes - rewrite to canonical positioning sentence                                                   |
| Go to Market rollout fields (if present)                          | Contains "audience", "channel", "rollout", "launch" (case-insensitive)                                                                                                                                                                                                                                    | Yes - add missing fields                                                                          |
| Each Use Case describes behavior, not implementation              | No scenario under `## Use Cases` mentions: framework names, file paths, HTTP methods, database operations, or code constructs                                                                                                                                                                             | Yes - rewrite offending scenario lines at customer-observable level                               |
| Each metric in Success Metrics is tech-agnostic                   | Metrics do not contain: "p95", "p99", "latency", "throughput", "queue depth", "milliseconds", "bytes", "CPU", "memory", "API response time"                                                                                                                                                               | Yes - rephrase to user-facing equivalent (e.g., "time to first result", "task completion rate")   |
| Glossary present only when terms require definition               | If Glossary section present: each bullet is a bold term followed by a one-sentence plain-language definition. If absent: no domain-specific terms in the document require definition for a non-technical reader                                                                                           | Yes - add missing definitions; remove section if no term gap exists                               |
| Assumptions present only when source has material assumptions     | If Assumptions section present: each bullet states one assumption with a condition that would invalidate it. If absent and source spec contains assumption markers or undeclared dependencies: add the section                                                                                            | Yes - add invalidation clause to entries without one; remove section if source has no assumptions |
| No optional marker leaks into a heading                           | No heading contains `_(optional)_` or a trailing `(optional)`; the marker is a template authoring flag, not title text                                                                                                                                                                                    | Yes - strip the marker from the heading                                                           |

**Iteration protocol**:

1. Evaluate all items against current in-memory spec text. Record which fail.
2. For each failing item that is auto-fixable: apply the fix in memory.
3. Re-evaluate all previously failing items. If any still fail, apply fix again (max 2 additional passes per item to prevent loops).
4. After final pass, classify remaining failures:
   - If a fix was applied but the item still fails: mark `- [ ]` in the checklist and record the specific failure reason.
   - Items that cannot be evaluated (e.g., source spec in English was already confirmed): mark `- [x]`.

**Checklist structure for the `## Spec` section**: replace the section content with:

```markdown
## Spec (`product/10-spec.md`)

**Validated**: [DATE] · [PASSED]/[TOTAL] items

- [x] ... (passing items in the order they appear in the template)
- [ ] ... (failing items, if any - see ## Needs Review)
```

**`## Needs Review` section**: after updating `## Spec`, rebuild the `## Needs Review` section at the bottom of the file by aggregating all `- [ ]` items from all four sections (`## Info`, `## Spec`, `## Plan`, `## Design`). Each entry must include a one-sentence explanation of what to look for. If no items remain unchecked across all sections, write:

```markdown
## Needs Review

> All items auto-validated. No manual review required.
```

### Step 7: Write files

Write `${FEATURE_DIR}/product/10-spec.md` and `${FEATURE_DIR}/product/checklist.md`. Both files are written atomically (write to a temp file in the same directory, then rename) to avoid leaving partial output if the process is interrupted.

**Source files are READ-ONLY.** The following files MUST NEVER be written, edited, or truncated - they are inputs only: `spec.md`, `plan.md`, `tasks.md`, `research.md`, `data-model.md`, `.specify/feature.json`, `.specify/extensions.yml`, and any file outside `${FEATURE_DIR}/product/`. The only files this command may write are `${FEATURE_DIR}/product/10-spec.md` and `${FEATURE_DIR}/product/checklist.md`.

### Step 8: Status report

Print a short status report to the user:

```text
Wrote: <abs path>/product/10-spec.md
Updated: <abs path>/product/checklist.md  §Spec
Sections populated: 9 mandatory[, Glossary][, Assumptions][, Positioning][, Go to Market and Rollout]
Open product questions surfaced: <N>
Spec checklist: <PASSED>/<TOTAL> auto-validated[, <REMAINING> need manual review]
```

The `[, <REMAINING> need manual review]` segment is omitted when all spec items pass. `<N>` is the number of `[NEEDS CLARIFICATION]` markers surfaced into Section 9.

## Refusal Output Format

On any refusal, print exactly one line of the form:

```text
[product-spec] <CODE>: <human readable remediation>
```

When `E_PLACEHOLDERS` lists multiple placeholders, print one line per placeholder. Feature directory resolution failures surface speckit's own error message verbatim (no product-spec error code).

## Idempotence

Two consecutive runs against the same `spec.md`, with the user choosing overwrite on the second run, produce a `product/10-spec.md` whose content is byte identical except for the `Created` field if the date has rolled over.

The command never modifies `spec.md`.

## Error Codes

| Code           | Condition                                                                       |
| -------------- | ------------------------------------------------------------------------------- |
| E_NO_SPEC      | `spec.md` missing in the feature directory.                                     |
| E_PLACEHOLDERS | `spec.md` still contains template placeholders.                                 |
| E_LANGUAGE     | `spec.md` is not in English.                                                    |
| E_USER_ABORT   | User chose abort at the overwrite prompt or declined to surface clarifications. |
