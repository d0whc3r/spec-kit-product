# Quickstart: Self-Serve Billing Usage Dashboard

How to run and validate the feature locally. Each section maps to a prioritized user
story so the slices can be verified independently.

## Prerequisites

- Python 3.12, PostgreSQL 16, Node 20 (dashboard)
- Backend deps installed; Alembic migrations applied (creates `plan`, `invoice`, `invoice_line_item`, `alert_rule`, `alert_event`, `usage_aggregate`, `usage_projection`)
- A reachable metering source (or a seeded fixture standing in for it) and the existing transactional email + in-app notification paths
- Env: `DATABASE_URL`, `METERING_URL`, `EMAIL_PROVIDER_*`, `FRESHNESS_WINDOW_MINUTES`

```bash
cd backend
alembic upgrade head
uvicorn src.api.app:app --reload          # APIs
python -m src.jobs.projection_alert_job   # run the scheduled job once, on demand
```

## Validate P1 — Cost and projection at a glance

1. Seed a test org partway through its cycle with usage below allowance.
2. `GET /billing/overview` as an admin -> plan, per-dimension `consumed` vs `allowance`, and a `projection` whose `included_amount` and `projected_overage_amount` are **separate**, with `basis_as_of` set.
3. Push the run-rate above an allowance -> `projected_overage_amount > 0` and `overage_by_dimension` lists the offending dimension (AS1.2).
4. Switch the org to a flat plan -> `projected_overage_amount` is `"0.00"`, `overage_by_dimension` is `[]` (AS1.3).
5. Make the metering source lag past `FRESHNESS_WINDOW_MINUTES` -> response has `stale: true` and the panel shows "as of ..." with a warning (FR-006).

Verifies: AS1.1–1.3, FR-001/002/003/004/005/006/023.

## Validate P2 — Explain why charges changed

1. Seed usage across several teams plus some usage with `team_id = null`.
2. `GET /billing/usage-by-team` -> each team's charges and share, an `unattributed` bucket, and `account_total`. Assert `sum(teams) + unattributed == account_total` per dimension (SC-006, FR-010).
3. Seed a prior period with lower usage, then `GET /billing/period-comparison` -> `change_amount` and a `drivers` list ranked by absolute contribution; the biggest team/dimension increase is first (FR-008, FR-009).
4. Rename a team that had prior-period usage -> the comparison still shows its old `team_name` for that period (Edge Case).
5. (Empty) For an org with no team-attributable usage -> `empty_state: "no_team_usage"` (FR-021).

Verifies: AS2.1–2.3, FR-007/008/009/010, SC-006.

## Validate P3 — Alerts before the invoice

1. `PUT /billing/alerts` with `{ enabled: true, threshold: { type: "percent_of_allowance", value: 90 }, channels: ["email","in_app"] }`.
2. Drive projected usage past 90% of allowance, run `projection_alert_job` -> an `AlertEvent` is written, email + in-app delivered, and `GET /billing/alerts` shows it in `recent_activity`. Confirm `sent_at` precedes the period's invoice `issued_at` (SC-003, FR-013).
3. Run the job again without changing usage -> **no** duplicate alert for the same `(rule, period, threshold)` (FR-014, AS3.2).
4. `PUT` `{ enabled: false }`, re-run the job past threshold -> no alert sent (FR-011, AS3.3).

Verifies: AS3.1–3.3, FR-011/012/013/014/015, SC-003.

## Validate P4 — Invoice history and export

1. Seed several past invoices with mixed statuses (paid, pending, failed, refunded).
2. `GET /billing/invoices` -> reverse-chronological list with date, period, total, and status (FR-016).
3. `GET /billing/invoices/{id}` -> line-item detail (FR-017).
4. `GET /billing/invoices/export?invoice_ids=...&format=csv` -> a CSV with one row per line item, amounts in account currency; complete the flow (list -> select -> export) in under 1 minute and 3 actions (SC-004, FR-018).

Verifies: AS4.1–4.3, FR-016/017/018, SC-004.

## Validate P5 — Empty states for new customers

1. Create a brand-new org: no usage this period, no invoices, no team usage.
2. `GET /billing/overview` -> `usage: []`, `projection: null`, `empty_state: "no_usage_yet"`.
3. `GET /billing/invoices` -> `invoices: []`, `empty_state: "no_invoices_yet"`.
4. `GET /billing/usage-by-team` -> `empty_state: "no_team_usage"`.
5. Load the dashboard -> every panel renders a purposeful empty state with a next step; none is blank or shows an error (SC-005).

Verifies: AS5.1–5.3, FR-019/020/021, SC-005.

## Access-control check (FR-022)

As a non-admin, non-billing member, call every endpoint above -> all return `403`; the dashboard route is not reachable. As an admin of org A, no parameter exposes org B's data (session-scoped `org_id`).

## Reconciliation check (SC-006)

For several orgs of varying size, assert that `GET /billing/usage-by-team` satisfies `sum(teams) + unattributed == account_total` for every dimension. A property test over randomized usage fixtures (including null-team usage and late-arriving records) should never find a discrepancy, because both sides come from one aggregation pass.
