# docs/

Wiki source for the Product Spec Extension. The files in this folder are
authored to be browsed two ways:

1. **In the repo on GitHub.** Click any `*.md` file from
   <https://github.com/d0whc3r/spec-kit-product/tree/main/docs> and read.
2. **As the project GitHub Wiki.** Publish this folder to the repo's wiki
   (see below). Wiki users get sidebar and footer navigation from
   `_Sidebar.md` and `_Footer.md`.

## Reading order

Start at [Home.md](Home.md). The intended path for new users is:

1. [Home](Home.md)
2. [Getting Started](Getting-Started.md)
3. [Workflow](Workflow.md)
4. [Commands](Commands.md)
5. [Examples](Examples.md)

Reference material:

- [Style Guide](Style-Guide.md)
- [Troubleshooting](Troubleshooting.md)
- [FAQ](FAQ.md)
- [Architecture](Architecture.md)
- [Contributing](Contributing.md)

## Publishing to GitHub Wiki

The GitHub Wiki is a separate git repo at
`https://github.com/d0whc3r/spec-kit-product.wiki.git`. To publish this
folder to it:

```bash
# one-time setup
git clone https://github.com/d0whc3r/spec-kit-product.wiki.git /tmp/skp-wiki

# whenever docs/ changes
cp docs/*.md /tmp/skp-wiki/
cd /tmp/skp-wiki
git add .
git commit -m "docs: sync from main repo"
git push
```

GitHub renders `_Sidebar.md` and `_Footer.md` automatically as navigation
chrome. Pages are flat (no nested folders), which is the wiki's required
structure.

**Automatic sync.** `.github/workflows/sync-wiki.yml` runs
`.github/scripts/stage-wiki.sh` to stage `docs/*.md` into `.wiki-staging/`,
then publishes that staging dir to the wiki on every push to `main` that
touches `docs/`. It can also be triggered manually from the Actions tab.

The staging script:

- Excludes `docs/README.md` (this file, repo-only meta-doc).
- Strips `.md` from intra-wiki links (`[Commands](Commands.md)` ->
  `[Commands](Commands)`) since GitHub Wiki does not resolve the extension.
- Rewrites `../FILE.md` parent-dir links to absolute repo URLs so they keep
  working from the wiki.

To rehearse the staged output locally:

```bash
bash .github/scripts/stage-wiki.sh docs .wiki-staging
ls .wiki-staging/
```

**One-time setup.** GitHub does not create the `.wiki.git` repo until the
wiki has at least one page. Before the first sync, go to Settings →
Features → Wikis, enable Wikis, then create any placeholder page from the
UI. After that the workflow can push unattended.

## Editing rules

- File names are CamelCase or `Hyphen-Case` (GitHub Wiki page name rules).
- Relative links between pages use `[Page Name](Page-Name.md)`. The same
  link works on both the rendered repo and the wiki.
- No images yet. If you add one, place it under `docs/assets/` and link
  with a repo-root-relative URL so it resolves on the wiki too.
- Follow the same voice rules the extension itself enforces: plain English,
  no em dash, short sentences. See [Style Guide](Style-Guide.md).
