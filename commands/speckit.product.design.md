---
description: "Generate a high-level technical design document from the current feature's plan.md and spec.md, aimed at tech leads and senior developers"
---

# Generate Technical Design

Derive a `product/30-design.md` from the `plan.md` and `spec.md` of the active feature, then auto-validate and update the `## Design` section of the shared `product/checklist.md`. The artifact answers "how are we building this technically?" for tech leads and senior developers. It covers architectural approach, affected modules and layers, data model and API shapes, spec coverage mapping, key technical decisions, testing strategy, and rollout plan. Unlike the product-facing `product/plan.md`, this document is allowed to reference component names, module boundaries, file-level granularity, API surface shapes, and data schemas at a conceptual level. No runnable code, no full ORM definitions, no line-by-line implementation detail.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty). The user MAY pass `--feature-dir <path>` to override the pointer in `.specify/feature.json`.

## Inputs

The command reads (does not modify):

- `.specify/feature.json` to locate the active feature directory.
- `<feature-dir>/plan.md` as the primary source.
- `<feature-dir>/spec.md` as required supplementary context for use cases, acceptance criteria, and personas.
- `<feature-dir>/tasks.md` as optional supplementary context for implementation hints (read silently if present).
- `<feature-dir>/data-model.md` as optional supplementary context for existing data shapes (read silently if present).

The command writes:

- `<feature-dir>/product/30-design.md`
- `<feature-dir>/product/checklist.md` (creates if absent; otherwise updates only the `## Design` section, preserving all other sections)

**Source files are READ-ONLY.** The following files MUST NEVER be written, edited, or truncated: `plan.md`, `spec.md`, `tasks.md`, `research.md`, `data-model.md`, `.specify/feature.json`, `.specify/extensions.yml`, and any file outside `${FEATURE_DIR}/product/`. The only files this command may write are `${FEATURE_DIR}/product/30-design.md` and `${FEATURE_DIR}/product/checklist.md`.

## Templates

The command MUST read the following template from the installed extension and use it verbatim as the structural skeleton of the output. Do NOT invent additional sections. Do NOT reorder sections.

