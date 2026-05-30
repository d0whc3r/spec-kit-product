# Quickstart: Per-Tenant API Rate Limiting

How to run and validate the feature locally. Each section maps to a prioritized
user story so the slices can be verified independently.

## Prerequisites

- Python 3.12, Redis 7, PostgreSQL 16 (all reachable from the backend)
- Backend deps installed; Alembic migrations applied (creates `rate_limit_policy`, `limit_change_audit`)
- Env: `DEFAULT_BURST_LIMIT_PER_MINUTE`, `DEFAULT_MONTHLY_QUOTA`, `REDIS_URL`, `DATABASE_URL`

```bash
cd backend
alembic upgrade head
uvicorn src.api.app:app --reload
```

## Validate P1 — Per-minute burst protection

1. Set a small burst limit for a test tenant (default applies, or PUT an override).
2. Send `N` requests within one minute as that tenant — all `200`.
3. Send one more in the same minute — `429`, header `Retry-After` ≤ 60, body `binding_limit: "burst"`.
4. As a **second** tenant, send requests in the same minute — still `200` (isolation, FR-011).
5. Wait for the next minute — first tenant is accepted again.

Verifies: AS1.1–1.4, FR-002/005/006/007/009/011.

## Validate P2 — Monthly quota

1. Set a low monthly quota for the test tenant.
2. Consume accepted requests until the quota is reached.
3. Next request -> `429`, `binding_limit: "monthly"`, `Retry-After` = seconds to first instant of next UTC month, `resets_at` = next month.
4. Force a request that breaks **both** limits -> response names `monthly` and `Retry-After` is the longer wait (FR-008).
5. (Boundary) at month rollover, the month counter key changes and remaining resets to full.

Verifies: AS2.1–2.4, FR-003/004/008/010.

## Validate P3 — Admin raises a limit without deploy

1. Drive the tenant into `429` at its current burst limit.
2. `PUT /admin/tenants/{id}/limits` as an admin, raising `burst_limit_per_minute`.
3. Within 1 minute, the tenant's requests are accepted up to the new limit — no restart performed (SC-004).
4. `GET` the audit trail: a row records actor, timestamp, tenant, old + new values (FR-017, SC-007).
5. Repeat the `PUT` as a **non-admin** -> `403`, no change, no audit row (FR-016).

Verifies: AS3.1–3.4, FR-014/015/016/017.

## Validate P3 — Tenant usage in the dashboard

1. Generate a known amount of traffic for the test tenant.
2. `GET /usage` as a user of that tenant -> `consumed_this_month`, `remaining_this_month`, `quota_resets_at`, `burst_limit_per_minute` match the traffic within 1 minute (SC-005).
3. Push consumption past the warn threshold -> `approaching_limit: true` (FR-021); the dashboard panel shows the warning.
4. As a user of a **different** org, `GET /usage` -> only that org's numbers; no parameter exposes another org (FR-020).

Verifies: AS4.1–4.4, FR-018/019/020/021.

## Concurrency / accuracy check (SC-006)

Fire a burst of concurrent requests well above the limit for one tenant and
assert the accepted count equals the limit within 1% (atomic Redis counters,
FR-022). A load script issuing > limit concurrent calls should see exactly
`limit` (±1%) `200`s and the rest `429`.

## Fail-open check

Make Redis unreachable and confirm requests are **allowed** (fail open per spec
Assumptions) and a monitoring alert/metric fires. Restore Redis and confirm
enforcement resumes.
