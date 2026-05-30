# Phase 0 Research: Per-Tenant API Rate Limiting

This document resolves the open technical questions for the feature. Because the
specification is implementation-agnostic and this repository has no application
codebase, each decision states the choice, the rationale, and the alternatives
considered. Choices marked **(demo assumption)** would normally be constrained by
an existing codebase or constitution.

---

## 1. Counter store and atomicity under concurrency

**Decision**: Redis 7 with atomic `INCR` + `EXPIRE` for the per-minute fixed window, and a separate `INCR` on a month-keyed counter for the quota. A small Lua script performs the read-limit-then-increment in one round trip so the check is atomic.

**Rationale**: SC-006 requires enforced counts within 1% of true accepted counts under peak concurrency. A single atomic operation on a shared store eliminates the read-modify-write race that in-process counters suffer when API replicas scale horizontally. Redis `INCR` is atomic by definition, sub-millisecond, and `EXPIRE` gives free per-minute window reset (FR-009) without a sweeper job. This satisfies the < 5 ms p95 overhead target.

**Alternatives considered**:

- _In-process counters per replica_: rejected — cannot enforce a shared limit across horizontally scaled replicas; violates tenant isolation accuracy.
- _PostgreSQL row-level counter with `SELECT ... FOR UPDATE`_: rejected — lock contention at thousands of req/s adds latency well beyond 5 ms and risks deadlocks on hot tenants.
- _Token bucket in Redis_: viable and more burst-friendly, but fixed-window keyed to the wall-clock minute is simpler, directly matches the spec's "per-minute window" language (FR-002, FR-009), and keeps `Retry-After` trivially computable (seconds to the next minute boundary).

---

## 2. Windowing strategy (fixed vs sliding)

**Decision**: Fixed one-minute window anchored to the UTC wall clock for the burst limit; fixed calendar-month window (UTC) for the quota.

**Rationale**: The spec explicitly anchors counting to "a consistent clock" (Edge Cases) and aligns the monthly period to the UTC calendar month (Assumptions). A fixed window keyed `tenant:{id}:min:{yyyymmddhhmm}` and `tenant:{id}:mon:{yyyymm}` makes each request attributable to exactly one window (resolves the boundary edge case), makes resets implicit (key rolls over), and keeps `Retry-After` deterministic.

**Trade-off accepted**: fixed windows allow up to 2x the limit across a window boundary (classic edge burst). SC-006's 1% accuracy bar is about counting accuracy, not boundary smoothing, so this is acceptable for v1. A sliding-window-log upgrade is noted as a future option if boundary bursts become a problem.

**Alternatives considered**: sliding window log (more accurate boundaries, higher memory and complexity) — deferred.

---

## 3. Binding-limit selection and Retry-After

**Decision**: On rejection, evaluate the monthly quota first. If the monthly quota is exhausted, the response names the monthly limit and `Retry-After` = seconds until the next UTC month start. Otherwise the per-minute limit is named and `Retry-After` = seconds until the next minute boundary. When both are violated, the monthly (longer) wait wins.

**Rationale**: Directly implements FR-008 and the Retry-After edge case — the binding constraint is the longer wait, and surfacing the wrong (shorter) wait would cause the caller to retry into another 429.

**Alternatives considered**: returning both limits in structured fields and letting the caller decide — kept as additional response body fields, but the header reflects the single binding wait per the HTTP `Retry-After` contract.

---

## 4. Policy storage, defaults, and live updates

**Decision**: A `rate_limit_policy` table in PostgreSQL holds per-tenant overrides; platform defaults live in configuration. The effective policy (override or default) is resolved by `policy_store` and cached in Redis with a short TTL plus explicit invalidation on admin write.

**Rationale**: FR-012/FR-013 require configurable per-tenant values with documented defaults; FR-015 requires changes to take effect with no deploy/restart. Writing the override to Postgres and deleting the Redis cache key means the next request re-resolves the new value — well within the SC-004 one-minute target. Durable storage also underpins the audit trail.

