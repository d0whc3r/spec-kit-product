---
description: "Generate a product oriented product-spec.md and quality checklist from the current feature's spec.md"
---

# Generate Product Spec

Derive a stakeholder facing `product-spec.md` from the populated `spec.md` of the active feature, and write a paired quality checklist. The artifact follows Amazon Working Backwards (PRFAQ), Jobs to Be Done (Ulwick), Gherkin BDD, and Lean PRD conventions, in plain English, with strict style rules.

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

- `<feature-dir>/product-spec.md`
- `<feature-dir>/checklists/product.md`

## Templates

The command MUST read the following templates from the installed extension and use them verbatim as the structural skeleton of the output. Do NOT invent additional sections. Do NOT reorder sections.

- Product spec template: `templates/product-spec-template.md` (relative to this command's extension root).
- Quality checklist template: `templates/product-checklist-template.md` (relative to this command's extension root).

When this extension is installed under `.specify/extensions/product/`, the absolute paths are:

- `.specify/extensions/product/templates/product-spec-template.md`
- `.specify/extensions/product/templates/product-checklist-template.md`

## Execution

### Step 1: Resolve the feature directory

Run the cross platform helper:

- **Bash**: `.specify/extensions/product/scripts/bash/resolve-feature-dir.sh [--feature-dir "<path>"]`
- **PowerShell**: `.specify/extensions/product/scripts/powershell/resolve-feature-dir.ps1 [-FeatureDir "<path>"]`

The script prints an absolute path on stdout, or exits non zero with one of `E_NO_PROJECT`, `E_NO_POINTER`, `E_BAD_POINTER`. Surface the script's stderr verbatim to the user and stop on any non zero exit code.

Capture the printed path as `FEATURE_DIR`.

### Step 2: Verify spec.md

Refuse to proceed when:

1. **E_NO_SPEC**: `${FEATURE_DIR}/spec.md` does not exist. Tell the user to run `/speckit-specify` first.
2. **E_PLACEHOLDERS**: `spec.md` still contains literal placeholders from the Spec Kit `spec-template.md`. Detect these by looking for any of the following exact bracketed strings as substrings of the file (case sensitive):
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
- Ask the user: `Surface these as open product questions in product-spec.md? (yes/no)`
- On `no` or any non affirmative response, abort with no files written.
- On `yes`, continue. Each marker MUST appear as a bullet under "Open product questions" in Section 9 of the generated `product-spec.md`. Never silently resolve a marker.

### Step 4: Handle existing product-spec.md

If `${FEATURE_DIR}/product-spec.md` already exists:

- Print the absolute path of the existing file.
- Ask: `product-spec.md already exists. Overwrite? (yes/no)`
- On `no` or any non affirmative response, abort with `E_USER_ABORT`. Do not write any files.
- On `yes`, continue. The existing `product-spec.md` will be replaced byte for byte. The companion `checklists/product.md` is also regenerated; prior tick state is not preserved.

### Step 5: Generate product-spec.md

Read `templates/product-spec-template.md`. Replace every bracketed placeholder with concrete content drawn from `spec.md`. Apply the following rules without exception.

#### Style rules (enforced)

1. **English only.** All output is in English.
2. **No em dash.** The character `—` MUST NOT appear in the output. Use commas, parentheses, colons, semicolons, or sentence breaks. Hyphens (`-`) are allowed.
3. **Plain English.** Active voice, short sentences, human tone. Avoid AI tells: do not use "delve", "tapestry", "in essence", "navigate the landscape", or similar filler.
4. **No implementation detail.** No frameworks, languages, APIs, data stores, code, or file paths. The single allowed file path is the link to `spec.md` in the metadata block.
5. **Bullets are short. Prose is full sentences.**

#### Section rules

- **Mandatory sections (1 through 9)**: always present, in canonical order, populated. If the source spec lacks information for a mandatory section, do NOT fabricate. Instead, populate the section with what is known, and add a precise open product question to Section 9.
- **Optional sections (10 Positioning, 11 Go to Market and Rollout)**: include ONLY when the source spec contains real content for them. Do not emit empty optional sections. Do not write `N/A`. Remove the entire section heading when not used.

#### Use Case rules (Section 7)

Each scenario MUST contain exactly three lines, in this order:

```text
**Given** [one full sentence beginning with "Given" describing the starting context].
**When** [one full sentence beginning with "When" describing the user action].
**Then** [one full sentence beginning with "Then" describing the observable outcome].
```

Each line is a single complete sentence ending with a period. Do not bullet sub conditions; if a scenario needs more, split it into two scenarios. Aim for fewer than ten scenarios across the document.

Map source spec User Stories and Acceptance Scenarios into Use Cases by translating the engineering language into customer observable behavior. Drop implementation specifics.

#### Job to Be Done (Section 3)

Write the primary job in the Ulwick form, exactly:

```text
When [situation], I want to [motivation], so I can [expected outcome].
```

Use an action verb. Do NOT name a solution (avoid "When I open the app", "I want to click the button"). Frame the situation, motivation, and outcome at the level the user experiences them.

#### Success Metrics (Section 8)

Provide exactly one north star metric and at least one supporting metric. Each metric must be measurable and technology agnostic. No system internals (no "p95 latency", no "queue depth"). Acceptable patterns: time to outcome, completion rate, satisfaction signal, retention, adoption.

#### Header metadata

- `Feature` field: the feature directory name (the segment after `specs/` in `FEATURE_DIR`).
- `Source Spec` field: the literal markdown link `[spec.md](./spec.md)`.
- `Created` field: today's date in `YYYY-MM-DD`.
- `Status` field: `Draft`.

### Step 6: Generate checklists/product.md

Read `templates/product-checklist-template.md`. Replace bracketed placeholders:

- `[FEATURE NAME]`: the feature title used in `product-spec.md` Section 1 heading.
- `[DATE]`: today's date in `YYYY-MM-DD`.

Leave every checkbox unchecked (`- [ ]`). The user or a reviewer ticks them after manual review.

If `${FEATURE_DIR}/checklists/` does not exist, create it.

### Step 7: Write files

Write `${FEATURE_DIR}/product-spec.md` and `${FEATURE_DIR}/checklists/product.md`. Both files are written atomically (write to a temp file in the same directory, then rename) to avoid leaving partial output if the process is interrupted.

Files outside the feature directory MUST NOT be modified. Specifically: do not touch `.specify/feature.json`, `.specify/extensions.yml`, `spec.md`, or any sibling feature.

### Step 8: Status report

Print a short status report to the user:

```text
Wrote: <abs path>/product-spec.md
Wrote: <abs path>/checklists/product.md
Sections populated: 9 mandatory[, 10 (Positioning)][, 11 (Go to Market)]
Open product questions surfaced: <N>
```

Replace bracketed parts with actual values. The optional section markers are listed only when those sections are present in the output. `<N>` is the number of `[NEEDS CLARIFICATION]` markers surfaced into Section 9.

## Refusal Output Format

On any refusal, print exactly one line of the form:

```text
[product] <CODE>: <human readable remediation>
```

Use the codes from `command-contract.md`: `E_NO_PROJECT`, `E_NO_POINTER`, `E_BAD_POINTER`, `E_NO_SPEC`, `E_PLACEHOLDERS`, `E_LANGUAGE`, `E_USER_ABORT`. When `E_PLACEHOLDERS` lists multiple placeholders, print one line per placeholder.

## Idempotence

Two consecutive runs against the same `spec.md`, with the user choosing overwrite on the second run, produce a `product-spec.md` whose content is byte identical except for the `Created` field if the date has rolled over.

The command never modifies `spec.md`.

## Error Codes

| Code | Condition |
|------|-----------|
| E_NO_PROJECT | No `.specify/` directory in any ancestor of the working directory. |
| E_NO_POINTER | `.specify/feature.json` missing and `--feature-dir` not provided. |
| E_BAD_POINTER | Feature directory in pointer does not exist. |
| E_NO_SPEC | `spec.md` missing in the feature directory. |
| E_PLACEHOLDERS | `spec.md` still contains template placeholders. |
| E_LANGUAGE | `spec.md` is not in English. |
| E_USER_ABORT | User chose abort at the overwrite prompt or declined to surface clarifications. |
