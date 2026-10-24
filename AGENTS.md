# AGENTS.md

This repository is the `product` extension for [Spec Kit](https://github.com/github/spec-kit). The extension adds three agent commands. Each command reads the `spec.md` or `plan.md` of a feature and writes stakeholder documents to `<feature-dir>/product/`.

## Commands

Use the pnpm version in `package.json` (`packageManager`) and the Node version in `.nvmrc`.

| Task                                         | Command                           |
| -------------------------------------------- | --------------------------------- |
| Install dependencies                         | `pnpm install`                    |
| Run the CI checks                            | `pnpm check` and `pnpm web:build` |
| Format all files                             | `pnpm format`                     |
| Copy the identity fields from `package.json` | `pnpm sync`                       |
| Build the release zip into `dist/`           | `pnpm build`                      |
| Run the website on a local server            | `pnpm web:dev`                    |

`pnpm check` runs `validate`, `sync:check`, `lint`, and `lint:content`. Run it before you finish a change.

## Layout

- `extension.yml`: the extension manifest. It declares the commands, the hooks, and `requires.speckit_version` (`>=0.12.17`).
- `catalog.json`: the entry for the Spec Kit community catalog.
- `commands/speckit.product.{brief,plan,design}.md`: one agent prompt for each command.
- `templates/`: the output skeletons and `humanization-guide.md`. After install, the commands read them from `.specify/extensions/product/templates/`.
- `examples/specs/`: real Spec Kit inputs and the `product/` documents that the commands made from them. The website shows these files.
- `docs/`: the source of the GitHub Wiki. A workflow publishes it on each push to `main`.
- `web/`: the GitHub Pages site (Vite, TypeScript, `marked`, and `mermaid`).
- `.github/scripts/`: the release, validation, and lint scripts (Node ESM with `zx`).
- `.agents/skills/`: contributor skills. `.claude/skills/` holds symlinks to them.

## Conventions

- `package.json` owns the identity fields: `description`, `author`, `homepage`, `repository`, `license`, and `keywords` (the catalog `tags`). Edit them there, then run `pnpm sync`.
- semantic-release owns the version. Do not edit `version` in `extension.yml`, `catalog.json`, or `package.json`.
- Use Conventional Commits. Only `feat:`, `fix:`, and `perf:` commits cause a release. To rename or remove a command, use a `BREAKING CHANGE:` footer. The release preset (angular) ignores a `feat!:` header.
- A command writes only to `<feature-dir>/product/`. All other Spec Kit files are read-only inputs, `.specify/feature.json` included.
- Generated documents obey `templates/humanization-guide.md`: no em dash, plain English, no AI-tell phrases, and every `[NEEDS CLARIFICATION]` marker kept.

## When you change a command or a template

- Keep `version`, `requires.speckit_version`, and the `provides` counts in `catalog.json` equal to `extension.yml`. `pnpm validate` fails when they differ.
- Add each new runtime file to `REQUIRED` in `.github/scripts/validate-manifest.mjs`.
- Update the heading lists in `.github/scripts/lint-content.mjs` when a template adds, removes, or reorders a `##` section.
- Each command copies the AI-tell list from the "The enforced minimum" block of the guide two times. `pnpm lint:content` fails when a copy drifts.
- In a command body, refer to extension files as `templates/<file>`. At install, Spec Kit rewrites them to `.specify/extensions/product/templates/<file>`.
- In a command body, write each Spec Kit command as a token, for example `__SPECKIT_COMMAND_PLAN__` or `__SPECKIT_COMMAND_PRODUCT_BRIEF__`. At install, Spec Kit replaces the token with `/speckit.plan` or `/speckit-plan`, as the agent needs. The token includes the `/`, so do not write `/__SPECKIT_COMMAND_...`.
- Spec Kit does not replace tokens in `templates/`. A template that becomes part of a generated document keeps plain command names.
- `extension.yml` declares four optional hooks: `after_specify` and `after_clarify` offer `speckit.product.brief`. `after_plan` is a list that offers `speckit.product.plan` (priority 10), then `speckit.product.design` (priority 20). A hook change also changes `provides.hooks` in `catalog.json`.
- Update the user docs in `README.md`, `WORKFLOW.md`, `docs/`, and `web/index.html`. The `maintain-docs` skill covers this.

## Gotchas

- `specs/` and `.specify/` are local dogfood state. Git ignores both, so do not refer to them from tracked files.
- The release zip holds only `extension.yml`, `README.md`, `LICENSE`, `commands/`, and `templates/`. `.extensionignore` gives `specify extension add --dev` the same set.
- `pnpm web:build` copies `examples/` into `web/public/examples/`. Edit `examples/`, never the copy.
- semantic-release writes `CHANGELOG.md`. Do not edit it.
- A husky pre-commit hook runs oxfmt on the staged files.
- Renovate updates the dependencies (`renovate.json`). Each update uses `chore`, because no npm dependency ships in the release zip.

<!-- CODEGRAPH_START -->

## CodeGraph

`.mcp.json` configures the CodeGraph MCP server. For structural questions (where a symbol is, what calls it, what a change breaks), call `codegraph_explore` before you use grep.

<!-- CODEGRAPH_END -->
