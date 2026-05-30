# Phase 1 Data Model: Per-Tenant API Rate Limiting

Entities derive from the spec's Key Entities and Functional Requirements. Durable
entities live in PostgreSQL; live counters live in Redis (ephemeral, reconstructable).

---

## Tenant (Customer Organization)

The unit limits apply to. Assumed to already exist (spec Assumptions); referenced here, not owned by this feature.

| Field       | Type          | Notes                                                                |
| ----------- | ------------- | -------------------------------------------------------------------- |
| `tenant_id` | UUID / string | Stable identity used to attribute requests (FR-001) and key counters |

Relationships: one Tenant has zero-or-one `RateLimitPolicy` override and many `LimitChangeAuditRecord`.

---

## RateLimitPolicy

The configurable limits for a tenant (FR-012). Absence of a row means the tenant uses platform defaults (FR-013).

| Field                    | Type         | Rules                                                          |
| ------------------------ | ------------ | -------------------------------------------------------------- |
| `tenant_id`              | FK -> Tenant | Primary key; unique per tenant                                 |
| `burst_limit_per_minute` | integer      | > 0; requests allowed per one-minute window (FR-002)           |
| `monthly_quota`          | integer      | > 0; accepted requests allowed per UTC calendar month (FR-003) |
| `updated_at`             | timestamptz  | UTC; set on every change                                       |
| `updated_by`             | actor ref    | Last admin to change (mirrors latest audit row)                |

Platform defaults (config, not a row): `DEFAULT_BURST_LIMIT_PER_MINUTE`, `DEFAULT_MONTHLY_QUOTA`.

**Effective policy resolution**: `policy_store.get(tenant_id)` returns the row if present, else the configured defaults. Result cached in Redis; cache invalidated on write (FR-015).

Validation: both values must be positive integers. An admin lowering a value below current usage is allowed; the tenant is then over-limit for the rest of the window (Edge Case, FR-014).

---

## UsageCounter (Redis, ephemeral)

Live consumption for a tenant. Not a stored entity — reconstructable from traffic; modeled as Redis keys.

| Key                                 | Meaning                                | TTL / reset                        |
| ----------------------------------- | -------------------------------------- | ---------------------------------- |
| `rl:{tenant_id}:min:{yyyymmddhhmm}` | accepted count in the active minute    | 60s TTL -> implicit reset (FR-009) |
| `rl:{tenant_id}:mon:{yyyymm}`       | accepted count in the active UTC month | rolls at month boundary (FR-010)   |

State derived for the dashboard / usage API:

- `consumed_this_month` = value of the month key (0 if absent)
- `monthly_quota` = effective policy quota
- `remaining_this_month` = max(0, quota − consumed)
- `quota_resets_at` = first instant of next UTC month
- `burst_limit_per_minute` = effective policy burst limit

Counting rule: only **accepted** requests increment counters (FR-004). A request rejected for being over-limit does not consume quota.

---

## LimitChangeAuditRecord

Immutable history of every limit change (FR-017, SC-007).

| Field               | Type           | Rules                              |
| ------------------- | -------------- | ---------------------------------- |
| `id`                | UUID           | PK                                 |
| `tenant_id`         | FK -> Tenant   | Affected tenant                    |
| `actor`             | actor ref      | Admin who made the change (FR-017) |
| `changed_at`        | timestamptz    | UTC, server-assigned               |
| `old_burst_limit`   | integer / null | Previous value (null if first set) |
| `new_burst_limit`   | integer        | New value                          |
| `old_monthly_quota` | integer / null | Previous value (null if first set) |
| `new_monthly_quota` | integer        | New value                          |

Constraints: append-only (no update/delete); written in the same DB transaction as the `RateLimitPolicy` change so a policy change can never exist without its audit row.

---

## RateLimitDecision (transient, per request)

Computed by the limiter; not persisted. Shapes the response.

| Field                 | Type                          | Notes                                                           |
| --------------------- | ----------------------------- | --------------------------------------------------------------- |
| `allowed`             | boolean                       | Whether the request proceeds                                    |
| `binding_limit`       | enum `{none, burst, monthly}` | Which limit blocked it (FR-007, FR-008)                         |
| `retry_after_seconds` | integer / null                | Seconds to wait; longer of the two waits when both hit (FR-008) |
| `limit_value`         | integer                       | The limit that was hit                                          |
| `window_resets_at`    | timestamptz                   | Minute boundary or month boundary                               |

---

## Entity relationships

```text
Tenant (1) ──< (0..1) RateLimitPolicy        # override; absent => defaults
Tenant (1) ──< (0..*) LimitChangeAuditRecord  # full change history
Tenant (1) ──< (2)    UsageCounter (Redis)    # one minute key + one month key, ephemeral
RateLimitDecision                              # transient per-request, not stored
```

## Mapping to functional requirements

| Entity / field                         | Requirements                           |
| -------------------------------------- | -------------------------------------- |
| Tenant.tenant_id                       | FR-001, FR-011                         |
| RateLimitPolicy.burst_limit_per_minute | FR-002, FR-009, FR-012, FR-013         |
| RateLimitPolicy.monthly_quota          | FR-003, FR-010, FR-012, FR-013         |
| UsageCounter keys                      | FR-004, FR-009, FR-010, FR-018, FR-022 |
| RateLimitDecision                      | FR-005, FR-006, FR-007, FR-008         |
| LimitChangeAuditRecord                 | FR-014, FR-017                         |
| (admin authz, not data)                | FR-016                                 |
| Usage derivations                      | FR-018, FR-019, FR-020, FR-021         |
