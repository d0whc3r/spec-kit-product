# Feature Specification: Per-Tenant API Rate Limiting

**Feature Branch**: `001-tenant-rate-limiting`

**Created**: 2026-05-29

**Status**: Draft

**Input**: User description: "Add per-tenant API rate limiting so each customer organization has a configurable monthly request quota and a per-minute burst limit, returns clear 429 responses with a Retry-After header, shows current usage in the dashboard, and lets admins raise a tenant's limit without a deploy."

## Clarifications

### Session 2026-05-29

- Q: At what share of the monthly quota should the dashboard "approaching limit" warning appear? → A: 80% of the monthly quota.
- Q: What peak scale should the design and SC-006 load tests target? → A: ~5,000 requests/sec aggregate across thousands of tenants.

## User Scenarios & Testing _(mandatory)_

### User Story 1 - Per-minute burst protection (Priority: P1)

A customer organization sends a sudden spike of API requests. The platform caps how many requests that organization can make within any single minute. Once the cap is reached, further requests in that minute are rejected with a clear 429 response and a Retry-After header telling the caller how many seconds to wait. Other organizations are unaffected by this one's spike.

**Why this priority**: This is the core protection that keeps a single tenant from degrading service for everyone. It delivers immediate value on its own: even without monthly quotas, dashboards, or admin tooling, the platform is protected from bursts and abusive callers receive a clear, actionable response.

**Independent Test**: Configure a small per-minute burst limit for a test tenant, send requests above that limit within one minute, and confirm the over-limit requests receive a 429 with a Retry-After header while a second tenant's requests in the same window succeed normally.

**Acceptance Scenarios**:

1. **Given** a tenant with a per-minute burst limit of N, **When** the tenant makes N requests within the current minute, **Then** all N requests are accepted.
2. **Given** a tenant that has already used its full per-minute burst limit, **When** it makes one more request in the same minute, **Then** the request is rejected with a 429 response and a Retry-After header indicating the seconds until the next minute window.
3. **Given** two different tenants, **When** one tenant exhausts its burst limit, **Then** the other tenant's requests continue to be accepted up to its own limit.
4. **Given** a tenant that was rate limited, **When** the next minute window begins, **Then** the tenant can make requests again up to its burst limit.

---

### User Story 2 - Monthly request quota (Priority: P2)

Each customer organization has a configurable total number of requests it may make per calendar month. As requests accumulate, the remaining quota decreases. When the monthly quota is exhausted, further requests are rejected with a 429 response and a Retry-After header pointing to the start of the next monthly period. At the start of the next month, the quota resets.

**Why this priority**: Monthly quotas enforce fair use and align consumption with each customer's plan. It builds on the enforcement mechanism from P1 but operates on a longer window, so it can be added once burst protection exists.

**Independent Test**: Set a low monthly quota for a test tenant, consume requests until the quota is reached, confirm subsequent requests receive a 429 with a Retry-After header pointing to the next month, and confirm the counter resets at the month boundary.

**Acceptance Scenarios**:

1. **Given** a tenant with a monthly quota of M and zero usage this month, **When** it makes requests, **Then** each accepted request reduces the remaining monthly quota by one.
2. **Given** a tenant that has consumed its full monthly quota, **When** it makes another request in the same month, **Then** the request is rejected with a 429 response and a Retry-After header indicating the time until the next monthly reset.
3. **Given** a tenant that exhausted its monthly quota, **When** the next monthly period begins, **Then** its remaining monthly quota is restored to the full configured amount.
4. **Given** a request that would exceed both the burst limit and the monthly quota, **When** it is rejected, **Then** the 429 response clearly indicates which limit was hit.

---

### User Story 3 - Admins raise a tenant's limit without a deploy (Priority: P3)

A support or operations admin needs to raise a customer's per-minute burst limit or monthly quota, for example because the customer upgraded their plan or hit a temporary spike during an event. The admin changes the tenant's limit through an administrative interface, and the new limit takes effect for that tenant's subsequent requests without any code change, deploy, or service restart.

