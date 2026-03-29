# Protocol Commerce

> The open infrastructure for agent-native commerce.

Protocol Commerce is an open initiative to create standardized, auditable, and interoperable protocols for AI agent-driven commerce. This repository contains the specification, SDKs, and technical manifesto.

## Contents

| Directory | Description |
|-----------|-------------|
| [`manifesto/`](manifesto/) | Why open protocols matter for commerce — principles, landscape analysis, and rationale |
| [`adcp-spec/`](adcp-spec/) | **AdCP v0.1.0** — Agentic Discovery Commerce Protocol specification, JSON schemas, and examples |
| [`adcp-sdk-typescript/`](adcp-sdk-typescript/) | TypeScript SDK: types, validators, client, and scoring reference implementation |
| [`webmcp-reference/`](webmcp-reference/) | WebMCP browser integration: expose commerce tools to in-browser AI agents via `navigator.modelContext` |

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

const results = await client.search({
  query: 'organic olive oil',
  intent: 'purchase',
  geo: 'CH',
});
```

## The Problem

AI agents are becoming the primary interface for product discovery and purchase. The protocols powering this shift — OpenAI's ACP, Google's UCP — are proprietary and platform-controlled. Publishers have no representation. There is no open standard.

**Protocol Commerce fills this gap.**

Read the full [Technical Manifesto →](manifesto/README.md)

## Key Principles

1. **Open by Default** — MIT-licensed, auditable, forkable
2. **Publisher Parity** — Publishers are first-class protocol participants
3. **Privacy Native** — Context signals, not user profiles
4. **Transparent Scoring** — Public formula: `score = 0.4×bid + 0.4×relevance + 0.2×quality`

[All 7 principles →](manifesto/PRINCIPLES.md)

## Reference Implementation: Nexbid

[Nexbid](https://nexbid.dev) is the production-grade reference implementation of Protocol Commerce, built by [digital opua GmbH](https://nexbid.dev) (CHE-435.289.702, Switzerland).

| Metric | Status |
|--------|--------|
| **MCP Integration** | Native — full commerce lifecycle |
| **Formal Verification** | Lean 4 — core security properties proven |
| **Privacy** | Cookie-free, Swiss-hosted, nDSG + GDPR compliant |
| **AI Scoring** | Multi-provider, model-agnostic |
| **Phase** | Production-grade closed beta |

### Connect Any LLM

```json
{
  "mcpServers": {
    "nexbid": {
      "url": "https://mcp.nexbid.dev/mcp",
      "transport": "streamable-http"
    }
  }
}
```

Any MCP-compatible LLM (Claude, GPT-4, Gemini) can directly search, browse, and purchase products through the Nexbid marketplace.

### Why Formal Verification?

Nexbid is the only commerce platform whose core security properties are mathematically proven in [Lean 4](https://lean-lang.org/) — not just tested, but proven correct for all possible inputs.

→ [Technology details](https://nexbid.dev/technology) · [How Nexbid compares](https://nexbid.dev/compare)

## Sponsors

| Sponsor | Role |
|---------|------|
| [Nexbid](https://nexbid.dev) | Initiator, reference implementation, initial maintainer |

## License

MIT — Use it, fork it, build on it. No strings attached.

## Links

- [AdCP Specification](adcp-spec/)
- [Protocol Landscape (ACP vs UCP vs AdCP)](manifesto/LANDSCAPE.md)
- [Nexbid — Reference Implementation](https://nexbid.dev)
- [Nexbid Technology & Facts](https://nexbid.dev/technology)
- [Nexbid vs. Traditional Ad Servers](https://nexbid.dev/compare)
- [MCP Documentation](https://nexbid.dev/docs/mcp)
- [Formal Verification](https://nexbid.dev/docs/verification)
- [Protocol Commerce Manifesto (DE)](https://digital-opua.ch/blog/protocol-commerce--warum-commerce-offene-protokolle-braucht)
