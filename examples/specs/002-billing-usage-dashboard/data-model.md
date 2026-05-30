# Phase 1 Data Model: Self-Serve Billing Usage Dashboard

Entities derive from the spec's Key Entities and Functional Requirements. Durable
billing data (plans, invoices, alert rules, alert events, cached projections) lives
in PostgreSQL. Usage records are owned by an existing metering source (upstream) and
are read, aggregated, and materialized for the current period; they are not owned by
this feature.

---

## Organization (Account)

The billable entity an admin administers. Assumed to already exist (spec Assumptions); referenced here, not owned by this feature.

| Field              | Type          | Notes                                                                           |
| ------------------ | ------------- | ------------------------------------------------------------------------------- |
| `org_id`           | UUID / string | Stable identity; scopes every billing query (FR-022)                            |
| `billing_currency` | ISO 4217 code | Single currency per account (Assumptions); all amounts labeled with it (FR-023) |

Relationships: one Organization has one current `Plan`, many `Invoice`, many `Team`, zero-or-many `AlertRule`, and many `MeteredUsage` records (upstream).

---

## Plan (Subscription)

The current plan and its commercial terms (FR-001).

| Field                       | Type                     | Rules                                                                       |
| --------------------------- | ------------------------ | --------------------------------------------------------------------------- |
| `org_id`                    | FK -> Organization       | The account this plan applies to                                            |
| `plan_name`                 | string                   | Displayed on the overview (FR-001)                                          |
| `cycle_start` / `cycle_end` | date                     | Current billing-period bounds (FR-001)                                      |
| `included_allowances`       | map<dimension, quantity> | Included units per metered dimension (FR-001, FR-002)                       |
| `overage_rates`             | map<dimension, money>    | Price per unit beyond allowance; absent/zero dimension => no overage (flat) |
| `effective_from`            | timestamptz              | Supports mid-cycle plan change (FR-024)                                     |

Notes: a mid-cycle change is represented as a new effective plan within the cycle; the projector prices usage-to-date against the plan in effect when consumed and the remainder against the current plan (FR-024, research §5).

---

## Team

An organizational unit usage is attributed to (FR-007). Assumed to already exist; referenced for breakdown and comparison, not owned here.

| Field       | Type               | Notes                                                                                 |
| ----------- | ------------------ | ------------------------------------------------------------------------------------- |
| `team_id`   | UUID / string      | Attribution key for usage breakdown                                                   |
| `team_name` | string             | Displayed in the breakdown; retained for renamed/deleted teams in history (Edge Case) |
| `org_id`    | FK -> Organization | Owning account                                                                        |

---

## MeteredUsage (upstream, read-only)

Consumption of a billable dimension during a period, attributable (where possible) to a team. Owned by the metering source; this feature reads and aggregates it.

| Field         | Type        | Notes                                                                          |
| ------------- | ----------- | ------------------------------------------------------------------------------ |
| `org_id`      | ref         | Account the usage belongs to                                                   |
| `team_id`     | ref / null  | Attributed team; **null => unattributed bucket** (FR-010)                      |
| `dimension`   | string      | Metered dimension (e.g. requests, seats, GB)                                   |
| `quantity`    | number      | Units consumed                                                                 |
| `occurred_at` | timestamptz | Used to assign usage to a billing period and to the pre/post plan-change split |

Counting rule: aggregation produces the account total and the per-team + unattributed split in **one pass** so they reconcile exactly (SC-006, research §2).

---

## UsageAggregate (materialized per period)

Stored snapshot of per-team usage for a period, refreshed for the current period and computed once for closed periods (research §3). Guarantees fast reads and deterministic reconciliation.

| Field         | Type               | Rules                                                |
| ------------- | ------------------ | ---------------------------------------------------- |
| `org_id`      | FK -> Organization | Account                                              |
| `period`      | period key         | Billing period this aggregate covers                 |
| `team_id`     | ref / null         | null row = unattributed bucket                       |
| `dimension`   | string             | Metered dimension                                    |
| `quantity`    | number             | Aggregated units for (team, dimension) in the period |
| `computed_at` | timestamptz        | When this snapshot was built                         |

Invariant: for each `(org, period, dimension)`, `sum(quantity over teams + unattributed) == account_total(org, period, dimension)` (SC-006).

---

## UsageProjection (cached)

The computed end-of-period estimate for the current period (FR-003, FR-004, FR-005).

| Field                      | Type                     | Rules                                                          |
| -------------------------- | ------------------------ | -------------------------------------------------------------- |
| `org_id`                   | FK -> Organization       | Account                                                        |
| `period`                   | period key               | Current billing period                                         |
| `projected_usage`          | map<dimension, quantity> | Run-rate extrapolation to cycle end (research §1)              |
| `included_amount`          | money                    | Already-included plan price (FR-004)                           |
| `projected_overage_amount` | money                    | Projected charge beyond allowance, shown distinctly (FR-004)   |
| `projected_total`          | money                    | included + projected overage                                   |
| `basis_as_of`              | timestamptz              | "based on usage through [date]" (FR-005)                       |
| `confidence`               | enum `{low, normal}`     | low early in the period when little usage exists (research §1) |

