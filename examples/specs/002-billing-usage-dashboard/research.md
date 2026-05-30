# Phase 0 Research: Self-Serve Billing Usage Dashboard

This document resolves the open technical questions for the feature. Because the
specification is implementation-agnostic and this repository has no application
codebase, each decision states the choice, the rationale, and the alternatives
considered. Choices marked **(demo assumption)** would normally be constrained by
an existing codebase or constitution.

---

## 1. Projection method for end-of-period cost

**Decision**: Linear run-rate extrapolation. Take usage consumed so far in the current period, divide by the elapsed fraction of the billing cycle, and project to the full cycle; price the projected usage against the plan's included allowance and overage rates to produce a projected total with the overage split out.

**Rationale**: The spec Assumptions explicitly scope projection to a simple run-rate and defer sophisticated forecasting. Run-rate is transparent and explainable, which matters because the dashboard's job is to build trust ("based on usage through [date]", FR-005). It needs only the current period's usage-to-date and the elapsed-time fraction, both already available.

**Edge handling**: On day 1 (little or no usage) the extrapolation is unstable, so the projection is labeled low-confidence and the UI leans on "based on usage through [date]" rather than a hard number until enough of the period has elapsed. On a mid-cycle plan change, the projection prices usage against the allowance/rates in effect for the remainder of the cycle (see §5).

**Alternatives considered**:

- _Seasonal/trend models (e.g. day-of-week weighting, regression)_: rejected for v1 — more accurate in theory but not explainable to an admin, and out of scope per Assumptions.
- _Projecting from the prior period's total_: rejected — ignores in-period signal and would mislead during ramps.

---

## 2. Reconciliation of per-team and account totals (SC-006)

**Decision**: Compute the account total and the per-team breakdown in a **single aggregation pass** over the same metered-usage records for the period. Usage that carries no team attribution is summed into one explicit `unattributed` bucket. The breakdown response includes the account total and asserts `sum(teams) + unattributed == account_total`.

**Rationale**: SC-006 requires exact reconciliation. The only robust way to guarantee parts equal the whole is to derive them from one source pass rather than two independent queries that can drift (different filters, timing, rounding). The explicit unattributed bucket (FR-010) means no usage is silently dropped.

**Alternatives considered**:

- _Separate "account total" and "per-team" queries_: rejected — two queries can disagree under late-arriving data or differing filters, breaking SC-006.
- _Hiding unattributed usage_: rejected — it would make the parts fail to sum to the whole and violate FR-010.

---

## 3. Materialization vs live aggregation for usage-by-team

**Decision**: Materialize the current-period per-team aggregate (refreshed by the same scheduled job that recomputes projections, plus on-demand on dashboard load if the cached value is older than the freshness window). Historical periods are aggregated once and stored, since closed periods do not change.

**Rationale**: Large orgs have hundreds of teams; aggregating raw metering rows on every page load risks the 1.5 s p95 target (Performance Goals). Materializing keeps reads fast and makes reconciliation deterministic (one stored snapshot). Closed periods are immutable, so their aggregate is computed once.

**Alternatives considered**:

- _Always live-aggregate_: rejected for large orgs on latency grounds.
- _Cache only, never materialize_: rejected — a cold cache on a big org would blow the latency budget and a transient cache could desync from the displayed account total.

---

## 4. Explaining charge changes / driver ranking (FR-008, FR-009)

**Decision**: For period-over-period comparison, compute per-(team, dimension) deltas between the current and previous period and rank by absolute contribution to the total change. Surface the top drivers ("Team X usage of dimension Y rose Z"). The comparison reuses the materialized per-team aggregates from §3.

**Rationale**: Directly implements FR-008/FR-009. Ranking by absolute contribution answers the admin's real question ("what moved my bill the most?") rather than listing every team. Reusing the materialized aggregates keeps it cheap and consistent with the numbers shown elsewhere.

**Alternatives considered**:

- _Percentage-change ranking_: rejected as the primary sort — a tiny team doubling looks dramatic but barely moves the bill; absolute contribution matches the dollars. (Percentage is still shown as context.)
- _Full diff table of every team_: kept available, but the dashboard leads with ranked drivers to avoid burying the signal.

---

## 5. Mid-cycle plan change handling (FR-024, Edge Case)

**Decision**: Attribute usage-to-date to the plan/allowance in effect when it was consumed, and price the remaining projected usage against the plan in effect for the rest of the cycle. The overview notes that a plan change occurred in the current period.

**Rationale**: FR-024 requires the current-period view and projection to reflect a mid-cycle change. Splitting at the change boundary avoids both under- and over-charging in the projection and keeps the explanation honest.

**Alternatives considered**:

- _Apply the new plan to the whole period_: rejected — misstates already-consumed usage and the bill.
- _Ignore the change until next period_: rejected — directly violates FR-024.

---

## 6. Alert evaluation, timing, and dedup (FR-011..FR-015, SC-003)

**Decision**: A scheduled job runs at least daily and is also triggered ahead of each billing close. For every enabled `AlertRule`, it recomputes the projection (§1), checks the configured threshold, and — if crossed — writes an `AlertEvent` and delivers the alert, but only if no `AlertEvent` already exists for that `(rule, threshold, billing_period)`. The activity feed reads from `AlertEvent`.

