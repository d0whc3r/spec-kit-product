# Contract: Invoice History API (US4)

Read-only endpoints to list past invoices, open line-item detail, and export invoice
data for finance.

**Covers**: FR-016, FR-017, FR-018, FR-023, FR-020 (empty state)

---

## GET /billing/invoices

Reverse-chronological list of the org's invoices (FR-016). Supports pagination for long histories. Org resolved from session (FR-022).

**Authorization**: organization admin or billing role. Others -> `403`.

### 200 Response

```json
{
  "currency": "USD",
  "invoices": [
    {
      "invoice_id": "in_12",
      "period_start": "2026-04-01",
      "period_end": "2026-04-30",
      "issued_at": "2026-05-01T00:00:00Z",
      "total_amount": "410.00",
      "status": "paid",
      "document_url": "https://.../in_12.pdf"
    },
    {
      "invoice_id": "in_11",
      "period_start": "2026-03-01",
      "period_end": "2026-03-31",
      "issued_at": "2026-04-01T00:00:00Z",
      "total_amount": "388.00",
      "status": "refunded",
      "document_url": "https://.../in_11.pdf"
    }
  ],
  "next_cursor": null
}
```

`status` is one of `paid | pending | failed | refunded` (FR-016, Edge Case). Sorted by `issued_at` descending.

### 200 Response (empty state — no invoice history)

```json
{ "currency": "USD", "invoices": [], "next_cursor": null, "empty_state": "no_invoices_yet" }
```

Drives the invoice-history empty state for new accounts (FR-020, SC-005).

---

## GET /billing/invoices/{invoice_id}

Line-item detail for one invoice (FR-017).

### 200 Response

```json
{
  "invoice_id": "in_12",
  "currency": "USD",
  "period_start": "2026-04-01",
  "period_end": "2026-04-30",
  "issued_at": "2026-05-01T00:00:00Z",
  "status": "paid",
  "total_amount": "410.00",
  "document_url": "https://.../in_12.pdf",
  "line_items": [
    {
      "description": "Growth plan (April)",
      "dimension": null,
      "quantity": null,
      "amount": "299.00"
    },
    {
      "description": "API request overage",
      "dimension": "api_requests",
      "quantity": 90000,
      "amount": "111.00"
    }
  ]
}
```

---

## GET /billing/invoices/export

Exports invoice data in a structured, machine-readable format for finance (FR-018).

Query:

- `invoice_ids` — comma-separated list, or omitted to export all retained invoices.
- `format` — `csv` (default). The existing human-readable document remains available via each invoice's `document_url` (research §8).

### 200 Response

`Content-Type: text/csv`, `Content-Disposition: attachment; filename="invoices-<range>.csv"`.

One row per line item, with invoice-level columns repeated for joinability in spreadsheets:

```csv
invoice_id,period_start,period_end,issued_at,status,currency,line_description,dimension,quantity,line_amount,invoice_total
in_12,2026-04-01,2026-04-30,2026-05-01T00:00:00Z,paid,USD,"Growth plan (April)",,,"299.00","410.00"
in_12,2026-04-01,2026-04-30,2026-05-01T00:00:00Z,paid,USD,"API request overage",api_requests,90000,"111.00","410.00"
```

All monetary columns are in the account currency (FR-023). Achievable in under 1 minute and within 3 actions (list -> select -> export) per SC-004.

### Errors (all endpoints)

| Status | When                                           |
| ------ | ---------------------------------------------- |
| `401`  | Not authenticated                              |
| `403`  | Lacks admin/billing role (FR-022)              |
| `404`  | `invoice_id` not found or not owned by the org |
| `400`  | Unsupported `format`                           |
