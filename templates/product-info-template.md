# Product Info: [FEATURE NAME]

**Feature**: [FEATURE NAME]
**Created**: [DATE]
**Status**: Draft

> Authoring note (not emitted in the generated document): write every prose section to follow the humanization guide at `templates/humanization-guide.md` - plain English, varied cadence, no AI-tell phrases, no em dash.

## Overview

> One short paragraph, two to four sentences. Who this is for, the problem it addresses, what changes for them, and the new outcome they can reach. No jargon, no implementation detail, no feature lists.

[Paragraph here.]

## What is Changing

> Two to five short bullets. Customer-observable language only. Each bullet is one sentence ending with a period.

- [Bullet here.]
- [Bullet here.]
- [Bullet here.]

## Out of Scope

> What is explicitly not included, even though a reader might expect it. Always populate it. If it feels empty, think harder. One short sentence with a one-phrase reason each.

- [Item excluded, with one short reason.]
- [Item excluded, with one short reason.]

## Risks _(optional)_

> Pre-mortem: imagine this shipped and quietly failed. Two to four bullets naming the most likely causes, drawn from the spec. Each names the risk and its consequence in one sentence. Omit when the spec has no real risk signal.

- [Risk and its consequence in one sentence.]
- [Risk and its consequence in one sentence.]

## Key Decisions _(optional)_

> Only when spec.md has a populated `## Clarifications` section, or confirmed `[NEEDS CLARIFICATION]` markers. Surfaces the decisions that shaped this spec, and flags anything still open.

These decisions were made while writing this spec. Review them to confirm they still hold, and flag any that have changed.

**[Short noun phrase naming the decision area]**
[One sentence stating what was chosen and why it matters. Active voice.]
_Session: YYYY-MM-DD_

**[Short noun phrase naming the decision area]**
[One sentence.]
_Session: YYYY-MM-DD_

> **Still open**: These questions were raised but not yet resolved. They should be answered before this feature is built.
>
> - [Open question in one sentence.]

## References _(optional)_

> Only when the source spec cites external resources: research reports, briefs, customer interviews, dashboards, standards, or third-party docs. Never link to spec-kit artifacts (spec.md, plan.md, tasks.md, or any file this extension generates). One plain-language label and an external URL per line. Omit when there are none.

- [Plain-language label]: [URL]
- [Plain-language label]: [URL]
