# Implementation Plan: Per-Tenant API Rate Limiting

**Branch**: `001-tenant-rate-limiting` | **Date**: 2026-05-29 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-tenant-rate-limiting/spec.md`

## Summary

Enforce two independent rate limits per customer organization (tenant): a per-minute burst limit and a monthly request quota. Over-limit requests get a 429 with a `Retry-After` header and a human-readable reason that names the binding limit. Tenants see their own usage (consumed, remaining, reset date, burst limit) in the existing dashboard; internal admins raise a tenant's limits through an admin interface with no deploy, and every change is audited.

Technical approach: enforce at an API gateway middleware that resolves the tenant from the authenticated request, then checks two atomic counters in Redis (fixed-window per-minute key with a 60s TTL; monthly key keyed to the UTC calendar month). Policy values and the audit trail live in PostgreSQL; the effective policy is cached in Redis and invalidated on admin change so updates take effect within the SC-004 one-minute target without a restart. The dashboard reads a usage endpoint that aggregates the live counters.

> **Note on technology choices**: the spec is implementation-agnostic and this repository (a Spec Kit docs extension) has no application codebase to constrain the stack. The stack below is chosen in [research.md](./research.md) with rationale and is a reasonable default for this demo feature, not an existing-codebase constraint.

## Technical Context

**Language/Version**: Python 3.12

**Primary Dependencies**: FastAPI (ASGI middleware as the enforcement point), `redis-py` (atomic counter operations), SQLAlchemy + Alembic (policy/audit persistence), Pydantic v2 (request/response contracts)

**Storage**: Redis 7 for rate counters and the effective-policy cache (atomic `INCR`/`EXPIRE`); PostgreSQL 16 for the durable rate-limit policy table and the immutable audit trail

**Testing**: pytest + httpx (backend unit/integration, including a fakeredis-backed counter suite); Playwright (dashboard usage panel E2E)

**Target Platform**: Linux server, containerized; horizontally scaled stateless API replicas sharing one Redis and one PostgreSQL

**Project Type**: web application (backend API + existing dashboard frontend)

**Performance Goals**: rate-limit check adds < 5 ms p95 to request latency; sustain 5k req/s aggregate across replicas

**Constraints**: counters MUST be atomic under concurrency so enforced counts stay within 1% of true accepted counts (SC-006); admin limit changes MUST take effect within 1 minute (SC-004); dashboard usage fresh within 1 minute (SC-005); when the counter store is unavailable the gateway fails **open** (per spec Assumptions) and emits a monitored alert

**Scale/Scope**: thousands of tenants; 4 entities; 3 API contract surfaces (rate-limited response envelope, admin limits API, tenant usage API); 4 prioritized user stories (P1 burst, P2 monthly, P3 admin override, P3 dashboard usage)

## Constitution Check

_GATE: Must pass before Phase 0 research. Re-check after Phase 1 design._

The project constitution at `.specify/memory/constitution.md` is the **unratified template** — all principles are placeholders (`[PRINCIPLE_1_NAME]`, etc.) with no ratified content. There are therefore **no concrete gates to evaluate** against this plan.

- **Initial check (pre-Phase 0)**: PASS (vacuously — no defined principles to violate).
- **Post-design re-check (post-Phase 1)**: PASS (no new violations; design stays within the single-backend + existing-dashboard footprint, no speculative complexity).

If the constitution is later ratified (e.g. Test-First, Simplicity, Versioning principles), this plan must be re-checked against it. No entries are required in Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/001-tenant-rate-limiting/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
│   ├── ratelimit-response.md   # 429 envelope + Retry-After / headers contract
│   ├── admin-limits-api.md     # admin read/update of a tenant's policy
│   └── tenant-usage-api.md     # tenant-scoped usage read for the dashboard
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
backend/
├── src/
│   ├── models/
│   │   ├── rate_limit_policy.py   # RateLimitPolicy (burst, monthly, defaults)
│   │   ├── usage.py               # UsageSnapshot view model over live counters
│   │   └── audit.py               # LimitChangeAuditRecord
│   ├── services/
│   │   ├── tenant_resolver.py     # request -> tenant id (FR-001)
│   │   ├── limiter.py             # atomic burst + monthly counter checks (FR-002..FR-011, FR-022)
│   │   ├── policy_store.py        # effective policy w/ defaults + Redis cache (FR-012, FR-013, FR-015)
│   │   └── audit_log.py           # append-only audit writes (FR-017)
│   └── api/
│       ├── middleware.py          # ASGI enforcement layer; builds 429 envelope (FR-005..FR-008)
│       ├── admin_limits.py        # admin-only policy read/update (FR-014, FR-016)
│       └── usage.py               # tenant-scoped usage endpoint (FR-018..FR-021)
└── tests/
    ├── contract/                  # one suite per file in contracts/
    ├── integration/               # per-tenant isolation, window resets, concurrency
    └── unit/                      # limiter math, window-boundary, Retry-After selection

frontend/
├── src/
│   ├── components/
│   │   └── UsagePanel.tsx         # consumed / remaining / reset date / burst limit (FR-019, FR-021)
│   └── services/
│       └── usageClient.ts         # calls tenant-usage-api
└── tests/
    └── e2e/                       # Playwright: usage panel reflects traffic, tenant scoping (FR-020)
```

**Structure Decision**: Web-application layout (Option 2). The enforcement logic, policy store, and audit live in `backend/`; the dashboard usage view is an additive component in the existing `frontend/`. Per spec Assumptions, the dashboard and tenant identity already exist — this feature adds a usage panel and a usage endpoint rather than creating a new surface.

## Complexity Tracking

> No Constitution Check violations to justify (constitution is the unratified template). Section intentionally empty.
