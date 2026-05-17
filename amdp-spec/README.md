# AMDP — Agent Mandate Discovery Protocol

> An open protocol for discovering, verifying, and revoking cross-vertical agent mandates.

**Version:** 0.1.0
**Status:** Draft — open for feedback, breaking changes expected
**License:** MIT (specification) / Apache 2.0 (reference implementations)
**Spec authoring org:** [digital opua GmbH](https://nexbid.dev) (Switzerland) via [Nexbid](https://nexbid.dev)
**Submission targets:** IAB Tech Lab AAMP · Linux Foundation Agent-Infrastructure-WG

---

## What is AMDP?

AMDP is an open protocol that answers a single, structurally-difficult question across the entire agent-commerce stack:

> Which agent is authorized to do what, on behalf of whom, with which constraints, in which vertical — and how do third parties verify and revoke that authorization?

Today, every vertical (advertising, procurement, equity research, public services) reimplements its own mandate logic. AMDP standardizes the layer **underneath** verticals, not next to them. It is not a marketplace, not a capability registry, not a transaction protocol — it is the **mandate-discovery layer** that those three depend on.

## Status: v0.1.0 Draft

This is a **working draft**, not a final standard. The protocol surface, schemas, error codes, and taxonomy will change as the spec moves toward v1.0.0. Implementers should expect breaking changes between minor versions during the v0.x phase.

| Version range | Stability promise |
|---------------|-------------------|
| `v0.x.x` | Draft. Breaking changes between minor versions are expected. Feedback welcome. |
| `v1.0.0` | Stable. Breaking changes only in major versions. |

Current version: **v0.1.0** (initial draft, 2026-05-17).

## Position in the Agent-Commerce Stack

AMDP is the fourth, currently-missing layer in the agent-commerce stack:

```
+----------------------------------------------------+
|                  AI Agent Layer                    |
|       Claude · ChatGPT · Gemini · Custom           |
+----------------------------------------------------+
|              Marketplace Layer (existing)          |
|  Circle Agent Marketplace · Shoppable UCM · ...    |
+----------------------------------------------------+
|         Capability-Registry Layer (existing)       |
|     IAB Tech Lab Agent Registry · MCP Registry     |
+----------------------------------------------------+
|         Transaction-Protocol Layer (existing)      |
|         UCP · ACP · AdCP · AP2 · x402              |
+====================================================+
|        Mandate-Discovery Layer (this spec)         |
|                       AMDP                         |
+----------------------------------------------------+
```

The three upper layers all rely on an answer to "is this agent authorized to act?" but none of them define that answer in a cross-vertical, third-party-verifiable way. AMDP fills that gap.

## Three components

```
+------------------+      +------------------+      +-------------------+
| Mandate Document |----->| Resolver Endpoint|----->| Discovery Endpoint|
+------------------+      +------------------+      +-------------------+
   Signed JSON              GET /.well-known/         GET /.well-known/
   issued by principal      amdp/verify              amdp/discover
   carried by agent         POST .../revoke          (federated lookup)
```

1. **Mandate Document** — A signed JSON document a principal (user, company, family office) issues to authorize an agent for one or more vertical-bound actions under explicit constraints. See [Mandate Schema](SPECIFICATION.md#2-mandate-document-schema).

2. **Resolver Endpoint** — A well-known HTTP endpoint a relying party (merchant, exchange, public-service portal) calls to verify a mandate's signature, expiration, revocation status, and constraint applicability for a proposed action. See [Resolver Spec](SPECIFICATION.md#7-resolver-endpoint-spec).

3. **Discovery Endpoint** — An optional federated lookup that returns the list of resolver endpoints supporting a given vertical-action pair, so an agent can find a compatible resolver without hard-coded URLs. See [Discovery Spec](SPECIFICATION.md#8-discovery-endpoint-spec).

## Quick Start

### Minimal mandate document

```json
{
  "amdp_version": "0.1.0",
  "mandate_id": "01904ad8-5e1e-7d2a-8b1c-4f5e6a7b8c9d",
  "principal": {
    "id": "did:web:family-office.example",
    "verifier_url": "https://family-office.example/.well-known/amdp/jwks"
  },
  "agent": {
    "id": "did:web:agent.example/agents/research-bot-1",
    "name": "Research Bot 1"
  },
  "scope": {
    "vertical": "equity-research",
    "actions": ["make_investment_decision"],
    "constraints": {
      "max_amount": { "value": 500000, "currency": "USD" },
      "time_window": {
        "from": "2026-05-17T00:00:00Z",
        "to": "2026-08-17T00:00:00Z"
      },
      "asset_classes": ["mining-equity", "energy-equity"]
    }
  },
  "issued_at": "2026-05-17T10:00:00Z",
  "expires_at": "2026-08-17T00:00:00Z",
  "signature": {
    "algorithm": "hybrid-ed25519-mldsa65",
    "value": "..."
  }
}
```

### Verify a mandate (resolver-side)

```bash
curl -s "https://family-office.example/.well-known/amdp/verify?mandate_id=01904ad8-5e1e-7d2a-8b1c-4f5e6a7b8c9d" \
  -H "Accept: application/json"
```

```json
{
  "valid": true,
  "reason": null,
  "constraints_match": true,
  "remaining_actions": ["make_investment_decision"]
}
```

A status code of `200` means the mandate is currently valid for the queried action. `401` means signature failed, `403` means expired, `404` means unknown mandate, `410` means revoked. See [Error Codes](SPECIFICATION.md#9-error-codes).

## Specification

| Document | Description |
|----------|-------------|
| [SPECIFICATION.md](SPECIFICATION.md) | Main specification: terminology, schemas, taxonomies, signature algorithms, endpoint specs, error codes, versioning policy |
| [CONFORMANCE.md](CONFORMANCE.md) | MUST / SHOULD / MAY requirements for AMDP-conformant verifiers, resolvers, and discovery endpoints; test-vectors plan |
| [SECURITY.md](SECURITY.md) | Threat model (T1-T6), PQC migration strategy, audit-log requirements |
| [CHANGELOG.md](CHANGELOG.md) | Version history |
| [REFERENCES.md](REFERENCES.md) | Cross-references to related ADRs, RFCs, IAB Tech Lab, Linux Foundation |
| [examples/](examples/) | Validated reference mandate documents covering five concrete scenarios |

## Why a separate protocol?

A reasonable reader will ask: why not extend an existing protocol like ACP, UCP, AdCP, or AP2 to cover mandates?

The honest answer is that each of those protocols handles a different layer:

- **ACP / UCP** answer *how a transaction is executed* (cart, checkout, settlement). They assume the agent is already authorized.
- **AdCP** answers *how an agent discovers and ranks commerce inventory* (search, scoring, attribution). It also assumes authorization exists.
- **AP2** answers *how to bind an intent to a payment instrument* at a single point in time. It is mandate-adjacent but transaction-bound and single-vertical.
- **x402** answers *how to settle a micropayment via HTTP*. Out of scope for authorization.

What none of them define is the **cross-vertical, revocable, third-party-verifiable mandate** that a relying party in one vertical can use to verify an agent acting on behalf of a principal whose primary identity lives in another vertical. AMDP fills that specific gap, and is designed to interoperate with all four (mandate produced once, consumed by ACP carts, UCP checkouts, AdCP attributions, AP2 payment bindings).

## Relationship to existing precedents

AMDP generalizes patterns established in two earlier specifications:

- **ADR-008 Universal Purchase Mandate** (Nexbid, 2026-04-23) defined a single-vertical (commerce / payment) Ed25519-signed mandate format. AMDP extends that pattern cross-vertical and adds a discovery layer. See [REFERENCES.md](REFERENCES.md).

- **ADR-025 Crypto-Agility and PQC Migration** (Nexbid, 2026-04-29) established the Hybrid Ed25519 + ML-DSA-65 signature scheme used in AMDP for post-quantum readiness. AMDP signatures conform to that scheme.

## License

- **Specification:** MIT — free to read, implement, fork, distribute. See [LICENSE](../LICENSE).
- **Reference implementations** (planned, separate repos): Apache 2.0 — explicit patent grant.

## Co-Maintainers

Open. Initial draft authored by digital opua GmbH (CHE-435.289.702, Switzerland) via Nexbid. Submission to IAB Tech Lab AAMP and Linux Foundation Agent-Infrastructure-WG is in progress; co-maintainership will reflect those affiliations once submission is accepted.

| Role | Holder | Affiliation |
|------|--------|-------------|
| Initial editor | Holger von Ellerts | digital opua GmbH / Nexbid |
| AAMP submission contact | TBD | IAB Tech Lab (post-submission) |
| LF Agent-Infra WG contact | TBD | Linux Foundation (post-submission) |
| EU sovereignty co-maintainer | TBD | (open seat) |

## Contributing

1. **Spec feedback:** Open an issue in `nexbid-dev/protocol-commerce` describing the problem and proposed change. Tag with `area:amdp`.
2. **Schema contributions:** PRs against [SPECIFICATION.md](SPECIFICATION.md) and [examples/](examples/). Examples must validate against the Mandate schema in `SPECIFICATION.md` section 2.
3. **New verticals / actions / constraints:** Propose via issue, discuss, then PR. See the IANA-style taxonomy registry in `SPECIFICATION.md` sections 3-5.
4. **Reference implementations:** Build a verifier, resolver, or discovery endpoint — list it under "Reference implementations" once interoperability tests pass.

## Cross-repo links

- ADR-040 (this protocol's rationale): `github.com/Baldri/nexbid/blob/main/docs/knowledge-base/adr/040-amdp-agent-mandate-discovery-protocol.md`
- Strategy note (positioning): `github.com/Baldri/nexbid/blob/main/docs/strategy/2026-05-17-amdp-google-fuer-agenten-ehrliche-positionierung.md`
- IAB Tech Lab submission draft: `github.com/Baldri/nexbid/blob/main/docs/outreach/2026-05-17-iab-amdp-submission-draft.md`
- ADR-008 (single-vertical precedent): `github.com/Baldri/nexbid/blob/main/docs/knowledge-base/adr/008-payment-authorization-and-purchase-mandate.md`
- ADR-025 (PQC migration): `github.com/Baldri/nexbid/blob/main/docs/knowledge-base/adr/025-crypto-agility-and-pqc-migration.md`
