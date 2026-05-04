# Quickstart: /speckit-product-info

This is the first-run guide for an end user who has just upgraded to a release of the `product` extension that includes `/speckit-product-info`.

## Prerequisites

- Spec Kit `>=0.2.0` initialized in the current project (`.specify/` directory exists).
- The `product` extension installed at the version that ships `/speckit-product-info` (see `extension.yml` `extension.version`).
- A feature directory under `specs/` with a populated `spec.md` (run `/speckit-specify` first if you do not have one).

## Install or upgrade the extension

```bash
specify extension add product --from <release-zip-url>
# or, if the catalog is already configured:
specify extension add product
# upgrade flow:
specify extension upgrade product
```

After the install completes, both `/speckit-product-spec` and `/speckit-product-info` are available in your AI assistant.

## Generate a product-info.md

From inside the project, with your AI assistant attached:

```text
/speckit-product-info
```

The command resolves the active feature directory from `.specify/feature.json`. To target a different feature, pass the override:

```text
/speckit-product-info --feature-dir specs/002-info-command
```

The command then:

1. Verifies that `spec.md` exists, is in English, and is free of unfilled Spec Kit template placeholders. If not, it refuses with a single line of the form `[product-info] <CODE>: <remediation>` and writes nothing.
2. Surfaces any `[NEEDS CLARIFICATION]` markers found in `spec.md` and asks whether to carry them into `product-info.md` as open questions.
3. Asks before overwriting an existing `product-info.md`.
4. Writes `<feature-dir>/product/product-info.md`.

## Read the result

The generated file lives at `<feature-dir>/product/product-info.md`. It is one rendered page or less. It contains four mandatory sections in this order:

1. **Headline** — one paragraph saying who this is for and what is changing.
2. **What is Changing** — two to five short bullets in customer-observable language.
3. **Why Now** — two to four short sentences explaining the trigger.
4. **Out of Scope** — a short list of what is deliberately excluded.

If the source spec had clarification markers and you accepted the prompt, an additional **Open Questions** section appears at the end.

## Share with stakeholders

`product-info.md` is designed to be shared as-is with non-technical stakeholders. It contains no frameworks, no APIs, no code, no file paths beyond the link to `../spec.md`, no em dash, no AI-tell filler, and no engineering jargon. Open it directly in your editor or paste it into a chat thread.

## Combine with /speckit-product-spec

`/speckit-product-info` and `/speckit-product-spec` are siblings. They both read the same `spec.md` and they both write into the same `product/` subfolder. You can run them in either order. Neither modifies the other's output. A common pattern is to run `/speckit-product-info` early to validate direction with stakeholders, then run `/speckit-product-spec` once direction is confirmed.

## Troubleshoot

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `[product-info] E_NO_PROJECT: ...` | You are running outside a Spec Kit project. | `cd` into a project that contains `.specify/`, or run `specify init` first. |
| `[product-info] E_NO_POINTER: ...` | No active feature is recorded and you did not pass `--feature-dir`. | Run `/speckit-specify` first, or pass `--feature-dir <path>`. |
| `[product-info] E_NO_SPEC: ...` | The resolved feature directory has no `spec.md`. | Run `/speckit-specify` to create one. |
| `[product-info] E_PLACEHOLDERS: ...` | `spec.md` still contains unfilled template scaffolding. | Open `spec.md` and replace the listed placeholders with real content. |
| `[product-info] E_LANGUAGE: ...` | `spec.md` is not written in English. | Translate `spec.md` to English first. The command does not auto-translate. |
| `[product-info] E_USER_ABORT: ...` | You answered "no" at a prompt (overwrite or surface clarifications). | Re-run when ready. |

## Verify the install

To confirm the release zip you installed contains the new command:

```bash
ls .specify/extensions/product/commands/
# expected:
# speckit.product.info.md
# speckit.product.spec.md
```

```bash
ls .specify/extensions/product/templates/
# expected:
# product-checklist-template.md
# product-info-template.md
# product-spec-template.md
```

If any of those files is missing, your installed extension is from before this feature shipped. Run the upgrade command above.