- Technical design template: `templates/product-design-template.md` (relative to this command's extension root).

When this extension is installed under `.specify/extensions/product/`, the absolute path is:

- `.specify/extensions/product/templates/product-design-template.md`

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

### Step 2: Verify plan.md and spec.md

Refuse to proceed when:

1. **E_NO_PLAN**: `${FEATURE_DIR}/plan.md` does not exist. Tell the user to run `/speckit-plan` first.
2. **E_NO_SPEC**: `${FEATURE_DIR}/spec.md` does not exist. Tell the user to run `/speckit-spec` first.
3. **E_PLACEHOLDERS**: `plan.md` or `spec.md` still contain literal placeholders from their templates. Detect these by looking for any of the following exact bracketed strings as substrings of either file (case sensitive):
   - `[FEATURE]`
   - `[DATE]`
   - `[###-feature-name]`
   - `[link]`
   - `[Extract from feature spec: primary requirement + technical approach from research]`

   These are unfilled template scaffolding. Refuse with `E_PLACEHOLDERS`, naming the affected file and listing each detected placeholder on its own line under the error code.

4. **E_LANGUAGE**: Either source file is not written in English. Detect non-English content by sampling the prose paragraphs (skip code fences and metadata) and checking that the dominant language is English. If the dominant language is not English, refuse with a single line naming the detected language and file. Do not auto-translate.

### Step 3: Load optional context

Read the following files silently if they exist. Do not warn or error if absent.

- `${FEATURE_DIR}/tasks.md` — use for implementation hints to populate Affected Modules and Spec Coverage.
- `${FEATURE_DIR}/data-model.md` — use to ground the Data Design section in existing schemas.

### Step 4: Check for sparse sources

Inspect `plan.md` and `spec.md` for architecture information, component descriptions, data model details, use cases, and explicit technical decisions. If none are found across both files:

- Emit a non-blocking console notice:

  ```text
  [product-design] NOTICE: plan.md and spec.md appear sparse. Output coverage may be limited.
  ```

- Continue with generation. Do not abort.

### Step 5: Handle existing product/30-design.md

If `${FEATURE_DIR}/product/30-design.md` already exists:

- Print the absolute path of the existing file.
- Ask: `product/30-design.md already exists. Overwrite? (yes/no)`
- On `no` or any non-affirmative response, abort with `E_USER_ABORT`. Do not write any files.
- On `yes`, continue. The existing `product/30-design.md` will be replaced.

If `${FEATURE_DIR}/product/` does not exist yet, create it before writing.

### Step 6: Generate product/30-design.md

Read `templates/product-design-template.md`. Populate all sections from `plan.md`, `spec.md`, and any optional context files. Apply the following rules without exception.

#### Style rules (enforced)

1. **English only.** All output is in English.
2. **No em dash.** The character `—` MUST NOT appear in the output. Use commas, parentheses, colons, semicolons, or sentence breaks. Hyphens (`-`) are allowed.
3. **Active voice, short sentences.** Human tone. Do not use AI-tell phrases: "delve", "tapestry", "in essence", "navigate the landscape", "seamless", "intuitive", "leverage" (as a standalone verb without a concrete object), "robust" (without a measurable target), "it is worth noting".
4. **Technical depth is appropriate.** This document targets tech leads and senior developers. Component names, module boundaries, file-system layer references (frontend, backend, data layer), API surface shapes, and data schemas at a conceptual level are all permitted and encouraged. Do NOT dumb down technical content.
5. **No runnable code.** No language-specific syntax, no full class or function definitions, no ORM schema DDL. Use plain `text` blocks for data shapes and API contracts.
6. **No full OpenAPI specs.** API Design section shows request/response shapes conceptually. Error codes and constraints are listed but not exhaustive.
7. **Bullets are short. Prose is full sentences.**
8. **No invented content.** Do not invent components, decisions, data models, API endpoints, risks, or test scenarios not present in the source files.

#### Section rules

- **Summary**: always present. 2-4 sentences: what is being built, which layers are affected, and the key architectural approach.
- **Technical Context**: always present. Three labeled fields (Current state, Affected layers, Technical constraints). Current state is one sentence. Affected layers is a comma-separated list. Technical constraints is a bullet list of concrete constraints from the source; if none are stated, write "No explicit constraints identified."
- **Architectural Approach**: always present. 3-6 paragraphs covering how the solution fits into the existing architecture, which components are added/changed/removed, how they connect, and key design principles. C4 container and component level — not class or function level.
- **Affected Modules**: always present. A table with columns: Module/Component, Change (adds/modifies/removes/uses), Responsibility. At least two rows. If `tasks.md` is present, use it to identify affected modules.
- **Data Design**: always present when `plan.md`, `spec.md`, or `data-model.md` contains any data model information. Two subsections: Data Model (entities and key fields as plain text blocks) and Data Flow (how data moves). Omit the entire section when no data model information exists in any source.
- **API Design**: always present when the feature exposes or modifies any API surface. Show request/response shapes and error cases at a conceptual level using plain `text` blocks. Omit the entire section when the feature has no API surface.
- **Spec Coverage**: always present when `spec.md` exists and contains use cases or Gherkin scenarios. A table mapping each scenario to the component or operation that implements it. Gaps (scenarios not yet covered by the design) MUST be listed with "GAP" in the Notes column.
- **Key Technical Decisions**: always present when `plan.md` contains explicit design decisions. Each decision gets a subsection with: Context, Options considered, Decision, Consequences (positive and negative). Omit the entire section when plan.md has no explicit decisions.
- **Testing Strategy**: always present. Four labeled bullets: Unit, Integration, E2E / BDD, Observability. Derive from `spec.md` use cases for E2E targets. If a bullet has no content derivable from the source, write "Not specified in source."
- **Rollout and Migration**: always present. Three labeled fields: Strategy, Data migration, Rollback. Derive from `plan.md`. If a field has no content, write "Not specified in source."
- **Risks and Mitigations (optional)**: include only when `plan.md` or `spec.md` contains concrete risk signals. Pre-mortem lens: two to four entries. Each entry has: What could go wrong, Probability (Low/Medium/High), Impact (Low/Medium/High), Mitigation. No generic or speculative risks. Omit otherwise.
- **Open Questions (optional)**: include only when unresolved technical decisions remain in `plan.md` or `spec.md`. Each becomes one bullet as a single-sentence question. Never silently resolve. Omit otherwise.

#### Header metadata

- `Feature` field: the H1 title of `plan.md`. If no H1 is present, fall back to the H1 of `spec.md`. If neither has an H1, use the feature directory name with any leading numeric prefix and hyphens removed (e.g., `003-my-feature` becomes `My Feature`, capitalised as title case).
- `Created` field: today's date in `YYYY-MM-DD`.
- `Status` field: `Draft`.

### Step 7: Write the file atomically

Write to a temp file inside `${FEATURE_DIR}/product/`, then rename to `30-design.md`. This avoids leaving partial output if the process is interrupted. Create `${FEATURE_DIR}/product/` if it does not exist.

### Step 7b: Prepare product/checklist.md

If `${FEATURE_DIR}/product/checklist.md` does **not** exist:

- Read `templates/product-checklist-template.md`.
- Replace `[FEATURE NAME]` with the feature title and `[DATE]` with today's date.
- Write the file. All sections start with the "not yet generated" placeholder state.

If the file **already exists**, read its current content. You will replace only the `## Design` section (between the `## Design` heading and the next `---` horizontal rule). All other sections and `## Needs Review` are preserved verbatim.

If the `## Design` section does not exist in the current `checklist.md`, insert it between the `## Plan` section and the `## Needs Review` section (or at the end before `## Needs Review`).

### Step 7c: Auto-validate and iterate (Design section)

**Goal: all Design checklist items checked. Zero manual items if possible.**

After writing `product/30-design.md`, evaluate each item below against its content. For each failing item that is auto-fixable: rewrite the affected portion of **`product/30-design.md`** in memory, re-evaluate (max 2 extra passes per item). Then update `product/checklist.md` with the results.

| Checklist item                                         | Rule                                                                                                                                                                                                                | Auto-fixable?                                                         |
| ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| Summary present with ≥2 sentences                      | `## Summary` heading exists; ≥2 sentence paragraph before next `##`                                                                                                                                                 | Yes                                                                   |
| Technical Context has all required fields              | `## Technical Context` exists; Current state, Affected layers, Technical constraints fields present and non-placeholder                                                                                             | Yes - derive from source                                              |
| Architectural Approach present with ≥3 paragraphs      | `## Architectural Approach` heading exists; ≥3 non-empty paragraphs                                                                                                                                                 | Yes - expand from source                                              |
| Affected Modules table present with ≥2 rows            | `## Affected Modules` heading exists; markdown table with ≥2 data rows                                                                                                                                              | Yes - derive from source                                              |
| Data Design present when source has data model content | `## Data Design` exists when any source file contains entity/model information                                                                                                                                      | Yes - add from source                                                 |
| API Design present when source has API surface         | `## API Design` exists when source describes any API endpoints or operations                                                                                                                                        | Yes - add from source                                                 |
| Spec Coverage table present when spec.md has use cases | `## Spec Coverage` exists when spec.md has Gherkin scenarios or use cases                                                                                                                                           | Yes - derive from spec.md                                             |
| Spec Coverage has no unaddressed gaps                  | All rows in Spec Coverage table have a component assigned; "GAP" rows have an explanation                                                                                                                           | No - requires design decision                                         |
| Testing Strategy present with all four bullets         | `## Testing Strategy` heading exists; Unit, Integration, E2E / BDD, Observability bullets present                                                                                                                   | Yes - add missing bullets                                             |
| Rollout and Migration present with all three fields    | `## Rollout and Migration` heading exists; Strategy, Data migration, Rollback fields present                                                                                                                        | Yes - add missing fields                                              |
| Written entirely in English                            | Dominant language of prose is English                                                                                                                                                                               | No - source was validated in Step 2                                   |
| No em dash (`—`)                                       | Character `—` absent from entire file                                                                                                                                                                               | Yes - replace with comma, colon, or semicolon                         |
| No AI tells                                            | File does not contain: "delve", "tapestry", "in essence", "navigate the landscape", "seamless", "intuitive", "leverage" (standalone), "robust" (without measurable target), "it is worth noting" (case-insensitive) | Yes - rewrite sentence                                                |
| No runnable code                                       | File does not contain language-specific syntax blocks (fenced blocks tagged with a language identifier other than `text`)                                                                                           | Yes - change language tag to `text` or remove                         |
| Bullets are short (≤12 words each)                     | Every `-` line contains ≤12 words                                                                                                                                                                                   | Yes - split or shorten                                                |
| Key Decisions follow required format                   | Key Decisions section, if present: each entry has Context, Options considered, Decision, Consequences fields                                                                                                        | Yes - add missing fields from source                                  |
| Risks include probability and impact                   | Risks and Mitigations section, if present: each entry has What could go wrong, Probability (Low/Medium/High), Impact (Low/Medium/High), Mitigation                                                                  | Yes - add missing fields; default to Medium when source has no signal |
| Optional sections present only when source warrants    | Key Decisions, Risks and Mitigations, Open Questions present only when source has corresponding content                                                                                                             | Yes - remove sections with no source backing                          |
| Header has non-placeholder Feature and Created         | File has `Feature:` and `Created: YYYY-MM-DD` with real values                                                                                                                                                      | Yes - set from context                                                |

**Checklist structure for the `## Design` section**: replace the section content with:

```markdown
## Design (`product/30-design.md`)

**Validated**: [DATE] · [PASSED]/[TOTAL] items

- [x] ... (passing items)
- [ ] ... (failing items, if any — see ## Needs Review)
```

**`## Needs Review` section**: rebuild the `## Needs Review` section at the bottom by aggregating all `- [ ]` items from all sections. Each entry includes a one-sentence explanation. If no items remain unchecked, write:

```markdown
## Needs Review

> All items auto-validated. No manual review required.
```

### Step 8: Print a status report

```text
Wrote: <abs path>/product/30-design.md
Updated: <abs path>/product/checklist.md  §Design
Sections populated: Summary, Technical Context, Architectural Approach, Affected Modules[, Data Design][, API Design][, Spec Coverage][, Key Technical Decisions], Testing Strategy, Rollout and Migration[, Risks and Mitigations][, Open Questions]
Spec coverage gaps: <N>
Design checklist: <PASSED>/<TOTAL> auto-validated[, <REMAINING> need manual review]
```

The `[, <REMAINING> need manual review]` segment is omitted when all design items pass. Only list optional sections that were included. `<N>` is the count of spec coverage rows marked GAP. If none, `<N>` is `0`.

## Refusal Output Format

On any refusal, print exactly one line of the form:

```text
[product-design] <CODE>: <human readable remediation>
```

When `E_PLACEHOLDERS` lists multiple placeholders, print one line per placeholder after the `E_PLACEHOLDERS` header line.

## Error Codes

| Code           | Condition                                                              |
| -------------- | ---------------------------------------------------------------------- |
| E_NO_PLAN      | `plan.md` missing in the feature directory. Run `/speckit-plan` first. |
| E_NO_SPEC      | `spec.md` missing in the feature directory. Run `/speckit-spec` first. |
| E_PLACEHOLDERS | A source file still contains template placeholders.                    |
| E_LANGUAGE     | A source file is not in English.                                       |
| E_USER_ABORT   | User chose abort at the overwrite prompt.                              |

## Idempotence

Two consecutive runs against the same source files, with the user choosing overwrite on the second run, produce a `product/30-design.md` whose content is equivalent except for the `Created` field if the date has rolled over.
