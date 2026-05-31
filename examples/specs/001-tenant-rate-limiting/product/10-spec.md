# Product Spec: Per-Tenant API Rate Limiting

**Feature**: Per-Tenant API Rate Limiting
**Created**: 2026-05-31
**Status**: Draft

## Headline

Every customer organization on the platform now gets a fair, predictable share of the API, even when a neighbor sends a sudden flood of requests. Until now, one organization's traffic spike could slow the service for everyone, and changing a customer's limit meant waiting for an engineering release. With per-tenant rate limiting, each organization has its own per-minute and monthly request allowance, sees its current usage in the dashboard, and gets a clear, actionable response when it goes over. Support and operations staff can raise a customer's limit on their own, in about a minute, with no release required.

## Glossary

- **Tenant**: A customer organization treated as one account for limits.
- **Burst limit**: The most requests an organization may make per minute.
- **Monthly quota**: Total requests an organization may make per calendar month.
- **Rate limiting**: Capping how many requests an organization makes per window.

## Target Users and Personas

- **Customer developer**: Builds on the platform API. Cares about predictable, uninterrupted access.
- **Customer admin**: Watches their organization's usage. Wants to avoid surprise limits.
- **Support or operations staff**: Manage customer limits. Want to resolve requests fast.

## Problem Statement (Job to Be Done)

**Primary job**:

> When I depend on a shared platform for my organization's work, I want to keep my request capacity fair and predictable, so I can rely on the service even when other customers spike.

**Why this matters now**: Without per-tenant limits, a single customer's spike can degrade service for everyone, and every limit change waits on an engineering release. Both costs grow as the customer base grows, which makes fair, self-serviceable limits the priority now.

## Assumptions

- Only internal staff raise limits; invalid if customers must self-serve.
- Quotas reset on the UTC month; invalid if billing cycles differ.
- Tracking failures fail open; invalid if protection outranks availability.
- A dashboard and tenant identity exist; invalid if missing.

## Value Proposition

Today, one customer's traffic surge can slow the platform for everyone, and a customer who needs a higher limit has to wait for an engineering release. With this feature, each organization gets its own protected capacity, so one customer's spike no longer hurts another. Customers can watch their usage and see a warning before they run out, instead of being surprised by a rejection. Staff resolve limit requests in about a minute on their own, which removes a recurring engineering interruption.

## Scope

- Per-minute burst limit enforced for each organization.
- Monthly request quota enforced for each organization.
- Tenant isolation so one organization never affects another.
- Clear over-limit response telling callers when to retry.
- Configurable per-tenant limits, with documented defaults.
- Staff change limits without a release, with an audit trail.
- Dashboard usage view with an 80% near-limit warning.

## Out of Scope

- Customers raising their own limits; only internal staff can.
- Overage or pay-as-you-go beyond the monthly quota; hard-blocked until reset.
- Counting unauthenticated requests; the existing login path handles those.
- Per-customer billing cycles; quotas reset on the calendar month.
- A new dashboard; usage is added to the existing one.

## Use Cases

### Use Case 1: One customer's spike does not affect others

**Given** a customer organization suddenly sends far more requests than its per-minute limit allows.
**When** the organization passes that limit within the same minute.
**Then** its extra requests are turned away with a clear retry time, while other organizations keep working normally.

### Use Case 2: A monthly allowance runs out

**Given** a customer organization has used its entire monthly request allowance.
**When** it makes another request in the same month.
**Then** the request is turned away with a clear message and the time until the allowance resets.

### Use Case 3: Staff raise a limit without a release

**Given** a customer organization is being limited at its current allowance.
**When** a staff member raises that organization's limit.
**Then** the organization's later requests are accepted up to the new limit within about a minute, with no release.

### Use Case 4: A customer sees usage and an early warning

**Given** a customer organization has used most of its monthly allowance.
**When** a user from that organization opens the dashboard.
**Then** they see how much they have used, how much remains, the reset date, and a warning that they are near the limit.

### Use Case 5: A customer sees only their own usage

**Given** a user belongs to one customer organization.
**When** they view the usage dashboard.
**Then** they see only their own organization's usage and never another organization's.

## Success Metrics

**North star**:

- **Engineering-free limit changes**: Share of limit-increase requests resolved without engineering, target 100%.

**Supporting metrics**:

- **Self-service retry**: Share of limited callers retrying successfully without support, target 95%.
- **Usage freshness**: Dashboard usage matches reality within one minute, 99% of views.
- **Customer isolation**: No measurable effect of one organization's volume on another's rate.

## Risks and Open Product Questions

**Risks**:

- Fail-open during a tracking outage lets spikes through unchecked.
- Counting may drift under peak load, missing the accuracy target.
- Slow limit propagation could break the one-minute change promise.
- Stale dashboard usage may mislead customers about remaining quota.

**Open product questions**:

- Should the platform fail open or fail closed when tracking is down?
- Will any tenants need billing-cycle quotas instead of calendar months?
