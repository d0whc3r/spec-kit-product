# Product Spec Extension Wiki

A Spec Kit extension that turns engineering `spec.md` and `plan.md` into four
stakeholder-facing artifacts. Output follows Amazon Working Backwards (PRFAQ),
Jobs to Be Done (Ulwick), Gherkin BDD, and Lean PRD conventions, in plain
English with a strict no em dash style.

## Start here

| Page                                  | When to read                                                                                     |
| ------------------------------------- | ------------------------------------------------------------------------------------------------ |
| [Getting Started](Getting-Started.md) | First install, zero to first generated artifact in five minutes.                                 |
| [Commands](Commands.md)               | Deep reference for the three `/speckit.product.*` commands.                                      |
| [Workflow](Workflow.md)               | Input and output flow, recommended order, the `product/` layout.                                 |
| [Examples](Examples.md)               | Sample `spec.md` input and the four artifacts it produces.                                       |
| [Style Guide](Style-Guide.md)         | The voice rules every generated artifact enforces.                                               |
| [Diagrams](Diagrams.md)               | How diagrams and optional sections are generated, and the value gate that keeps them meaningful. |
| [Troubleshooting](Troubleshooting.md) | Error codes, refusals, common breakages and their fixes.                                         |
| [FAQ](FAQ.md)                         | Conceptual questions and design rationale.                                                       |
| [Architecture](Architecture.md)       | How the extension works when you run a command.                                                  |

## The commands at a glance

| Command                   | Reads                               | Writes                                     | Audience                         |
| ------------------------- | ----------------------------------- | ------------------------------------------ | -------------------------------- |
| `/speckit.product.brief`  | `spec.md`                           | `product/00-info.md`, `product/10-spec.md` | Any stakeholder, PMs, leadership |
| `/speckit.product.plan`   | `plan.md`, `spec.md`                | `product/20-plan.md`                       | PMs, engineering leads           |
| `/speckit.product.design` | `plan.md`, `spec.md`, optional more | `product/30-design.md`                     | Tech leads, senior developers    |

All three also update the shared `product/checklist.md`; `/speckit.product.brief`
writes both the Info and Spec sections. None of them modify `spec.md`,
`plan.md`, or any other source file.

## Source of truth

`spec.md` and `plan.md` are canonical. Everything under `product/` is a derived
view, regenerated on demand. If a source file changes, rerun the matching
command and choose overwrite. `[NEEDS CLARIFICATION]` markers in `spec.md` are
surfaced as open product questions in the output, never silently resolved.

## External links

- Repository: <https://github.com/d0whc3r/spec-kit-product>
- Issues: <https://github.com/d0whc3r/spec-kit-product/issues>
- Discussions: <https://github.com/d0whc3r/spec-kit-product/discussions>
- Spec Kit core: <https://github.com/github/spec-kit>
