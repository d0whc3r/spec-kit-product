# Coverage Map

For each wiki page, the canonical sources it documents and the specific
facts it asserts. Use this in Phase 2 of `maintain-docs` to figure out
which sources to re-check when a given page is suspected of drift.

The reverse direction (canonical file → which pages depend on it) is at
the bottom.

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
changes (e.g. someone proposes dropping the `00-`/`10-`/`20-`/`30-`
prefixes).

### `docs/Examples.md`

Documents: a sample `spec.md` and the four artifacts derived from it.

Asserts:

- Filenames of derived artifacts match the templates.
- Section structure of each example matches the current template.

Re-check whenever: `templates/*.md` changes shape. The example bodies
are illustrative and do not need byte-exact match, but section names,
ordering, and presence of required sections must match the current
template.

### `docs/Style-Guide.md`

Documents: the voice rules every generated artifact must enforce.

Asserts:

- No em dash rule.
- Plain English, short sentences.
- PRFAQ / JTBD / Gherkin / Lean PRD conventions.
- `[NEEDS CLARIFICATION]` markers preserved.

Re-check whenever: `.specify/memory/constitution.md` §III changes, or
the lint script in `.github/scripts/` changes.

### `docs/Troubleshooting.md`

Documents: error codes, refusals, common breakages.

Asserts:

- One row per `E_*` error code defined in any `commands/*.md`.
- Each refusal scenario the command prompts can produce.

Re-check whenever: a command file adds or renames an error code.

### `docs/FAQ.md`

Documents: conceptual questions and design rationale.

Asserts: rationale that may reference constitutional rules. Drift here
is rare; most edits to this page are additive.

Re-check whenever: a constitutional rule is added or relaxed; a
frequently asked question surfaces in issues that is not yet covered.

### `docs/Architecture.md`

Documents: what the extension is, repo layout, invocation flow, source of
truth contract, hooks, release pipeline, constitution rules that bind the
output.

Scope rule: this page describes the extension itself. It does not
enumerate per-agent mirror surfaces (`.claude/`, `.github/agents/`,
`.github/prompts/`) or name specific assistants. Mirror surfaces are a
contributor concern and belong in `docs/Contributing.md` or
`.specify/memory/constitution.md`, not here.

Asserts:

- The repo layout tree (must include every top-level directory that the
  page lists, and must not list directories that don't exist).
- The hooks table (must match `extension.yml.hooks`).
- The release pipeline diagram references the actual workflow files
  under `.github/workflows/` and the actual release tooling
  (`.releaserc.json`, `.github/scripts/semantic-release-prepare.sh`).

Re-check whenever: a top-level directory is added or removed; a workflow
under `.github/workflows/` is added or renamed; a hook is added or
removed; the release tooling changes.

### `docs/Contributing.md`

Documents: repo layout for contributors, dev install, release procedure.

Asserts:

- Dev install command (`specify extension add --dev`).
- The release procedure steps reference the actual workflow names and
  versioning rules from the constitution.

Re-check whenever: the dev install command changes; the release pipeline
changes; the versioning rules in the constitution change.

### `docs/_Sidebar.md`

Documents: wiki navigation.

Asserts: one bullet per wiki page that exists, in reading order, plus
external links to Repo / Issues / Discussions.

Re-check whenever: a wiki page is added or removed; the repo URL
changes.

### `docs/_Footer.md`

Documents: a footer line for the wiki.

Asserts: copyright and a link back to the repo. Rarely changes.

### `docs/README.md`

Documents: how to publish the wiki, the file naming rules, the editing
rules.

Asserts: the wiki repo URL (`https://github.com/d0whc3r/spec-kit-product.wiki.git`).

Re-check whenever: the repo URL changes; the wiki publishing process
changes.

## Root markdown

### `README.md`

Documents: the same things `docs/Home.md` documents plus install and
quickstart. The repo's front door.

Asserts:

- Description paragraph (must match `extension.yml.extension.description`
  in intent).
- The four-row command table (must be byte-equivalent to
  `docs/Home.md` and `docs/Commands.md`).
- Install paths and pinned version (must match `extension.yml.extension.version`).
- Links to every `docs/*.md` page that exists.

Re-check whenever: command count changes; version bumps; a wiki page is
added.

### `CHANGELOG.md`

Documents: per-version change log.

Asserts: top entry version matches `extension.yml.extension.version`
(unless an `[Unreleased]` block is open).

Re-check whenever: the version bumps. The release pipeline edits this
file; the skill only verifies the top entry version is consistent and
does not edit it unless explicitly asked.

### `WORKFLOW.md`

Documents: the canonical workflow narrative. Longer-form than
`docs/Workflow.md`.

Asserts: same flow as `docs/Workflow.md` but with more context. Treat
the two as a long/short pair. When `docs/Workflow.md` updates,
`WORKFLOW.md` may also need an update.

Re-check whenever: `docs/Workflow.md` changes; commands are added.

### `CONTRIBUTING.md`

Documents: how to contribute. Root-level mirror of
`docs/Contributing.md`. The two should not contradict each other.

Re-check whenever: `docs/Contributing.md` changes; the dev install
command changes.

### `AGENTS.md` (symlinked as `CLAUDE.md`)

Documents: behavioral guidelines for any AI agent working in this repo.

Asserts: the four-agent boundary table (which surface owns which
files). Must match `docs/Architecture.md` on this table.

Re-check whenever: agent surfaces change; the four-surface mirror rule
in the constitution changes.

### `SECURITY.md`, `SUPPORT.md`, `CODE_OF_CONDUCT.md`

Standard repo files. Rarely drift with extension features. Leave alone
unless explicitly asked.

## Canonical sources → pages that depend on them

Use this when you know which source changed and want to find every page
that might need a touch.

| Canonical file                            | Pages to re-check                                                                                   |
| ----------------------------------------- | --------------------------------------------------------------------------------------------------- |
| `extension.yml` (commands/hooks/version)  | `README.md`, `docs/Home.md`, `docs/Commands.md`, `docs/Getting-Started.md`, `docs/Architecture.md`, `CHANGELOG.md` |
| `extension.yml.extension.description`     | `README.md`, `docs/Home.md`                                                                         |
| `catalog.json` (version, counts)          | `README.md`, `docs/Getting-Started.md`                                                              |
| `commands/speckit.product.<verb>.md`      | `docs/Commands.md`, `docs/Troubleshooting.md`, `docs/Examples.md`                                   |
| `templates/<artifact>-template.md`        | `docs/Commands.md` (output sections), `docs/Examples.md` (example bodies)                            |
| `.specify/integrations/<agent>.manifest.json` | `AGENTS.md`, `docs/Contributing.md` (the wiki does not surface per-agent mirrors)                |
| `.specify/memory/constitution.md`         | `docs/Style-Guide.md`, `docs/FAQ.md`, `docs/Architecture.md`, `AGENTS.md`                            |
| `.github/workflows/*.yml`                 | `docs/Architecture.md`, `docs/Contributing.md`                                                       |
| `.releaserc.json`, release scripts        | `docs/Architecture.md`, `docs/Contributing.md`, `CONTRIBUTING.md`                                    |
| New file at `docs/<Page>.md`              | `docs/Home.md`, `docs/_Sidebar.md`, `docs/README.md`, `README.md` (if linked there)                  |
