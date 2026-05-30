# Implementation Plan: Self-Serve Billing Usage Dashboard

**Branch**: `002-billing-usage-dashboard` | **Date**: 2026-05-30 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-billing-usage-dashboard/spec.md`

## Summary

Give organization admins a read-only billing dashboard that answers "what will this cost me, and why?" without contacting support. It shows the current plan and included allowances, current-period usage per metered dimension, and a projected end-of-period total that separates the already-included plan price from projected overage. It explains charge changes by breaking usage down per team (with an explicit "unattributed" bucket that reconciles to the account total) and comparing the current period against the previous one to surface the largest drivers. Admins can enable projected-overage alerts that fire before the invoice is issued, browse invoice history with line-item detail, and export invoice data for finance. Every panel renders a purposeful empty state for brand-new accounts.

Technical approach: a read-oriented billing API aggregates from an existing metering source (the source of truth for usage) and a durable store that holds plans, invoices, alert rules, an alert-event log, and cached projections. Usage-by-team and the account total are computed from one aggregation pass so the parts always reconcile (SC-006). A scheduled projection-and-alert job runs at least daily and ahead of each billing close: it recomputes the run-rate projection, evaluates each enabled alert rule, dedupes against the alert-event log so a threshold fires at most once per period (FR-014), and delivers via email and in-app notification before the invoice is issued (SC-003, FR-013). The dashboard is a React surface that calls four read APIs (overview, usage breakdown, alerts, invoices) plus an invoice export; empty states are response-driven so the UI never shows a blank or error panel.

> **Note on technology choices**: the spec is implementation-agnostic and this repository (a Spec Kit docs extension) has no application codebase to constrain the stack. The stack below is chosen in [research.md](./research.md) with rationale and mirrors the baseline used by the sibling example (`001-tenant-rate-limiting`) for coherence. It is a reasonable default for this demo feature, not an existing-codebase constraint.

## Technical Context

**Language/Version**: Python 3.12 (backend), TypeScript 5 (dashboard frontend)

**Primary Dependencies**: FastAPI (read APIs + export endpoint), SQLAlchemy + Alembic (durable billing data and migrations), Pydantic v2 (response contracts), a scheduled worker (APScheduler or an external cron invoking a management command) for the projection/alert job, an email-delivery integration (existing transactional email provider), React + TypeScript for the dashboard

**Storage**: PostgreSQL 16 for durable data (plans/subscriptions, invoices and line items, alert rules, alert-event log, cached usage projections). Usage itself is read from an existing metering source (treated as upstream, not owned by this feature); aggregated per-team usage is materialized for the current period to guarantee reconciliation and fast reads

**Testing**: pytest + httpx (backend unit/integration, including reconciliation and projection-math suites and an alert-dedup suite); Playwright (dashboard E2E for overview, breakdown, invoice export, and every empty state)

**Target Platform**: Linux server, containerized; stateless API replicas plus one scheduled worker; single PostgreSQL; reads from the metering source over its existing interface

**Project Type**: web application (backend API + scheduled worker + dashboard frontend)

**Performance Goals**: dashboard overview returns within 1 s p95 so an admin can read the projected bill well inside the 30 s SC-001 budget; usage-by-team breakdown returns within 1.5 s p95 for an org with hundreds of teams

**Constraints**: per-team plus unattributed usage MUST reconcile exactly to the account total shown (SC-006), so both come from one aggregation pass over the same source; the projection/alert job MUST run at least daily and before each billing close so overage alerts precede invoice issuance (SC-003, FR-013); a threshold alert fires at most once per billing period (FR-014); all amounts render in the account's single billing currency and are labeled (FR-023, single-currency assumption); the dashboard is read-only with respect to billing (no plan changes, payments, or disputes); every panel MUST render a purposeful empty state, never a blank panel or error (SC-005); the dashboard MUST surface when usage/projection data is stale or unavailable rather than imply a confident projection (FR-006)

**Scale/Scope**: thousands of organizations, hundreds of teams per large org; 7 entities; 4 read-API contract surfaces plus invoice export; 5 prioritized user stories (P1 overview, P2 charge-change explanation, P3 overage alerts, P4 invoice history/export, P5 empty states)

## Constitution Check

_GATE: Must pass before Phase 0 research. Re-check after Phase 1 design._

The project constitution at `.specify/memory/constitution.md` is the **unratified template** — all principles are placeholders (`[PRINCIPLE_1_NAME]`, etc.) with no ratified content. There are therefore **no concrete gates to evaluate** against this plan.

- **Initial check (pre-Phase 0)**: PASS (vacuously — no defined principles to violate).
- **Post-design re-check (post-Phase 1)**: PASS (no new violations; the design stays read-only over existing billing/metering systems, adds one scheduled job and one dashboard surface, and introduces no speculative complexity or new write paths into billing).

If the constitution is later ratified (e.g. Test-First, Simplicity, Versioning principles), this plan must be re-checked against it. No entries are required in Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/002-billing-usage-dashboard/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
│   ├── billing-overview-api.md   # plan + current usage + projection (US1)
│   ├── usage-breakdown-api.md    # per-team breakdown + period comparison + drivers (US2)
│   ├── overage-alerts-api.md     # alert-rule config + alert activity (US3)
│   └── invoice-history-api.md    # invoice list, detail, and export (US4)
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
backend/
├── src/
│   ├── models/
│   │   ├── plan.py                # Plan/Subscription: allowances, overage rates, cycle, currency
│   │   ├── invoice.py             # Invoice + InvoiceLineItem (status, totals)
│   │   ├── alert_rule.py          # AlertRule (threshold, enabled, channels)
│   │   ├── alert_event.py         # AlertEvent log (what/when, for dedup + activity feed)
│   │   └── projection.py          # UsageProjection cache (computed end-of-period estimate)
│   ├── services/
│   │   ├── usage_aggregator.py    # one pass -> account total + per-team + unattributed (FR-002, FR-007, FR-010, SC-006)
│   │   ├── projector.py           # run-rate end-of-period projection + overage split (FR-003, FR-004, FR-005)
│   │   ├── change_explainer.py    # period-over-period deltas + ranked drivers (FR-008, FR-009)
│   │   ├── alert_engine.py        # evaluate rules, dedup vs alert log, deliver before close (FR-011..FR-015)
│   │   ├── invoice_export.py      # structured (CSV) export of invoice data (FR-018)
│   │   └── empty_state.py         # shared empty-state resolution for each panel (FR-019..FR-021)
│   ├── jobs/
│   │   └── projection_alert_job.py # scheduled: recompute projection, fire/record alerts (FR-013, SC-003)
│   ├── integrations/
│   │   └── metering_client.py     # read-only client over the existing metering source (+ freshness, FR-006)
│   └── api/
│       ├── overview.py            # GET billing overview (US1)
│       ├── usage_breakdown.py     # GET usage-by-team + comparison (US2)
│       ├── alerts.py              # GET/PUT alert rules, GET alert activity (US3)
│       └── invoices.py            # GET list/detail, export invoice data (US4)
└── tests/
    ├── contract/                  # one suite per file in contracts/
    ├── integration/               # reconciliation, mid-cycle plan change, alert-before-close, role gating
    └── unit/                      # projection math, driver ranking, alert dedup, empty-state resolution

frontend/
├── src/
│   ├── pages/
│   │   └── BillingDashboard.tsx   # composes the panels below; admin/billing-role gated (FR-022)
│   ├── components/
│   │   ├── CostOverviewPanel.tsx  # plan, usage vs allowance, projected total w/ overage split (US1)
│   │   ├── UsageByTeamPanel.tsx   # per-team + unattributed + period comparison + drivers (US2)
│   │   ├── AlertsPanel.tsx        # enable/configure alerts + recent alert activity (US3)
│   │   ├── InvoiceHistoryPanel.tsx# invoice list, detail, export action (US4)
│   │   └── EmptyState.tsx         # reusable purposeful empty state (US5)
│   └── services/
│       └── billingClient.ts       # calls the four read APIs + export
└── tests/
    └── e2e/                       # Playwright: overview, breakdown, export, and each empty state (SC-005)
```

**Structure Decision**: Web-application layout (backend API + scheduled worker + existing dashboard frontend). Per spec Assumptions, plans, teams, invoices, and metered usage already exist in upstream systems; this feature adds read APIs, a projection/alert job, and an additive dashboard surface rather than owning billing data or introducing write paths into billing. The scheduled worker is the only non-request component and exists solely to satisfy "alert before invoice is issued" (SC-003).

## Complexity Tracking

> No Constitution Check violations to justify (constitution is the unratified template). Section intentionally empty.
