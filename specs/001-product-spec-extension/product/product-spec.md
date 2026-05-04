# Product Spec: Product Spec Extension for Spec Kit

**Feature**: 001-product-spec-extension
**Source Spec**: [spec.md](../spec.md)
**Created**: 2026-05-04
**Status**: Draft

## 1. Headline

> Spec Kit now writes the product side of the spec for you.

Product managers and founders working alongside Spec Kit teams can finally produce a stakeholder facing product specification in one command, without retyping the engineering spec into a different document. The extension reads the existing `spec.md`, generates a `product-spec.md` shaped around customer value (headline, Job to Be Done, scope, success metrics), and pairs it with a quality checklist that catches drift in voice, structure, and detail. One command, one minute, one source of truth.

## 2. Target Users and Personas

- **Product manager on a Spec Kit team**: owns the why and the what, needs a stakeholder facing artifact that mirrors the technical spec without having to maintain it by hand.
- **Founder or solo builder**: writes specs themselves, wants a press release style summary they can show to design partners and early customers.
- **Engineering manager**: wants product and engineering to stop diverging, and wants the product side to come from the same canonical input the team already maintains.
- **Spec Kit extension author**: wants a worked example of the publishing flow (manifest, release pipeline, catalog entry) that they can pattern match against.

## 3. Problem Statement (Job to Be Done)

> When I have a finished technical `spec.md` and a non engineering audience that needs to understand the same feature in product terms, I want to generate a stakeholder facing product spec from that single source, so I can keep one canonical input and avoid maintaining a parallel document by hand.

**Why this matters now**: Spec Kit has become the default way many teams write feature specs, but the output is engineering shaped. Teams either ignore Spec Kit at the product layer, or they hand author a parallel document that drifts within a sprint. The extension gap closes by adding a derived view, not a competing source of truth.

## 4. Value Proposition

The product spec is generated from the technical spec in a single command, in under two minutes, with structure and voice that match an opinionated template (Working Backwards headline, Ulwick Job to Be Done, Gherkin scenarios, Lean PRD compactness). The status quo today is either no product spec at all, or a hand maintained doc that goes stale within days. The change is small but meaningful: one source, two views, zero drift between them at the moment of generation, with a quality checklist that flags any leak of implementation detail before the artifact is shared.

## 5. Scope

- One slash command, `/speckit-product-spec`, that derives `product-spec.md` from the active feature's `spec.md`.
- A canonical product spec template covering nine mandatory sections plus two optional sections (Positioning, Go to Market and Rollout).
- A canonical quality checklist written to `checklists/product.md` covering structure, style, and content.
- Cross platform install via `specify extension add product` (catalog), `specify extension add product --from <zip-url>` (direct), and `specify extension add --dev <path>` (developer).
- A GitHub Actions release pipeline that validates the manifest, lints content, builds a deterministic release zip, publishes a GitHub Release, and updates `catalog.json`.
- Refusal modes for missing pointer, missing spec, unfilled template placeholders, non English source spec, and an existing `product-spec.md` (overwrite or abort).

## 6. Out of Scope

- Refresh and section level diff or merge. Re-running the command is overwrite or abort only in v1.
- Automatic lifecycle hooks. The command is user invoked only, to avoid surprising overwrites.
- Multi language output. v1 is English only; non English source specs are refused with no auto translation.
- Extra commands beyond `speckit.product.spec` in v1. The `product.<verb>` namespace is reserved for future commands such as a refresh.
- Pulling content from issue trackers, design tools, or external systems. The only input is `spec.md`.
- Cross platform binary signing, multi channel releases (beta, nightly), and external registries (npm, PyPI). v1 ships only stable tagged zips.

## 7. Use Cases

### Use Case 1: First product spec from a finished technical spec

**Given** a feature directory with a populated `spec.md` and no `product-spec.md` yet.
**When** the user runs `/speckit-product-spec`.
**Then** the user receives a `product-spec.md` populated from the source spec, a `checklists/product.md` with all boxes unchecked, and a status report listing both file paths.

### Use Case 2: Source spec has open clarifications

**Given** a `spec.md` containing one or more `[NEEDS CLARIFICATION]` markers.
**When** the user runs `/speckit-product-spec` and confirms the warning prompt.
**Then** every marker appears as an open product question under Section 9 of the generated `product-spec.md`, never silently resolved.

### Use Case 3: Regenerate after the technical spec changed

**Given** a feature directory with both a populated `spec.md` and a previously generated `product-spec.md`.
**When** the user runs `/speckit-product-spec` and chooses overwrite at the prompt.
**Then** the existing `product-spec.md` and `checklists/product.md` are replaced with regenerated versions reflecting the current `spec.md`.

### Use Case 4: Install in a separate Spec Kit project

**Given** a separate Spec Kit project that does not have the extension installed.
**When** the user runs `specify extension add product` and opens the project in their AI assistant.
**Then** the slash command `/speckit-product-spec` is discoverable and can be invoked against any feature in that project.

### Use Case 5: Tagged release ships a validated zip

**Given** a maintainer pushes a git tag `v0.1.0` to the extension repository.
**When** the release pipeline runs.
**Then** a deterministic `product-0.1.0.zip` is attached to a GitHub Release at `v0.1.0` and the catalog entry is updated to point at the new asset within five minutes.

## 8. Success Metrics

**North star**:

- **Time to first product spec**: median wall clock time from typing `/speckit-product-spec` to receiving a reviewable `product-spec.md`. Target: under two minutes.

**Supporting metrics**:

- **First pass quality**: share of generated product specs that pass every Required item on the shipped quality checklist on first generation, when the source spec is itself complete. Target: 100 percent.
- **Implementation leak rate**: share of generated product specs that contain any implementation detail (frameworks, languages, APIs, data stores, code, file paths beyond the cross link). Target: 0 percent, measured on a rolling sample of ten specs.
- **Install success**: share of installs from a clean Spec Kit project that complete in under three minutes via the documented `specify extension add` command. Target: 100 percent.
- **Release validation rate**: share of attempted releases that pass the pipeline's manifest validation before publishing. Target: 100 percent over a rolling six month window.

## 9. Risks and Open Product Questions

**Risks**:

- The Spec Kit extension contract or `specify extension add` CLI changes shape between minor versions, breaking install. Mitigation: pin `requires.speckit_version` and document the minimum tested version.
- The opinionated template feels too generic for some domains (deep B2B, regulated industries). Mitigation: ship optional sections, gather signal from early adopters, and revise in a minor version rather than at v1.
- The release pipeline silently publishes a malformed zip if a validator is bypassed. Mitigation: validators are sequential gates, fail closed, and the zip is re validated after build before publish.
- Users skip the quality checklist and ship a product spec with implementation leakage. Mitigation: the checklist file is generated on every run, all boxes unchecked, and the command's status report calls it out.

**Open product questions**:

- Should the extension support a future `speckit.product.refresh` command that does section level diff and merge, or is overwrite or abort sufficient long term?
- When the source spec is non English, is a future opt in translation flag desirable, or should the English only constraint stay permanent?
- Should the catalog entry track download counts or other adoption signal, or is GitHub Release stats enough for v1?
