# Product Spec: Self-Serve Billing Usage Dashboard

**Feature**: Self-Serve Billing Usage Dashboard
**Created**: 2026-05-31
**Status**: Draft

## Headline

Organization admins see where this period's bill is heading before the invoice arrives, instead of being surprised by it. Today they learn what they owe only when the bill lands, and answering "why did it change" means a support ticket or a spreadsheet. The dashboard projects the end-of-period total, breaks usage down by team, and warns before an overage happens, all self-serve. The alert is the genuinely new part; the rest already existed but was scattered or invisible, and now sits in one place.

## Glossary

- **Overage**: usage beyond your plan's included allowance, billed at extra cost.
- **Included allowance**: the usage your plan covers before overage applies.
- **Metered dimension**: a usage type measured and billed separately.
- **Run-rate projection**: an estimate extending current usage to period end.
- **Unattributed usage**: usage that cannot be tied to a specific team.

## Users

- **Organization admin**: runs the account; wants no surprise bills.
- **Billing owner**: holds the billing role; tracks spend and overages closely.
- **Finance teammate**: reconciles invoices; needs exportable, accurate records.

## Problem (Job to Be Done)

> When I am responsible for my organization's bill, I want to understand and predict what we will owe, so I can avoid surprise charges and act before costs climb.

**Why now**: No time-sensitive trigger; this is a standing need. The surprise-bill problem is constant, not tied to a recent change.

## Assumptions

- Metering already attributes usage to teams; invalid if attribution is unavailable.
- Run-rate extrapolation is accurate enough; invalid if usage is highly irregular.
- Admins want a read-only view; invalid if they expect in-place actions.
- Each account uses one currency; invalid for multi-currency accounts.

## Scope

**In scope**:

- Show current plan, allowances, and usage per metered dimension.
- Project the end-of-period bill, separating included price from overage.
- Indicate when usage data was last updated or stale.
- Break usage down by team, including unattributed usage.
- Compare the current period against the previous one.
- Configurable alerts before a projected overage occurs.
- List, inspect, and export past invoices.
- Purposeful empty states for brand-new accounts.
- Restrict billing data to admin and billing roles.

**Out of scope**:

- Changing or canceling plans, that stays in existing flows.
- Making payments or disputing charges, handled elsewhere.
- Creating or managing teams, used here as existing data.
- Advanced forecasting, only run-rate projection is included.
- Alert channels beyond email and in-app, deferred for now.
- Spend caps or cost-saving tips, not in this version.
- Historical backfill of usage or invoices, not included.

## Use Cases

### Use Case 1: See current cost and projected bill

**Given** an admin is partway through a billing period with usage recorded.
**When** the admin opens the billing dashboard.
**Then** they see the current plan, usage against allowance, and a projected end-of-period total.

### Use Case 2: Understand why charges changed

**Given** an account's projected bill is higher than the previous period.
**When** the admin views usage broken down by team and compares the two periods.
**Then** the teams and dimensions driving the increase are surfaced clearly.

### Use Case 3: Be alerted before an overage

**Given** an admin has enabled a projected-overage alert with a threshold.
**When** projected usage crosses that threshold during the period.
**Then** the admin is notified before the period's invoice is issued.

### Use Case 4: Review and export invoices

**Given** an account has several past invoices on record.
**When** the admin opens invoice history and selects invoices to export.
**Then** a structured file of the invoice data is produced for finance.

### Use Case 5: Helpful experience for new customers

**Given** a brand-new account has no usage and no invoices yet.
**When** the admin opens the dashboard and its panels.
**Then** every panel shows a purposeful empty state with a clear next step.

## Success Metrics

**North star**:

- **Surprise-bill support contacts**: down 40% within one quarter of launch.

**Supporting**:

- **Time to projected bill**: under 30 seconds for a new visitor.
- **Overage alert coverage**: 90% of alerting overage accounts warned pre-invoice.
- **Invoice export ease**: any invoice exported under one minute, three actions.
- **Charge-driver comprehension**: 85% of admins identify the main change driver.

## Risks and Open Questions

**Risks**:

- Stale or missing upstream usage makes projections wrong, eroding trust.
- Early-period projections may overstate cost and trigger false alarms.
- Per-team usage that fails to reconcile undermines dashboard credibility.
- Late alerts still leave admins with the surprise bills they feared.

**Open questions**:

- What default alert threshold ships, and is one enabled by default?
- Which export format do finance teams need beyond a basic table?
