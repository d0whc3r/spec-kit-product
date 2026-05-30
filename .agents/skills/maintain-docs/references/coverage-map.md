# Coverage Map

For each user-facing page, the canonical sources it documents and the
specific facts it asserts. Use this in Phase 2 of `maintain-docs` to
figure out which sources to re-check when a page is suspected of drift.

The reverse direction (canonical file → which pages depend on it) is at
the bottom.

Only user-facing pages appear here. Contributor and tooling docs
(`CONTRIBUTING.md`, `AGENTS.md`/`CLAUDE.md`) are out of this skill's
scope and are intentionally absent.

## Wiki pages

### `docs/Home.md`

Documents: the extension purpose, the four commands at a glance, the
reading order, the source-of-truth contract.

Asserts:

- Extension purpose paragraph (matches `README.md` lead and
  `extension.yml.extension.description`).
- The four-row command table (must be byte-equivalent to the same table
  in `README.md` and `docs/Commands.md`).
- The links to every other wiki page.

Re-check whenever: a command is added or removed; the description in
`extension.yml` changes; a wiki page is added or removed.

### `docs/Getting-Started.md`

Documents: install, first run, basic usage.

Asserts:

- Spec Kit version requirement (must match `extension.yml.requires.speckit_version`).
- Install URL with pinned version (must match
  `extension.yml.extension.version` and `catalog.json.version`).
- The order of the four commands and what each writes.
- The example output file paths.

Scope rule: this page covers the user install paths (catalog install and
pinned-version install). It does not cover the dev install
(`specify extension add --dev`); that is a contributor step and lives in
`CONTRIBUTING.md`.

Re-check whenever: version bumps; install paths change;
`/speckit.product.*` reads/writes change.

### `docs/Commands.md`

Documents: every command in full.

Asserts:

- One section per command in `commands/`.
- Each section's "Reads" and "Writes" must match the command file body.
- Output sections list must match the corresponding template under
  `templates/`.
- Error codes table must include every `E_*` code referenced in the
  command body.
- The hooks table at the bottom must match `extension.yml.hooks`.

Re-check whenever: any file under `commands/` or `templates/` changes;
hooks are added, removed, or renamed.

### `docs/Workflow.md`

Documents: the input/output flow and recommended command order.

Asserts:

- The recommended order (info → spec → plan → design).
- The `product/` folder layout with the numeric prefixes.
- The hook trigger points.

Re-check whenever: a new command lands; the artifact naming scheme
changes.

### `docs/Examples.md`

Documents: a sample `spec.md` and the four artifacts derived from it.

Asserts:

- Filenames of derived artifacts match the templates.
- Section structure of each example matches the current template.

Re-check whenever: `templates/*.md` changes shape. The example bodies are
illustrative and do not need byte-exact match, but section names,
ordering, and presence of required sections must match the current
template.

### `docs/Style-Guide.md`

Documents: the voice rules every generated artifact follows, written so a
user understands why the output reads the way it does.

Asserts:

- No em dash rule.
- Plain English, short sentences.
- PRFAQ / JTBD / Gherkin / Lean PRD conventions.
- `[NEEDS CLARIFICATION]` markers preserved.

Scope rule: describe the rules and why they exist. Do not describe how
the rules are enforced in the repo (the lint script, the release
pipeline, the "change these files together" coupling). That coupling is a
contributor concern and lives in `CONTRIBUTING.md`.

Re-check whenever: `.specify/memory/constitution.md` §III changes in a way
that changes the user-visible output style.

### `docs/Diagrams.md`

Documents: how `/speckit.product.plan` and `/speckit.product.design`
generate Mermaid diagrams and the design Non-Functional Requirements
table, and the value gate that decides when each one renders or is
omitted.

Asserts:

- The per-section diagram table for both commands (must match each
  command's `#### Diagram generation` block and the template `>`
  instruction lines).