Derived for the overview: per-dimension `consumed` vs `allowance` (FR-002), and the included/overage split (FR-004).

---

## Invoice + InvoiceLineItem

Issued bills for closed periods (FR-016, FR-017).

**Invoice**

| Field                         | Type                                     | Rules                                                                     |
| ----------------------------- | ---------------------------------------- | ------------------------------------------------------------------------- |
| `invoice_id`                  | UUID                                     | PK                                                                        |
| `org_id`                      | FK -> Organization                       | Account                                                                   |
| `period_start` / `period_end` | date                                     | Billing period covered                                                    |
| `issued_at`                   | timestamptz                              | Issue date (FR-016); alerts for the period MUST precede this (SC-003)     |
| `total_amount`                | money                                    | In account currency (FR-023)                                              |
| `status`                      | enum `{paid, pending, failed, refunded}` | Payment status (FR-016, Edge Case)                                        |
| `document_url`                | url / null                               | Existing human-readable invoice document, reused for export (research §8) |

**InvoiceLineItem**

| Field         | Type          | Rules                            |
| ------------- | ------------- | -------------------------------- |
| `invoice_id`  | FK -> Invoice | Parent invoice                   |
| `description` | string        | Line description                 |
| `dimension`   | string / null | Metered dimension, if applicable |
| `quantity`    | number / null | Units billed                     |
| `amount`      | money         | Line amount in account currency  |

Relationships: one Invoice has many InvoiceLineItem. Export (FR-018) serializes invoice + line items to CSV.

---

## AlertRule

An admin's configured overage-alert preference (FR-011, FR-012).

| Field        | Type                  | Rules                                                |
| ------------ | --------------------- | ---------------------------------------------------- |
| `rule_id`    | UUID                  | PK                                                   |
| `org_id`     | FK -> Organization    | Account                                              |
| `enabled`    | boolean               | Toggling off suppresses alerts (FR-011, AS3.3)       |
| `threshold`  | descriptor            | "projected overage" or "at N% of allowance" (FR-012) |
| `channels`   | set `{email, in_app}` | Delivery channels (research §7); extensible later    |
| `updated_at` | timestamptz           | Last change                                          |

---

## AlertEvent (durable log)

Record of every alert sent; also the dedup ledger (FR-014, FR-015).

| Field           | Type               | Rules                             |
| --------------- | ------------------ | --------------------------------- |
| `event_id`      | UUID               | PK                                |
| `rule_id`       | FK -> AlertRule    | Rule that fired                   |
| `org_id`        | FK -> Organization | Account                           |
| `period`        | period key         | Billing period the alert is about |
| `threshold`     | descriptor         | Threshold that was crossed        |
| `sent_at`       | timestamptz        | When delivered (FR-015)           |
| `channels_sent` | set                | Channels actually delivered to    |

Constraints: **unique on `(rule_id, period, threshold)`** so a given threshold fires at most once per period (FR-014). Append-only. The dashboard's "recent alert activity" reads from this table (FR-015).

---

## Entity relationships

```text
Organization (1) ──< (1)    Plan                      # current plan; new effective row on mid-cycle change
Organization (1) ──< (0..*) Team                       # usage attribution units (upstream)
Organization (1) ──< (0..*) MeteredUsage               # upstream, read-only; team_id null => unattributed
Organization (1) ──< (0..*) UsageAggregate             # materialized per (period, team, dimension)
Organization (1) ──< (0..1) UsageProjection            # current-period cached estimate
Organization (1) ──< (0..*) Invoice ──< (1..*) InvoiceLineItem
Organization (1) ──< (0..*) AlertRule ──< (0..*) AlertEvent   # unique (rule, period, threshold)
```

## Mapping to functional requirements

| Entity / field                                                  | Requirements                   |
| --------------------------------------------------------------- | ------------------------------ |
| Plan (name, cycle, allowances, rates)                           | FR-001, FR-002, FR-024         |
| MeteredUsage + UsageAggregate (single-pass, unattributed)       | FR-002, FR-007, FR-010, SC-006 |
| UsageProjection (split, basis, confidence)                      | FR-003, FR-004, FR-005         |
| UsageAggregate.computed_at / metering freshness                 | FR-006                         |
| UsageAggregate across periods (comparison + drivers)            | FR-008, FR-009                 |
| AlertRule (enable, threshold, channels)                         | FR-011, FR-012                 |
| AlertEvent (sent_at, unique key)                                | FR-013, FR-014, FR-015, SC-003 |
| Invoice + InvoiceLineItem                                       | FR-016, FR-017                 |
| invoice export (CSV over invoice + line items)                  | FR-018                         |
| empty-state resolution (no usage / no invoices / no team usage) | FR-019, FR-020, FR-021, SC-005 |
| Organization.org_id scoping + role gate                         | FR-022                         |
| Organization.billing_currency                                   | FR-023                         |
