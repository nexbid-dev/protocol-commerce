# The Protocol Landscape (March 2026)

A technical comparison of the three dominant agent-commerce protocol approaches and the open alternative.

## Overview

| Dimension | ACP (OpenAI/Stripe) | UCP (Google) | Amazon Rufus | AdCP (Open) |
|-----------|-------------------|-------------|-------------|-------------|
| **Governance** | OpenAI Inc. | Google LLC | Amazon Inc. | Community (MIT) |
| **License** | Proprietary | Proprietary | Proprietary | MIT |
| **Transport** | Stripe API | Google APIs | Internal | MCP (JSON-RPC 2.0) |
| **Architecture** | Centralized | Centralized | Closed | Decentralized |
| **Publisher Role** | None | None | None | First-class participant |
| **Privacy Model** | Platform-controlled | Google ecosystem | Amazon ecosystem | No cookies, no fingerprinting |
| **Scoring Transparency** | Opaque | Opaque | Opaque | Public formula |
| **Revenue Share** | ~96/4 (OpenAI retains ~4%) | Google-controlled | N/A (Amazon only) | 70/30 default (configurable) |
| **Lock-in Risk** | High | High | Maximum | None (MIT) |
| **Agent Support** | ChatGPT only | Gemini primarily | Alexa/Rufus only | Any MCP-compatible agent |

## ACP — Agentic Commerce Protocol (OpenAI/Stripe)

**Launched:** September 2025
**Partners:** Stripe (payment infrastructure)
**Model:** Pay-per-completed-purchase

### Architecture

ACP embeds the entire commerce flow inside ChatGPT. Users discover products in the chat interface, and Stripe handles checkout without leaving the conversation.

### Current Status (March 2026)

OpenAI has scaled back Instant Checkout (Sources: SearchEngineLand, Forrester, The Drum, March 2026). Key issues:

- Users browse in ChatGPT but purchase on merchant sites
- Of 1M+ announced Shopify merchants, approximately a dozen actually integrated (Source: Awesome Agents)
- No system for collecting and remitting US sales tax across states
- ChatGPT is repositioning as a **discovery engine**, not a transaction platform

### Technical Characteristics

- Stripe-based payment flow
- Merchant-only integration (no publisher path)
- Minimum ad spend: $200K (early pilot)
- CPM ~$60 (3× Meta rates)
- No disclosed ranking algorithm
- Closed ecosystem: ChatGPT agents only

### Implications

ACP addresses the merchant-to-consumer path but creates single-vendor dependency. Pricing, visibility rules, and terms are set by OpenAI. Merchants cannot verify ranking decisions or switch to an alternative without rebuilding their integration.

## UCP — Universal Commerce Protocol (Google)

