---
name: "maintain-docs"
description: "Keep the project wiki and root markdown in sync with the canonical extension sources. Invoke whenever someone asks to update the docs, sync the wiki, refresh documentation, audit docs for drift, document a new command, regenerate the README/CHANGELOG cross-references, or after any change under commands/, templates/, extension.yml, catalog.json, or .specify/integrations/. Use this skill before merging structural changes, even if the user only said 'update the docs' in passing. It does an exhaustive review of project purpose, usage, use cases, and examples, detects drift against the actual code, and updates docs/*.md and the relevant root markdown files in place."
compatibility: "Requires the spec-kit-product repo layout: extension.yml, catalog.json, commands/, templates/, .specify/integrations/, docs/."
metadata:
  author: "spec-kit-product"
  scope: "repo-local"
---

# Maintain Project Docs

Keep the wiki under `docs/` and the root-level markdown in sync with what
the extension actually does. The canonical truth lives in code-adjacent
files (`extension.yml`, `catalog.json`, `commands/`, `templates/`, the
manifests in `.specify/integrations/`). The wiki is a derived view of
those files, written for humans. Drift between the two is a bug.

This skill audits both sides, reports the drift, and edits the docs.
It never edits the canonical sources. If a doc and a source disagree,
the source wins.

## When to run this

Run it whenever any of the following just happened or is being requested:

- A command was added, renamed, or removed under `commands/`.
- A template under `templates/` changed shape (sections added or
  removed, error codes added or renamed).
- `extension.yml` or `catalog.json` changed (version, hooks, command
  count, descriptions, tags, requires).
- A manifest under `.specify/integrations/` changed.
- The release pipeline workflow under `.github/workflows/` changed in a
  way humans should know about.
- The user said any of: "update the docs", "sync the wiki", "refresh
  documentation", "docs are out of date", "audit the docs", "document
  this new command", "the README is stale", "fix the wiki", "what's
  drifted in the docs".
- A new release was just cut and `CHANGELOG.md` got a new entry that
  the wiki should reference.

Default behavior: do an exhaustive audit, propose a change list, then
apply edits. Ask the user only when a drift is ambiguous (e.g. a
template added a section that the wiki could describe in two reasonable
ways).

## Mental model

Treat the project as having two layers:

```
canonical layer                                derived layer
─────────────                                  ─────────────
extension.yml          ┐                       docs/Home.md
catalog.json           │                       docs/Getting-Started.md
commands/*.md          │  ──> drift detector ──> docs/Commands.md
templates/*.md         │                       docs/Workflow.md
.specify/integrations/ ┘                       docs/Examples.md
                                               docs/Style-Guide.md
                                               docs/Troubleshooting.md
                                               docs/FAQ.md
                                               docs/Architecture.md
                                               docs/Contributing.md
                                               docs/_Sidebar.md
                                               docs/_Footer.md
                                               README.md
                                               CHANGELOG.md (entry shape)
                                               WORKFLOW.md
                                               CONTRIBUTING.md
                                               AGENTS.md (= CLAUDE.md)
```

The job is one direction only: canonical → derived. The skill must not
touch the canonical layer. It must touch only the derived layer, and
only the parts that drifted.

## The workflow

Follow these phases in order. Each phase explains what to read, what to
produce, and how to verify the result.

### Phase 1: Inventory the canonical layer

Read these and build an in-memory picture of what the extension actually
does:

1. `extension.yml` — id, name, version, description, `requires`,
   `provides.commands[]`, `hooks{}`, `tags[]`, `homepage`,
   `repository`.
2. `catalog.json` — must match `extension.yml` on version, description,
   tags, requires, `provides.commands` count, `provides.hooks` count,
   homepage, repository.
3. `commands/speckit.*.md` — list of canonical command files. Each
   filename maps 1:1 to a command name (`speckit.product.spec.md` →
   `/speckit.product.spec`). Skim each file's frontmatter and the first
   ~40 lines to capture: what it reads, what it writes, the audience,
   the error codes, the output section list.
4. `templates/*.md` — output section list per artifact. Cross-check
   against what the command prompt claims to emit.
5. `.specify/integrations/*.manifest.json` — every public command must
   appear in all four manifests (`claude`, `copilot`, `codex`,
   `speckit`) per the constitution §V. Surface missing entries.
6. `CHANGELOG.md` — top entry version and date should equal
   `extension.yml.extension.version` (modulo an in-flight `[Unreleased]`
   block).

Open each file with `Read`. Do not trust grep alone for structure.

Output of this phase: a coverage map you carry in your head (or write
to a scratch note) of the form:

```
Commands actually shipped:
  /speckit.product.info   reads spec.md          writes product/00-info.md
  /speckit.product.spec   reads spec.md          writes product/10-spec.md
  /speckit.product.plan   reads plan.md, spec.md writes product/20-plan.md
  /speckit.product.design reads plan.md, spec.md writes product/30-design.md
Hooks declared: after_specify, after_clarify, after_plan
Version: 0.1.2  Requires: speckit >= 0.2.0
```

