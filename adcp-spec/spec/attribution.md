# AdCP Attribution Model

**Version:** 0.1.0

## Design Principle

> Track value, not users.

AdCP attribution measures which content sources contributed to a commerce outcome — without creating persistent user profiles or tracking users across sessions.

## Attribution Events

| Event Type | Description | Billable | Trigger |
|-----------|-------------|----------|---------|
| `impression` | Product shown to user via agent | Optional | Agent renders product in response |
| `click` | User follows product link | Yes (default) | User clicks through to merchant site |
| `add_to_cart` | User adds product to cart | Optional | Merchant-side event (requires JS pixel or server callback) |
| `purchase` | User completes purchase | Yes (CPA model) | Merchant confirms transaction |

## Event Schema

```json
{
  "eventType": "click",
  "productId": "550e8400-e29b-41d4-a716-446655440000",
  "campaignId": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "queryId": "01905b4e-3f5c-7d2a-8b1c-4f5e6a7b8c9d",
  "placementId": "placement-search-001",
  "agentType": "claude",
  "geo": "CH",
  "sourceUrl": "https://agent.example.com/chat/session-123"
}
```

### Field Definitions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `eventType` | enum | Yes | `impression`, `click`, `add_to_cart`, `purchase` |
| `productId` | UUID | Yes | The product involved |
| `campaignId` | UUID | Yes | The campaign that funded the placement |
| `queryId` | UUID v7 | Yes | The original search query ID (links event to discovery) |
| `placementId` | string | No | Publisher placement identifier |
| `agentType` | enum | No | `claude`, `chatgpt`, `gemini`, `custom`, `unknown` |
| `geo` | string | No | ISO 3166-1 alpha-2 |
| `sourceUrl` | string | No | Where the interaction occurred |

## Privacy Design

### UUID v7 Query IDs

Every search query receives a UUID v7 identifier. This ID:

- Is **time-ordered** (enables time-based analytics without user tracking)
- Is **unique per query** (no cross-session linking)
- Contains **no user-identifying information**
- Is **non-reversible** (cannot be used to reconstruct a user profile)

Attribution events reference the `queryId` to connect an outcome (click, purchase) to its origin (search query) — without knowing who the user is.

### What Is NOT Tracked

- No user IDs, session IDs, or device fingerprints
- No cookies or local storage identifiers
- No IP addresses
- No cross-site tracking pixels
- No behavioral profiles

### What IS Tracked

- Which query led to which product recommendation
- Which campaign funded the placement
- Which agent served the result
- Which geography the interaction occurred in
- Timing (via UUID v7 timestamps)

## Revenue Share Model

Attribution events trigger revenue calculations:

```
gross_revenue = bid_amount (for the winning auction)
publisher_share = gross_revenue × revenue_share_pct
platform_fee = gross_revenue × (1 - revenue_share_pct)
```

### Default Split

| Recipient | Share | Configurable |
|-----------|-------|-------------|
| Publisher | 70% | Yes (per placement) |
| Platform | 30% | Yes (per placement) |

Revenue share percentages are set per publisher placement and disclosed in the placement configuration. There are no hidden fees, no take-rate adjustments, and no opaque deductions.

## Multi-Source Attribution (v0.2.0 — Planned)

When an agent recommendation draws from multiple content sources, attribution must be distributed. For example:

- Merchant provides product feed (price, availability)
- Publisher provides product review
- Brand provides specification sheet

The planned multi-source attribution model will assign contribution weights based on:

1. **Data contribution:** Which source provided information that influenced the recommendation?
2. **Content freshness:** More recent data gets higher weight
3. **Exclusivity:** Unique information (only available from one source) gets higher weight

This is an active area of protocol development. Feedback and proposals are welcome via GitHub issues.

## Billing Trigger Configuration

Servers can configure which events trigger billing:

| Model | Billing Trigger | Use Case |
|-------|----------------|----------|
| CPC (default) | `click` | Standard product discovery |
| CPA | `purchase` | Performance-based campaigns |
| Enriched Snippet | `impression` + data retrieval | Content-rich agent responses |
| Hybrid | `click` + `purchase` (weighted) | Balanced risk sharing |

The billing model is set per campaign and disclosed to all participants.
