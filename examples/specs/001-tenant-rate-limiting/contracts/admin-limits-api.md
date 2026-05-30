# Contract: Admin Limits API

Internal admin surface to read and change a tenant's limits without a deploy.
Covers FR-014, FR-015, FR-016, FR-017. Admin-only (existing internal admin auth).

## GET /admin/tenants/{tenant_id}/limits

Read the effective policy for a tenant.

**Auth**: admin role required; non-admin -> `403 Forbidden` (FR-016).

**200 response**:

```json
{
  "tenant_id": "org_123",
  "burst_limit_per_minute": 600,
  "monthly_quota": 100000,
  "source": "override", // "override" | "default"
  "updated_at": "2026-05-29T10:00:00Z",
  "updated_by": "admin_jane"
}
```

`source` is `"default"` when no per-tenant override exists (FR-013).

## PUT /admin/tenants/{tenant_id}/limits

Create or update a tenant's override. Takes effect within 1 minute, no deploy/restart (FR-015, SC-004).

**Auth**: admin role required; non-admin -> `403` (FR-016).

**Request** (`application/json`):

```json
{
  "burst_limit_per_minute": 1200,
  "monthly_quota": 250000
}
```

Validation: both fields positive integers. Lowering below current usage is permitted; the tenant is over-limit for the remainder of the active window (Edge Case).

**200 response**: the updated policy (same shape as GET). Side effects, in one DB transaction:

1. upsert `rate_limit_policy` row;
2. append a `limit_change_audit` row with actor, timestamp, tenant, old + new values (FR-017);
3. invalidate the Redis policy cache so the next request resolves the new value (FR-015).

**Error responses**:

| Status | When                            |
| ------ | ------------------------------- |
| `400`  | non-positive or missing values  |
| `403`  | caller is not an admin (FR-016) |
| `404`  | unknown tenant                  |

## Contract test scenarios

| #   | Given                                  | When                           | Then                                                               | Maps to               |
| --- | -------------------------------------- | ------------------------------ | ------------------------------------------------------------------ | --------------------- |
| 1   | tenant rejected at current burst limit | admin PUT raises burst limit   | subsequent requests accepted to new limit within 1 min, no restart | AS3.1, FR-015, SC-004 |
| 2   | tenant near monthly quota              | admin PUT raises monthly quota | remaining increases, reflected on next request                     | AS3.2                 |
| 3   | admin PUT any change                   | change saved                   | audit row exists with actor, time, old + new values                | AS3.3, FR-017, SC-007 |
| 4   | non-admin caller                       | attempts PUT                   | `403`, no change, no audit row                                     | AS3.4, FR-016         |
