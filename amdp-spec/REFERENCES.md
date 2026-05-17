# AMDP — References

**Version:** 0.1.0
**License:** MIT (specification)

This document collects external and internal references relevant to the AMDP specification.

---

## 1. AMDP authoring context

### ADRs (`Baldri/nexbid` repo)

- **ADR-040 — AMDP as Open Standard**
  `github.com/Baldri/nexbid/blob/main/docs/knowledge-base/adr/040-amdp-agent-mandate-discovery-protocol.md`
  Rationale, decision, alternatives, consequences, and revisit triggers for AMDP. Authored 2026-05-17.

- **ADR-008 — Payment Authorization and Universal Purchase Mandate**
  `github.com/Baldri/nexbid/blob/main/docs/knowledge-base/adr/008-payment-authorization-and-purchase-mandate.md`
  Single-vertical (commerce/payment) Ed25519-signed mandate format. AMDP generalizes this pattern cross-vertical.

- **ADR-025 — Crypto-Agility and PQC Migration**
  `github.com/Baldri/nexbid/blob/main/docs/knowledge-base/adr/025-crypto-agility-and-pqc-migration.md`
  Hybrid Ed25519 + ML-DSA-65 signature scheme. AMDP signatures conform to this scheme.

- **ADR-006 — Compliance Manifest (Ed25519 infrastructure)**
  `github.com/Baldri/nexbid/blob/main/docs/knowledge-base/adr/006-compliance-manifest.md`
  Original Ed25519 signing infrastructure that ADR-008 and ADR-025 built on.

### Companion documents

- **Strategy note (positioning):**
  `github.com/Baldri/nexbid/blob/main/docs/strategy/2026-05-17-amdp-google-fuer-agenten-ehrliche-positionierung.md`
  Honest positioning of AMDP: not "Google for agents", but the missing fourth layer of the agent-commerce stack.

- **IAB Tech Lab submission draft:**
  `github.com/Baldri/nexbid/blob/main/docs/outreach/2026-05-17-iab-amdp-submission-draft.md`
  Submission pitch for IAB Tech Lab AAMP inclusion.

---

## 2. Sibling protocols in `nexbid-dev/protocol-commerce`

- **AdCP — Agentic Discovery Commerce Protocol**
  `./adcp-spec/` (this repository)
  Adjacent protocol: agent-mediated commerce discovery, ranking, and attribution. AMDP and AdCP share the `nexbid-dev/protocol-commerce` repo and are designed for interoperability. An agent acting on an AdCP `create_media_buy` flow MAY carry an AMDP mandate authorizing the buy.

- **Protocol Commerce manifesto**
  `./manifesto/`
  Principles, landscape, and rationale for open protocols in agent-mediated commerce.

---

## 3. IETF / W3C standards

- **RFC 2119** — Key words for use in RFCs to indicate requirement levels.
  https://www.rfc-editor.org/rfc/rfc2119
  Source of MUST/SHOULD/MAY semantics.

- **RFC 3339** — Date and time on the Internet: Timestamps.
  https://www.rfc-editor.org/rfc/rfc3339
  Used for `issued_at`, `expires_at`, `time_window`.

- **RFC 7517** — JSON Web Key (JWK) and JWK Set (JWKS).
  https://www.rfc-editor.org/rfc/rfc7517
  Principal public-key distribution.

- **RFC 8032** — Edwards-Curve Digital Signature Algorithm (EdDSA).
  https://www.rfc-editor.org/rfc/rfc8032
  Ed25519 component of `hybrid-ed25519-mldsa65`.

- **RFC 8785** — JSON Canonicalization Scheme (JCS).
  https://www.rfc-editor.org/rfc/rfc8785
  Deterministic byte-stream for signing.

- **RFC 9052** — CBOR Object Signing and Encryption (COSE).
  https://www.rfc-editor.org/rfc/rfc9052
  COSE_Sign1 wrapping format for AMDP signatures.

- **RFC 9457** — Problem Details for HTTP APIs.
  https://www.rfc-editor.org/rfc/rfc9457
  Error response format on resolver endpoints.

- **draft-ietf-uuidrev-rfc4122bis** — UUID v7.
  https://datatracker.ietf.org/doc/draft-ietf-uuidrev-rfc4122bis/
  Time-ordered, unique mandate identifiers.

- **W3C DID Core v1.0** — Decentralized Identifiers.
  https://www.w3.org/TR/did-core/
  Principal and agent identification.

---

## 4. NIST / FIPS

- **FIPS 204** — Module-Lattice-Based Digital Signature Standard (ML-DSA).
  https://csrc.nist.gov/pubs/fips/204/final
  ML-DSA-65 component of `hybrid-ed25519-mldsa65`. Standardized August 2024.

- **NIST PQC project** — Post-Quantum Cryptography standardization.
  https://csrc.nist.gov/projects/post-quantum-cryptography

---

## 5. Industry standards / WG / coalitions

- **IAB Tech Lab AAMP — Agent-Authority Marketplace Protocol**
  https://iabtechlab.com (AAMP project page TBD)
  Submission target for AMDP. Curation-Protocol Q2 2026 window closes 30.06.2026.

- **Linux Foundation Agent-Infrastructure-WG**
  Submission target. x402 (HTTP 402 Payment Standard) is a precedent for LF-hosted agent protocol stewardship.

- **UCP — Universal Commerce Protocol**
  https://ucp.dev
  Transaction-layer protocol. UCP coalition (Google + Shopify + Amazon + Meta + Microsoft + Salesforce + Stripe + Etsy + Target + Wayfair as of 2026-04-24). AMDP is the mandate-discovery layer UNDER UCP — orthogonal, not competing.

- **ACP — Agentic Commerce Protocol (OpenAI + Stripe)**
  Transaction-layer protocol. Apache 2.0. AMDP mandates can authorize ACP-bound agent purchases.

- **AP2 — Agent Payments Protocol (Google → FIDO Foundation, donated 2026-05-11)**
  Transaction-layer protocol focused on intent-to-payment-instrument binding. Single-vertical and single-transaction-bound; AMDP is cross-vertical and longer-lived.

- **x402 — HTTP 402 Payment Standard**
  https://x402.org (Linux Foundation)
  Payment-rail standard. Out of scope for AMDP authorization.

- **MCP — Model Context Protocol (Anthropic)**
  https://modelcontextprotocol.io
  Agent-tool transport. AMDP-aware MCP servers MAY expose mandate-verification tools (planned reference implementation).

---

## 6. EU and regulatory context

- **EU AI Act (Regulation (EU) 2024/1689)** — Art. 14 (Human Oversight), Art. 50 (Transparency obligations for AI systems).
  Mandate-discovery is a structural mechanism supporting both articles for high-risk AI systems.

- **nDSG (Swiss Data Protection Act, revised, effective 2023-09-01)**
  Applicable to Swiss-hosted resolvers and verifiers handling personal data.

- **GDPR (Regulation (EU) 2016/679)**
  Applicable when mandates handle EU-resident personal data. AMDP itself imposes no PII obligations; implementations handling PII alongside AMDP MUST comply with GDPR independently.

---

## 7. Editorial conventions

- Cross-repo links use `github.com/<org>/<repo>/blob/main/<path>` form.
- Internal links within `amdp-spec/` use relative paths (e.g., `[SPECIFICATION.md](SPECIFICATION.md)`).
- Each spec file carries a status header (Version, Status, License).
- RFC 2119 keywords appear in ALL CAPS only in normative sections.
