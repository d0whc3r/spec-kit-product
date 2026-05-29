# Product Spec Extension for Spec Kit

A Spec Kit extension that derives four stakeholder-facing artifacts from a technical `spec.md` and `plan.md`. Output follows Amazon Working Backwards (PRFAQ), Jobs to Be Done (Ulwick), Gherkin BDD, and Lean PRD conventions, in plain English, with a strict no em dash style.

## Documentation

The full guide lives in the **[project wiki](https://github.com/d0whc3r/spec-kit-product/wiki)**. This README is the front door only.

| Wiki page                                                                           | When to read                                                     |
| ----------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| [Home](https://github.com/d0whc3r/spec-kit-product/wiki/Home)                       | Overview and reading order.                                      |
| [Getting Started](https://github.com/d0whc3r/spec-kit-product/wiki/Getting-Started) | First install, zero to first generated artifact in five minutes. |
| [Commands](https://github.com/d0whc3r/spec-kit-product/wiki/Commands)               | Deep reference for the four `/speckit.product.*` commands.       |
| [Workflow](https://github.com/d0whc3r/spec-kit-product/wiki/Workflow)               | Input and output flow, recommended order, the `product/` layout. |
| [Examples](https://github.com/d0whc3r/spec-kit-product/wiki/Examples)               | Sample `spec.md` input and the four artifacts it produces.       |
| [Style Guide](https://github.com/d0whc3r/spec-kit-product/wiki/Style-Guide)         | The voice rules every generated artifact enforces.               |
| [Troubleshooting](https://github.com/d0whc3r/spec-kit-product/wiki/Troubleshooting) | Error codes, refusals, common breakages and their fixes.         |
| [FAQ](https://github.com/d0whc3r/spec-kit-product/wiki/FAQ)                         | Conceptual questions and design rationale.                       |
| [Architecture](https://github.com/d0whc3r/spec-kit-product/wiki/Architecture)       | How the extension works when you run a command.                  |

The wiki is generated from [`docs/`](docs/) on every push to `main`. To browse the same content as plain markdown, open the [docs folder](docs/).

## At a glance

| Command                   | Reads                               | Writes                 | Audience                       |
| ------------------------- | ----------------------------------- | ---------------------- | ------------------------------ |
| `/speckit.product.info`   | `spec.md`                           | `product/00-info.md`   | Any stakeholder, non-technical |
| `/speckit.product.spec`   | `spec.md`                           | `product/10-spec.md`   | Product managers, leadership   |
| `/speckit.product.plan`   | `plan.md`, `spec.md`                | `product/20-plan.md`   | PMs, engineering leads         |
| `/speckit.product.design` | `plan.md`, `spec.md`, optional more | `product/30-design.md` | Tech leads, senior developers  |

All four commands also update their respective section of the shared `product/checklist.md`. No command modifies `spec.md` or `plan.md`.

## Source of truth

`spec.md` and `plan.md` are canonical. Everything under `product/` is a derived view, regenerated on demand by rerunning the matching command and choosing overwrite. `[NEEDS CLARIFICATION]` markers in `spec.md` are surfaced as open product questions in the generated output, never silently resolved.

## Install

```bash
specify extension add product
```

To pin a specific version:

```bash
specify extension add product --from https://github.com/d0whc3r/spec-kit-product/releases/download/v0.5.1/product-0.5.1.zip
```

For prerequisites and the first-run walkthrough see [Getting Started](https://github.com/d0whc3r/spec-kit-product/wiki/Getting-Started).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) at the repo root.

## License

MIT. See [LICENSE](LICENSE).
