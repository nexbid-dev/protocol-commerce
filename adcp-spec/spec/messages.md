# AdCP Message Types

**Version:** 0.1.0

AdCP defines a set of MCP tool calls that commerce servers expose to AI agents. Each tool follows the MCP tool specification with AdCP-specific parameters and response formats.

## Discovery Messages

### `adcp.search` — Product Search

The primary discovery tool. Agents send a natural-language query with optional filters. The server returns ranked products.

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `query` | string | Yes | Natural language search query (1-500 chars) |
| `intent` | enum | No | `purchase`, `compare`, `research`, `browse` |
| `geo` | string | No | ISO 3166-1 alpha-2 country code (e.g., `CH`, `DE`) |
| `category` | string | No | Product category filter |
| `brand` | string | No | Brand name filter |
| `budget_min_cents` | integer | No | Minimum price in cents |
| `budget_max_cents` | integer | No | Maximum price in cents |
| `currency` | enum | No | `CHF`, `EUR`, `USD`, `GBP` |
| `max_results` | integer | No | 1-50, default 10 |

**Response:**

```json
{
  "products": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "title": "Bio Olivenöl Extra Vergine",
      "description": "Cold-pressed organic olive oil from Tuscany",
      "url": "https://shop.example.com/product/123",
      "imageUrl": "https://cdn.example.com/images/oliveoil.jpg",
      "price": {
        "amount": 19.90,
        "currency": "CHF"
      },
      "category": "Food & Beverages",
      "brand": "Alnatura",
      "availability": "in_stock",
      "score": 0.85,
      "sponsored": false
    }
  ],
  "totalMatches": 42,
  "latencyMs": 125
}
```

**Score Calculation:**

For organic (non-sponsored) results: `score = semantic_similarity(query, product)` (0.0 to 1.0).

For sponsored results: `score = 0.4 × normalized_bid + 0.4 × similarity + 0.2 × quality_signal`. See [Scoring](scoring.md).

**Sponsored Indicator:**

Sponsored products MUST include `"sponsored": true`. The agent SHOULD disclose sponsored results to the user. Transparency is a protocol requirement, not a recommendation.

---

### `adcp.product` — Product Detail

Retrieves full details for a specific product by ID.

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `product_id` | string (UUID) | Yes | Product identifier from search results |

**Response:**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Bio Olivenöl Extra Vergine",
  "description": "Cold-pressed organic olive oil from Tuscany. 500ml bottle.",
  "url": "https://shop.example.com/product/123",
  "imageUrl": "https://cdn.example.com/images/oliveoil.jpg",
  "price": {
    "amount": 19.90,
    "currency": "CHF"
  },
  "category": "Food & Beverages",
  "brand": "Alnatura",
  "availability": "in_stock",
  "geoScope": ["CH", "DE", "AT"],
  "createdAt": "2026-01-15T10:30:00Z",
  "updatedAt": "2026-03-10T14:22:00Z"
}
```

---

### `adcp.categories` — Category Browse

Lists available product categories with counts. Useful for agents building browse experiences.

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `geo` | string | No | ISO 3166-1 alpha-2 country code to filter categories |

**Response:**

```json
{
  "categories": [
    { "category": "Food & Beverages", "productCount": 1234 },
    { "category": "Electronics", "productCount": 567 },
    { "category": "Home & Garden", "productCount": 890 }
  ]
}
```

---

## Auction Messages (v0.2.0 — Planned)

The following message types are planned for the next spec revision. They extend the discovery flow with bidding and revenue mechanics.

### `adcp.bid` — Submit Bid

Advertisers (or their agents) submit bids for visibility in response to a specific query context.

**Parameters (draft):**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `campaign_id` | string (UUID) | Yes | Campaign identifier |
| `product_id` | string (UUID) | Yes | Product to bid on |
| `bid_cents` | integer | Yes | Bid amount in cents (≥ 1) |
| `placement_type` | enum | No | `search`, `recommendation`, `category` |
| `geo` | string | No | Target geography |

### `adcp.decision` — Auction Result

Server communicates the auction outcome.

### `adcp.report` — Attribution Event

Tracks value-generating events. See [Attribution](attribution.md).

---

## Common Types

### Price Object

```json
{
  "amount": 19.90,
  "currency": "CHF"
}
```

Currencies: `CHF`, `EUR`, `USD`, `GBP`. Amount is a decimal number representing the display price (not cents).

### Availability

`in_stock` | `out_of_stock` | `preorder`

### Search Intent

`purchase` | `compare` | `research` | `browse`

Agents SHOULD set intent when known. Servers MAY use intent to adjust ranking (e.g., `purchase` intent may weight price more heavily).

### Error Response

```json
{
  "error": "Product not found",
  "code": "NOT_FOUND"
}
```

Standard error codes: `NOT_FOUND`, `INVALID_INPUT`, `RATE_LIMITED`, `UNAUTHORIZED`, `INTERNAL_ERROR`.

---

## MCP Compliance

All AdCP tools follow MCP tool conventions:

- **Hints:** `readOnlyHint: true`, `idempotentHint: true`, `openWorldHint: true` (for discovery tools)
- **Transport:** JSON-RPC 2.0 over HTTP (Streamable HTTP transport)
- **Authentication:** API key via `x-api-key` header or `Authorization: Bearer <token>`
- **Content type:** Responses use `text/plain` with structured content for agent consumption

Servers MUST support the MCP `initialize`, `tools/list`, and `tools/call` methods.
