# Troubleshooting

Error codes the commands emit, with cause and fix.

This page uses the slash-command names, such as `/speckit.product.brief`. Skills agents, such as Claude Code, use hyphens instead: `/speckit-product-brief`.

## Installation errors

### "found in the 'community' catalog, which is discovery-only"

```text
Error: 'product' was found in the 'community' catalog, which is discovery-only
```

This is expected behavior. Spec Kit lists community extensions in a discovery-only catalog (`install_allowed: false`) and does not install from it. Spec Kit advises against setting that catalog to `install_allowed`.

Install the extension directly from the release archive. This is also how you pin a version:

```bash
specify extension add product --from \
  https://github.com/d0whc3r/spec-kit-product/releases/download/v1.0.2/product-1.0.2.zip
```

To update later, run the same command with a newer release URL and add `--force`.

Community extensions are author-maintained, and Spec Kit does not review them. Review the source before you install.

## Project resolution errors

These come from Spec Kit core's feature resolver and are surfaced verbatim
before the extension runs. They are not extension error codes; the message
you see is core's own.

- Not inside a Spec Kit project: `cd` into a project with `.specify/`, or
  run `specify init`.
- No active feature recorded and `--feature-dir` not passed: run
  `/speckit.specify` first, or pass `--feature-dir specs/<dir>`.

`.specify/feature.json` points to the active feature. If it is missing or
stale, run any Spec Kit core command on the feature (`/speckit.specify`,
`/speckit.plan`) to refresh it, or pass `--feature-dir` explicitly.

## Source file errors

| Code             | Cause                                                                       | Fix                                                                      |
| ---------------- | --------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| `E_NO_SPEC`      | Feature directory has no `spec.md`.                                         | Run `/speckit.specify` to create one.                                    |
| `E_NO_PLAN`      | Feature directory has no `plan.md`.                                         | Run `/speckit.plan` to generate it.                                      |
| `E_PLACEHOLDERS` | Source file still contains unfilled template markers like `[FEATURE NAME]`. | Open the file and replace every bracketed placeholder with real content. |
| `E_LANGUAGE`     | Source file is not in English.                                              | Translate the source file. The command does not auto-translate.          |

The placeholder check is strict on purpose. A spec with unfilled placeholders
will produce garbage downstream, so the command refuses early.

## User interaction errors

| Code           | Cause                                                 | Fix               |
| -------------- | ----------------------------------------------------- | ----------------- |
| `E_USER_ABORT` | You answered "no" at the overwrite or clarify prompt. | Rerun when ready. |

## The slash command does not appear in my assistant

1. Confirm the extension is registered:
   ```bash
   cat .specify/extensions/.registry
   ```
   You should see a `product` entry.
2. Confirm extension files are present:
   ```bash
   ls .specify/extensions/product
   ```
   You should see `extension.yml`, `commands/`, `templates/`.
3. Restart the host agent. Some agents cache the slash command surface at
   startup. Open a new chat or reload the agent's window.
4. If it still does not appear, try a fresh install:
   ```bash
   specify extension update product
   ```

## Output does not match the style rules

Walk the relevant section of `product/checklist.md`. Any failed Required
item is the regenerate signal. Common causes:

- Em dashes in the source `spec.md`. The generator copies content; if the
  source has an em dash, the output can carry it. Remove em dashes from the
  source first.
- The source contains framework or language names that bled into the
  product-facing artifact. Edit the source to push those into `plan.md` (the
  engineering plan) and out of `spec.md` (the product spec).
- Optional sections appeared as empty stubs. Remove them, or regenerate.

## "detected non English content"

v1 of the extension is English only. The command refuses to operate on a
non-English source file. To proceed, translate the source file to English
and rerun. There is no auto-translate.

This is enforced because the voice rules (PRFAQ, Ulwick, Gherkin, no em dash,
no AI tell filler) are pinned to English in the templates.

## "output file already exists"

Choose **overwrite** to regenerate. Choose **abort** to keep the existing
file untouched. The product artifacts are derived views; overwriting is the
intended flow when the source changes.

If you want to keep both, copy the current output elsewhere before
overwriting.

## "spec.md still contains template placeholders"

Open `spec.md` and find every bracketed token like `[FEATURE NAME]`,
`[PLACEHOLDER]`, `[NEEDS CLARIFICATION]`. Replace each with real content.
`[NEEDS CLARIFICATION]` is special: leave it in place if the team has not
yet answered the question. The command will surface it as an open product
question, not refuse.

## Filing a bug

When the commands refuse with a code you cannot resolve, file a bug with:

- Extension version: `grep version extension.yml` or
  `cat .specify/extensions/product/extension.yml | grep version`.
- Spec Kit core version: `specify --version`.
- Host agent name and version.
- The exact command invocation.
- The minimal `spec.md` / `plan.md` that reproduces it.
- The exact error string the command emitted.

Use the bug template: <https://github.com/d0whc3r/spec-kit-product/issues/new?template=bug_report.yml>.

For security issues, use private vulnerability reporting instead. See
[SECURITY.md](../SECURITY.md).
