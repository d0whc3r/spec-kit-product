# Frequently Asked Questions

## Why does `specify extension add product` fail with a catalog error?

If you see `'product' is available in the 'community' catalog but installation
is not allowed from that catalog`, that is expected. Spec Kit ships the
community catalog as discovery only (`install_allowed: false`), so it can list
the extension but will not install it until you opt in.

The quickest fix is a direct install:

```bash
specify extension add product --from \
  https://github.com/d0whc3r/spec-kit-product/releases/download/v0.9.0/product-0.9.0.zip
```

To install and update by name instead, approve the community catalog once. See
[Troubleshooting](Troubleshooting.md#installation-errors) for both paths in
full.

## Why does this extension exist when Spec Kit already produces `spec.md`?

`spec.md` is written for engineers. Product managers, leadership, designers,
and cross-functional reviewers need the same information in a different
shape: a press-release headline, a Job to Be Done, scope and out of scope,
Gherkin scenarios, delivery phases, ADRs in plain language.

Rewriting that by hand for every feature is busywork and drifts from the
canonical `spec.md`. This extension generates four audience-specific
artifacts from the existing engineering spec, each with an auto-validated
quality checklist.

## Do I have to run all four commands?

No. Stop at the level of detail your audience needs.

- A small change that only needs stakeholder buy-in: just `/speckit.product.info`.
- A full feature definition: `info` plus `spec`.
- A feature in active build: add `plan` and `design`.

Each command stands alone. The four outputs do not depend on each other,
only on the canonical `spec.md` and `plan.md`.

## Will the extension modify my `spec.md` or `plan.md`?

No. The source files are read-only to this extension. Every artifact lives
under `product/` in the same feature directory. This is enforced both by
the command body and by the constitution.

## What happens to `[NEEDS CLARIFICATION]` markers in `spec.md`?

They are surfaced in the generated output as open product questions,
never silently resolved. The relevant artifact gets a "Key Decisions" or
"Risks and Open Product Questions" section that lists them.

## Can I keep two outputs side by side, like a v1 and a v2?

The default behavior overwrites `product/10-spec.md` and the others. To keep
the previous version, rename or copy it before regenerating. The shared
`checklist.md` is sectioned by command, so other sections survive.

## Why is the em dash banned?

It is the single strongest "AI tell" in modern LLM output. Banning it
makes the generated text harder to dismiss as AI slop. The checklist lets
you verify the rule held after generation.

## Does the extension run by itself?

No. The commands are markdown prompts: they need a Spec Kit-aware assistant
to resolve and execute them. The release zip itself is portable and has no
runtime of its own.

## My team writes specs in Spanish. Can the extension help?

Not in v1. The commands refuse non-English sources because the templates
and voice rules are pinned to English. Translate the source file first.

The extension's design does not preclude future localized templates. See
the open discussion on the repo if you want to advocate for this.

## Does this work in a brownfield codebase?

Yes. The product commands operate on a `spec.md`, so they work the same way
whether the spec describes a greenfield feature or an existing system. Produce
the `spec.md` however you like (for example with `/speckit.specify`), then run
the product commands against it.

## Is there a Python or Node API to run these programmatically?

No. The commands run inside a Spec Kit-aware assistant. If you need
scriptable generation, the underlying templates at
`templates/product-*-template.md` are plain markdown and can be filled by
any process you build.

## Why is the technical design separate from the product plan?

They have different audiences and different constraints. `product/20-plan.md`
is read by PMs and leadership; no code, no file paths, no ORM. `product/30-design.md`
is read by tech leads and senior developers; component names, module
boundaries, API shapes are appropriate.

Mixing them produces a document that is too technical for PMs and too
hand-wavy for engineers.

## How do I update the extension?

If you installed directly with `--from`, rerun the same command with a newer
release URL:

```bash
specify extension add product --from \
  https://github.com/d0whc3r/spec-kit-product/releases/download/v0.9.0/product-0.9.0.zip
```

If you approved the community catalog, you can update by name:

```bash
specify extension update product
```

Either way, your generated `product/*.md` files are not touched; they are in
your feature directories, not the extension directory.

## Where do I report a bug or request a feature?

| You want to                                | Use                                                                                                          |
| ------------------------------------------ | ------------------------------------------------------------------------------------------------------------ |
| Report a bug in this extension             | [Bug report issue](https://github.com/d0whc3r/spec-kit-product/issues/new?template=bug_report.yml)           |
| Request a feature                          | [Feature request issue](https://github.com/d0whc3r/spec-kit-product/issues/new?template=feature_request.yml) |
| Propose a new `/speckit.product.*` command | [New command issue](https://github.com/d0whc3r/spec-kit-product/issues/new?template=new_command.yml)         |
| Doc problem                                | [Docs issue](https://github.com/d0whc3r/spec-kit-product/issues/new?template=docs.yml)                       |
| Usage question or tip                      | [Discussions](https://github.com/d0whc3r/spec-kit-product/discussions)                                       |
| Security vulnerability                     | [Private security advisory](https://github.com/d0whc3r/spec-kit-product/security/advisories/new)             |
| Report an issue in Spec Kit core           | [github/spec-kit](https://github.com/github/spec-kit/issues)                                                 |
