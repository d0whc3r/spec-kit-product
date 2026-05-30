# Product Info: Per-Tenant API Rate Limiting

**Feature**: Per-Tenant API Rate Limiting
**Created**: 2026-05-30
**Status**: Draft

## Overview

Per-Tenant API Rate Limiting gives every customer organization its own request limits so that one organization's traffic cannot slow the service for others. It pairs a short-term burst limit with a monthly quota, returns a clear refusal when a caller goes over, and shows each customer their own usage. Internal staff can adjust any customer's limits on demand.

## Headline

This is for customer organizations that rely on our service and for the internal staff who support them. Each organization now has a per-minute burst limit and a monthly request quota, so heavy use by one customer no longer affects anyone else. Customers can see how much of their quota they have used and when it resets, and when they go over a limit they get a plain response telling them what happened and when to retry. Support and operations staff can raise a customer's limits right away, without waiting for an engineering release.

## What is Changing

- Each organization gets a per-minute burst limit and monthly quota.
- Over-limit requests return a clear refusal with a retry time.
- The dashboard shows used, remaining, reset date, and burst limit.
- The dashboard warns when usage reaches 80% of quota.
- Staff can raise a customer's limits without a release.

## Out of Scope

- Customers cannot change their own limits, since that would defeat paid plans.
- No pay-as-you-go overage beyond the monthly quota in this version.
- Unauthenticated requests are not counted, since authentication handles them.
- No per-customer billing cycle; the month follows the calendar in UTC.

## Risks

- Fail-open mode could let abuse through when usage tracking is down.
- Counting errors under peak load could break the 1% accuracy target.
- Reliance on existing dashboard and admin access controls could delay delivery.
- Calendar-month resets in UTC may confuse customers in other time zones.

## Key Decisions

These decisions were made while writing this spec. Review them to confirm they still reflect the right direction, and flag any that have changed.

**Approaching-limit warning threshold**
The dashboard warns a customer once usage reaches 80% of the monthly quota, giving early notice before requests are blocked.
_Session: 2026-05-29_

**Peak scale target**
The design and load tests target about 5,000 requests per second across thousands of customers, setting the scale the feature must hold up under.
_Session: 2026-05-29_
