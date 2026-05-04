# Command Contract: /speckit.product.plan

This contract pins the externally observable behavior of the command. Any change to a section here is a breaking change to the extension's public surface and requires a major version bump in `extension.yml`.

## Identity

- **Slash command name**: `/speckit.product.plan`
- **Manifest entry**: `provides.commands[].name == "speckit.product.plan"`
- **Command file path** (in source and in zip): `commands/speckit.product.plan.md`
- **Extension**: `product` (existing, no new extension)

## Inputs

The command reads, but does not modify:

- `.specify/feature.json` to locate the active feature directory, OR `--feature-dir <path>` if the user passes the override flag.
- `<feature-dir>/plan.md` as the primary source.
- `<feature-dir>/spec.md` as optional supplementary context when present.
- `templates/product-plan-template.md` as the structural skeleton for the output.

The command does not read `<feature-dir>/product/spec.md`, `<feature-dir>/product/info.md`, `tasks.md`, `research.md`, `data-model.md`, or any sibling feature.

## Outputs

The command writes:

- `<feature-dir>/product/plan.md`

The command creates `<feature-dir>/product/` if it does not already exist.

The command never modifies `plan.md`, `spec.md`, `tasks.md`, `product/spec.md`, `product/info.md`, `checklist.md`, `.specify/feature.json`, `.specify/extensions.yml`, or any file outside the resolved feature directory.

## Templates

The command reads the following template verbatim from the installed extension and uses it as the structural skeleton of the output. The command MUST NOT invent additional sections or reorder existing ones.

- `templates/product-plan-template.md` (relative to the extension root)

When this extension is installed under `.specify/extensions/product/`, the absolute path is `.specify/extensions/product/templates/product-plan-template.md`.

## Execution flow

1. **Resolve the feature directory** by invoking the existing helper:
   - Bash: `.specify/extensions/product/scripts/bash/resolve-feature-dir.sh [--feature-dir "<path>"]`
   - PowerShell: `.specify/extensions/product/scripts/powershell/resolve-feature-dir.ps1 [-FeatureDir "<path>"]`
   The command captures the printed absolute path as `FEATURE_DIR` and surfaces stderr verbatim on any non-zero exit.

2. **Verify `plan.md`**, refusing on:
   - `E_NO_PLAN` if `${FEATURE_DIR}/plan.md` does not exist. Instructs the user to run `/speckit.plan` first.
   - `E_PLACEHOLDERS` if `plan.md` contains any of the following literal placeholder strings (case-sensitive): `[FEATURE]`, `[DATE]`, `[###-feature-name]`, `[link]`, `[Extract from feature spec: primary requirement + technical approach from research]`. Lists each detected placeholder, one per line.
   - `E_LANGUAGE` if `plan.md` is not written in English. Names the detected language.

3. **Load optional context**: If `${FEATURE_DIR}/spec.md` exists, read it silently for supplementary context (personas, problem framing, Why Now). If absent, proceed without warning.

4. **Check for sparse plan**: If `plan.md` contains no identifiable phases, decisions, or component information, emit a non-blocking console notice:
   ```
   [product-plan] NOTICE: plan.md appears sparse. Output coverage may be limited.
   ```
   Continue with generation. Do not abort.

5. **Handle existing `product/plan.md`**: If `${FEATURE_DIR}/product/plan.md` already exists:
   - Print the absolute path of the existing file.
   - Ask: `product/plan.md already exists. Overwrite? (yes/no)`
   - On `no` or any non-affirmative response, abort with `E_USER_ABORT`. Write nothing.
   - On `yes`, continue.
   If `${FEATURE_DIR}/product/` does not exist, create it before writing.

6. **Generate `product/plan.md`**: Read `templates/product-plan-template.md`. Populate all sections from `plan.md` (and `spec.md` when available). Apply all writing rules (see below). Omit optional sections entirely when the source has no relevant content.

7. **Write atomically**: Write to a temp file inside `${FEATURE_DIR}/product/`, then rename to `plan.md`. Create `${FEATURE_DIR}/product/` if it does not exist.

8. **Print a status report**:
   ```
   Wrote: <abs path>/product/plan.md
   Sections populated: <mandatory list>[, <optional sections present>]
   Open questions surfaced: <N>
   ```
   The optional sections list names only the sections that were included. `<N>` is the count of open questions or marked assumptions surfaced. If none were present, `<N>` is `0`.

## Writing rules (enforced)

1. **English only.** All output in English.
2. **No em dash.** The character `—` must not appear. Use commas, parentheses, colons, semicolons, or sentence breaks. Hyphens are allowed.
3. **Plain English.** Active voice, short sentences, human tone.
4. **No AI-tell phrases.** Banned: "delve", "tapestry", "in essence", "navigate the landscape", "leverage" (standalone verb without a concrete object), "robust" (without a measurable target), "seamless", "intuitive". List inherited verbatim from sibling commands.
5. **No implementation detail.** No code, no framework names, no library names, no file paths. The only allowed file path is `[plan.md](../plan.md)` in the metadata block.
6. **Technical terms glossed on first use.** Terms from the following list must carry a plain-language gloss in parentheses on the same line as their first occurrence: "API", "CLI", "SDK", "refactor", "idempotent", "atomic", "schema", "linter", "manifest", "hook", "pipeline". Subsequent occurrences require no gloss.
7. **Bullets are short. Prose is full sentences.**
8. **No invented content.** The command must not invent phases, decisions, or components not present in the source `plan.md`.

## Refusal output format

On any refusal, print exactly one line of the form:

```
[product-plan] <CODE>: <human-readable remediation>
```

Error codes:

| Code | Trigger | Remediation message |
|---|---|---|
| `E_NO_PROJECT` | No `.specify/` ancestor found | Run this command from inside a Spec Kit project. |
| `E_NO_PLAN` | `plan.md` does not exist | Run `/speckit.plan` to generate the engineering plan first. |
| `E_PLACEHOLDERS` | `plan.md` contains unfilled template placeholders | Fill in or regenerate `plan.md` before running this command. |
| `E_LANGUAGE` | `plan.md` is not in English | This command requires an English-language `plan.md` (detected: <language>). |
| `E_USER_ABORT` | User answered `no` to overwrite prompt | Aborted. Existing `product/plan.md` was not modified. |

## Idempotence

Running the command twice in a row on an unchanged `plan.md` and `spec.md` produces the same `product/plan.md` (modulo the Created date in the metadata block). The command never modifies its input files.

## Version

This contract is introduced in extension version `0.3.0`. Prior versions do not provide this command.
