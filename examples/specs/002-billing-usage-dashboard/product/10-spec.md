# Product Spec: Feature Specification: Self-Serve Billing Usage Dashboard

**Feature**: Feature Specification: Self-Serve Billing Usage Dashboard
**Created**: 2026-05-30
**Status**: Draft

## Headline

Organization admins can understand likely billing costs before an invoice arrives. The dashboard explains current usage, projected overage, invoice history, and charge drivers in one read-only place. It helps admins avoid surprise bills and answer finance questions without contacting support.

## Glossary

- **Billing period**: The date range covered by one bill.
- **Allowance**: Usage included in the current plan price.
- **Overage**: Extra cost after included usage is exceeded.
- **Unattributed usage**: Usage that cannot be tied to a team.
- **Projection**: An estimate based on current-period usage so far.

## Target Users and Personas

- **Organization admin**: Owns account health and avoids billing surprises.
- **Billing manager**: Reviews invoices and reconciles costs for finance.
- **Team lead**: Explains why their team changed account usage.

## Problem Statement (Job to Be Done)

**Primary job**:

> When my organization is using a billed product during the month, I want to understand expected charges and their causes, so I can prevent surprises and explain costs before the invoice arrives.

**Why this matters now**: Admins currently need support or manual investigation to understand likely costs. Billing questions become more urgent when usage changes across teams and invoices arrive after the chance to react has passed.

## Assumptions

- **Read-only billing**: Invalid if admins need billing actions here.
- **Admin access**: Invalid if non-admin members need billing visibility.
- **Existing usage data**: Invalid if usage cannot identify teams.
- **Simple forecasting**: Invalid if run-rate estimates are too inaccurate.
- **Email and in-app alerts**: Invalid if customers require other channels.
- **Single currency**: Invalid if accounts span multiple billing currencies.

## Value Proposition

Today, admins must piece together usage, invoices, and support answers to understand billing. This feature gives them a clear view of expected cost, why it changed, and what may happen before the billing period ends. It turns billing from a surprise into something admins can monitor, explain, and act on.

## Scope

- Show current plan, usage, allowances, and projected bill.
- Separate included plan price from projected overage.
- Explain charge changes by team and usage dimension.
- Let admins enable projected-overage alerts.
- Show recent alert activity.
- List past invoices with line-item detail.
- Export invoice data for finance.
- Show helpful empty states for new accounts.
- Restrict billing data to permitted roles.

## Out of Scope

- Plan changes stay in existing flows.
- Payments and disputes stay in existing billing tools.
- Team management uses existing team data.
- Advanced forecasting is excluded from the first version.
- Extra alert channels are not included.
- Spend caps are not included.
- Historical backfill is not included.

## Use Cases

### Use Case 1: See Expected Bill

**Given** Given an admin checks billing during an active billing period.
**When** When they review the current cost summary.
**Then** Then they see plan, usage, allowance, and projected total.

### Use Case 2: Spot Projected Overage

**Given** Given an account is trending beyond included usage.
**When** When the admin reviews the projected charges.
**Then** Then overage appears separately from the included plan price.

### Use Case 3: Explain A Charge Increase

**Given** Given charges are higher than the previous period.
**When** When the admin compares usage by team and dimension.
**Then** Then the largest drivers of the change are highlighted.

### Use Case 4: Include Unattributed Usage

**Given** Given some usage cannot be tied to a team.
**When** When the admin reviews the team breakdown.
**Then** Then unattributed usage appears and reconciles to the total.

### Use Case 5: Receive Overage Alert

**Given** Given an admin has enabled projected-overage alerts.
**When** When projected usage crosses the chosen threshold.
**Then** Then the admin receives one recorded alert for that period.

### Use Case 6: Export Invoice Data

**Given** Given an account has past invoices.
**When** When the admin selects invoices to export.
**Then** Then finance receives structured invoice data for reconciliation.

### Use Case 7: Start With No Usage

**Given** Given a new account has no usage or invoices.
**When** When the admin opens the billing dashboard.
**Then** Then every panel explains what will appear later.

## Success Metrics

**North star**:

- **Time to billing confidence**: Admins find projected bill within 30 seconds.

**Supporting metrics**:

- **Surprise-charge contacts**: Support contacts drop 40% within one quarter.
- **Alert coverage**: 90% of eligible overage accounts receive timely alerts.
- **Invoice export speed**: Admins export past invoice data within one minute.
- **Charge-driver understanding**: 85% identify the main change driver.

## Risks and Open Product Questions

**Risks**:

- Delayed usage data could make projections feel more certain than warranted.
- Mid-period plan changes could confuse usage and overage explanations.
- Unattributed usage could reduce trust in team-level charge drivers.
- Duplicate or late alerts could weaken confidence in overage warnings.
