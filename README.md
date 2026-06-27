# Product Spec Extension for Spec Kit

A Spec Kit extension that derives four stakeholder-facing artifacts from a technical `spec.md` and `plan.md`. Output follows Amazon Working Backwards (PRFAQ), Jobs to Be Done (Ulwick), Gherkin BDD, and Lean PRD conventions, in plain English, with a strict no em dash style.

## Documentation

The full guide lives in the **[project wiki](https://github.com/d0whc3r/spec-kit-product/wiki)**. This README is the front door only.

| Wiki page                                                                           | When to read                                                          |
| ----------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| [Home](https://github.com/d0whc3r/spec-kit-product/wiki/Home)                       | Overview and reading order.                                           |
| [Getting Started](https://github.com/d0whc3r/spec-kit-product/wiki/Getting-Started) | First install, zero to first generated artifact in five minutes.      |
| [Commands](https://github.com/d0whc3r/spec-kit-product/wiki/Commands)               | Deep reference for the three `/speckit.product.*` commands.           |
| [Workflow](https://github.com/d0whc3r/spec-kit-product/wiki/Workflow)               | Input and output flow, recommended order, the `product/` layout.      |
| [Examples](https://github.com/d0whc3r/spec-kit-product/wiki/Examples)               | Sample `spec.md` input and the four artifacts it produces.            |
| [Style Guide](https://github.com/d0whc3r/spec-kit-product/wiki/Style-Guide)         | The voice rules every generated artifact enforces.                    |
| [Diagrams](https://github.com/d0whc3r/spec-kit-product/wiki/Diagrams)               | How diagrams and optional sections are generated, and the value gate. |
| [Troubleshooting](https://github.com/d0whc3r/spec-kit-product/wiki/Troubleshooting) | Error codes, refusals, common breakages and their fixes.              |
| [FAQ](https://github.com/d0whc3r/spec-kit-product/wiki/FAQ)                         | Conceptual questions and design rationale.                            |
| [Architecture](https://github.com/d0whc3r/spec-kit-product/wiki/Architecture)       | How the extension works when you run a command.                       |

The wiki is generated from [`docs/`](docs/) on every push to `main`. To browse the same content as plain markdown, open the [docs folder](docs/).

## At a glance

| Command                   | Reads                               | Writes                                     | Audience                         |
| ------------------------- | ----------------------------------- | ------------------------------------------ | -------------------------------- |
| `/speckit.product.brief`  | `spec.md`                           | `product/00-info.md`, `product/10-spec.md` | Any stakeholder, PMs, leadership |
| `/speckit.product.plan`   | `plan.md`, `spec.md`                | `product/20-plan.md`                       | PMs, engineering leads           |
| `/speckit.product.design` | `plan.md`, `spec.md`, optional more | `product/30-design.md`                     | Tech leads, senior developers    |

All three commands also update their section of the shared `product/checklist.md` (`/speckit.product.brief` writes both the Info and Spec sections). No command modifies `spec.md` or `plan.md`.

## Source of truth

`spec.md` and `plan.md` are canonical. Everything under `product/` is a derived view, regenerated on demand by rerunning the matching command and choosing overwrite. `[NEEDS CLARIFICATION]` markers in `spec.md` are surfaced as open product questions in the generated output, never silently resolved.

## Install

Install directly from the latest release. This needs no catalog setup and is the recommended path:

```bash
specify extension add product --from https://github.com/d0whc3r/spec-kit-product/releases/download/v1.0.1/product-1.0.1.zip
```

Change the version in the URL to pin a different release.

Want to install by name with `specify extension add product`? That resolves the extension from Spec Kit's community catalog, which ships as discovery only (`install_allowed: false`). Approve it once:

```bash
specify extension catalog add https://raw.githubusercontent.com/github/spec-kit/main/extensions/catalog.community.json --name community --install-allowed
specify extension add product
```

If `specify extension add product` fails with `installation is not allowed from that catalog`, that is why. See [Troubleshooting](https://github.com/d0whc3r/spec-kit-product/wiki/Troubleshooting#installation-errors).

For prerequisites and the first-run walkthrough see [Getting Started](https://github.com/d0whc3r/spec-kit-product/wiki/Getting-Started).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) at the repo root.

## License

MIT. See [LICENSE](LICENSE).
