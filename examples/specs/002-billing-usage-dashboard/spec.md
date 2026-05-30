# Feature Specification: Self-Serve Billing Usage Dashboard

**Feature Branch**: `002-billing-usage-dashboard`

**Created**: 2026-05-30

**Status**: Draft

**Input**: User description: "Add a self-serve billing usage dashboard for organization admins. Admins need to see current plan, monthly usage, projected overage, invoice history, and usage by team. The dashboard should explain why charges changed and help admins avoid surprise bills. Include alerts for projected overage, exportable invoice data, and clear empty states for new customers."

## User Scenarios & Testing _(mandatory)_

### User Story 1 - See current cost and projected bill at a glance (Priority: P1)

An organization admin opens the billing dashboard and immediately sees their current plan, how much of their included allowance they have used this billing period, and a projected total for the bill at the end of the period (including any projected overage). They leave the page knowing whether they are on track or heading for an unexpected charge.

**Why this priority**: This is the core value of the feature and the heart of "avoid surprise bills." Without it, admins have no self-serve way to know what they will owe. It is a viable MVP on its own: even with nothing else, an admin can answer "what is this month going to cost me?"

**Independent Test**: Load the dashboard for an account with mid-period usage and confirm it shows the current plan, usage versus included allowance per metered dimension, and a projected end-of-period total that separates already-included usage from projected overage.

**Acceptance Scenarios**:

1. **Given** an account partway through its billing period with usage below its allowance, **When** the admin opens the dashboard, **Then** the current plan, period dates, usage-to-date per dimension, and a projected total at or below the plan price are displayed.
2. **Given** an account whose run-rate will exceed its included allowance, **When** the admin opens the dashboard, **Then** a projected overage amount is shown distinctly from the included plan price, with the date the projection is based on.
3. **Given** an account on a flat plan with no overage possible, **When** the admin opens the dashboard, **Then** the projection shows no overage and states that overage does not apply to the plan.

---

### User Story 2 - Understand why charges changed (Priority: P2)

An admin notices their projected or last bill is higher than before. They open the dashboard, break usage down by team, and compare the current period against the previous one to see which teams or usage dimensions drove the change.

**Why this priority**: Directly serves "explain why charges changed." It converts a surprise into an explanation the admin can act on (for example, talking to a specific team). It builds on P1's usage data.

**Independent Test**: For an account with usage attributed to multiple teams across two periods, confirm the dashboard shows per-team usage for the current period and a period-over-period comparison that highlights the largest contributors to any change.

**Acceptance Scenarios**:

1. **Given** an account with usage across several teams, **When** the admin views the usage-by-team breakdown, **Then** each team's usage and share of charges for the current period is listed and the per-team total reconciles to the account total.
2. **Given** a period where charges rose versus the prior period, **When** the admin views the comparison, **Then** the primary drivers of the increase (teams and/or dimensions) are surfaced.
3. **Given** usage that is not attributable to any team, **When** the admin views the breakdown, **Then** that usage appears under a clearly labeled "unattributed" category rather than being hidden or dropped.

---

### User Story 3 - Be alerted before an overage happens (Priority: P3)

An admin enables a projected-overage alert. When their account's run-rate is on track to exceed the included allowance, they are notified before the invoice is issued, giving them time to react.

**Why this priority**: Turns the dashboard from a place admins must remember to check into a proactive guardrail. Strongly reinforces "avoid surprise bills," but depends on the projection logic delivered in P1.

**Independent Test**: Configure an alert on an account, drive projected usage past the configured threshold, and confirm a notification is generated and recorded before the period's invoice is issued.

**Acceptance Scenarios**:

1. **Given** an admin has enabled overage alerts, **When** projected usage crosses the configured threshold, **Then** an alert is sent and recorded in the dashboard's recent alert activity.
2. **Given** an alert was already sent for a threshold this period, **When** projected usage stays above the same threshold, **Then** the admin is not spammed with duplicate alerts for the same threshold and period.
3. **Given** an admin disables alerts, **When** projected usage crosses the threshold, **Then** no alert is sent.

---

### User Story 4 - Review and export invoice history (Priority: P4)

An admin opens invoice history to review past bills, inspect the line items of a specific invoice, and export the data so their finance team can reconcile it in their own systems.

