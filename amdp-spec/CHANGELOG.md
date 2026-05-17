# Changelog — AMDP

All notable changes to the AMDP specification will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

While AMDP is in Draft (v0.x), breaking changes between MINOR versions are explicitly permitted. See [SPECIFICATION.md section 10](SPECIFICATION.md#10-versioning-policy) for the versioning policy.

---

## [0.1.0] — 2026-05-17

### Added

- Initial draft specification.
- Mandate Document JSON Schema (Draft 2020-12).
- Verticals taxonomy v0.1: `advertising`, `procurement`, `equity-research`, `public-services`.
- Actions taxonomy v0.1: 13 initial actions across the four verticals.
- Constraints taxonomy v0.1: `max_amount`, `time_window`, `vendor_whitelist`/`vendor_blacklist`, `asset_classes`/`categories`, `geo_regions`, `data_classes`.
- Signature algorithms: `hybrid-ed25519-mldsa65` (RECOMMENDED), `ed25519` (legacy), `ml-dsa-65` (PQC-only).
- COSE_Sign1 wrapping per RFC 9052.
- JWKS-based key distribution per RFC 7517.
- Resolver Endpoint OpenAPI 3.1 spec (`/.well-known/amdp/verify`, `/.well-known/amdp/revoke`).
- Discovery Endpoint OpenAPI 3.1 spec (`/.well-known/amdp/discover`).
- Stable error-code set (15 codes).
- SemVer-based versioning policy with pre-1.0 contract.
- Conformance specification with role-based MUST/SHOULD/MAY requirements (Issuer, Verifier, Resolver, Discovery Endpoint).
- Test-vector plan (15 vectors planned for Phase 4 reference test suite).
- Security threat model (T1-T6) with explicit mitigations.
- Post-quantum cryptography migration strategy (4-phase plan).
- Audit-log requirements (resolver-side, verifier-side, audit-trail-endpoint format).
- Five reference example mandates: advertising publisher mandate, equity-research family-office, procurement cross-vendor, multi-vertical family-office, public-services citizen request.

### Authored by

- digital opua GmbH (CHE-435.289.702, Switzerland) via Nexbid.
- Initial editor: Holger von Ellerts.

### Submission intents

- IAB Tech Lab AAMP (Agent-Authority Marketplace Protocol) — Curation-Protocol window Q2 2026 (30.06.2026).
- Linux Foundation Agent-Infrastructure-WG.

### Known open items for v0.2.0

- Test-vector files in `examples/test-vectors/` (15 vectors enumerated in CONFORMANCE.md section 6).
- npm package `@protocol-commerce/amdp-conformance` (CLI + library).
- Audit-event signing scheme details (deferred from v0.1.0).
- Resolver version-range advertisement on `/discover` responses.
- Multi-source attribution for sub-delegated mandates (analogous to AdCP multi-source attribution planned for v0.2.0).
- Lean 4 reference implementation announcement once protocol-commerce repo includes it.
