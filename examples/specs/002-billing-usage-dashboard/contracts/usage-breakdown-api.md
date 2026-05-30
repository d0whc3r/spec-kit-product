# Contract: Usage Breakdown API (US2)

Read-only endpoint backing the "why did charges change?" panel: per-team usage for the
current period (with an explicit unattributed bucket that reconciles to the account
total) and a period-over-period comparison that ranks the drivers of any change.

**Covers**: FR-007, FR-008, FR-009, FR-010, FR-023, FR-021 (empty state), SC-006

---

## GET /billing/usage-by-team

Per-team usage for a period. Defaults to the current period; accepts an optional `period` for closed periods. Org resolved from session (FR-022).

**Authorization**: organization admin or billing role. Others -> `403`.

### 200 Response

```json
{
  "currency": "USD",
  "period": "2026-05",
  "account_total": { "charges": "562.00", "by_dimension": { "api_requests": 820000, "seats": 42 } },
  "teams": [
    {
      "team_id": "t_1",
      "team_name": "Payments",
      "charges": "300.00",
      "share": 0.534,
      "by_dimension": { "api_requests": 500000, "seats": 20 }
    },
    {
      "team_id": "t_2",
      "team_name": "Search",
      "charges": "180.00",
      "share": 0.32,
      "by_dimension": { "api_requests": 250000, "seats": 15 }
    }
  ],
  "unattributed": {
    "charges": "82.00",
    "share": 0.146,
    "by_dimension": { "api_requests": 70000, "seats": 7 }
  }
}
```

Reconciliation invariant (SC-006, FR-010): `sum(teams[].charges) + unattributed.charges == account_total.charges`, and likewise per dimension. The response is computed from a single aggregation pass (research §2) so the assertion always holds. Unattributed usage is always present as its own labeled bucket, never dropped.

### 200 Response (empty state — no team-attributable usage)

```json
{
  "currency": "USD",
  "period": "2026-05",
  "account_total": { "charges": "0.00", "by_dimension": {} },
  "teams": [],
  "unattributed": { "charges": "0.00" },
  "empty_state": "no_team_usage"
}
```

Drives the usage-by-team empty state (FR-021, SC-005).

---

## GET /billing/period-comparison

Compares a period against the prior one and ranks the drivers of the change (FR-008, FR-009).

Query: `period` (defaults to current), compared against the immediately preceding period.

### 200 Response

```json
{
  "currency": "USD",
  "current_period": "2026-05",
  "previous_period": "2026-04",
  "current_total": "562.00",
  "previous_total": "410.00",
  "change_amount": "152.00",
  "change_pct": 0.371,
  "drivers": [
    {
      "team_id": "t_1",
      "team_name": "Payments",
      "dimension": "api_requests",
      "change_amount": "110.00",
      "change_pct": 0.58,
      "direction": "increase"
    },
    {
      "team_id": null,
      "team_name": "Unattributed",
      "dimension": "api_requests",
      "change_amount": "30.00",
      "change_pct": 0.4,
      "direction": "increase"
    }
  ]
}
```

Rules:

- `drivers` is ranked by absolute `change_amount` (research §4) so the largest contributors to the bill change appear first; `change_pct` is context, not the sort key.
- Renamed/deleted teams retain their stored `team_name` for the period they had usage (Edge Case).
- A decrease is represented with `direction: "decrease"` and a negative `change_amount`.

### Errors (both endpoints)

| Status | When                                                                    |
| ------ | ----------------------------------------------------------------------- |
| `401`  | Not authenticated                                                       |
| `403`  | Lacks admin/billing role (FR-022)                                       |
| `404`  | Requested `period` predates retained history (Assumptions: no backfill) |
