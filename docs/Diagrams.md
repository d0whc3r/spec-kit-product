# Diagrams and the Value Gate

`/speckit.product.plan` and `/speckit.product.design` embed Mermaid diagrams in
their output by default, and `/speckit.product.design` can add a Non-Functional
Requirements table. None of these are decorative. Each one renders only when it
earns its place. This page explains what gets drawn, when, and what is left out.

## The value gate

A diagram or optional section is emitted only when it shows the reader something
the prose cannot convey at a glance: connections between parts, ordering or
dependencies, a flow, or a state machine. Diagrams are reserved for flows, never
for charts whose structure is the same every time regardless of content (a
matrix or quadrant).

It is omitted when it would:

- only re-list what the prose already enumerates,
- duplicate a relationship another diagram or table already shows, or
- collapse to a trivial shape (a single node, or a straight chain with no
  branching).

The rule of thumb: prefer no diagram over a decorative one. If a diagram would
not teach the reader anything the surrounding text does not, it does not appear.
The shared `product/checklist.md` carries a "diagrams and sections earn their
place" item so you can confirm this after generation.

## What each command draws

### `/speckit.product.plan`

| Section         | Diagram     | Renders when                                  |
| --------------- | ----------- | --------------------------------------------- |
| Delivery Phases | `flowchart` | Two or more phases whose dependencies branch. |

The Delivery Phases flowchart draws one node per phase and an edge for each
`Depends on`. A set of phases that forms a single straight chain adds nothing
over the numbered list, so it is omitted; the diagram appears when the
dependencies branch (a phase has more than one dependent, or more than one phase
is a starting point). Labels carry no dates or durations, in line with the
plan's atemporal style.

### `/speckit.product.design`

| Section                | Diagram                          | Renders when                                                           |
| ---------------------- | -------------------------------- | ---------------------------------------------------------------------- |
| Architectural Approach | `flowchart`                      | Always. Layers grouped into C4-level subgraphs.                        |
| Architectural Approach | `stateDiagram-v2`                | The source describes a lifecycle or state machine.                     |
| Data Design            | `flowchart` or `sequenceDiagram` | The Data Design section is present and the data flow is worth showing. |
| API Design             | `sequenceDiagram`                | The API Design section is present.                                     |

The Architectural Approach flowchart is the one diagram that always renders: its
grouping of components into layers is structure worth showing even for a simple
design. Every other design diagram follows the value gate.

## Non-Functional Requirements (design)

`/speckit.product.design` can include a Non-Functional Requirements table that
maps each measurable quality target to an ISO 25010 quality category and the way
it is verified. It uses numbers, not adjectives ("p95 under 250 ms", not
"fast").

The table and the Technical Constraints list divide the work. Technical
Constraints holds non-measurable design rules and boundaries; the Non-Functional
Requirements table is the single home for the measurable numeric targets. A
target is stated once, not in both places. The table is omitted when the source
names no measurable target, or when it would only restate the constraints
without adding the category and verification columns.

## Where they render

The diagrams are standard Mermaid. They render anywhere Mermaid is supported,
including GitHub's markdown view and the
[project website](https://d0whc3r.github.io/spec-kit-product/). If a viewer does
not support Mermaid, the block stays as readable text.

See [Commands](Commands.md) for the full per-command output, [Examples](Examples.md)
for sample artifacts, and [Style Guide](Style-Guide.md) for the voice rules. The
[project website](https://d0whc3r.github.io/spec-kit-product/) renders a full
plan and design with their diagrams in place.
