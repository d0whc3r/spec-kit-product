# web/

The public landing site for the Product Spec Extension, published to GitHub
Pages. It is a static, hand-authored site with no build step and no external
dependencies, so the files in this folder are served exactly as they are.

```
web/
├── index.html     single-page site (hero, commands, examples, getting started, workflow, install help, FAQ)
├── styles.css      all styling, responsive, light and dark
├── script.js       progressive enhancement (nav toggle, tabs, copy buttons)
├── favicon.svg
└── README.md       this file
```

## Relationship to the docs

The site is a **derived view** of the same canonical sources the wiki under
[`docs/`](../docs/) draws from: `extension.yml`, `catalog.json`,
`commands/`, and `templates/`. The wiki is the long-form reference; this site
is the short, public front door to it.

Because both are derived, they must agree. The `maintain-docs` skill owns that
alignment: when a command, version, install URL, hook, or output file changes,
the skill updates the wiki **and** this site together, and its drift detector
flags the site when it falls behind. See
[`.agents/skills/maintain-docs/SKILL.md`](../.agents/skills/maintain-docs/SKILL.md).

Facts on this page that must match the canonical sources and the wiki:

- Version pin and `requires.speckit_version` (hero badges, install snippet).
- The command list and the Command / Reads / Writes / Audience table.
- Install and usage commands.
- The `product/` output filenames (`00-info.md`, `10-spec.md`, `20-plan.md`,
  `30-design.md`, `checklist.md`).
- Repository, wiki, issues, and discussions links.

## Deployment

The [`pages.yml`](../.github/workflows/pages.yml) workflow publishes this
folder to GitHub Pages on every push to `main` that touches `web/` or `docs/`.
The site is served at `https://d0whc3r.github.io/spec-kit-product/`.

GitHub Pages must be set to the **GitHub Actions** source once, in the
repository settings, for the workflow to publish.

## Local preview

Open `index.html` directly, or serve the folder:

```bash
cd web
python3 -m http.server 8000
# then open http://localhost:8000
```
