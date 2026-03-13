# AdCP — Agentic Discovery Commerce Protocol

**Version:** 0.1.0 (Draft)
**License:** MIT
**Transport:** MCP (Model Context Protocol)
**Status:** Draft — open for feedback

## What is AdCP?

AdCP is an open protocol for communication between AI agents and commerce servers. It defines how agents discover products, request bids, and attribute value — all through standardized, auditable message types built on top of [MCP](https://modelcontextprotocol.io).

AdCP is not a product. It is a specification that anyone can implement.

## Quick Start

```bash
npm install @protocol-commerce/adcp-sdk
```

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
```

## Specification

| Document | Description |
|----------|-------------|
| [Messages](spec/messages.md) | Message types: search, product detail, category browse, bid, attribution |
| [Scoring](spec/scoring.md) | The public scoring formula and weight configuration |
| [Attribution](spec/attribution.md) | How value contribution is tracked without user surveillance |
| [Privacy](spec/privacy.md) | The privacy model: context signals, not user profiles |
| [Interop](spec/interop.md) | Bridges to OpenRTB 2.6, ARTF, Prebid.js |

## Schemas

JSON Schema definitions for all message types are in [`schemas/`](schemas/).

## Examples

Working examples for common integration patterns are in [`examples/`](examples/).

## Design Rationale

### Why MCP?

MCP (Model Context Protocol) is an open standard by Anthropic for agent-to-tool communication. It provides:

- JSON-RPC 2.0 transport (well-understood, widely supported)
- Tool discovery and capability negotiation
- Growing ecosystem (Claude, ChatGPT via MCP adapters, custom agents)
- Stateless HTTP transport suitable for serverless deployments

AdCP extends MCP with commerce-specific semantics. An AdCP server is a valid MCP server — any MCP client can connect.

### Why First-Price Sealed-Bid?

Unlike second-price auctions (where the winner pays the second-highest bid), first-price sealed-bid auctions are simpler and more transparent:

- **What you bid is what you pay.** No bid shading, no gaming.
- **Predictable costs** for advertisers.
- **Industry trend:** Google Ad Manager switched to first-price in 2019. The industry has moved on from second-price.

### Why Context Over Identity?

Traditional ad tech relies on user profiles built from cookies, fingerprinting, and cross-site tracking. AdCP takes a different approach:

- **Context signals** describe the page, the query, and the intent — not the user.
- **No cookies, no fingerprinting, no user IDs** cross the protocol boundary.
- **Regulatory simplicity:** No GDPR consent flows for ad targeting, because no personal data is processed for targeting.

### Why Revenue Share?

Fixed CPM pricing doesn't reflect the value of agent-mediated commerce. Revenue share aligns incentives:

- Default: **70% publisher / 30% platform** (configurable per deployment)
- Higher-value interactions (purchases, detailed product queries) generate proportionally more revenue
- Publishers are incentivized to provide high-quality content that agents find useful

## Versioning

AdCP follows [Semantic Versioning](https://semver.org/):

- **v0.x.x** — Draft phase. Breaking changes expected. Feedback welcome.
- **v1.0.0** — Stable. Breaking changes only in major versions.

Current version: **v0.1.0**

## Relationship to Existing Standards

AdCP does not replace existing ad-tech standards. It adds an agent-native layer:

```
┌──────────────────────────────────────────┐
│              AI Agent Layer               │
│    (Claude, ChatGPT, Gemini, Custom)      │
├──────────────────────────────────────────┤
│           AdCP (this protocol)            │
│    Agent ↔ Commerce Server via MCP        │
├──────────────────────────────────────────┤
│        Compatibility Bridges              │
│   OpenRTB 2.6 │ Prebid.js │ ARTF │ GPP   │
├──────────────────────────────────────────┤
│      Existing Programmatic Infra          │
│    DSPs │ SSPs │ Ad Exchanges │ GAM       │
└──────────────────────────────────────────┘
```

## Contributing

1. **Spec feedback:** Open an issue describing the problem and proposed change
2. **Schema contributions:** PRs to `schemas/` with JSON Schema definitions
3. **New message types:** Propose via issue, discuss, then PR
4. **Implementations:** Build a server or client — list it in the ecosystem

## Maintainers

| Name | Organization | Role |
|------|-------------|------|
| Holger von Ellerts | [Nexbid](https://nexbid.dev) | Lead maintainer |

## License

MIT