**Rationale**: SC-003 requires alerts to precede invoice issuance; a job tied to "at least daily and before close" guarantees that. FR-014 requires no duplicate alerts for the same threshold in a period; keying dedup on `(rule, threshold, period)` in the durable event log enforces exactly-once per threshold per period and survives job restarts. FR-015 requires a record of what/when, which the same `AlertEvent` rows provide.

**Alternatives considered**:

- _Real-time alerting on every usage event_: rejected — needs a streaming pipeline this feature does not own, and the spec's projection is periodic anyway.
- _In-memory dedup_: rejected — would re-fire after a restart, violating FR-014.

---

## 7. Alert delivery channels (FR-013) **(scoped by spec Assumptions)**

**Decision**: Email plus in-app notification. Email goes through the existing transactional email provider; in-app notifications are written to a notification store the dashboard already reads.

**Rationale**: The spec Assumptions fix v1 channels to email and in-app and explicitly defer SMS/Slack/webhook. Reusing existing delivery paths avoids building new infrastructure.

**Alternatives considered**: SMS, Slack, webhooks — deferred per Assumptions; the `AlertRule.channels` field leaves room to add them later without a schema rework.

---

## 8. Invoice export format (FR-018) **(scoped by spec Assumptions)**

**Decision**: Structured CSV export of invoice data (one row per line item, with invoice-level columns repeated or a header block), suitable for import into finance/accounting tools. The existing human-readable invoice document (PDF) is reused and linked, not regenerated.

**Rationale**: Assumptions scope export to a structured data format for reconciliation and reuse of the existing invoice document. CSV is the lowest-friction, universally importable format for finance teams and satisfies "machine-readable" (FR-018).

**Alternatives considered**:

- _Custom JSON_: viable for programmatic use but less directly consumable by finance spreadsheets; CSV chosen as the default, JSON notable as an easy future addition.
- _Generating a new PDF layout_: rejected — out of scope per Assumptions (reuse the existing invoice document).

---

## 9. Access control (FR-022)

**Decision**: Restrict every billing endpoint and the dashboard route to the organization **admin** role and an optional **billing** role; all other members receive 403 and never see billing data.

**Rationale**: Implements FR-022 and the Assumptions (only admins and an optional billing role see billing). Reuses the platform's existing role mechanism rather than inventing authorization.

**Alternatives considered**: exposing read-only usage to all members — rejected; billing data is sensitive and the spec restricts it.

---

## 10. Data freshness / staleness signaling (FR-006)

**Decision**: The metering client records the timestamp of the most recent usage data it read; the overview response includes `data_as_of` and a `stale` flag set when that timestamp is older than the freshness window or the metering source is unreachable. The UI shows "as of [time]" and a clear warning when stale, and avoids presenting a confident projection on stale data.

**Rationale**: FR-006 and the Edge Cases require the dashboard to indicate staleness rather than imply confidence. Surfacing `data_as_of` turns a silent risk into an explicit, honest signal.

**Alternatives considered**: failing the page when metering is unavailable — rejected; a degraded-but-honest view (last known data, clearly stamped) is more useful to an admin than an error.

---

## 11. Technology stack **(demo assumption)**

**Decision**: Python 3.12 + FastAPI backend; PostgreSQL 16 for durable billing data; a scheduled worker for the projection/alert job; React/TypeScript dashboard; pytest + httpx and Playwright for tests.

**Rationale**: Read-heavy aggregation, a periodic job, and a dashboard map cleanly onto this mainstream, container-friendly stack. It matches the baseline of the sibling example (`001-tenant-rate-limiting`) so the two demo specs stay coherent. **This is a reasonable default for a tech-agnostic spec, not an existing-codebase constraint** — substitute the host platform's real stack if this were a real adoption; the design (single-pass reconciliation, run-rate projection, durable alert-event dedup) is stack-independent.

**Alternatives considered**: Node/TypeScript end-to-end, Go backend — equally valid; none changes the architecture.

---

## Resolved unknowns summary

| Open question                      | Resolution                                                                                |
| ---------------------------------- | ----------------------------------------------------------------------------------------- |
| End-of-period projection method    | Linear run-rate extrapolation, overage split out, low-confidence early in period          |
| Per-team vs account reconciliation | Single aggregation pass; explicit `unattributed` bucket; parts assert-equal the whole     |
| Aggregation latency for big orgs   | Materialize current-period per-team aggregate; historical periods stored once             |
| Charge-change drivers              | Per-(team, dimension) deltas ranked by absolute contribution to the change                |
| Mid-cycle plan change              | Split at change boundary: past usage at old plan, projection at new plan                  |
| Alert timing + dedup               | Scheduled job (daily + before close); dedup on `(rule, threshold, period)` in durable log |
| Alert channels                     | Email + in-app (SMS/Slack/webhook deferred)                                               |
| Invoice export format              | Structured CSV; reuse existing invoice PDF                                                |
| Access control                     | Admin + optional billing role; 403 otherwise                                              |
| Data staleness                     | `data_as_of` + `stale` flag; honest degraded view                                         |
| Stack                              | Python/FastAPI + Postgres + scheduled worker + React (demo assumption)                    |

No `NEEDS CLARIFICATION` markers remain.