**Why this priority**: Important for finance and record-keeping, but less time-sensitive than understanding and preventing the current bill. Sits naturally after the live-usage stories.

**Independent Test**: For an account with several past invoices, confirm the history lists each invoice with date, period, total, and status; that line-item detail can be opened; and that invoice data can be exported in a structured format.

**Acceptance Scenarios**:

1. **Given** an account with past invoices, **When** the admin opens invoice history, **Then** invoices are listed in reverse-chronological order with date, billing period, total amount, and payment status.
2. **Given** a specific past invoice, **When** the admin opens it, **Then** its line-item detail is shown.
3. **Given** one or more selected invoices, **When** the admin exports them, **Then** a structured, machine-readable file containing the invoice data is produced.

---

### User Story 5 - Helpful experience for brand-new customers (Priority: P5)

A newly signed-up organization with no usage and no invoices yet opens the dashboard. Instead of blank panels or errors, they see clear guidance explaining what will appear here and what to do next.

**Why this priority**: Protects the first impression for new customers and prevents confusion, but affects only the empty-data path, so it is the lowest priority while still in scope.

**Independent Test**: Load the dashboard for a freshly created account with no usage and no invoices and confirm every panel renders a purposeful empty state with a next step rather than a blank, broken, or error view.

**Acceptance Scenarios**:

1. **Given** a new account with no usage this period, **When** the admin opens the dashboard, **Then** the usage and projection panels show an empty state explaining that data appears once usage begins.
2. **Given** a new account with no invoices, **When** the admin opens invoice history, **Then** an empty state explains that invoices appear after the first billing period closes.
3. **Given** a new account with no team-attributable usage, **When** the admin opens the usage-by-team view, **Then** an empty state explains how usage will be attributed once it occurs.

---

### Edge Cases

- A plan change occurs mid-period (upgrade or downgrade): usage-to-date and the projection must reflect the change rather than mixing allowances incorrectly.
- The projection is requested on day 1 of a period when there is little or no usage to extrapolate from.
- A team that had historical usage is renamed or deleted: its past usage must still be representable in comparisons and history.
- An invoice is in a pending, failed, or refunded payment state rather than paid.
- An account exceeds its allowance on multiple metered dimensions at once.
- A very large organization has many teams, requiring the breakdown to remain readable (sorting/grouping/pagination).
- An admin's access is revoked while they have the dashboard open.
- Usage data is delayed or temporarily unavailable from the metering source: the dashboard must indicate staleness rather than imply a confident projection.

## Requirements _(mandatory)_

### Functional Requirements

**Current plan and usage overview (US1)**

- **FR-001**: System MUST display the organization's current plan, including plan name, billing cycle dates, and included usage allowances.
- **FR-002**: System MUST display usage consumed in the current billing period for each metered dimension, compared against the plan's included allowance.
- **FR-003**: System MUST display a projected end-of-period usage and projected total charge, including any projected overage beyond included allowances.
- **FR-004**: System MUST visually distinguish the already-included plan price from projected overage charges in the cost summary.
- **FR-005**: System MUST present the projected charge as an estimate and indicate the basis of the projection (for example, "based on usage through [date]").
- **FR-006**: System MUST indicate when the usage and projection data was last updated, and surface when that data is stale or unavailable.

**Explaining charge changes (US2)**

- **FR-007**: System MUST present usage broken down by team for the current billing period, including each team's share of charges.
- **FR-008**: System MUST allow admins to compare the current period's usage and charges against the previous period.
- **FR-009**: System MUST surface the primary drivers of any change in charges between periods (which teams and/or dimensions increased or decreased).
- **FR-010**: System MUST represent usage that cannot be attributed to a specific team as a clearly labeled "unattributed" category, and the sum of per-team and unattributed usage MUST reconcile to the account total.

**Projected-overage alerts (US3)**

- **FR-011**: System MUST allow admins to enable and disable alerts that notify them when projected usage is on track to exceed the plan's included allowance.
- **FR-012**: System MUST allow admins to configure the alert threshold (for example, at projected overage, or at a chosen percentage of the allowance).
- **FR-013**: System MUST deliver each alert before the invoice for that period is issued.
- **FR-014**: System MUST avoid sending duplicate alerts for the same threshold within the same billing period.
- **FR-015**: System MUST record alerts that were sent, including what and when, and display recent alert activity to the admin.