### Phase 2: Inventory the derived layer

Read the wiki pages and root markdown:

- `docs/Home.md`, `docs/Getting-Started.md`, `docs/Commands.md`,
  `docs/Workflow.md`, `docs/Examples.md`, `docs/Style-Guide.md`,
  `docs/Troubleshooting.md`, `docs/FAQ.md`, `docs/Architecture.md`,
  `docs/Contributing.md`, `docs/_Sidebar.md`, `docs/_Footer.md`,
  `docs/README.md`.
- `README.md` (root), `WORKFLOW.md`, `CONTRIBUTING.md`, `CHANGELOG.md`,
  `AGENTS.md` (and the `CLAUDE.md` symlink — same file, do not edit
  twice).

For each page note: which canonical artifacts it claims to describe,
and what specific claims it makes that can drift (command list, version
strings, install URLs, file paths, hook names, error codes, output
section lists, example snippets).

See `references/coverage-map.md` for the page-by-page list of which
canonical sources each page is responsible for. Read it now.

### Phase 3: Detect drift

Run `scripts/detect_drift.sh` from the repo root:

```bash
bash .claude/skills/maintain-docs/scripts/detect_drift.sh
```

It prints a machine-readable report of common drift classes:

- Command count mismatch between `extension.yml`, `catalog.json`, and
  the number of files in `commands/`.
- Command names that exist in `commands/` but are missing from any
  manifest under `.specify/integrations/`, or vice versa.
- Hook list mismatch between `extension.yml` and `docs/Architecture.md`
  / `docs/Commands.md`.
- Version mismatch between `extension.yml`, `catalog.json`, latest
  `CHANGELOG.md` entry, install URLs in `README.md` and
  `docs/Getting-Started.md`.
- Em dash characters present anywhere in `docs/` or root `*.md`
  (constitution §III forbids them).
- Broken intra-wiki links (relative `*.md` references that do not
  resolve).

After the script, do a second-pass semantic audit that the script
cannot do:

1. For each command in Phase 1, open `docs/Commands.md` and confirm the
   section for that command exists and lists the same reads, writes,
   audience, output sections, and error codes as the canonical command
   file and its template.
2. For each error code defined in a `commands/*.md`, confirm
   `docs/Troubleshooting.md` lists it with the same meaning.
3. For each install path in `README.md`, confirm `docs/Getting-Started.md`
   has the same paths and version pin.
4. Confirm `docs/_Sidebar.md` lists every page that exists under `docs/`
   and nothing else.
5. Confirm the table of command audiences in `README.md`,
   `docs/Home.md`, and `docs/Commands.md` is byte-equivalent (it is the
   single source of "who reads what").
6. Confirm `docs/Examples.md` references the same output filenames as
   the templates produce (`00-info.md`, `10-spec.md`, etc.).

Write the drift report as a short bullet list grouped by file. Do not
write it to disk unless the user asked for a report-only run.

### Phase 4: Propose the change set

Before editing, summarize for the user:

```
Drift found:
  docs/Commands.md
    - Missing section for /speckit.product.foo (added in extension.yml v0.2.0)
    - Error code E_NEW_CODE in commands/speckit.product.info.md is not listed
  docs/Getting-Started.md
    - Install URL points to v0.1.1, extension.yml is at 0.1.2
  README.md
    - "provides 3 commands" should be 4
  docs/_Sidebar.md
    - Missing entry for new Examples-Advanced.md page

Planned edits (in order):
  1. docs/Commands.md  add /speckit.product.foo section, append E_NEW_CODE row
  2. docs/Getting-Started.md  bump install URLs to v0.1.2
  3. README.md  fix command count
  4. docs/_Sidebar.md  add Examples-Advanced entry

Pages with no drift: docs/Home.md, docs/Workflow.md, docs/FAQ.md, ...
```

If a drift has more than one reasonable resolution (e.g. a new template
section could be documented under "Output sections" or under a new
"Advanced" subsection), ask once, then proceed.

### Phase 5: Apply edits

Edit in place with `Edit` (preferred) or `Write` (only when rewriting a
whole page). Apply one change at a time so each edit is reviewable.

Style rules every edit must obey (these come from
`.specify/memory/constitution.md` §III and `docs/Style-Guide.md`):

- No em dash characters. Use a hyphen, comma, or period instead.
- Plain English. Short sentences. No marketing voice.
- Match the existing voice of the page you are editing.
- Preserve `[NEEDS CLARIFICATION]` markers if any appear in source
  files surfaced through examples. Never silently resolve them.
- File references use the `[Page Name](Page-Name.md)` form so they
  work both in the repo and on GitHub Wiki.
- Command names in prose are wrapped in backticks:
  `` `/speckit.product.spec` ``.
