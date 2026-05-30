# Contract: Billing Overview API (US1)

Read-only endpoint backing the cost-at-a-glance panel: current plan, current-period
usage vs allowance, and the projected end-of-period total with overage split out.

**Covers**: FR-001, FR-002, FR-003, FR-004, FR-005, FR-006, FR-023, FR-024, FR-019 (empty state)

---

## GET /billing/overview

Returns the current plan, per-dimension usage, and the projection for the requesting admin's organization. Org is resolved from the authenticated session; never from a query parameter (FR-022).

**Authorization**: organization admin or billing role. Others -> `403`.

### 200 Response (has usage)

```json
{
  "currency": "USD",
  "data_as_of": "2026-05-30T08:00:00Z",
  "stale": false,
  "plan": {
    "name": "Growth",
    "cycle_start": "2026-05-01",
    "cycle_end": "2026-05-31",
    "plan_changed_this_cycle": false
  },
  "usage": [
    { "dimension": "api_requests", "consumed": 820000, "allowance": 1000000, "unit": "requests" },
    { "dimension": "seats", "consumed": 42, "allowance": 50, "unit": "seats" }
  ],
  "projection": {
    "basis_as_of": "2026-05-30T08:00:00Z",
    "confidence": "normal",
    "included_amount": "499.00",
    "projected_overage_amount": "63.00",
    "projected_total": "562.00",
    "overage_by_dimension": [
      { "dimension": "api_requests", "projected_overage_units": 50000, "amount": "63.00" }
    ]
  }
}
```

Rules:

- `included_amount` and `projected_overage_amount` are always separate fields so the UI can distinguish already-paid from projected charges (FR-004).
- `projection.basis_as_of` states the date the projection is based on (FR-005).
- For a flat plan with no overage, `projected_overage_amount` is `"0.00"` and `overage_by_dimension` is `[]` (AS1.3).

### 200 Response (stale data)

```json
{
  "currency": "USD",
  "data_as_of": "2026-05-28T08:00:00Z",
  "stale": true,
  "plan": { "...": "..." },
  "usage": ["..."],
  "projection": { "confidence": "low", "...": "..." }
}
```

When `stale` is `true`, the UI shows "as of [data_as_of]" with a warning and does not present the projection as confident (FR-006).

### 200 Response (empty state — new account, no usage this period)

```json
{
  "currency": "USD",
  "data_as_of": "2026-05-30T08:00:00Z",
  "stale": false,
  "plan": { "...": "..." },
  "usage": [],
  "projection": null,
  "empty_state": "no_usage_yet"
}
```

`usage: []` with `projection: null` and `empty_state: "no_usage_yet"` drives the purposeful empty state (FR-019, SC-005) rather than a blank or error panel.

### Errors

| Status | When                                                                                                      |
| ------ | --------------------------------------------------------------------------------------------------------- |
| `401`  | Not authenticated                                                                                         |
| `403`  | Authenticated but lacks admin/billing role (FR-022)                                                       |
| `503`  | Metering source unreachable AND no last-known snapshot exists (otherwise return `200` with `stale: true`) |
