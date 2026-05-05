---
description: "Generate a high-level, product-oriented plan from the current feature's plan.md and update the shared quality checklist"
---

# Generate Product Plan

Derive a stakeholder-facing `product/plan.md` from the populated `plan.md` of the active feature, then auto-validate and update the `## Plan` section of the shared `product/checklist.md`. The artifact answers "how are we building this?" for product managers and cross-functional leads. It uses Shape Up appetite framing for phases, a NOW/NEXT/LATER delivery view, C4 container-level component descriptions, and condensed ADR summaries for key decisions. Technical terms are used but always glossed in plain English on first use. No code, no file paths, no task-level detail.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty). The user MAY pass `--feature-dir <path>` to override the pointer in `.specify/feature.json`.

## Inputs

The command reads (does not modify):

- `.specify/feature.json` to locate the active feature directory.
- `<feature-dir>/plan.md` as the primary source.
- `<feature-dir>/spec.md` as optional supplementary context (personas, problem framing, Why Now).

The command writes:

- `<feature-dir>/product/plan.md`
- `<feature-dir>/product/checklist.md` (creates if absent; otherwise updates only the `## Plan` section, preserving all other sections)

The command reads (does not modify): `plan.md`, `spec.md`, `tasks.md`, `research.md`, `data-model.md`, and all spec-kit generated files. The only files this command writes are under `${FEATURE_DIR}/product/`.

## Templates

The command MUST read the following template from the installed extension and use it verbatim as the structural skeleton of the output. Do NOT invent additional sections. Do NOT reorder sections.

