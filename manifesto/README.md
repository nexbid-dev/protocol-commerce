# Protocol Commerce: An Open Standard for Agent-Native Commerce

> The protocols chosen today will define the next decade of digital commerce.
> Choose open.

## Abstract

AI agents are becoming the primary interface for product discovery, comparison, and purchase. The protocols powering this shift — OpenAI's ACP, Google's UCP, Amazon's Rufus — are proprietary, centralized, and designed to benefit the platform, not the participant. There is no open standard for agent-to-commerce communication that represents all stakeholders: merchants, publishers, and brands alike.

**Protocol Commerce** is the discipline of conducting commerce transactions through open, standardized protocols — instead of proprietary platforms. This repository defines the principles, landscape, and rationale for an open approach.

## Why This Matters

Three numbers tell the story:

- **$26 billion** — projected AI advertising market by 2029, up from $1B in 2025 (Source: FAZ, March 2026)
- **58%** of consumers have partially replaced traditional search with generative AI (Source: Salesforce, 2025)
- **+805%** year-over-year growth in AI-referred traffic to retail sites (Source: Adobe Analytics, 2025)

The infrastructure for this market is being built right now. Once protocols ossify, switching costs make change nearly impossible. The browser wars, the mobile platform wars, the payment rails — history shows that protocol decisions made in year one persist for decades.

## The Problem

### 1. Proprietary Lock-in

ACP (OpenAI/Stripe) and UCP (Google/Shopify) are closed protocols controlled by single entities. Merchants who integrate today depend on platform decisions tomorrow. Pricing, visibility, and terms can change unilaterally.

### 2. Publisher Exclusion

Neither ACP nor UCP provides a role for publishers — the entities that create content, build audiences, and provide the context that makes agent recommendations valuable. When an AI agent recommends a product based on a publisher's review, the publisher receives nothing.

### 3. Opaque Auctions

Current agent-commerce systems do not disclose how product recommendations are ranked. Merchants cannot verify whether visibility is earned through relevance or purchased through opaque fees.

### 4. Privacy Theater

Platform-controlled protocols route user data through centralized systems. "Privacy-first" claims are unverifiable when the protocol is closed-source.

## Principles

See [PRINCIPLES.md](PRINCIPLES.md) for the seven design principles that guide Protocol Commerce.

## The Protocol Landscape (2026)

See [LANDSCAPE.md](LANDSCAPE.md) for a technical comparison of ACP, UCP, and AdCP.

## The Four Layers of Protocol Commerce

Protocol Commerce operates across four distinct layers, each requiring open standards:

### Layer 1: Discovery

How does an agent find relevant products and content? An open discovery protocol allows any commerce participant — merchant, publisher, brand — to make offerings visible to agents without platform gatekeeping.

### Layer 2: Transaction

How is a transaction initiated and settled? Protocol Commerce expands the transaction concept beyond direct purchases: a product recommendation, a review retrieval, or a price comparison query all generate value and can be billed.

### Layer 3: Attribution

Who contributed to the outcome? When an agent recommends a product based on data from three sources (merchant feed, publisher review, brand specification), an open attribution model determines fair revenue distribution — not controlled by a single platform.

### Layer 4: Settlement

How does money flow? Revenue share, enriched snippets, subscriptions, and hybrid models — the settlement layer must be transparent, configurable, and auditable.

## Getting Started

- **Read the spec:** [adcp-spec](https://github.com/nexbid-dev/protocol-commerce/adcp-spec) — the Agentic Discovery Commerce Protocol
- **Use the SDK:** [adcp-sdk-typescript](https://github.com/nexbid-dev/protocol-commerce/adcp-sdk-typescript) — TypeScript client library
- **Try a live implementation:** [nexbid.dev](https://nexbid.dev) — reference implementation by Nexbid

## Contributing

Protocol Commerce is an open initiative. Contributions are welcome:

1. **Spec feedback:** Open issues on [adcp-spec](https://github.com/nexbid-dev/protocol-commerce/adcp-spec)
2. **SDK contributions:** PRs on [adcp-sdk-typescript](https://github.com/nexbid-dev/protocol-commerce/adcp-sdk-typescript)
3. **New language SDKs:** Python, Go, Rust — see the spec and build a client
4. **Implementations:** Build your own AdCP-compatible server

## Governance

**Phase 1 (current):** [Nexbid](https://nexbid.dev) acts as initial maintainer and benevolent dictator. Spec changes are proposed via GitHub issues and decided by the maintainer team.

**Phase 2 (3+ external contributors):** RFC process for spec changes. Community review periods. Consensus-based decision making.

**Phase 3 (broad adoption):** Foundation governance under an appropriate standards body.

## Sponsors

| Sponsor | Role |
|---------|------|
| [Nexbid](https://nexbid.dev) | Initiator, reference implementation, initial maintainer |
| *Your organization?* | [Become a sponsor →](https://github.com/nexbid-dev/protocol-commerce/manifesto/issues/new) |

## License

MIT — because commerce infrastructure should be auditable, forkable, and free from lock-in.

## Further Reading

- [Protocol Commerce Manifesto](https://digital-opua.ch/blog/protocol-commerce-manifesto) — strategic perspective (German)
- [Nexbid Documentation](https://nexbid.dev) — reference implementation
- [AdCP Specification](https://github.com/nexbid-dev/protocol-commerce/adcp-spec) — the protocol
