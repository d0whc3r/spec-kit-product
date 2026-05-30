# Product Info: Feature Specification: Self-Serve Billing Usage Dashboard

**Feature**: Feature Specification: Self-Serve Billing Usage Dashboard
**Created**: 2026-05-30
**Status**: Draft

## Overview

This feature gives organization admins a read-only billing dashboard for current costs, usage, projected overage, and invoice history. It addresses surprise bills by showing what is driving charges and when the current period may exceed included allowances.

## Headline

Organization admins will have one place to understand what they are likely to owe before the bill arrives. They can see current usage, projected overage, charge drivers, alerts, invoice history, and clear empty states for new accounts.

## What is Changing

- Admins see current usage against plan allowances.
- Projected overage appears before the bill closes.
- Charge changes are explained by team and dimension.
- Past invoices can be reviewed and exported.
- New accounts get clear empty states.

## Out of Scope

- Plan changes stay in existing flows.
- Payments and disputes stay in existing billing tools.
- Team management is excluded because teams already exist.
- Spend caps are excluded for this version.

## Risks

- Delayed usage data could make projections look more certain than warranted.
- Mid-period plan changes could confuse projected charges.
- Unattributed usage could weaken trust in team breakdowns.
- Alert timing could miss invoices if projections run late.
