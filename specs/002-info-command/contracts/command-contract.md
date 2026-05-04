# Command Contract: /speckit-product-info

This contract pins the externally observable behavior of the new command. Any change to a section here is a breaking change to the extension's public surface and requires a major version bump.

## Identity

- **Slash command name**: `/speckit-product-info`
- **Manifest entry**: `provides.commands[].name == "speckit.product.info"`
- **Command file path** (in source and in zip): `commands/speckit.product.info.md`
- **Extension**: `product` (existing, no new extension)

## Inputs

The command reads, but does not modify:

- `.specify/feature.json` to locate the active feature directory, OR `--feature-dir <path>` if the user passes the override flag.
- `<feature-dir>/spec.md` as the source spec.

The command does not read `<feature-dir>/product/product-spec.md`, `plan.md`, `tasks.md`, or any sibling feature.

## Outputs

The command writes:

- `<feature-dir>/product/product-info.md`

The command creates `<feature-dir>/product/` if it does not already exist.

The command never modifies `spec.md`, `plan.md`, `tasks.md`, `product-spec.md`, `checklist.md`, `.specify/feature.json`, `.specify/extensions.yml`, or any file outside the resolved feature directory.

## Templates

The command reads the following template verbatim from the installed extension and uses it as the structural skeleton of the output. The command MUST NOT invent additional sections or reorder existing ones.

- `templates/product-info-template.md` (relative to the extension root).

When this extension is installed under `.specify/extensions/product/`, the absolute path is `.specify/extensions/product/templates/product-info-template.md`.

## Execution flow

1. **Resolve the feature directory** by invoking the existing helper:
   - Bash: `.specify/extensions/product/scripts/bash/resolve-feature-dir.sh [--feature-dir "<path>"]`
   - PowerShell: `.specify/extensions/product/scripts/powershell/resolve-feature-dir.ps1 [-FeatureDir "<path>"]`
   The command captures the printed absolute path as `FEATURE_DIR` and surfaces stderr verbatim on any non-zero exit.

2. **Verify `spec.md`**, refusing on:
   - `E_NO_SPEC` if `${FEATURE_DIR}/spec.md` does not exist.
   - `E_PLACEHOLDERS` if `spec.md` still contains literal Spec Kit template placeholders (same detection list as `/speckit-product-spec`). One refusal line per detected placeholder. `[NEEDS CLARIFICATION]` markers do NOT count as placeholders.
   - `E_LANGUAGE` if `spec.md` is not in English.

3. **Surface `[NEEDS CLARIFICATION]` markers**: list each marker, ask the user `Surface these as open questions in product-info.md? (yes/no)`. On a non-affirmative answer, abort with `E_USER_ABORT`. On `yes`, each marker becomes a bullet under Section 5 (Open Questions) of the generated `product-info.md`.

4. **Handle existing `product-info.md`**: if `${FEATURE_DIR}/product/product-info.md` already exists, print its absolute path and ask `product-info.md already exists. Overwrite? (yes/no)`. On a non-affirmative answer, abort with `E_USER_ABORT` and write nothing. On `yes`, the file is replaced byte for byte.

5. **Generate `product-info.md`** by reading `templates/product-info-template.md` and substituting bracketed placeholders. Apply every writing rule from the Writing rules section of `plan.md`.

6. **Write the file atomically**: write to a temp file inside the destination directory, then rename. The companion `product/` subfolder is created if missing.

7. **Print a status report**:

   ```text
   Wrote: <abs path>/product/product-info.md
   Sections populated: 4 mandatory[, 5 (Open Questions)]
   Open product questions surfaced: <N>
   ```

   The `5 (Open Questions)` segment appears only when Section 5 is present in the output. `<N>` is the count of `[NEEDS CLARIFICATION]` markers surfaced.

## Refusal output format

On any refusal, print exactly one line of the form:

```text
[product-info] <CODE>: <human readable remediation>
```

When `E_PLACEHOLDERS` lists multiple placeholders, print one line per placeholder.

## Error codes

| Code | Condition |
|------|-----------|
| E_NO_PROJECT | No `.specify/` directory in any ancestor of the working directory. |
| E_NO_POINTER | `.specify/feature.json` missing and `--feature-dir` not provided. |
| E_BAD_POINTER | Feature directory in the pointer does not exist. |
| E_NO_SPEC | `spec.md` missing in the feature directory. |
| E_PLACEHOLDERS | `spec.md` still contains template placeholders. |
| E_LANGUAGE | `spec.md` is not in English. |
| E_USER_ABORT | User chose abort at the overwrite prompt or declined to surface clarifications. |

The codes mirror those of `/speckit-product-spec`. Users get one consistent vocabulary across the extension.

## Idempotence

Two consecutive runs against the same `spec.md`, with the user choosing overwrite on the second run, produce a `product-info.md` whose content is byte-identical except for the `Created` field if the date has rolled over.

The command never modifies `spec.md`.

## Style guarantees on the output

The generated `product-info.md` always satisfies the following invariants:

- It is written entirely in English.
- It contains zero em dash characters (`—`).
- It contains zero banned AI-tell phrases (see Writing rules in `plan.md`).
- It contains no implementation detail (no frameworks, languages, APIs, data stores, code, or file paths) other than the `[spec.md](../spec.md)` link in the metadata block.
- It contains all four mandatory sections in canonical order: Headline, What is Changing, Why Now, Out of Scope.
- It contains the optional Section 5 (Open Questions) if and only if at least one `[NEEDS CLARIFICATION]` marker was surfaced.
