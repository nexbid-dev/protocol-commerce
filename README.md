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

## Sponsors

| Sponsor | Role |
|---------|------|
| [Nexbid](https://nexbid.dev) | Initiator, reference implementation, initial maintainer |

## License

MIT

## Links

- [AdCP Specification](adcp-spec/)
- [Protocol Landscape (ACP vs UCP vs AdCP)](manifesto/LANDSCAPE.md)
- [Nexbid — Reference Implementation](https://nexbid.dev)
- [Protocol Commerce Manifesto (DE)](https://digital-opua.ch/blog/protocol-commerce-manifesto)
