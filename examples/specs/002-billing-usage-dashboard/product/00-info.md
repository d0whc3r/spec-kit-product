# Product Info: Self-Serve Billing Usage Dashboard

**Feature**: Self-Serve Billing Usage Dashboard
**Created**: 2026-05-31
**Status**: Draft

## Overview

Organization admins often cannot tell what their bill will be until it arrives, which leads to surprise charges and support tickets. The Self-Serve Billing Usage Dashboard gives admins a single place to see their current plan, usage this period, and a projected end-of-period bill. It also explains what is driving charges and warns admins before an overage happens.

## Headline

This is for organization admins and billing owners who are responsible for what their company spends. Instead of waiting for an invoice to learn what they owe, they can open the dashboard at any time and see where this period's bill is heading. They can find out which teams are driving costs, get an early warning before an overage, and pull past invoices for their finance team. The result is fewer surprise bills and less back-and-forth with support.

## What is Changing

- Admins see their current plan and usage in one place.
- A projected end-of-period bill shows whether an overage is coming.
- Usage breaks down by team to explain what changed.
- Admins can be alerted before a projected overage occurs.
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