**Invoice history and export (US4)**

- **FR-016**: System MUST display a reverse-chronological history of past invoices showing date, billing period, total amount, and payment status.
- **FR-017**: Admins MUST be able to open the line-item detail of any past invoice.
- **FR-018**: Admins MUST be able to export invoice data for one or more invoices in a structured, machine-readable format suitable for finance and accounting use.

**Empty states (US5)**

- **FR-019**: System MUST display a purposeful empty state, with a clear next step, for organizations that have no usage yet in the current period.
- **FR-020**: System MUST display a purposeful empty state for organizations that have no invoice history.
- **FR-021**: System MUST display a purposeful empty state for the usage-by-team view when no team-attributable usage exists.

**Access and presentation (all stories)**

- **FR-022**: System MUST restrict the dashboard to users holding the organization admin or billing role; other members MUST NOT see billing data.
- **FR-023**: System MUST present all monetary amounts in the account's billing currency and label that currency.
- **FR-024**: System MUST reflect a mid-period plan change in both current-period usage attribution and the end-of-period projection.

### Key Entities _(include if feature involves data)_

- **Organization (Account)**: The billable entity that holds a plan and is administered by one or more admins.
- **Plan / Subscription**: The current plan with its included allowances, overage rates, billing cycle dates, and currency.
- **Metered Usage**: Consumption of a billable dimension during a period, attributable (where possible) to a team.
- **Team**: An organizational unit that usage is attributed to for breakdown and comparison.
- **Usage Projection**: An estimate of end-of-period usage and resulting charge, with the date/basis it was computed from.
- **Invoice**: An issued bill for a closed period, with line items, total, currency, issue date, and payment status.
- **Alert Rule / Alert Event**: An admin's configured overage-alert threshold and preference, plus the record of alerts that were sent.

## Success Criteria _(mandatory)_

### Measurable Outcomes

- **SC-001**: An admin can determine their projected end-of-period bill within 30 seconds of opening the dashboard, without contacting support.
- **SC-002**: Billing-related support contacts about surprise charges or "why did my bill change" drop by at least 40% within one quarter of launch.
- **SC-003**: At least 90% of accounts that end a period in overage and have alerts enabled receive a projected-overage alert before that period's invoice is issued.
- **SC-004**: An admin can locate and export the data for any past invoice in under 1 minute and in no more than 3 actions.
- **SC-005**: 100% of dashboard panels render a purposeful empty state (never a blank panel or error) for a brand-new account with no usage and no invoices.
- **SC-006**: For any account, the sum of per-team and unattributed usage shown on the dashboard reconciles exactly to the account's total usage for the period.
- **SC-007**: In post-launch usability checks, at least 85% of admins correctly identify the main driver of a period-over-period charge change using only the dashboard.

## Assumptions

- The dashboard is read-only with respect to billing: admins view plan, usage, projections, and invoices but do not change plans, make payments, or dispute charges from it; those remain existing flows.
- Access is limited to the organization admin role and an optional billing role; regular members do not see billing data.
- A metering system already records usage and can attribute it to teams where possible; this feature surfaces existing data rather than introducing new metering or a new concept of teams.
- Projected overage is computed by extrapolating current-period usage at the observed run-rate to the end of the billing cycle; more sophisticated forecasting is out of scope for the first version.
- Overage alerts are delivered by email and in-app notification; additional channels such as SMS, Slack, or webhooks are out of scope for the first version.
- Invoice export is provided in a structured data format (such as CSV) for reconciliation; the existing human-readable invoice document is reused and no new invoice layout is designed.
- Each account is billed in a single currency.
- Usage and invoice history are shown only for periods the system already retains; no historical backfill is in scope.

### Out of Scope

- Changing plans, upgrading, downgrading, or canceling from the dashboard.
- Making payments, updating payment methods, or disputing charges.
- Creating or managing teams (teams are consumed as existing data).
- Forecasting beyond a simple run-rate extrapolation.
- Alert channels beyond email and in-app notification.
- Cost optimization recommendations or automated spend caps that throttle usage.
