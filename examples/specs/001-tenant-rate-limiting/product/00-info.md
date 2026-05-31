# Product Info: Per-Tenant API Rate Limiting

**Feature**: Per-Tenant API Rate Limiting
**Created**: 2026-05-31
**Status**: Draft

## Overview

The platform serves many customer organizations through a shared API, and one organization sending too many requests can slow the service for everyone. Per-tenant rate limiting gives each organization its own request limits: a cap on requests per minute and a total number of requests each month. It protects shared capacity, enforces fair use, and gives customers and staff a clear view of and control over those limits.

## Headline

This is for the platform's customer organizations and the support and operations staff who manage them. Each organization now has its own request limits, so one customer's traffic spike can no longer degrade service for the others. Customers can see their current usage and remaining allowance in the dashboard, and staff can raise a customer's limits on their own, without waiting for an engineering release.

## What is Changing

- Each organization has its own per-minute and monthly request limits.
- One organization's traffic no longer affects another organization's limits.
- Over-limit requests get a clear rejection telling callers when to retry.
- The dashboard shows usage, remaining quota, reset date, and a near-limit warning.
- Staff can raise a customer's limits without an engineering release.

## Out of Scope

- Customers raising their own limits; only internal staff can.
- Pay-as-you-go overage beyond the monthly quota, blocked until reset.
- Counting unauthenticated requests, which the login path already handles.
- Per-customer billing cycles; limits reset on the calendar month.
- A new dashboard; usage is added to the existing one.

## Risks

- If usage tracking fails open during an outage, spikes pass unchecked.
- At about 5,000 requests per second, counting may drift past the 1% target.
- Raised limits may propagate slowly, missing the one-minute effect promise.
- Dashboard usage lags up to a minute, so warnings may mislead.

## Key Decisions

These decisions were made while writing this spec. Review them to confirm they still reflect the right direction, and flag any that have changed.

**Approaching-limit threshold**
The dashboard warns a customer once they have used 80% of their monthly quota, giving them room to react before they are blocked.
_Session: 2026-05-29_

**Peak load target**
The design and accuracy tests aim at a peak of about 5,000 requests per second spread across thousands of customer organizations.
_Session: 2026-05-29_
