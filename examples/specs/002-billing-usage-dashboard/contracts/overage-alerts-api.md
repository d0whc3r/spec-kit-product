# Contract: Overage Alerts API (US3)

Endpoints to configure projected-overage alerts and to read recent alert activity.
Alert _delivery_ and dedup are performed by the scheduled projection/alert job
(research §6); these endpoints only manage the rule and expose the event log.

**Covers**: FR-011, FR-012, FR-013, FR-014, FR-015

---

## GET /billing/alerts

Returns the org's alert rule (or the default-disabled state) and recent alert activity. Org resolved from session (FR-022).

**Authorization**: organization admin or billing role. Others -> `403`.

### 200 Response

```json
{
  "rule": {
    "rule_id": "ar_1",
    "enabled": true,
    "threshold": { "type": "percent_of_allowance", "value": 90 },
    "channels": ["email", "in_app"],
    "updated_at": "2026-05-10T12:00:00Z"
  },
  "recent_activity": [
    {
      "event_id": "ae_9",
      "period": "2026-05",
      "threshold": { "type": "percent_of_allowance", "value": 90 },
      "sent_at": "2026-05-22T06:00:00Z",
      "channels_sent": ["email", "in_app"]
    }
  ]
}
```

`recent_activity` reads the durable `AlertEvent` log (FR-015). Empty list when no alerts have fired.

---

## PUT /billing/alerts

Creates or updates the org's alert rule (FR-011, FR-012).

### Request

```json
{ "enabled": true, "threshold": { "type": "projected_overage" }, "channels": ["email", "in_app"] }
```

`threshold.type` is one of:

- `projected_overage` — fire when the projection shows any overage (FR-011).
- `percent_of_allowance` with `value` in (0, 100] — fire when projected usage reaches that percentage of the included allowance (FR-012).

### 200 Response

Returns the saved rule (same shape as `rule` above).

### Behavior notes (enforced by the job, not this endpoint)

- The job evaluates the threshold against the recomputed projection and delivers **before the period's invoice is issued** (FR-013, SC-003).
- A given `(rule, period, threshold)` fires **at most once** — the `AlertEvent` unique key dedups it (FR-014). Re-crossing the same threshold in the same period does not re-alert (AS3.2).
- Setting `enabled: false` suppresses delivery even if the threshold is crossed (FR-011, AS3.3).

### Errors

| Status | When                                                                                            |
| ------ | ----------------------------------------------------------------------------------------------- |
| `400`  | `threshold.type` invalid, or `percent_of_allowance.value` outside (0, 100], or `channels` empty |
| `401`  | Not authenticated                                                                               |
| `403`  | Lacks admin/billing role (FR-022)                                                               |
