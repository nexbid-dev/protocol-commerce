# AMDP — Conformance

**Version:** 0.1.0
**Status:** Draft
**License:** MIT (specification)

> This document defines testable conformance requirements for AMDP implementations. RFC 2119 keywords (MUST, SHOULD, MAY) apply.

---

## 1. Conformance roles

An AMDP implementation conforms to one or more of the following roles. A single deployment MAY implement multiple roles.

| Role | Responsibility |
|------|----------------|
| **Mandate Issuer** | Produces signed mandate documents on behalf of a principal. |
| **Verifier** | Receives mandates from agents and calls a resolver to verify them. |
| **Resolver** | Verifies signatures, evaluates constraints, answers revocation queries. |
| **Discovery Endpoint** | Maps (vertical, action) pairs to resolvers. OPTIONAL role. |

The remainder of this document specifies the MUST/SHOULD/MAY requirements for each role.

---

## 2. Mandate Issuer conformance

An Issuer MUST:

- **I-1** Produce mandate documents that validate against the JSON Schema in SPECIFICATION.md section 2.1.
- **I-2** Generate `mandate_id` as a UUID v7 per [draft-ietf-uuidrev-rfc4122bis](https://datatracker.ietf.org/doc/draft-ietf-uuidrev-rfc4122bis/).
- **I-3** Canonicalize the mandate per [RFC 8785](https://www.rfc-editor.org/rfc/rfc8785) before signing.
- **I-4** Wrap the signature in a COSE_Sign1 structure per [RFC 9052](https://www.rfc-editor.org/rfc/rfc9052).
- **I-5** Publish the principal's public keys via a JWKS at `principal.verifier_url`.
- **I-6** Use `expires_at` no later than 12 months from `issued_at`. Issuers MAY use shorter windows; they MUST NOT use longer.
- **I-7** Reject scope combinations where an action is not defined for the vertical (section 4 of SPECIFICATION.md).

An Issuer SHOULD:

- **I-8** Use `hybrid-ed25519-mldsa65` for all new mandates.
- **I-9** Include at least one constraint in every mandate.
- **I-10** Include an `audit_trail_endpoint` for mandates that will be used in regulated verticals (`equity-research`, `public-services`, `procurement` over a stakeholder threshold).
- **I-11** Document the issuance process so an auditor can reproduce a mandate's provenance.

An Issuer MAY:

- **I-12** Sub-delegate by issuing a mandate with a `delegation_chain`. Each chain link MUST narrow scope.

---

## 3. Verifier conformance

A Verifier MUST:

- **V-1** Validate the mandate document against the schema in SPECIFICATION.md section 2.1 BEFORE any further processing. Return `AMDP_INVALID_SCHEMA` on failure.
- **V-2** Fetch the principal's JWKS from `principal.verifier_url` and independently validate the signature (NOT relying solely on the resolver's `valid=true`).
- **V-3** Call the resolver's `/verify` endpoint with the `mandate_id`, the proposed `action`, and an action `context` payload sufficient for constraint evaluation.
- **V-4** Treat any non-200 response from the resolver as authorization-denied.
- **V-5** Re-verify on every action attempt; MUST NOT cache positive verifications for longer than the resolver's `Cache-Control: max-age`.
- **V-6** Reject mandates whose `amdp_version` major component is outside the verifier's supported range (`AMDP_VERSION_INCOMPATIBLE`).
- **V-7** Refuse to bypass the resolver and locally compute constraint satisfaction. The resolver is the single source of truth for constraint state. See SECURITY.md threat T3.

A Verifier SHOULD:

- **V-8** Send action audit events to the principal's `audit_trail_endpoint` if one is configured.
- **V-9** Implement exponential backoff with jitter when retrying after `AMDP_RATE_LIMITED` or `AMDP_INTERNAL`.
- **V-10** Surface the human-readable `reason` from a `valid=false` response to the agent and (where applicable) to the principal.

A Verifier MAY:

- **V-11** Cache the principal's JWKS for up to 24 hours per RFC 7517 conventions.
- **V-12** Maintain a local audit log of mandates seen, in addition to forwarding to the principal's audit endpoint.

---

## 4. Resolver conformance

A Resolver MUST:

- **R-1** Implement `GET /.well-known/amdp/verify` per the OpenAPI spec in SPECIFICATION.md section 7.1.
- **R-2** Implement `POST /.well-known/amdp/revoke` per the OpenAPI spec in SPECIFICATION.md section 7.1.
- **R-3** Validate mandate documents against the schema in SPECIFICATION.md section 2.1 before any verification work.
- **R-4** Validate mandate signatures against the principal's current JWKS.
- **R-5** Evaluate constraints provided in the `context` query parameter, returning `constraints_match: false` (in a 200 response) when constraints fail. The mandate is still considered "verifiable" — only the proposed action is denied.
- **R-6** Implement revocation as a one-way state transition (no un-revocation).
- **R-7** Return errors per the Problem Details format ([RFC 9457](https://www.rfc-editor.org/rfc/rfc9457)) with the error codes defined in SPECIFICATION.md section 9.
- **R-8** Reject revocation requests not signed by the current principal key (`AMDP_INVALID_SIGNATURE`).
- **R-9** Support the entire `hybrid-ed25519-mldsa65` signature scheme. Resolvers MAY additionally support `ed25519` for legacy mandates.
- **R-10** Refuse mandates exceeding 16 KiB (`AMDP_MANDATE_TOO_LARGE`).
- **R-11** Resolve every link in a `delegation_chain`, verifying that each link strictly narrows scope vs. its parent. Return `AMDP_DELEGATION_WIDENS_SCOPE` if any link widens.
- **R-12** Rate-limit requests per source (IP, API key, or DID) and return `AMDP_RATE_LIMITED` on excess.

A Resolver SHOULD:

- **R-13** Implement a webhook or pub/sub mechanism to push revocation events to subscribed verifiers, in addition to the polling-based `/verify` interface.
- **R-14** Support ETag conditional GETs on `/verify` to reduce verifier bandwidth.
- **R-15** Log every verify and revoke call with the mandate ID, source identifier (IP or API key), and outcome, retained per the principal's data-retention policy.
- **R-16** Expose operational metrics (verify latency, error rate, cache hit rate) for monitoring.

A Resolver MAY:

- **R-17** Cache constraint evaluations for identical (mandate_id, action, context) tuples for up to 60 seconds.
- **R-18** Co-locate with the issuer's identity provider for efficient JWKS access.

---

## 5. Discovery Endpoint conformance

A Discovery Endpoint MUST:

- **D-1** Implement `GET /.well-known/amdp/discover` per the OpenAPI spec in SPECIFICATION.md section 8.1.
- **D-2** Return only resolvers it has confirmed are reachable within the last 24 hours.
- **D-3** Set appropriate `Cache-Control` and `ETag` headers to permit efficient caching.

A Discovery Endpoint SHOULD:

- **D-4** Document its aggregation policy (which resolvers it lists, how new resolvers are added, removal criteria).
- **D-5** Support filtering by `vertical` (required) and `action` (optional) per the spec.
- **D-6** Implement health checks against listed resolvers and remove resolvers failing health for over 24 hours.

A Discovery Endpoint MAY:

- **D-7** Federate with other discovery endpoints by including their resolvers in its own response.
- **D-8** Charge for inclusion in a federated discovery endpoint, provided the policy is documented.

---

## 6. Test vectors

The following test vectors will be published alongside the spec at `examples/test-vectors/` (planned for v0.2.0). All conformant implementations MUST validate every test vector correctly.

| Vector | Purpose | Expected result |
|--------|---------|-----------------|
| TV-001 | Minimal valid mandate, no constraints | Verifier: `valid=true` |
| TV-002 | Mandate expired by 1 second | Resolver: `AMDP_EXPIRED` (403) |
| TV-003 | Mandate with `max_amount=50000 USD`, action `context.amount=49999` | `constraints_match=true` |
| TV-004 | Mandate with `max_amount=50000 USD`, action `context.amount=50001` | `constraints_match=false`, reason cites max_amount |
| TV-005 | Mandate signed with wrong key | `AMDP_INVALID_SIGNATURE` (401) |
| TV-006 | Mandate with `delegation_chain` that widens scope | `AMDP_DELEGATION_WIDENS_SCOPE` (422) |
| TV-007 | Mandate with `vendor_whitelist=["a.example"]`, context vendor=`b.example` | `constraints_match=false` |
| TV-008 | Mandate with both `vendor_whitelist` AND `vendor_blacklist` | `AMDP_CONSTRAINT_VIOLATION` (422) |
| TV-009 | Mandate revoked, /verify call | `AMDP_REVOKED` (410) |
| TV-010 | Mandate with unknown constraint key `mystery_constraint` | `AMDP_UNKNOWN_CONSTRAINT` (422) |
| TV-011 | Hybrid signature with valid Ed25519 but invalid ML-DSA-65 | `AMDP_INVALID_SIGNATURE` (401) |
| TV-012 | Hybrid signature with invalid Ed25519 but valid ML-DSA-65 | `AMDP_INVALID_SIGNATURE` (401) |
| TV-013 | Mandate version `99.0.0` against resolver supporting only major 0 | `AMDP_VERSION_INCOMPATIBLE` (426) |
| TV-014 | Mandate document at 17 KiB | `AMDP_MANDATE_TOO_LARGE` (413) |
| TV-015 | Cross-vertical mandate `vertical=equity-research, actions=[submit_creative]` | `AMDP_OUT_OF_SCOPE` (422) |

Each test vector ships with:

- The input mandate document (JSON file).
- The signing key material (for signature verification tests).
- The expected resolver response (status code, body).
- A short prose description.

---

## 7. Reference test suite (planned)

A conformance test suite is planned for Phase 4 of the AMDP roadmap (ADR-040). The suite will:

- Be available as an npm package under `@protocol-commerce/amdp-conformance`.
- Run as both a CLI tool and a library.
- Test all conformance roles against a candidate implementation's deployed endpoints.
- Produce a Pass/Fail report per requirement (I-1, V-1, R-1, etc.).
- Be available under Apache 2.0 (separate from the MIT-licensed spec).

Implementations passing the test suite MAY display an "AMDP Conformant v0.X" badge linking to the test report.

---

## 8. Interoperability matrix

The following matrix tracks interoperability between AMDP-conformant implementations. It will be populated as implementations register.

| Implementation | Role | AMDP version | Last tested | Status |
|----------------|------|--------------|-------------|--------|
| Nexbid (reference) | Issuer, Verifier, Resolver | v0.1.0 | _planned Phase 4_ | _draft_ |
| _(open)_ | | | | |

---

## 9. Reporting non-conformance

If an implementation claims AMDP conformance but fails one or more requirements:

1. Open an issue in `nexbid-dev/protocol-commerce` with title `amdp: non-conformance — [implementation name]`.
2. Include the failing requirement IDs (e.g. `R-4, R-9`), the test vector(s) that failed, and the implementation's response.
3. Tag with `area:amdp` and `type:conformance`.

The implementation maintainer SHOULD respond within 14 days. If unresolved within 90 days, the implementation MUST drop conformance claims publicly.

---

End of conformance specification.