**Why this priority**: This removes a costly operational bottleneck (waiting on an engineering deploy to adjust a single customer's limits). It depends on enforcement (P1/P2) already reading limits from a configurable source.

**Independent Test**: With a tenant actively being rate limited at its current limit, have an admin raise that tenant's limit, then confirm the tenant's subsequent requests are accepted up to the new limit shortly afterward, with no deploy or restart performed.

**Acceptance Scenarios**:

1. **Given** a tenant being rejected at its current burst limit, **When** an admin raises that tenant's burst limit, **Then** the tenant's subsequent requests are accepted up to the new limit without a deploy or restart.
2. **Given** a tenant approaching its monthly quota, **When** an admin raises that tenant's monthly quota, **Then** the tenant's remaining quota increases accordingly and is reflected on the next request.
3. **Given** an admin changes a tenant's limit, **When** the change is saved, **Then** the change is recorded with who made it, when, and the old and new values.
4. **Given** a non-admin user, **When** they attempt to change a tenant's limit, **Then** the change is denied.

---

### User Story 4 - Tenant sees current usage in the dashboard (Priority: P3)

A customer organization's user opens the dashboard and sees their current API usage: how much of the monthly quota has been consumed, how much remains, when the quota resets, and their configured per-minute burst limit. This lets the customer understand their consumption and anticipate when they may hit a limit.

**Why this priority**: Visibility reduces surprise 429s and support load, and turns the limits into something customers can self-manage around. It depends on the usage tracking introduced by P1/P2 but is not required for enforcement to work.

**Independent Test**: Generate a known amount of API traffic for a test tenant, open that tenant's dashboard, and confirm the displayed consumed count, remaining quota, reset date, and burst limit match the traffic generated within the freshness window.

**Acceptance Scenarios**:

1. **Given** a tenant that has made some requests this month, **When** a user of that tenant views the dashboard, **Then** they see the monthly quota, amount consumed, amount remaining, and the date the quota resets.
2. **Given** a tenant viewing the dashboard, **When** they look at their limits, **Then** they see their current per-minute burst limit.
3. **Given** a tenant whose usage is approaching the monthly quota, **When** they view the dashboard, **Then** the dashboard visibly indicates that they are nearing the limit.
4. **Given** a user belonging to one tenant, **When** they view the dashboard, **Then** they see only their own organization's usage and never another organization's.

---

### Edge Cases

- What happens when a request cannot be attributed to a tenant (missing or invalid credentials)? Such requests are not counted against any tenant's limits and are handled by the existing authentication path, not by rate limiting.
- How does the system handle a tenant with no explicitly configured limit? A default burst limit and default monthly quota apply until an admin sets specific values.
- What happens at the exact boundary of a minute or month window while requests are in flight? Counting is anchored to a consistent clock so that a request is attributed to exactly one window.
- How does the system behave if usage tracking is temporarily unavailable? The platform must choose a documented fail mode (fail-open to preserve availability or fail-closed to preserve protection); see Assumptions.
- What happens when an admin lowers a limit below a tenant's current usage? The tenant is treated as over the limit for the remainder of the current window and receives 429 responses until the window resets or usage falls below the new limit.
- How are concurrent requests counted so the limit is enforced accurately under high concurrency without double counting or undercounting?
- What does Retry-After contain when the monthly quota is exhausted but the per-minute window is still open? It reflects the longer wait (time until the monthly reset), since that is the binding constraint.

## Requirements _(mandatory)_

### Functional Requirements

- **FR-001**: System MUST attribute every authenticated API request to exactly one customer organization (tenant).
- **FR-002**: System MUST enforce a per-tenant, per-minute burst limit, rejecting requests that exceed the limit within the current one-minute window.
- **FR-003**: System MUST enforce a per-tenant monthly request quota, rejecting requests once the tenant's accepted requests for the current monthly period reach the quota.
- **FR-004**: System MUST count each accepted request against both the tenant's per-minute burst counter and its monthly quota counter.
- **FR-005**: System MUST reject over-limit requests with a 429 (Too Many Requests) response.
- **FR-006**: Every 429 response MUST include a Retry-After header indicating how long the caller should wait before retrying.
- **FR-007**: Every 429 response MUST clearly communicate, in human-readable form, that a rate limit was exceeded and which limit was hit (per-minute burst versus monthly quota).
- **FR-008**: When a request would violate both the burst limit and the monthly quota, the Retry-After value MUST reflect the longer of the two waits and the response MUST indicate the monthly quota as the binding limit.
- **FR-009**: System MUST reset each tenant's per-minute burst counter at the start of every new minute window.
- **FR-010**: System MUST reset each tenant's monthly quota counter at the start of every new monthly period.
- **FR-011**: System MUST isolate tenants so that one tenant's request volume never consumes or affects another tenant's limits.
- **FR-012**: System MUST apply configurable per-tenant limit values for both the burst limit and the monthly quota.
- **FR-013**: System MUST apply documented default limit values to any tenant that has no explicitly configured limits.
- **FR-014**: System MUST allow authorized admins to change (including raise) a tenant's burst limit and monthly quota.
- **FR-015**: Changes to a tenant's limits MUST take effect for that tenant's subsequent requests without requiring a code change, deploy, or service restart.
- **FR-016**: System MUST restrict limit-changing actions to authorized admins and deny attempts by unauthorized users.
- **FR-017**: System MUST record an audit trail for every limit change capturing who made the change, when, the affected tenant, and the previous and new values.
- **FR-018**: System MUST track and expose, per tenant, the current monthly consumption, the remaining monthly quota, the date and time the monthly quota next resets, and the configured per-minute burst limit.
- **FR-019**: System MUST present a tenant's own current usage in the dashboard, including consumed, remaining, reset date, and burst limit.
- **FR-020**: Dashboard usage MUST be scoped to the viewing user's own organization and MUST NOT expose any other organization's usage.
- **FR-021**: The dashboard MUST visibly indicate when a tenant is approaching its monthly quota, where "approaching" means consumption has reached 80% or more of the monthly quota.
- **FR-022**: System MUST enforce limits accurately under concurrent requests, neither double counting nor undercounting accepted requests.

### Key Entities _(include if feature involves data)_

- **Tenant (Customer Organization)**: The unit that limits are applied to. Each tenant has an identity used to attribute incoming requests, an effective rate limit policy, and usage counters.
- **Rate Limit Policy**: The configurable limits for a tenant, comprising a per-minute burst limit and a monthly request quota. May be tenant-specific or fall back to platform defaults.
- **Usage Counter**: The current consumption for a tenant, including the count within the active minute window, the count within the active monthly period, and the timestamps at which each window resets.
- **Limit Change Audit Record**: A historical record of each modification to a tenant's limits, including the actor, timestamp, affected tenant, and previous and new values.

## Success Criteria _(mandatory)_

### Measurable Outcomes

- **SC-001**: 100% of requests that exceed a tenant's per-minute burst limit receive a 429 response that includes a Retry-After header.
- **SC-002**: 100% of requests made after a tenant's monthly quota is exhausted receive a 429 response that includes a Retry-After header pointing to the next monthly reset.
- **SC-003**: A tenant's request volume has no measurable effect on any other tenant's accepted request rate or remaining quota.
- **SC-004**: An admin can raise a tenant's limit and the new limit governs that tenant's requests within 1 minute, with no deploy or restart performed.
- **SC-005**: The usage shown in the dashboard matches actual consumption within a freshness window of 1 minute.
- **SC-006**: Enforced counts are accurate within 1% of true accepted-request counts even under peak concurrent load.
- **SC-007**: 100% of limit changes appear in the audit trail with actor, timestamp, tenant, and old and new values.
- **SC-008**: After a feature rollout, the share of customer support contacts asking for limit increases that require engineering involvement drops to zero, because admins resolve them directly.
- **SC-009**: Callers receiving a 429 can determine, from the response alone, which limit they hit and when they may retry, without contacting support.

## Assumptions

- "Admins" who raise limits are internal platform staff (support or operations roles), not the customer organization's own users, since allowing a customer to lift their own paid quota would defeat the purpose of the limits.
- The monthly quota period aligns to the calendar month in a single consistent time zone (UTC) unless a per-tenant billing cycle is later specified.
- When a monthly quota is exhausted, the tenant is hard-blocked with 429 responses until the next reset; there is no automatic overage allowance or pay-as-you-go burst beyond the quota in this version.
- All authenticated API requests count toward the limits; unauthenticated or failed-authentication requests are handled by the existing authentication layer and are out of scope for counting.
- The per-minute burst limit is evaluated against a one-minute window; the exact windowing strategy (fixed versus sliding) is an implementation choice that must still satisfy the accuracy criterion (SC-006).
- If the usage-tracking mechanism is temporarily unavailable, the platform fails open (allows requests) to preserve customer availability, and this behavior is monitored; a fail-closed alternative can be chosen during planning if protection is prioritized over availability.
- An existing tenant/organization identity and an existing dashboard surface are available to build on; this feature adds usage data to that dashboard rather than creating a new one.
- A mechanism already exists, or will be provided, to authenticate and authorize internal admins for the limit-management actions.
