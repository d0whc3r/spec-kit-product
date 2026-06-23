# Product Info: Per-Tenant API Rate Limiting

**Feature**: Per-Tenant API Rate Limiting
**Created**: 2026-05-31
**Status**: Draft

## Overview

The platform serves many customer organizations through a shared API, where one organization sending too many requests can slow the service for everyone. Per-tenant rate limiting gives each organization its own limits: a cap per minute and a total per month, so one customer's spike no longer degrades service for the others. Customers see their usage and remaining allowance in the dashboard, and support and operations staff can raise a customer's limits on their own, without an engineering release.

## What is Changing

- Each organization has its own per-minute and monthly request limits.
- One organization's traffic no longer affects another organization's limits.
- Over-limit requests get a clear rejection telling callers when to retry.
- The dashboard shows usage, remaining quota, reset date, and a near-limit warning.
- Staff can raise a customer's limits without an engineering release.

## Key Decisions

These decisions were made while writing this spec. Review them to confirm they still reflect the right direction, and flag any that have changed.

**Approaching-limit threshold**
The dashboard warns a customer once they have used 80% of their monthly quota, giving them room to react before they are blocked.
_Session: 2026-05-29_

**Peak load target**
The design and accuracy tests aim at a peak of about 5,000 requests per second spread across thousands of customer organizations.
_Session: 2026-05-29_