- The value gate: a diagram or optional section earns its place; omit when
  it restates the prose, duplicates another view, or is a trivial shape.
- The conditional gates: Delivery Phases flowchart only when phases branch;
  risk quadrant omitted when all risks share one cell; the NFR table holds
  measurable targets while Technical Constraints holds non-measurable
  rules; plan risks are product-level, design risks technical.
- That the Architectural Approach flowchart is the one diagram that always
  renders.

Re-check whenever: a command's `#### Diagram generation` block changes; a
diagram type is added or removed; the value-gate wording changes; the NFR
or Technical Constraints rules change.

### `docs/Troubleshooting.md`

Documents: error codes, refusals, common breakages.

Asserts:

- One row per `E_*` error code defined in any `commands/*.md`.
- Each refusal scenario the command prompts can produce.

Re-check whenever: a command file adds or renames an error code.

### `docs/FAQ.md`

Documents: conceptual questions and design rationale, from the user's
point of view.

Asserts: rationale that may reference the output style or the
source-of-truth contract. Drift here is rare; most edits are additive.

Re-check whenever: a frequently asked question surfaces in issues that is
not yet covered; the output behavior the FAQ describes changes.

### `docs/Architecture.md`

Documents: how the extension works at runtime, for a user who wants to
understand what happens when they run a command.

Scope rule: this page is "how it works", not "how it ships". It covers
what the extension is (text, no runtime), how a command resolves and what
it reads and writes, the source-of-truth contract, and the hook events.
It does **not** cover the repo source tree, the release pipeline,
`semantic-release`, CI, or constitution governance. Those are contributor
concerns in `CONTRIBUTING.md`. It also does not enumerate per-agent mirror
surfaces or name specific assistants; refer generically to "the host
agent" when needed.

Asserts:

- The runtime invocation flow (command → prompt → template → output
  path) matches the actual command and template files.
- The hooks table (must match `extension.yml.hooks`).
- The source-of-truth contract matches the behavior the commands enforce.

Re-check whenever: a command's read/write behavior changes; a hook is
added or removed; the source-of-truth contract changes.

### `docs/_Sidebar.md`

Documents: wiki navigation.

Asserts: one bullet per wiki page that exists, in reading order, plus
external links (Repo / Issues / Discussions, and a Contributing link that
points to `CONTRIBUTING.md` at the repo root by absolute URL).

Re-check whenever: a wiki page is added or removed; the repo URL changes.

### `docs/_Footer.md`

Documents: a footer line for the wiki.

Asserts: copyright and a link back to the repo. Rarely changes.

### `docs/README.md`

Repo-only meta-doc about the `docs/` folder (excluded from the published
wiki). Maintain only its reading-order link list so it matches the pages
that exist, and its editing voice rules. The wiki-publishing mechanics
(the sync workflow, the staging script) are tooling and live in
`CONTRIBUTING.md`, not here.

Re-check whenever: a wiki page is added or removed.

## Root markdown

### `README.md`

Documents: the same things `docs/Home.md` documents plus install and
quickstart. The repo's front door.

Asserts:

- Description paragraph (must match `extension.yml.extension.description`
  in intent).
- The four-row command table (must be byte-equivalent to `docs/Home.md`
  and `docs/Commands.md`).
- Install paths and pinned version (must match `extension.yml.extension.version`).
- Links to every `docs/*.md` page that exists.
- A single Contributing pointer to `CONTRIBUTING.md` at the repo root.

Re-check whenever: command count changes; version bumps; a wiki page is
added.

### `WORKFLOW.md`

Documents: the canonical usage narrative. Longer-form than
`docs/Workflow.md`, still written for the user running the commands.

Asserts: same flow as `docs/Workflow.md` but with more context. Treat the
two as a long/short pair. When `docs/Workflow.md` updates, `WORKFLOW.md`
may also need an update.

Re-check whenever: `docs/Workflow.md` changes; commands are added.

### `CHANGELOG.md`

Documents: per-version change log.

