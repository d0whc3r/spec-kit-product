# Product Info: Self-Serve Billing Usage Dashboard

**Feature**: Self-Serve Billing Usage Dashboard
**Created**: 2026-05-31
**Status**: Draft

## Overview

For organization admins and billing owners, the bill is a black box until the invoice arrives, which means surprise charges and support tickets. The Self-Serve Billing Usage Dashboard gives them one place to see the current plan, usage this period, and a projected end-of-period bill. It explains what is driving costs by team and warns before an overage happens, and finance can pull past invoices without a ticket. The result is fewer surprise bills and less back-and-forth with support.

## What is Changing

- Admins see their current plan and usage in one place.
- A projected end-of-period bill shows whether an overage is coming.
- Usage breaks down by team to explain what changed.
- An alert can fire before a projected overage, not after.
- Past invoices can be reviewed and exported for finance.

## Out of Scope

- Changing or canceling plans, that stays in existing flows.
- Making payments or disputing charges, handled elsewhere.
- Creating or managing teams, used here as existing data.
- Advanced forecasting, only simple run-rate projection is included.
- Alert channels beyond email and in-app, deferred for now.
- Spend caps or cost-saving tips, not in this version.

## Risks

- If upstream usage data is stale or missing, projections mislead admins.
- Early-period run-rate projections may overstate cost and trigger false alarms.
- If per-team usage fails to reconcile, admins distrust the dashboard.
- Alerts that fire late still leave admins with surprise bills.
