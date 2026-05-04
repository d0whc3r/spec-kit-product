# Phase 0 Research: Product Info Command

This feature is a small extension of an already-shipped, validated extension. No NEEDS CLARIFICATION markers remain in the spec. The research below is therefore narrow: it confirms that the patterns inherited from `/speckit-product-spec` apply unchanged, and it pins the few decisions that are specific to `/speckit-product-info`.

## Decision 1: Reuse the existing extension layout, do not introduce a new one

- **Decision**: Add `commands/speckit.product.info.md`, `templates/product-info-template.md`, and a second `provides.commands` entry in `extension.yml`. Do not create a new extension, a new release pipeline, or a new top-level directory.
- **Rationale**: The user explicitly stated during clarification that this is an extension of the existing `product` extension. The existing layout already holds two templates (`product-spec-template.md`, `product-checklist-template.md`) and one command, so adding a second command and a third template fits the established shape. Inventing a parallel structure would fragment the extension and force users to install or update two artifacts to get one logical product.
- **Alternatives considered**:
  - *New top-level Spec Kit command (`/speckit-info`) outside the `product` extension*: rejected. The user explicitly tied the new command to the product extension. Decoupling it would make the install story harder and would split the writing-rule enforcement across two different code paths.
  - *New extension named `product-info`*: rejected. It would duplicate `extension.yml`, `README.md`, `LICENSE`, the release pipeline, and the catalog entry, while adding nothing the user asked for.

## Decision 2: Mirror the writing rules of `/speckit-product-spec` exactly

- **Decision**: Apply the same six writing rules (English only, no em dash, plain English, no AI tells, no implementation detail, bullets short and prose full sentences) to `product-info.md`. Encode them in the command body and reinforce them in `lint-content.sh`.
- **Rationale**: The user's plan input asked for "the same scheme that started with the product-spec in terms of text quality, writing rules, 100 percent human, no em dash". A second style would create drift across the extension. The existing linter already detects em dashes and out-of-order headings on `product-spec-template.md`; extending it to a second template is one block of code, not a new tool.
- **Alternatives considered**:
  - *Looser rules for the shorter document*: rejected. Short documents are read by more people, not fewer. Quality rules should be at least as strict.

## Decision 3: Fixed four-section pattern, plus optional Open questions

- **Decision**: Four mandatory sections in this order: Headline, What is Changing, Why Now, Out of Scope. One optional section: Open Questions, included only when `[NEEDS CLARIFICATION]` markers are surfaced.
- **Rationale**: The user asked for a simple pattern that describes the feature at the product level so that the spec and plan are easier to understand in context. The four sections cover the four questions a non-technical reader actually asks: who and what, what is different, why now, and what this is not. A fifth mandatory section would push the document past the one-page target in SC-002.
- **Alternatives considered**:
  - *Reuse the nine-section product-spec structure*: rejected. That document already exists for that purpose. A shorter sibling that copies its structure would either duplicate content or feel arbitrarily empty.
  - *Single free-form summary*: rejected. The whole point is repeatability. A non-trained writer needs the section labels to know what to put where.

## Decision 4: No paired quality checklist template in v1

- **Decision**: Do not add `product-info-checklist-template.md`. Enforce quality through the linter on the template and through the command body on the generated file.
- **Rationale**: The artifact is one page. The quality checks are short. Shipping a separate checklist would force the user to maintain two paired files (template plus checklist) for a one-page deliverable, which is more overhead than the artifact justifies.
- **Alternatives considered**:
  - *Ship a checklist that mirrors `product-checklist-template.md`*: rejected for v1, kept as a follow-up option. If reviewers report that linter-only enforcement misses real defects, the checklist can be added in a later minor release with no breaking change.

## Decision 5: No lifecycle hooks for the new command in v1

- **Decision**: Do not modify `.specify/extensions.yml`. The new command does not register `before_product_info` or `after_product_info` hooks.
- **Rationale**: `/speckit-product-spec` does not register hooks today either. Symmetry between the two commands matters. Users who want auto-commit hooks around either command can register them manually.
- **Alternatives considered**:
  - *Add `before_product_info` and `after_product_info` hooks invoking `speckit.git.commit`*: rejected for v1. This would create asymmetry with `/speckit-product-spec` without solving a reported user problem.

## Decision 6: Source of truth is `spec.md`, not `product-spec.md`

- **Decision**: `/speckit-product-info` reads `spec.md` directly, the same way `/speckit-product-spec` does. It does not read `product-spec.md`, even when that file exists.
- **Rationale**: `spec.md` is the canonical engineering artifact. `product-spec.md` is a derivative. Chaining info on top of spec on top of info would compound translation errors. Reading from the same source guarantees that running both commands against the same spec produces consistent stories.
- **Alternatives considered**:
  - *Read `product-spec.md` when present*: rejected. It would make the output non-deterministic with respect to whether `/speckit-product-spec` had run, and it would entangle the two commands' versioning.

## Decision 7: Command file and template paths follow the existing extension's flat layout

- **Decision**: Place the new files at `commands/speckit.product.info.md` and `templates/product-info-template.md` at the repository root. The build-zip already places these at the zip root via the existing allowlist.
- **Rationale**: The repository root IS the canonical extension source for the `product` extension (per the existing `validate-manifest.sh` REQUIRED list and `build-zip.sh` allowlist). There is no `extension/` subdirectory, despite an earlier draft of the 001 plan suggesting one; the actual shipped layout is flat. Adopting a different layout for the new files would break `validate-manifest.sh` and `build-zip.sh`.
- **Alternatives considered**:
  - *Place the new files under an `extension/` subtree*: rejected. The repo does not use that subtree today; the validator and build script would have to be rewritten.

## Resolved unknowns

None. Every NEEDS CLARIFICATION listed in earlier drafts has been removed. The Clarifications session in `spec.md` (2026-05-04) closed the only material open question (command name and packaging).
