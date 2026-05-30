# Diagrams and the Value Gate

`/speckit.product.plan` and `/speckit.product.design` embed Mermaid diagrams in
their output by default, and `/speckit.product.design` can add a Non-Functional
Requirements table. None of these are decorative. Each one renders only when it
earns its place. This page explains what gets drawn, when, and what is left out.

## The value gate

A diagram or optional section is emitted only when it shows the reader something
the prose cannot convey at a glance: connections between parts, ordering or
dependencies, a flow, a state machine, or a spread across two axes.

It is omitted when it would:

- only re-list what the prose already enumerates,
- duplicate a relationship another diagram or table already shows, or
- collapse to a trivial shape (a single node, a straight chain with no
  branching, or a chart where every point lands in one cell).

The rule of thumb: prefer no diagram over a decorative one. If a diagram would
not teach the reader anything the surrounding text does not, it does not appear.
The shared `product/checklist.md` carries a "diagrams and sections earn their
place" item so you can confirm this after generation.

## What each command draws

### `/speckit.product.plan`

| Section               | Diagram         | Renders when                                                    |
| --------------------- | --------------- | --------------------------------------------------------------- |
| Feature Context       | `journey`       | The spec describes a user-facing flow for the persona.          |
| Build Overview        | `flowchart`     | The plan has structural content and the parts actually connect. |
| Delivery Phases       | `flowchart`     | Two or more phases whose dependencies branch.                   |
| Risks and Mitigations | `quadrantChart` | Two or more risks that do not all land in one cell.             |

The Delivery Phases flowchart draws one node per phase and an edge for each
`Depends on`. A set of phases that forms a single straight chain adds nothing
over the numbered list, so it is omitted; the diagram appears when the
dependencies branch (a phase has more than one dependent, or more than one phase
is a starting point). Labels carry no dates or durations, in line with the
plan's atemporal style.

### `/speckit.product.design`

| Section                | Diagram                        | Renders when                                        |
| ---------------------- | ------------------------------ | --------------------------------------------------- |
| Architectural Approach | `flowchart`                    | Always. Layers grouped into C4-level subgraphs.     |
| Architectural Approach | `stateDiagram-v2`              | The source describes a lifecycle or state machine.  |
| Data Design            | `erDiagram` and a flow diagram | The Data Design section is present.                 |
| API Design             | `sequenceDiagram`              | The API Design section is present.                  |
| Risks and Mitigations  | `quadrantChart`                | Two or more risks that do not all land in one cell. |

The Architectural Approach flowchart is the one diagram that always renders: its
grouping of components into layers is structure worth showing even for a simple
design. Every other design diagram follows the value gate.

## The risk matrix (`quadrantChart`)

Both the plan and the design can plot their risks on a probability-by-impact
matrix. Each point is a risk named in the prose above the chart; nothing is
invented. Probability and impact map to the axes (Low near the start, Medium
near the middle, High near the end). When two risks share a cell they get a
small offset only, never one large enough to imply a difference the prose does
not state. The chart is omitted when every risk lands in the same cell, because
then it adds nothing the Probability and Impact lines already say.

The plan and the design surface different risks. The plan lists product and
outcome risks (for example, abuse during an outage, or default limits that
throttle legitimate traffic). The design lists technical risks (for example,
miscounting under concurrency, or a stale cache). The two matrices are not
copies of each other.

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
