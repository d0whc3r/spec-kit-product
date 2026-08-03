# Edit Patterns

Concrete before/after examples for the doc edits that come up most
often. Reach for the closest pattern when you are about to make an
edit and want to keep voice and shape consistent across the wiki.

## 1. New command added

A new file `commands/speckit.product.<verb>.md` exists. The canonical
side (`extension.yml`, `catalog.json`, the integration manifests) is owned
by the release pipeline and contributors; this skill does not touch it.
The user-facing side to update:

- `README.md` and `docs/Home.md` command table (one new row).
- `docs/Commands.md` (one new section).
- `docs/Workflow.md` (mention in the recommended order if relevant).
- `docs/Troubleshooting.md` (one row per new error code).
- `docs/Architecture.md` (add to the runtime flow / hooks table if the
  command participates in a hook).
- `docs/_Sidebar.md` (no change unless a new top-level page was added).

### Before (excerpt of `docs/Commands.md`)

```markdown
| Command                                       | Reads     | Writes                            | Audience                       |
| --------------------------------------------- | --------- | --------------------------------- | ------------------------------ |
| [`/speckit.product.info`](#speckitproductinfo) | `spec.md` | `product/00-info.md` + checklist  | Any stakeholder, non-technical |
| [`/speckit.product.spec`](#speckitproductspec) | `spec.md` | `product/10-spec.md` + checklist  | Product managers, leadership   |
```

### After

```markdown
| Command                                       | Reads     | Writes                            | Audience                       |
| --------------------------------------------- | --------- | --------------------------------- | ------------------------------ |
| [`/speckit.product.info`](#speckitproductinfo) | `spec.md` | `product/00-info.md` + checklist  | Any stakeholder, non-technical |
| [`/speckit.product.brief`](#speckitproductbrief) | `spec.md` | `product/05-brief.md` + checklist | Execs, board                |
| [`/speckit.product.spec`](#speckitproductspec) | `spec.md` | `product/10-spec.md` + checklist  | Product managers, leadership   |
```

Then add a section body modeled on the existing per-command sections.
Always include: a one-paragraph summary, **Reads** / **Writes** lines,
the Output sections list, and the Error codes table.

## 2. New error code

A `commands/*.md` adds an `E_NEW_CODE`. Update two places:

- The command's section in `docs/Commands.md` (append to the error codes
  table).
- `docs/Troubleshooting.md` (one row).

### Before (`docs/Troubleshooting.md`)

```markdown
| `E_NO_SPEC`    | Feature directory has no `spec.md`.                       |
```

### After

```markdown
| `E_NO_SPEC`    | Feature directory has no `spec.md`.                       |
| `E_BAD_VERSION`| Spec Kit version below `0.2.0`.                           |
```

Preserve column alignment by hand if the surrounding table uses it.

## 3. Version bump

`extension.yml.extension.version` and `catalog.json.version` were bumped
by the release pipeline. The user-facing version references live in:

- `README.md`, the direct install snippet under "## Install".
- `docs/Getting-Started.md`, the install snippet under "Step 1: Install
  the extension".
- `web/index.html`, the two direct-install snippets, the brand version
  badge, and the "Requires Spec Kit" badge.

Each install snippet contains the literal version twice (in the URL path
and in the zip filename). Update both occurrences in each file.

### Before

```bash
specify extension add product --from \
  https://github.com/d0whc3r/spec-kit-product/releases/download/v0.1.2/product-0.1.2.zip
```

### After

```bash
specify extension add product --from \
  https://github.com/d0whc3r/spec-kit-product/releases/download/v0.1.3/product-0.1.3.zip
```

Do not touch the rest of the install snippets. The catalog install does
not pin a version.

## 4. Renamed file

The constitution treats command renames as breaking changes. The doc
side of a rename is straightforward but must be done in lockstep.

If `commands/speckit.product.spec.md` is renamed to
`commands/speckit.product.spec-v2.md`:

- Rename the section header in `docs/Commands.md`.
- Update the in-page anchor link in the table.
- Update every mention of `/speckit.product.spec` to
  `/speckit.product.spec-v2` in `README.md`, `docs/Home.md`,
  `docs/Getting-Started.md`, `docs/Workflow.md`, `docs/Examples.md`,
  `docs/Architecture.md`, `WORKFLOW.md`, `CHANGELOG.md` (the new entry).
- Update `extension.yml.hooks` if a hook command name referenced the
  old name (canonical, do not edit here; flag for the release owner).

When in doubt, do a project-wide search for the old name before
finishing:

```bash
git grep -l 'speckit.product.spec\b' -- '*.md' ':!CHANGELOG.md'
```

If any file still references the old name after your edits, you missed
one.

