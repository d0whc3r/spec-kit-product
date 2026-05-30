# Product Spec: Per-Tenant API Rate Limiting

**Feature**: Per-Tenant API Rate Limiting
**Created**: 2026-05-30
**Status**: Draft

## Headline

Customer organizations that build on our service can now count on steady, predictable access, even when a neighbor sends a sudden flood of traffic. Each organization gets its own request limits, so one heavy user can no longer slow things down for everyone else. When a customer goes over a limit, they get a plain response that says what happened and when they can try again, and they can watch their own usage in the dashboard. Support staff can lift a customer's limits the moment a plan changes, without waiting for an engineering release.

## Glossary

- **Tenant**: A single customer organization that the limits apply to.
- **Burst limit**: The most requests an organization may send in one minute.
- **Monthly quota**: The total requests an organization may send each month.

## Target Users and Personas

- **Customer organization developer**: Builds on our service. Cares about predictable, uninterrupted access.
- **Customer organization admin**: Manages the account. Cares about staying within plan limits.
- **Internal support staff**: Helps customers. Cares about resolving limit requests without engineering.

## Problem Statement (Job to Be Done)

**Primary job**:

> When my organization depends on a shared service for its daily work, I want to keep steady access regardless of what other customers do, so I can serve my own users without interruption.

**Why this matters now**: As more customers build on the same shared service, a single traffic spike from one customer can degrade everyone's experience. Today there is no fair, per-customer boundary, so protecting one customer can mean throttling all of them or scrambling through a manual release. A clear per-customer limit makes access predictable and lets support resolve plan changes on their own.

## Assumptions

- Admins are internal staff, not customers; invalid if customers self-serve.
- Monthly periods follow the calendar in UTC; invalid if billing cycles differ.
- Exhausted quotas hard-block until reset; invalid if overage is wanted.
- Tracking outages allow requests; invalid if protection outranks availability.
- A dashboard and admin identity exist; invalid if neither is available.

## Value Proposition

Today, one customer's traffic spike can slow the service for everyone, and raising a single customer's limit means waiting on an engineering release. With per-customer limits, each organization's access is protected from its neighbors, and a clear refusal tells callers exactly when to retry. Customers can track their own usage and see when they are close to a limit, instead of being surprised by a block. Support staff resolve limit changes in minutes, not in a deploy cycle.

## Scope

- Per-minute burst limit enforced for each organization.
- Monthly request quota enforced for each organization.
- Clear refusal response with a retry time when over limit.
- Per-customer usage shown in the dashboard with reset date.
- Warning in the dashboard at 80% of monthly quota.
- Staff can change a customer's limits without a release.
- Audit record of every limit change.
- Default limits for organizations with no custom values.

## Out of Scope

- Customers cannot change their own limits, since that defeats paid plans.
- No pay-as-you-go overage beyond the quota in this version.
- Unauthenticated requests are not counted, since authentication handles them.
- No per-customer billing cycle; the month follows the calendar in UTC.
- No new dashboard; usage is added to the existing one.

## Use Cases

### Use Case 1: A spike is capped within the minute

**Given** my organization has a per-minute limit and is sending many requests.
**When** my organization goes over that limit within one minute.
**Then** further requests get a clear refusal telling me when to retry.

### Use Case 2: One organization's spike does not affect another

**Given** two organizations are using the service at the same time.
**When** one organization uses up its per-minute limit.
**Then** the other organization's requests keep succeeding up to its own limit.

### Use Case 3: Monthly quota is exhausted

**Given** my organization has used its full monthly quota.
**When** my organization sends another request that month.
**Then** the request gets a clear refusal pointing to the next reset.

### Use Case 4: An admin raises a limit without a release

**Given** a customer is being blocked at its current limit.
**When** an admin raises that customer's limit.
**Then** the customer's later requests are accepted, with no release performed.

### Use Case 5: A customer reviews usage in the dashboard

**Given** my organization has made requests this month.
**When** I open my organization's dashboard.
**Then** I see used amount, remaining quota, reset date, and burst limit.

### Use Case 6: A customer is warned before being blocked

**Given** my organization has used 80% or more of its monthly quota.
**When** I view my dashboard.
**Then** I see a clear warning that I am nearing my limit.

## Success Metrics

**North star**:

- **Cross-tenant interference**: Share of customers affected by another's traffic, targeting zero.

**Supporting metrics**:

- **Self-served limit changes**: Limit increases resolved without engineering, targeting 100%.
- **Surprise blocks**: Customers blocked without a prior warning, trending toward zero.
- **Recovery without support**: Blocked callers who retry without contacting support, targeting high.

## Risks and Open Product Questions

**Risks**:

- Fail-open mode lets abuse through when usage tracking is down.
- Inaccurate counts under peak load break trust in the limits.
- UTC monthly resets may confuse customers in other time zones.
- Hard blocking at quota may frustrate customers expecting overage.

**Open product questions**:

- Should the platform fail open or fail closed when tracking is down?
- Should any paid overage be offered instead of a hard block?
