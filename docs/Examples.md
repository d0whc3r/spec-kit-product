# Examples

A worked example. The fictional feature is **bulk export of dashboards to
PDF** in a fictional product called Lumen.

## Source: `spec.md` (excerpt)

```markdown
# Feature: Bulk Dashboard Export

## Summary

Lumen users currently export one dashboard at a time. Power users on the
Analytics team build weekly reports by exporting 20+ dashboards manually,
one PDF at a time. We want a single action that exports any selection of
dashboards into one combined PDF or a zip of PDFs.

## Users

- Analytics lead. Builds weekly board report from many dashboards.
- Customer success ops. Sends a packet of dashboards to each enterprise customer.

## Acceptance

- A user can select multiple dashboards in the library view.
- They trigger one export action.
- They receive a single combined PDF, or a zip of individual PDFs, per
  their choice.

## Out of scope

- Scheduled recurring exports. (Tracked separately.)
- Live-data PDFs. v1 is snapshot at export time.

## Clarifications

- 2026-04-12: confirmed that v1 supports up to 50 dashboards per export.
  Above that, the export is queued and emailed.

## [NEEDS CLARIFICATION]

- Branding. Should exports use the user's workspace logo, or a Lumen
  logo, or both?
```

## What `/speckit.product.info` produces

`product/00-info.md`:

```markdown
# Product Info: Bulk Dashboard Export

## Overview

Lumen lets people see their numbers on dashboards. Today they can export one
dashboard at a time. This feature exports many dashboards at once so the
people who build weekly reports stop doing it by hand.

## Headline

Analytics leads and customer success teams can now export any selection of
their dashboards in a single action, as one combined PDF or a zip of PDFs.
What used to take half an hour of manual work now takes one click.

## What is Changing

- Users can select more than one dashboard at a time.
- A new export action handles the whole selection.
- Output is a single combined PDF or a zip, the user's choice.
- Exports of up to 50 dashboards run inline; larger jobs are emailed.

## Out of Scope

- Scheduled recurring exports. Tracked as a future feature.
- Live-data exports. v1 captures a snapshot at export time.

## Key Decisions

These decisions were made while writing this spec. Review them to confirm
they still reflect the right direction, and flag any that have changed.

**Maximum dashboards per inline export**
v1 supports up to 50 dashboards per export. Larger jobs are queued and
emailed.
_Session: 2026-04-12_

> **Still open**: These questions were raised but not yet resolved. They
> should be answered before this feature is built.
>
> - Should exports use the user's workspace logo, the Lumen logo, or both?
```

Note: the open clarification is surfaced, not silently resolved. The "no em
dash" and "no implementation detail" rules are visibly enforced.

## What `/speckit.product.spec` produces (selected sections)

`product/10-spec.md`:

```markdown
## Headline

For analytics leads and customer success ops who build weekly dashboard
packets, Lumen Bulk Dashboard Export turns thirty minutes of manual export
work into a single action. Users select any number of dashboards, choose
combined PDF or zip, and receive the result inline or by email.

## Problem Statement (Job to Be Done)

**Primary job**:

> When I need to share a weekly snapshot of many dashboards with my team or
> a customer, I want to export the full set in one action, so I can spend
> my time on analysis instead of clicking export fifty times.

## Use Cases

### Use Case 1: Combined PDF export

**Given** I have selected ten dashboards in the library view.
**When** I trigger the bulk export action with the combined PDF option.
**Then** I receive a single PDF containing all ten dashboards in selection order.

### Use Case 2: Large export queued and emailed

**Given** I have selected sixty dashboards in the library view.
**When** I trigger the bulk export action.
**Then** I see a confirmation that the export will be emailed when ready.
```

Three lines per scenario, each starting with the keyword, full sentence,
period at the end. This is the Gherkin shape the checklist enforces.

## What `/speckit.product.plan` produces (selected sections)

After `/speckit-plan` produces `plan.md`, `/speckit.product.plan` writes
`product/20-plan.md`:

```markdown
## Summary

We add a multi-select mode to the dashboard library and a single bulk
export action that produces either one combined document or a packaged
bundle of individual documents. Up to fifty dashboards process inline.
Larger jobs run in the background and are emailed when ready.

## Goals

- Reduce time to produce a weekly multi-dashboard packet from thirty
  minutes to under one minute for jobs up to fifty dashboards.
- Cap inline export latency at fifteen seconds at the ninety-fifth
  percentile for fifty dashboards.
- Zero new manual steps required to opt in to the feature.

## Delivery Phases

**Phase 1: Multi-select in the library**

- Users can select more than one dashboard at a time.
- The selection state survives pagination and filter changes.

**Phase 2: Inline combined export**

- A new action produces a combined document for selections up to fifty.
- Users choose combined or packaged at export time.

**Phase 3: Queued export for large jobs**

- Selections above fifty are queued, processed in the background, and
  delivered by email.
```

No file paths, no code, no time estimates. Plain English, periods, the
voice a PM can read aloud.

## What `/speckit.product.design` produces (selected sections)

`product/30-design.md`, after `/speckit-plan` produced `plan.md`:

```markdown
## Architectural Approach

The bulk export feature extends the existing single-dashboard export path
by adding a selection-set entry point and a renderer pool. Inline export
reuses the existing render service synchronously up to a configurable
limit. Above that limit, the export is enqueued to the background job
runner and a delivery worker emails the artifact when complete.

## Affected Modules

| Module            | Change type | Responsibility                                            |
| ----------------- | ----------- | --------------------------------------------------------- |
| dashboard-library | modifies    | Adds multi-select state and bulk action button.           |
| export-service    | modifies    | Accepts a list of dashboard ids, returns combined output. |
| job-runner        | uses        | Runs large bulk exports out of band.                      |
| delivery-mailer   | adds        | New worker that emails completed bulk exports.            |
```

Component-level detail. No code, no full ORM definitions, no line-by-line
implementation. This is the granularity tech leads need to review the
approach before tasks are cut.

## What the shared `product/checklist.md` looks like

```markdown
# Quality Checklist: Bulk Dashboard Export

## Info

- [x] Overview present.
- [x] Headline present.
- [x] What is Changing present.
- [x] Out of Scope present.
- [x] No em dash.
- [x] No implementation detail.

## Spec

- [x] Headline present.
- [x] Target Users and Personas present.
- [x] Problem Statement in Ulwick format.
- [x] Use Cases follow Given/When/Then with one line each.
- [x] No em dash.
- [ ] No AI tell filler phrases. ← MANUAL REVIEW REQUIRED

## Plan

- [x] Summary present.
- [x] Goals present.
- [x] Delivery Phases present.
- [x] No time estimates.

## Design

- [x] Architectural Approach present.
- [x] Affected Modules table present.
- [x] Testing Strategy present.
- [x] No runnable code in output.
```

Items that need manual review are explicitly flagged rather than silently
passed. Walk the failed Required items and regenerate if needed.
