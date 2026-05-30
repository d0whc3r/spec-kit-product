# Contract: Tenant Usage API

Tenant-scoped read powering the dashboard usage panel. Covers FR-018, FR-019,
FR-020, FR-021. Returns **only** the calling user's own organization's usage.

## GET /usage

**Auth**: any authenticated tenant user. The tenant is resolved from the
authenticated principal (FR-001); the path takes **no** tenant id, so a user can
never request another organization's usage (FR-020).

**200 response** (`application/json`):

```json
{
  "tenant_id": "org_123",
  "monthly_quota": 100000,
  "consumed_this_month": 81000,
  "remaining_this_month": 19000,
  "quota_resets_at": "2026-06-01T00:00:00Z",
  "burst_limit_per_minute": 600,
  "approaching_limit": true, // true when consumed >= warn threshold (FR-021)
  "as_of": "2026-05-29T10:00:30Z" // freshness; within 1 min of real usage (SC-005)
}
```

Field rules:

| Field                    | Rule                                                                                                 |
| ------------------------ | ---------------------------------------------------------------------------------------------------- |
| `consumed_this_month`    | live month counter (FR-018)                                                                          |
| `remaining_this_month`   | `max(0, monthly_quota − consumed_this_month)`                                                        |
| `quota_resets_at`        | first instant of next UTC month (FR-018)                                                             |
| `burst_limit_per_minute` | effective burst limit (FR-018)                                                                       |
| `approaching_limit`      | `true` once consumption crosses the warn threshold (e.g. 80%); drives the dashboard warning (FR-021) |
| `as_of`                  | timestamp of the read; data fresh within 1 minute (SC-005)                                           |

## Cross-tenant isolation

There is no parameter by which a caller can name a different tenant. Resolution
is server-side from the authenticated principal only (FR-020). Any future
admin-facing "view tenant X usage" must live on the admin surface, not here.

## Contract test scenarios

| #   | Given                                | When                    | Then                                            | Maps to           |
| --- | ------------------------------------ | ----------------------- | ----------------------------------------------- | ----------------- |
| 1   | tenant made some requests this month | user GET /usage         | sees quota, consumed, remaining, resets_at      | AS4.1, FR-018/019 |
| 2   | tenant viewing usage                 | reads response          | `burst_limit_per_minute` present and correct    | AS4.2             |
| 3   | consumption past warn threshold      | user GET /usage         | `approaching_limit = true`                      | AS4.3, FR-021     |
| 4   | user belongs to org A                | GET /usage              | response `tenant_id == A`; no way to read org B | AS4.4, FR-020     |
| 5   | known traffic generated              | GET /usage within 1 min | counts match within freshness window            | SC-005            |
