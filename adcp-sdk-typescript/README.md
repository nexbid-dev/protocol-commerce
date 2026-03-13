# @protocol-commerce/adcp-sdk

TypeScript SDK for the [Agentic Discovery Commerce Protocol (AdCP)](https://github.com/nexbid-dev/protocol-commerce).

## Install

```bash
npm install @protocol-commerce/adcp-sdk
```

## Quick Start

```typescript
import { AdcpClient } from '@protocol-commerce/adcp-sdk';

const client = new AdcpClient({
  serverUrl: 'https://mcp.nexbid.dev',
  apiKey: 'your-api-key',
});

// Search for products
const results = await client.search({
  query: 'organic olive oil',
  intent: 'purchase',
  geo: 'CH',
  maxResults: 5,
});

for (const product of results.products) {
  console.log(`${product.title} — ${product.price.amount} ${product.price.currency}`);
  if (product.sponsored) console.log('  [Sponsored]');
}

// Get product details
const detail = await client.product({ product_id: results.products[0].id });
console.log(`Available in: ${detail.geoScope.join(', ')}`);

// Browse categories
const categories = await client.categories({ geo: 'CH' });
for (const cat of categories.categories) {
  console.log(`${cat.category}: ${cat.productCount} products`);
}
```

## Validation

All message types have Zod validators for runtime type checking:

```typescript
import { searchParamsSchema, productResultSchema } from '@protocol-commerce/adcp-sdk';

// Validate search input
const params = searchParamsSchema.parse({
  query: 'running shoes',
  intent: 'purchase',
  geo: 'de', // auto-uppercased to 'DE'
});

// Validate server response
const product = productResultSchema.parse(serverResponse);
```

## Scoring

Reference implementation of the public scoring formula:

```typescript
import { calculateScore, normalizeBid, DEFAULT_SCORING_WEIGHTS } from '@protocol-commerce/adcp-sdk';

const score = calculateScore(
  normalizeBid(50, 100),  // bid: 50 cents, max bid: 100 cents → 0.5
  0.85,                    // similarity: 85%
  0.7,                     // quality: 70%
);
// score = 0.4 * 0.5 + 0.4 * 0.85 + 0.2 * 0.7 = 0.68
```

## Types

All protocol types are exported:

```typescript
import type {
  SearchParams,
  ProductResult,
  SearchResponse,
  ProductDetail,
  AttributionEvent,
  ScoringWeights,
  Currency,
  Availability,
  SearchIntent,
} from '@protocol-commerce/adcp-sdk';
```

## API Reference

### `AdcpClient`

| Method | Description | Returns |
|--------|-------------|---------|
| `search(params)` | Product search with optional filters | `SearchResponse` |
| `product(params)` | Get product details by UUID | `ProductDetail` |
| `categories(params?)` | List categories with product counts | `CategoriesResponse` |

### `AdcpError`

Custom error class with protocol error codes:

```typescript
import { AdcpClient, AdcpError } from '@protocol-commerce/adcp-sdk';

try {
  await client.search({ query: 'test' });
} catch (err) {
  if (err instanceof AdcpError) {
    console.log(err.code);    // 'UNAUTHORIZED', 'RATE_LIMITED', etc.
    console.log(err.message);  // Human-readable description
  }
}
```

## Compatibility

- **Node.js:** 18+
- **Runtime:** Any environment with `fetch` and `crypto.randomUUID`
- **MCP version:** 2024-11-05+
- **Dependencies:** `zod` (runtime validation only)

## License

MIT

## Links

- [AdCP Specification](https://github.com/nexbid-dev/protocol-commerce)
- [Protocol Commerce Manifesto](https://github.com/nexbid-dev/protocol-commerce)
- [Nexbid — Reference Implementation](https://nexbid.dev)