- Tables use the same column shape across pages. When the same table
  appears in `README.md`, `docs/Home.md`, and `docs/Commands.md`, copy
  it verbatim. Do not vary the spacing or wording across copies.

When you add a new wiki page, also:

- Add it to `docs/_Sidebar.md` in the correct order.
- Add it to the table on `docs/Home.md` if it belongs in the start-here
  list.
- Add it to the reading order list in `docs/README.md` if appropriate.

When you bump the version:

- `README.md` install snippets, `docs/Getting-Started.md` install
  snippets, `catalog.json`, and the latest `CHANGELOG.md` entry all
  refer to the same version. Only `CHANGELOG.md` and the README's
  install URL line are wiki concerns; `catalog.json` and
  `extension.yml` are canonical and the release pipeline owns them
  (do not edit them here).

### Phase 6: Verify

After editing, rerun the drift script:

```bash
bash .claude/skills/maintain-docs/scripts/detect_drift.sh
```

It should now report no drift. If anything remains, either the edit was
incomplete or a previously unnoticed drift surfaced; loop back to
Phase 4.

Also run the style check:

```bash
bash .claude/skills/maintain-docs/scripts/check_style.sh
```

It scans `docs/` and root `*.md` for em dash characters and other
style violations. Zero output means clean.

If the user gave a specific PR or commit range to react to, also run:

```bash
git diff --name-only <base>..HEAD -- commands/ templates/ extension.yml \
  catalog.json .specify/integrations/
```

Cross-check that every file in the diff has a corresponding doc edit in
this run. If something changed canonically and no doc edit was needed,
say so explicitly in the summary: "extension.yml description tweak was
cosmetic, no doc update needed."

### Phase 7: Report

End with a short summary the user can paste into a PR description:

```
Docs synced.
  Updated: docs/Commands.md, docs/Getting-Started.md, README.md, docs/_Sidebar.md
  No-op:   docs/Home.md, docs/Workflow.md, docs/FAQ.md, docs/Architecture.md,
           docs/Contributing.md, docs/Examples.md, docs/Style-Guide.md,
           docs/Troubleshooting.md, AGENTS.md, CONTRIBUTING.md, WORKFLOW.md
  Drift detector: clean.
  Style check: clean.
```

Do not commit. The user controls commits.

## Modes

- **Audit only.** User says "audit the docs" or "show me what's
  drifted". Stop after Phase 3 and print the drift report. Do not edit.
- **Scoped sync.** User points at a specific change ("after my last
  commit", "after the v0.2.0 cut"). Run the full workflow but in
  Phase 3 prioritize drift implied by the diff.
- **Full sync.** No scope given. Run all phases on the entire repo.
  This is the default.
- **New page.** User says "add a docs page for X" or "create a
  troubleshooting entry for X". Treat it as a Phase 5 edit with the
  drift report skipped, but still run Phase 6 verification.

## What this skill must not do

- Do not edit `commands/`, `templates/`, `extension.yml`,
  `catalog.json`, `.specify/integrations/`, the workflows under
  `.github/workflows/`, or `.specify/memory/constitution.md`. They are
  canonical.
- Do not "improve" prose adjacent to a drift fix. Touch only the
  drifted lines.
- Do not regenerate the `product/` artifacts under `specs/*/product/`.
  Those are produced by the `/speckit.product.*` commands, not by docs
  maintenance.
- Do not change the wiki page filenames without updating
  `docs/_Sidebar.md`, `docs/README.md`, and every inbound link in the
  same edit batch. Renaming a wiki page is a coordinated change.
- Do not silently delete `[NEEDS CLARIFICATION]` markers.
- Do not introduce em dashes. The lint will catch you and the
  constitution forbids them.
- Do not reintroduce per-agent surface detail to the wiki. The wiki
  describes the extension itself, not the integrations that host it.
  Per-agent mirror surfaces (`.claude/`, `.github/agents/`,
  `.github/prompts/`), assistant names (Claude Code, Copilot, Codex),
  and the four-agent boundary rule live in `docs/Contributing.md` and
  `AGENTS.md`. The wiki may refer generically to "a Spec Kit-aware
  assistant" when context demands it.

## References

- `references/coverage-map.md` — which canonical file each wiki page is
  responsible for. Read this in Phase 2.
- `references/edit-patterns.md` — concrete before/after examples of
  common doc edits (new command, new error code, version bump, new
  hook, renamed file). Read when you are about to make an edit and
  want a template.
- `references/style-rules.md` — the full style rule list extracted from
  the constitution and `docs/Style-Guide.md`. Read when in doubt.

## Scripts

- `scripts/detect_drift.sh` — machine-readable drift report. Run in
  Phase 3 and again in Phase 6.
- `scripts/check_style.sh` — em dash and basic style lint over `docs/`
  and root `*.md`. Run in Phase 6.
