# Contract: Rate-Limited Response Envelope

Applies to **every** authenticated API route behind the limiter. Defines what
callers receive when accepted and when rejected. Covers FR-005, FR-006, FR-007, FR-008.

## Accepted request

The request proceeds to its handler. Informational headers are added so callers can self-throttle:

```
X-RateLimit-Limit-Minute: <burst_limit_per_minute>
X-RateLimit-Remaining-Minute: <remaining in current minute>
X-RateLimit-Limit-Month: <monthly_quota>
X-RateLimit-Remaining-Month: <remaining this month>
```

## Rejected request (over limit)

**Status**: `429 Too Many Requests`

**Required headers**:

```
Retry-After: <integer seconds to wait>      # FR-006; longer wait when both limits hit (FR-008)
```

**Body** (`application/json`):

```json
{
  "error": "rate_limited",
  "message": "Monthly request quota exceeded. Retry after the quota resets.",
  "binding_limit": "monthly",
  "limit": 100000,
  "retry_after_seconds": 86400,
  "resets_at": "2026-06-01T00:00:00Z"
}
```

Field rules:

| Field                 | Rule                                                                        |
| --------------------- | --------------------------------------------------------------------------- |
| `binding_limit`       | `"burst"` or `"monthly"`; names the limit that blocked the request (FR-007) |
| `message`             | Human-readable; names which limit was hit (FR-007)                          |
| `retry_after_seconds` | Equals `Retry-After`; the **longer** wait when both are violated (FR-008)   |
| `resets_at`           | UTC instant the binding window resets                                       |

## Contract test scenarios

| #   | Given                             | When                         | Then                                                                | Maps to               |
| --- | --------------------------------- | ---------------------------- | ------------------------------------------------------------------- | --------------------- |
| 1   | burst limit N, N used this minute | one more request this minute | 429, `binding_limit=burst`, `Retry-After` ≤ 60                      | AS1.2, FR-005/006/007 |
| 2   | monthly quota M exhausted         | another request this month   | 429, `binding_limit=monthly`, `Retry-After` = secs to next month    | AS2.2, FR-006         |
| 3   | both burst and monthly exceeded   | a request                    | 429, `binding_limit=monthly`, `Retry-After` = longer (monthly) wait | AS2.4, FR-008         |
| 4   | within both limits                | a request                    | 200, `X-RateLimit-Remaining-*` decremented                          | AS1.1                 |
