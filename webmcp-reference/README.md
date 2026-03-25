# WebMCP Commerce Reference Implementation

A reference implementation showing how to expose commerce tools via the [WebMCP](https://webmachinelearning.github.io/webmcp/) browser API, making your product catalog discoverable and actionable by AI agents running in the browser.

> **Status:** WebMCP is available as a DevTrial in Chrome 146+ (since Feb 2026). GA is expected mid-to-late 2026. This implementation uses feature detection and works gracefully in browsers without WebMCP support.

## What is WebMCP?

WebMCP (Web Model Context Protocol) extends the browser with `navigator.modelContext`. Websites register structured tools that any AI agent in the browser — whether Perplexity Comet, OpenAI Atlas, or Chrome Auto Browse — can discover and execute directly.

| Dimension | Screenshot-based agents | WebMCP |
|-----------|------------------------|--------|
| Input | Pixels, DOM scraping | Typed JSON Schema |
| Reliability | Breaks on layout changes | Stable contract |
| Latency | Render + OCR + interpret | Direct function call |
| Security | Full DOM access | Scoped to registered tools |
| Privacy | Agent sees everything | Agent sees only tool schemas |

## Architecture

```
Browser Agent
    │
    ▼
navigator.modelContext.registerTool()
    │
    ▼
WebMCP Tool (client-side)
    │
    ▼
REST API (your existing backend)
```

WebMCP tools are thin client-side wrappers around your existing API endpoints. No new backend code required.

## Tools

This reference exposes 5 commerce tools:

| Tool | Description |
|------|-------------|
| `searchOffers` | Search products by query, category, brand, budget |
| `getOfferDetails` | Get full product details by ID |
| `listCategories` | List available product categories |
| `initiateTransaction` | Start a purchase (returns checkout URL) |
| `getOrderStatus` | Check purchase status |

## File Structure

```
src/
├── types.ts              # WebMCP TypeScript type definitions
├── api-client.ts         # REST API client (adapt to your endpoints)
├── register.ts           # Tool registration with feature detection
├── analytics.ts          # Optional invocation tracking
└── tools/
    ├── search-offers.ts
    ├── get-offer-details.ts
    ├── list-categories.ts
    ├── initiate-transaction.ts
    └── get-order-status.ts
```

## Integration

Call `registerNexbidWebMcpTools()` once on page load (e.g., in your root layout or app component):

```tsx
import { registerNexbidWebMcpTools } from './webmcp/register';

// In your React app:
useEffect(() => {
  registerNexbidWebMcpTools();
}, []);
```

Browsers without WebMCP support will log a debug message and continue normally.

## Adapting for Your Own Commerce Platform

1. **Replace `api-client.ts`** — Point the fetch calls to your own product API endpoints
2. **Adjust tool schemas** — Modify `inputSchema` in each tool to match your data model
3. **Update response formatting** — Adapt the `execute` functions to format your product data
4. **Add your own tools** — Follow the `WebMcpToolDefinition` interface pattern

The type definitions in `types.ts` and the registration logic in `register.ts` are generic and can be used as-is.

## Security Model

WebMCP operates in a SecureContext (HTTPS-only), respects same-origin policy, and provides:

- **Tool scoping:** Agents only see registered tools and their schemas — no access to DOM, cookies, or personal data
- **User interaction gates:** Sensitive actions (transactions) should use `requestUserInteraction()`
- **Same-origin API calls:** All backend requests go through same-origin routes (no CORS issues)

## Dual-Protocol Architecture

This WebMCP implementation complements a backend MCP server:

- **Backend MCP** — For server-side agents (Claude, GPT, etc.) via the standard Model Context Protocol
- **WebMCP** (this code) — For browser-native agents operating in the user's context, with automatic session cookie inheritance

Both protocols expose the same commerce capabilities through different channels.

## License

MIT — see [LICENSE](../LICENSE)