## 5. New hook

A new entry under `extension.yml.hooks` (canonical, do not edit) needs:

- A row in the hooks table in `docs/Commands.md` and
  `docs/Architecture.md`. The two tables must have identical column
  names. Copy the row format from the existing entries.

### Before (`docs/Architecture.md`)

```markdown
| Hook              | Triggers after        | Suggested command         |
| ----------------- | --------------------- | ------------------------- |
| `after_specify`   | `/speckit-specify`    | `/speckit.product.spec`   |
| `after_clarify`   | `/speckit-clarify`    | `/speckit.product.spec`   |
| `after_plan`      | `/speckit-plan`       | `/speckit.product.plan`   |
```

### After

```markdown
| Hook              | Triggers after        | Suggested command         |
| ----------------- | --------------------- | ------------------------- |
| `after_specify`   | `/speckit-specify`    | `/speckit.product.spec`   |
| `after_clarify`   | `/speckit-clarify`    | `/speckit.product.spec`   |
| `after_plan`      | `/speckit-plan`       | `/speckit.product.plan`   |
| `after_tasks`     | `/speckit-tasks`      | `/speckit.product.design` |
```

## 6. New wiki page

The user added `docs/Examples-Advanced.md` (for example) or you are
adding it as part of a sync. Touch these:

- `docs/_Sidebar.md` (add a bullet in the correct reading position).
- `docs/Home.md` (add a row to the start-here table if it belongs there;
  otherwise mention it in prose).
- `docs/README.md` (the reading-order list).
- `README.md` (the docs table at the top) if the page belongs in the
  main entry-point list.

The new page itself must start with a single `# H1` (matching the
filename's human form) and follow the voice rules in `docs/Style-Guide.md`.

## 7. Description change

A short sentence describing the extension exists in three places:

- `extension.yml.extension.description` (canonical, do not edit).
- `catalog.json.description` (canonical, the release pipeline owns it).
- `README.md` opening paragraph.
- `docs/Home.md` opening paragraph.

The README and Home page paragraphs are derived; they may expand on the
manifest description with one or two extra sentences but the lead line
should not contradict the manifest. When the manifest description
changes, rewrite the lead sentence in `README.md` and `docs/Home.md` to
match.

## 8. Em dash creep

The lint catches them but it is worth knowing the fix patterns. An em
dash (`—`) usually wants one of:

- A hyphen (`-`) for parenthetical asides.
- A comma for soft pauses.
- A period when the second clause stands on its own.

### Before

```
The four commands — info, spec, plan, design — derive from spec.md.
```

### After

```
The four commands (info, spec, plan, design) derive from spec.md.
```

or

```
The four commands derive from spec.md. They are info, spec, plan, and design.
```

Pick the form that reads cleanest in context.

## 9. Stale link

Relative wiki links break when a page is renamed. Run
`scripts/detect_drift.sh` after a rename; it lists broken links. Fix by
updating the link target, not the link text.

## 10. Long-form vs short-form workflow doc

`WORKFLOW.md` (root) and `docs/Workflow.md` are a long/short pair, both
written for the user running the commands. When they drift:

- Update `docs/Workflow.md` first (it is the wiki entry point).
- Mirror the structural changes in `WORKFLOW.md` while keeping its
  fuller narrative. Do not collapse `WORKFLOW.md` into
  `docs/Workflow.md`; the long form has room for more context.

If a fact appears in both files (a hook name, a filename, a command
name), make sure they match byte-for-byte.

## 11. Removing out-of-scope content

A user-facing page has drifted into contributor or tooling territory: it
describes the release pipeline, a CI workflow, the dev install
(`specify extension add --dev`), the repo source tree, or constitution
governance. This content is correct but misplaced; it belongs in
`CONTRIBUTING.md`, and on a user page it is noise that rots unread.

The fix is to cut it. If a reader might genuinely need the contributor
information, leave a single pointer rather than the content itself.

### Before (`docs/Style-Guide.md`)

```markdown
The shared `product/checklist.md` enforces them. `.github/scripts/lint-content.mjs`
in the release pipeline enforces them too.
```

### After

```markdown
The shared `product/checklist.md` enforces them.
```

### Before (a hand-off at the bottom of a page)

```markdown
See [Contributing](Contributing.md) for the full release coupling.
```

### After

```markdown
Contributors: see [CONTRIBUTING.md](https://github.com/d0whc3r/spec-kit-product/blob/main/CONTRIBUTING.md).
```

Do not leave a dangling link to a wiki `Contributing` page; that page is
not part of the user-facing wiki. Point at the repo-root `CONTRIBUTING.md`
by absolute URL so it resolves from both the repo and the wiki.