**Launched:** January 2026 (NRF Retail's Big Show)
**Partners:** Shopify, Wayfair, Target, Walmart, Zalando, 20+ others (Source: Google Developers Blog)
**Model:** Platform integration fee (details undisclosed)

### Architecture

UCP provides a unified API layer that merchants integrate once to make their products available across Google's AI surfaces (Search, Shopping, Gemini).

### Technical Characteristics

- Solves the N×N integration problem (one integration, many surfaces)
- Built on Google's existing Shopping infrastructure
- Supports structured product data (similar to Google Merchant Center)
- Integration with Google Ads ecosystem

### Conflict of Interest

Google simultaneously controls:
1. The protocol specification
2. The largest search engine
3. The largest display advertising network
4. A major AI assistant (Gemini)
5. The Android mobile ecosystem

This concentration creates structural incentives to steer the protocol toward Google's advertising business. The protocol's openness claims are unverifiable without source code access.

### Implications

UCP addresses a real problem (integration fragmentation) but concentrates control. Publishers are not represented. Merchants gain reach but lose independence — Google controls the rules of visibility.

## Amazon Rufus / Alexa+

**Status:** Internal, not a public protocol
**Users:** 300M+ (Amazon customer base)
**Key metric:** +60% purchase likelihood with Rufus recommendations

### Architecture

Amazon operates entirely within its own ecosystem. Rufus AI handles product discovery, and Alexa+ extends this to voice commerce. There is no external protocol — third-party participation is limited to selling on Amazon Marketplace.

### Implications

Amazon's approach is the most closed but also the most proven commercially. It demonstrates that AI-driven product discovery significantly increases conversion. However, it is not a protocol — it is a proprietary system with no external integration path.

## AdCP — Agentic Discovery Commerce Protocol (Open)

**Status:** v0.1.0 Draft
**License:** MIT
**Transport:** MCP (Model Context Protocol)
**Governance:** Nexbid (initial maintainer) → Community

### Architecture

AdCP extends Anthropic's Model Context Protocol (MCP) with commerce-specific message types. Any MCP-compatible AI agent can communicate with any AdCP-compatible server through standardized messages.

```
Agent ──MCP──▶ AdCP Server ──▶ Auction Engine ──▶ Results
                    │
                    ├── Products (merchant feeds)
                    ├── Content (publisher inventory)
                    └── Context signals (no user data)
```

### Design Decisions

| Decision | Rationale |
|----------|-----------|
| MCP as transport | Growing ecosystem (Claude, ChatGPT via MCP, custom agents). JSON-RPC 2.0 is well-understood. |
| First-price sealed-bid | Simpler than second-price. No bid shading. What you bid is what you pay. |
| Context over identity | Privacy native. Context signals (page topic, intent, affinity) replace user profiles. |
| Revenue share default | 70/30 (publisher/platform). Configurable per deployment. Transparent. |
| Public scoring formula | `score = 0.4×bid + 0.4×relevance + 0.2×quality`. Verifiable by any participant. |

### Specification

Full specification: [adcp-spec](https://github.com/nexbid-dev/protocol-commerce/adcp-spec)

### Reference Implementation

[Nexbid](https://nexbid.dev) — live at api.nexbid.dev (Discovery API) and mcp.nexbid.dev (MCP Server).

## Comparison Matrix: What Each Protocol Covers

| Capability | ACP | UCP | Rufus | AdCP |
|-----------|-----|-----|-------|------|
| Product Discovery | ✅ | ✅ | ✅ | ✅ |
| In-Chat Checkout | ⚠️ (scaled back) | ❌ | ✅ (Amazon only) | ❌ (by design) |
| Publisher Monetization | ❌ | ❌ | ❌ | ✅ |
| Open Source | ❌ | ❌ | ❌ | ✅ (MIT) |
| Multi-Agent Support | ❌ (ChatGPT only) | ⚠️ (Gemini primary) | ❌ (Alexa/Rufus) | ✅ (any MCP agent) |
| Transparent Scoring | ❌ | ❌ | ❌ | ✅ |
| Privacy Native | ❌ | ❌ | ❌ | ✅ |
| Revenue Share Disclosure | ⚠️ (~96/4) | ❌ | N/A | ✅ (70/30 default) |
| Existing Ad-Tech Integration | ❌ | ✅ (Google Ads) | ❌ | ✅ (OpenRTB bridge planned) |

## Standards Interoperability Roadmap

AdCP is designed to bridge to existing standards:

| Standard | Relationship | Timeline |
|----------|-------------|----------|
| MCP | Transport layer (native) | Now |
| OpenRTB 2.6 | Compatibility bridge for programmatic buyers | Q4 2026 |
| Prebid.js | Client-side adapter for header bidding | Q4 2026 |
| ARTF v1.0 | IAB agentic framework compatibility | Q4 2026 |
| GPP 1.1 / TCF 2.2 | Privacy compliance layer | Q4 2026 |
| A2A v0.3 | Agent-to-agent communication | 2027+ |

## Sources

- FAZ: AI Advertising Market Analysis (March 2026)
- SearchEngineLand: OpenAI ChatGPT Instant Checkout Pullback (March 2026)
- Forrester: What It Means That The Leader In Agentic Commerce Just Pulled Back (March 2026)
- Google Developers Blog: Universal Commerce Protocol (January 2026)
- Adobe Analytics: AI-Referred Traffic Report (2025)
- Salesforce: Generative AI Consumer Behavior Study (2025)
- Awesome Agents: ACP Integration Tracker (March 2026)