- Product plan template: `templates/product-plan-template.md` (relative to this command's extension root).

When this extension is installed under `.specify/extensions/product/`, the absolute path is:

- `.specify/extensions/product/templates/product-plan-template.md`

## Execution

### Step 1: Resolve the feature directory

Run the cross-platform helper:

- **Bash**: `.specify/extensions/product/scripts/bash/resolve-feature-dir.sh [--feature-dir "<path>"]`
- **PowerShell**: `.specify/extensions/product/scripts/powershell/resolve-feature-dir.ps1 [-FeatureDir "<path>"]`

The script prints an absolute path on stdout, or exits non-zero with one of `E_NO_PROJECT`, `E_NO_POINTER`, `E_BAD_POINTER`. Surface the script's stderr verbatim to the user and stop on any non-zero exit code.

Capture the printed path as `FEATURE_DIR`.

### Step 2: Verify plan.md

Refuse to proceed when:

1. **E_NO_PLAN**: `${FEATURE_DIR}/plan.md` does not exist. Tell the user to run `/speckit-plan` first.
2. **E_PLACEHOLDERS**: `plan.md` still contains literal placeholders from the plan template. Detect these by looking for any of the following exact bracketed strings as substrings of the file (case sensitive):
   - `[FEATURE]`
   - `[DATE]`
   - `[###-feature-name]`
   - `[link]`
   - `[Extract from feature spec: primary requirement + technical approach from research]`

   These are unfilled template scaffolding. Refuse with `E_PLACEHOLDERS`, listing each detected placeholder on its own line under the error code.

3. **E_LANGUAGE**: `plan.md` is not written in English. Detect non-English content by sampling the prose paragraphs (skip code fences and metadata) and checking that the dominant language is English. If the dominant language is not English, refuse with a single line naming the detected language. Do not auto-translate.

### Step 3: Load optional context

If `${FEATURE_DIR}/spec.md` exists, read it silently for supplementary context: personas, problem framing, Why Now. Use this context to enrich the Summary section. If absent, proceed without warning or error.

### Step 4: Check for sparse plan

Inspect `plan.md` for identifiable phases (sections named "Phase" or equivalent delivery bands), decisions, or component information. If none are found:

- Emit a non-blocking console notice:
  ```
  [product-plan] NOTICE: plan.md appears sparse. Output coverage may be limited.
  ```
- Continue with generation. Do not abort.

### Step 5: Handle existing product/plan.md

If `${FEATURE_DIR}/product/plan.md` already exists:

- Print the absolute path of the existing file.
- Ask: `product/plan.md already exists. Overwrite? (yes/no)`
- On `no` or any non-affirmative response, abort with `E_USER_ABORT`. Do not write any files.
- On `yes`, continue. The existing `product/plan.md` will be replaced.

If `${FEATURE_DIR}/product/` does not exist yet, create it before writing.

### Step 6: Generate product/plan.md

Read `templates/product-plan-template.md`. Populate all sections from `plan.md` (and `spec.md` when available). Apply the following rules without exception.

#### Style rules (enforced)

1. **English only.** All output is in English.
2. **No em dash.** The character `—` MUST NOT appear in the output. Use commas, parentheses, colons, semicolons, or sentence breaks. Hyphens (`-`) are allowed.
3. **Plain English.** Active voice, short sentences, human tone. Do not use AI-tell phrases: "delve", "tapestry", "in essence", "navigate the landscape", "seamless", "intuitive", "leverage" (as a standalone verb without a concrete object), "robust" (without a measurable target).
4. **No implementation detail.** No frameworks, languages, APIs, data stores, code, or file paths.
5. **Technical terms glossed on first use.** The following terms must carry a plain-language gloss in parentheses on the same line as their first occurrence: "API" (application programming interface), "CLI" (command-line interface), "SDK" (software development kit), "refactor" (restructure existing code without changing its behavior), "idempotent" (produces the same result when run multiple times), "atomic" (all-or-nothing operation), "schema" (structured definition of data), "linter" (automated style and error checker), "manifest" (declaration file listing components or contents), "hook" (event-triggered extension point), "pipeline" (automated sequence of steps). Subsequent occurrences of the same term require no gloss.
6. **Bullets are short. Prose is full sentences.**
7. **No invented content.** Do not invent phases, decisions, or components not present in the source `plan.md`.

#### Section rules

- **Mandatory sections (1 through 3)**: always present, in canonical order, populated. Section 1 (Summary), Section 2 (Delivery Phases), Section 3 (Out of Scope).
- **Optional section (4 Component Overview)**: include only when `plan.md` contains architecture or component information. Omit the entire section (including heading) otherwise.
- **Optional section (5 Key Technical Decisions)**: include only when `plan.md` contains explicit design decisions. Omit the entire section otherwise.
- **Optional section (6 Risks)**: include only when `plan.md` contains concrete risk signals. Apply the pre-mortem lens: imagine the feature shipped and quietly failed, name two to four concrete causes drawn from the plan. Do not emit generic risk platitudes. Omit the entire section when the plan has no meaningful risk signals.
- **Optional section (7 Open Questions)**: include only when `plan.md` contains open questions or marked assumptions. Each item becomes one bullet as a single-sentence question. Never silently resolve an open question.

#### Header metadata

- `Feature` field: the H1 title of `plan.md` (the text of the first `#` heading, stripped of the `#` prefix and trimmed). If no H1 is present, fall back to the H1 of `spec.md` when available. If neither has an H1, use the feature directory name with any leading numeric prefix and hyphens removed (e.g., `003-my-feature` becomes `My Feature`, capitalised as title case).
- `Created` field: today's date in `YYYY-MM-DD`.
- `Status` field: `Draft`.

#### Section guidance

- **Section 1 (Summary)**: one paragraph, three to five sentences. State what is being built, why it is being built now, and what the main approach is. Use `spec.md` personas and Why Now framing when available. No code, no file paths.
- **Section 2 (Delivery Phases)**: structured as three bands.
  - **NOW**: each phase from the engineering plan becomes a subsection. Include the phase name, a rough time-box (appetite), and two to four outcome bullets per phase. Outcomes are things delivered, not tasks performed.
  - **NEXT**: the natural follow-on capability after this feature ships. One to three short bullets. Not a commitment.
  - **LATER**: explicitly deferred work drawn from the Out of Scope list. One to three short bullets.
- **Section 3 (Out of Scope)**: a short, scannable list of what is explicitly not included. Always populate this section. Each item is one short sentence with a one-phrase reason. Draw from the plan's out-of-scope or exclusions list.
- **Section 4 (Component Overview, optional)**: list the main system parts this feature adds, changes, or depends on. Each part is one bullet: name, one-sentence responsibility, and whether this feature adds or modifies it. C4 container level only - no classes, no functions.
- **Section 5 (Key Technical Decisions, optional)**: each key decision from the plan uses the condensed ADR format: Decision (what was chosen), Why (plain-language reason), Trade-off (what was accepted).
- **Section 6 (Risks, optional)**: two to four bullets, each naming one concrete risk from the plan and its consequence.
- **Section 7 (Open Questions, optional)**: each open question or marked assumption from the plan becomes one bullet as a single-sentence question.

### Step 7: Write the file atomically

Write to a temp file inside `${FEATURE_DIR}/product/`, then rename to `plan.md`. This avoids leaving partial output if the process is interrupted. Create `${FEATURE_DIR}/product/` if it does not exist.

### Step 7b: Prepare product/checklist.md

If `${FEATURE_DIR}/product/checklist.md` does **not** exist:
- Read `templates/product-checklist-template.md`.
- Replace `[FEATURE NAME]` with the feature title and `[DATE]` with today's date.
- Write the file. All three sections start with the "not yet generated" placeholder state.

If the file **already exists**, read its current content. You will replace only the `## Plan` section (between the `## Plan` heading and the next `---` horizontal rule) below. All other sections and `## Needs Review` are preserved verbatim.

### Step 7c: Auto-validate and iterate (Plan section)

**Goal: all Plan checklist items checked. Zero manual items if possible.**

After writing `product/plan.md`, evaluate each item below against its content. For each failing item that is auto-fixable: rewrite the affected portion of **`product/plan.md`** (the artifact being generated — never the source `plan.md` or `spec.md`) in memory, re-evaluate (max 2 extra passes per item). Then update `product/checklist.md` with the results.

| Checklist item | Rule | Auto-fixable? |
|---|---|---|
| Section 1 (Summary) present with ≥1 paragraph | `## 1.` heading exists; 3–5 sentence paragraph before next `##` | Yes |
| Section 2 (Delivery Phases) has NOW/NEXT/LATER bands | `## 2.` exists; contains "NOW", "NEXT", "LATER" subsections with ≥1 bullet each | Yes — add missing band from source plan |
| Section 3 (Out of Scope) present with ≥1 item | `## 3.` exists; ≥1 bullet | Yes |
| Sections in canonical order 1–3 (4–7 optional) | Heading numbers appear in strictly ascending sequence | Yes — reorder |
| Written entirely in English | Dominant language of prose is English | No — source was validated in Step 2 |
| No em dash (`—`) | Character `—` absent from entire file | Yes — replace with comma, colon, or semicolon |
| No AI tells | File does not contain: "delve", "tapestry", "in essence", "navigate the landscape", "seamless", "intuitive", "leverage" (standalone), "robust" (without measurable target), "it is worth noting" (case-insensitive) | Yes — rewrite sentence |
| Bullets are short (≤12 words each) | Every `- ` line contains ≤12 words | Yes — split or shorten |
| No code or file paths | File does not contain: code fences, file extension patterns (`.js`, `.ts`, `.py`, `.go`, etc.), absolute or relative paths starting with `/` or `./` | Yes — remove or describe in prose |
| Technical terms glossed on first use | First occurrence of each term in this set carries a parenthetical gloss: API, CLI, SDK, refactor, idempotent, atomic, schema, linter, manifest, hook, pipeline | Yes — insert gloss after first occurrence |
| No invented content (phases match source plan) | Section 2 phases correspond to phases identifiable in source `plan.md`; no phase name absent from source | Yes — remove invented phases, consolidate into what source contains |
| Optional sections present only when source warrants | Section 4 present only if `plan.md` has architecture/component info; Section 5 only if explicit decisions; Section 6 only if concrete risks; Section 7 only if open questions | Yes — remove sections with no source backing |
| Header has non-placeholder Feature and Created | File has `Feature:` and `Created: YYYY-MM-DD` with real values | Yes — set from context |

**Checklist structure for the `## Plan` section**: replace the section content with:

```markdown
## Plan (`product/plan.md`)

**Validated**: [DATE] · [PASSED]/[TOTAL] items

- [x] ...  (passing items)
- [ ] ...  (failing items, if any — see ## Needs Review)
```

**`## Needs Review` section**: rebuild the `## Needs Review` section at the bottom by aggregating all `- [ ]` items from all three sections. Each entry includes a one-sentence explanation. If no items remain unchecked, write:

```markdown
## Needs Review

> All items auto-validated. No manual review required.
```

### Step 8: Print a status report

```text
Wrote: <abs path>/product/plan.md
Updated: <abs path>/product/checklist.md  §Plan
Sections populated: Summary, Delivery Phases, Out of Scope[, Component Overview][, Key Technical Decisions][, Risks][, Open Questions]
Open questions surfaced: <N>
Plan checklist: <PASSED>/<TOTAL> auto-validated[, <REMAINING> need manual review]
```

The `[, <REMAINING> need manual review]` segment is omitted when all plan items pass. Only list optional sections that were included. `<N>` is the count of open questions surfaced. If none, `<N>` is `0`.

## Refusal Output Format

On any refusal, print exactly one line of the form:

```text
[product-plan] <CODE>: <human readable remediation>
```

When `E_PLACEHOLDERS` lists multiple placeholders, print one line per placeholder after the `E_PLACEHOLDERS` header line.

## Error Codes

| Code | Condition |
|------|-----------|
| E_NO_PROJECT | No `.specify/` directory in any ancestor of the working directory. |
| E_NO_POINTER | `.specify/feature.json` missing and `--feature-dir` not provided. |
| E_BAD_POINTER | Feature directory in the pointer does not exist. |
| E_NO_PLAN | `plan.md` missing in the feature directory. Run `/speckit-plan` first. |
| E_PLACEHOLDERS | `plan.md` still contains template placeholders. |
| E_LANGUAGE | `plan.md` is not in English. |
| E_USER_ABORT | User chose abort at the overwrite prompt. |

## Idempotence

Two consecutive runs against the same `plan.md` and `spec.md`, with the user choosing overwrite on the second run, produce a `product/plan.md` whose content is equivalent except for the `Created` field if the date has rolled over.

**Source files are READ-ONLY.** The following files MUST NEVER be written, edited, or truncated — they are inputs only: `plan.md`, `spec.md`, `tasks.md`, `research.md`, `data-model.md`, `.specify/feature.json`, `.specify/extensions.yml`, and any file outside `${FEATURE_DIR}/product/`. The only files this command may write are `${FEATURE_DIR}/product/plan.md` and `${FEATURE_DIR}/product/checklist.md`.