**Alternatives considered**:

- _Config-file-only limits_: rejected — changing a config file is a deploy, violating FR-015.
- _Redis-only policy_: rejected — not durable; the audit trail and defaults belong in a system of record.

---

## 5. Audit trail

**Decision**: Append-only `limit_change_audit` table written in the same transaction as the policy update, capturing actor, timestamp (UTC), tenant, old values, new values.

**Rationale**: FR-017 and SC-007 require a complete record of every change with old/new values. Same-transaction write guarantees no policy change exists without a matching audit row (no partial writes).

**Alternatives considered**: emitting audit events to a log pipeline only — rejected as the sole mechanism because SC-007 demands 100% coverage queryable by tenant; a durable table is the source of truth (log shipping can be added downstream).

---

## 6. Admin authorization

**Decision**: Reuse the existing internal admin auth mechanism (per spec Assumptions, one exists or will be provided). The admin limits endpoints require an admin role; non-admins get 403 (FR-016).

**Rationale**: The spec assumes an existing authn/authz path for internal admins and an existing tenant identity. Building a new auth system is out of scope.

**Alternatives considered**: none — building bespoke auth contradicts the spec's stated assumption and would be scope creep.

---

## 7. Fail mode when the counter store is unavailable

**Decision**: Fail **open** (allow the request) and emit a monitored alert/metric, per the spec's documented default.

**Rationale**: Assumptions state the platform fails open to preserve customer availability, with monitoring. This is a deliberate availability-over-protection choice for v1; a fail-closed flag is left as a config-level future option.

**Alternatives considered**: fail closed (reject on store outage) — preserves protection but turns a Redis blip into a full outage for all tenants; rejected for v1 but documented as switchable.

---

## 8. Tenant resolution

**Decision**: A `tenant_resolver` maps the authenticated principal on each request to exactly one tenant id (FR-001). Requests with missing/invalid credentials are handled by the existing auth layer and never reach the limiter, so they count against no tenant.

**Rationale**: Implements FR-001 and the "unattributable request" edge case cleanly by ordering: authenticate first, resolve tenant, then rate-limit.

---

## 9. Technology stack **(demo assumption)**

**Decision**: Python 3.12 + FastAPI backend (ASGI middleware is the natural single enforcement point for all API routes); React/TypeScript for the dashboard usage panel; pytest + httpx + fakeredis for tests; Playwright for the dashboard E2E.

**Rationale**: FastAPI's ASGI middleware lets enforcement wrap every route in one place. The stack is mainstream, container-friendly, and matches the web-application structure. **This is a reasonable default for a tech-agnostic spec, not an existing-codebase constraint** — substitute the host platform's real stack if this were a real adoption.

**Alternatives considered**: Node/Express, Go/chi — equally valid; the rate-limit design (atomic Redis counters, Postgres policy/audit) is stack-independent, so the choice does not affect the architecture.

---

## Resolved unknowns summary

| Open question                    | Resolution                                                  |
| -------------------------------- | ----------------------------------------------------------- |
| Counter store under concurrency  | Redis atomic INCR/EXPIRE + Lua check-and-increment          |
| Window strategy                  | Fixed minute + fixed UTC calendar month                     |
| Retry-After when both limits hit | Longer (monthly) wait; response names binding limit         |
| Live limit updates w/o deploy    | Postgres override + Redis cache invalidation                |
| Audit completeness               | Append-only table, same transaction as update               |
| Admin authz                      | Reuse existing internal admin auth; 403 for non-admins      |
| Store-unavailable fail mode      | Fail open + monitored alert (switchable)                    |
| Tenant attribution               | Authenticate -> resolve tenant -> limit                     |
| Stack                            | Python/FastAPI + Redis + Postgres + React (demo assumption) |

No `NEEDS CLARIFICATION` markers remain.
