# Product Info: Feature Specification: Per-Tenant API Rate Limiting

**Feature**: Feature Specification: Per-Tenant API Rate Limiting
**Created**: 2026-05-30
**Status**: Draft

## Overview

Per-tenant API rate limiting protects the platform from one customer organization's request volume affecting others. It sets clear monthly and per-minute limits for each organization, gives callers useful retry guidance when a limit is reached, and gives teams visibility into current usage.

## Headline

Customer organizations will have clear API limits that match their account and protect service quality for everyone. Callers who exceed a limit will know which limit they hit and when to retry. Support and operations admins can raise limits for approved tenants without waiting for an engineering release.

## What is Changing

- Each organization has its own API limits.
- Over-limit callers receive clear 429 retry guidance.
- Customers can view current monthly API usage.
- Admins can adjust tenant limits without a release.

## Out of Scope

- Customer-managed limit increases are excluded to preserve plan control.
- Automatic overage billing is excluded from this version.
- Unauthenticated requests stay with existing authentication handling.
- A new dashboard area is excluded; existing views are extended.

## Risks _(optional)_

- Usage tracking outages could allow excess requests.
- High concurrency could make counts inaccurate.
- Missing admin authorization could delay limit management.
- Dashboard freshness gaps could surprise customers.

## Key Decisions _(optional)_

These decisions were made while writing this spec. Review them to confirm they still reflect the right direction.

**Approaching-limit warning**
The dashboard will warn tenants when monthly usage reaches 80% of quota.
_Session: 2026-05-29_

**Peak scale target**
The feature will target about 5,000 requests per second across thousands of tenants.
_Session: 2026-05-29_