Asserts: top entry version matches `extension.yml.extension.version`
(unless an `[Unreleased]` block is open).

Re-check whenever: the version bumps. The release pipeline edits this
file; the skill only verifies the top entry version is consistent and
does not edit it unless explicitly asked.

## Website

### `web/index.html`

Documents: the public, short front door to the extension. A single page
covering the purpose, the four commands, getting started, the workflow,
and a FAQ subset. Deployed to GitHub Pages.

Asserts:

- The hero purpose paragraph (matches `extension.yml.extension.description`
  and the `README.md` lead).
- The hero badges: command count, `Requires Spec Kit >= 0.2.0`, license.
- The four-row command table (same command names, reads, writes, and
  audiences as `docs/Home.md`; HTML form, not byte-equivalent).
- The install snippets and the pinned release URL (must match the version
  in `README.md` and `docs/Getting-Started.md`).
- The `product/` output filenames (`00-info.md`, `10-spec.md`,
  `20-plan.md`, `30-design.md`, `checklist.md`).
- The FAQ entries (a subset of `docs/FAQ.md`; must not contradict it).
- The repository, wiki, issues, and discussions links.

Edit content only. Do not restyle `web/src/styles.css` or rewrite
the TypeScript under `web/src/`. `web/README.md` is a repo-only meta-doc about the folder,
maintained like `docs/README.md`.

Re-check whenever: a command is added or removed; the description in
`extension.yml` changes; the version bumps; an FAQ answer in
`docs/FAQ.md` changes in a way the website echoes.

## Out of scope (do not maintain as user docs)

- `CONTRIBUTING.md` — the contributor home: repo layout, dev install,
  pipeline checks, release procedure, catalog submission, style coupling,
  branch naming. User-facing pages link here for contributor questions;
  the skill does not edit it.
- `AGENTS.md` / `CLAUDE.md` — agent behavioral guidelines and the
  four-agent boundary rule. Repo governance, not user docs.
- `SECURITY.md`, `SUPPORT.md`, `CODE_OF_CONDUCT.md` — standard repo
  files. Leave alone unless explicitly asked.

## Canonical sources → pages that depend on them

Use this when you know which source changed and want to find every
user-facing page that might need a touch.

| Canonical file                            | Pages to re-check                                                                                   |
| ----------------------------------------- | --------------------------------------------------------------------------------------------------- |
| `extension.yml` (commands/hooks/version)  | `README.md`, `docs/Home.md`, `docs/Commands.md`, `docs/Getting-Started.md`, `docs/Architecture.md`, `CHANGELOG.md`, `web/index.html` |
| `extension.yml.extension.description`     | `README.md`, `docs/Home.md`, `web/index.html`                                                       |
| `catalog.json` (version, counts)          | `README.md`, `docs/Getting-Started.md`, `web/index.html`                                            |
| `commands/speckit.product.<verb>.md`      | `docs/Commands.md`, `docs/Troubleshooting.md`, `docs/Examples.md`, `docs/Architecture.md`           |
| `commands/*.md` `#### Diagram generation` + value gate | `docs/Diagrams.md`, `docs/Commands.md`, `docs/Style-Guide.md`, `WORKFLOW.md`           |
| `templates/<artifact>-template.md`        | `docs/Commands.md` (output sections), `docs/Examples.md` (example bodies), `docs/Diagrams.md` (diagram and section gating) |
| `extension.yml.hooks`                     | `docs/Commands.md`, `docs/Architecture.md`, `docs/Workflow.md`                                       |
| `docs/FAQ.md` (echoed answers)            | `web/index.html` (FAQ subset)                                                                       |
| `.specify/memory/constitution.md` §III    | `docs/Style-Guide.md`, `docs/FAQ.md` (only the user-visible output style, not governance)            |
| New file at `docs/<Page>.md`              | `docs/Home.md`, `docs/_Sidebar.md`, `docs/README.md`, `README.md` (if linked there)                  |
