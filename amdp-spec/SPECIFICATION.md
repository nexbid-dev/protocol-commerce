# AMDP — Specification

**Version:** 0.1.0
**Status:** Draft
**License:** MIT (specification)

> This document is the normative specification for the Agent Mandate Discovery Protocol (AMDP). All sections marked MUST, SHOULD, and MAY follow [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) keywords.

---

## Table of Contents

1. [Terminology](#1-terminology)
2. [Mandate Document Schema](#2-mandate-document-schema)
3. [Verticals Taxonomy v0.1](#3-verticals-taxonomy-v01)
4. [Actions Taxonomy v0.1](#4-actions-taxonomy-v01)
5. [Constraints Taxonomy v0.1](#5-constraints-taxonomy-v01)
6. [Signature Algorithms](#6-signature-algorithms)
7. [Resolver Endpoint Spec](#7-resolver-endpoint-spec)
8. [Discovery Endpoint Spec](#8-discovery-endpoint-spec)
9. [Error Codes](#9-error-codes)
10. [Versioning Policy](#10-versioning-policy)

---

## 1. Terminology

The following terms have precise meanings throughout this specification.

| Term | Definition |
|------|-----------|
| **Principal** | The entity (natural person, legal person, organization, system account) that issues a mandate. The principal is the legal-effect owner of any action an agent takes under the mandate. Identified by a Decentralized Identifier (DID) and exposes a JWKS for key distribution. |
| **Agent** | The software actor authorized by a principal to perform actions. Identified by a DID. An agent is NOT the principal; it acts on the principal's behalf. |
| **Mandate** | A signed JSON document binding an agent to a principal under explicit scope and constraints, with explicit issuance and expiration times. The full Mandate Document schema is defined in section 2. |
| **Vertical** | A bounded domain of agent activity for which actions and constraints have well-defined semantics. Initial verticals are defined in section 3. |
| **Action** | A named operation within a vertical. An action's semantics are defined by the vertical's specification. Initial actions per vertical are defined in section 4. |
| **Constraint** | A condition on an action, evaluated by a resolver to determine whether a proposed action falls within mandate scope. Initial constraints are defined in section 5. |
| **Scope** | The triple (vertical, actions, constraints) that defines what the agent may do under the mandate. |
| **Resolver** | An HTTP service operated by (or on behalf of) the principal that verifies mandate signatures, evaluates constraints, and answers revocation queries. Defined in section 7. |
| **Verifier** | A relying party (merchant, exchange, public-service portal) that calls a resolver to verify a mandate before allowing an action. A verifier MUST trust the resolver's response, but MUST also independently validate the mandate's signature against the principal's JWKS. |
| **Discovery Endpoint** | An optional HTTP service that maps (vertical, action) pairs to resolver endpoints, enabling federated lookup. Defined in section 8. |
| **JWKS** | JSON Web Key Set per [RFC 7517](https://www.rfc-editor.org/rfc/rfc7517), used to distribute the principal's public keys. |
| **Mandate ID** | A UUID v7 ([draft-ietf-uuidrev-rfc4122bis](https://datatracker.ietf.org/doc/draft-ietf-uuidrev-rfc4122bis/)) identifying a single mandate document. Time-ordered, globally unique, contains no principal-identifying information. |
| **Delegation Chain** | An optional ordered list of mandate IDs documenting how a mandate was derived from a parent mandate (sub-delegation). Each link MUST narrow scope, never widen it. |

---

## 2. Mandate Document Schema

A Mandate Document is a JSON object that conforms to the schema below. Implementations MUST validate mandate documents against this schema before any further processing.

### 2.1 JSON Schema (Draft 2020-12)

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://nexbid-dev.github.io/protocol-commerce/amdp-spec/mandate.json",
  "title": "AMDP Mandate Document",
  "description": "A signed authorization issued by a principal to an agent for a bounded scope of vertical-bound actions.",
  "type": "object",
  "required": [
    "amdp_version",
    "mandate_id",
    "principal",
    "agent",
    "scope",
    "issued_at",
    "expires_at",
    "signature"
  ],
  "properties": {
    "amdp_version": {
      "type": "string",
      "pattern": "^\\d+\\.\\d+\\.\\d+$",
      "description": "SemVer version of the AMDP spec this mandate conforms to."
    },
    "mandate_id": {
      "type": "string",
      "pattern": "^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$",
      "description": "UUID v7. Time-ordered. Globally unique."
    },
    "principal": {
      "type": "object",
      "required": ["id", "verifier_url"],
      "properties": {
        "id": {
          "type": "string",
          "pattern": "^did:[a-z0-9]+:.+$",
          "description": "Decentralized Identifier of the principal."
        },
        "verifier_url": {
          "type": "string",
          "format": "uri",
          "description": "URL returning a JWKS containing the principal's public keys."
        },
        "display_name": {
          "type": "string",
          "description": "Human-readable principal name (optional)."
        }
      },
      "additionalProperties": false
    },
    "agent": {
      "type": "object",
      "required": ["id"],
      "properties": {
        "id": {
          "type": "string",
          "pattern": "^did:[a-z0-9]+:.+$",
          "description": "Decentralized Identifier of the agent."
        },
        "name": {
          "type": "string",
          "description": "Human-readable agent name (optional)."
        },
        "model": {
          "type": "string",
          "description": "Underlying model identifier (e.g. 'anthropic/claude-opus-4-7', 'openai/gpt-5'). Optional but RECOMMENDED for audit."
        }
      },
      "additionalProperties": false
    },
    "scope": {
      "type": "object",
      "required": ["vertical", "actions"],
      "properties": {
        "vertical": {
          "type": "string",
          "description": "Vertical identifier from section 3 taxonomy.",
          "enum": [
            "advertising",
            "procurement",
            "equity-research",
            "public-services"
          ]
        },
        "actions": {
          "type": "array",
          "minItems": 1,
          "items": {
            "type": "string"
          },
          "description": "Action identifiers from section 4 taxonomy. MUST be valid for the vertical."
        },
        "constraints": {
          "type": "object",
          "description": "Constraints from section 5 taxonomy. All listed constraints MUST be satisfied for the mandate to authorize an action.",
          "additionalProperties": true
        }
      },
      "additionalProperties": false
    },
    "issued_at": {
      "type": "string",
      "format": "date-time",
      "description": "RFC 3339 timestamp of mandate issuance."
    },
    "expires_at": {
      "type": "string",
      "format": "date-time",
      "description": "RFC 3339 timestamp after which the mandate is no longer valid."
    },
    "revocation_url": {
      "type": "string",
      "format": "uri",
      "description": "Optional URL of the resolver endpoint (defaults to principal.verifier_url base + /.well-known/amdp/verify)."
    },
    "audit_trail_endpoint": {
      "type": "string",
      "format": "uri",
      "description": "Optional URL where the principal accepts audit-event submissions from verifiers (see SECURITY.md)."
    },
    "delegation_chain": {
      "type": "array",
      "items": {
        "type": "string",
        "pattern": "^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"
      },
      "description": "Optional ordered list of parent mandate IDs. Each successive mandate MUST narrow scope (no widening). Verifiers MUST resolve every link."
    },
    "signature": {
      "type": "object",
      "required": ["algorithm", "value"],
      "properties": {
        "algorithm": {
          "type": "string",
          "enum": [
            "ed25519",
            "ml-dsa-65",
            "hybrid-ed25519-mldsa65"
          ],
          "description": "Signature algorithm. See section 6."
        },
        "value": {
          "type": "string",
          "description": "Base64url-encoded COSE_Sign1 structure per RFC 9052."
        },
        "key_id": {
          "type": "string",
          "description": "Optional 'kid' value pointing to a specific key in the principal's JWKS."
        }
      },
      "additionalProperties": false
    }
  },
  "additionalProperties": false
}
```

### 2.2 Required vs optional fields

The following fields are REQUIRED and MUST be present in every mandate:

- `amdp_version` — Allows resolvers to refuse mandates from incompatible spec versions.
- `mandate_id` — Globally unique, used as the primary key for verification and revocation.
- `principal` (and its `id`, `verifier_url`) — Anchors authorization to a verifiable identity.
- `agent` (and its `id`) — Binds the mandate to a specific agent.
- `scope` (and its `vertical`, `actions`) — Defines what is authorized.
- `issued_at`, `expires_at` — Bounds the temporal validity.
- `signature` (and its `algorithm`, `value`) — Makes the mandate verifiable.

The following fields are OPTIONAL:

- `principal.display_name`, `agent.name`, `agent.model` — Audit and UX metadata.
- `scope.constraints` — Mandates without constraints are valid but maximally broad within their action set; implementers SHOULD always include at least one constraint.
- `revocation_url` — If absent, the verifier derives it from `principal.verifier_url`.
- `audit_trail_endpoint` — Required only if the principal wants third-party audit ingestion.
- `delegation_chain` — Required only for sub-delegated mandates.

### 2.3 Canonical JSON for signing

To produce a deterministic byte-stream for signing, implementations MUST serialize the mandate document (excluding the `signature` field) using JSON Canonicalization Scheme ([RFC 8785](https://www.rfc-editor.org/rfc/rfc8785)). This guarantees identical signing input across implementations.

### 2.4 Size limits

A conformant mandate document MUST NOT exceed 16 KiB after canonicalization. Resolvers MAY reject larger mandates with `AMDP_MANDATE_TOO_LARGE`.

---

## 3. Verticals Taxonomy v0.1

A vertical is a bounded domain with shared action and constraint semantics. Initial v0.1 verticals are listed below. The taxonomy is maintained as an IANA-style registry; additions go through the AMDP governance process (see [README.md](README.md#contributing)).

| Identifier | Description | Compatible transaction protocols |
|------------|-------------|----------------------------------|
| `advertising` | Agent-mediated advertising operations: media-buying, creative submission, campaign management. | AdCP, UCP, ACP |
| `procurement` | B2B purchasing: vendor selection, order approval, terms negotiation. | UCP, ACP, native procurement APIs |
| `equity-research` | Financial research and investment-decision delegation. | Native broker APIs, custodian APIs |
| `public-services` | Government / civic / agency interactions: form submission, record queries, request handling. | National e-government protocols, OAuth-based portals |

Each vertical's semantics are defined by the vertical's owner(s). The AMDP spec defines only that the vertical-action pair MUST be consistent and that constraints MUST be evaluable.

### 3.1 Adding a new vertical

A new vertical requires:

1. A stable identifier (kebab-case, lowercase ASCII).
2. A description of the bounded domain.
3. At least one defined action with semantics.
4. At least one defined constraint with evaluation rules.
5. Identification of at least one transaction protocol the vertical is compatible with.
6. A community review through the contribution process.

---

## 4. Actions Taxonomy v0.1

The initial v0.1 action set per vertical. Action identifiers are kebab-case ASCII, scoped to their vertical (an action's semantics are vertical-specific).

### 4.1 advertising

| Action | Description |
|--------|-------------|
| `create_media_buy` | Initiate a paid media placement on behalf of the principal. Subject to `max_amount` constraint. |
| `pause_campaign` | Halt an active campaign. |
| `submit_creative` | Upload creative assets (image, video, copy) for a campaign. |
| `approve_invoice` | Approve a billing line item from a publisher or exchange. Subject to `max_amount`. |

### 4.2 procurement

| Action | Description |
|--------|-------------|
| `approve_order` | Approve a purchase order. Subject to `max_amount`, `vendor_whitelist`. |
| `select_vendor` | Choose a vendor from an approved list for a quote request. |
| `negotiate_terms` | Initiate or respond in a terms negotiation. Read/propose only; the principal retains final approval unless explicitly delegated. |

### 4.3 equity-research

| Action | Description |
|--------|-------------|
| `make_investment_decision` | Execute a buy/sell/hold decision against a brokerage or custodian. Subject to `max_amount`, `asset_classes`. |
| `rebalance_portfolio` | Adjust portfolio allocations within an explicit policy. Subject to `max_amount` per individual trade. |
| `subscribe_research_report` | Subscribe to or unsubscribe from a research subscription. |

### 4.4 public-services

| Action | Description |
|--------|-------------|
| `submit_request` | File a form or request with a public-service portal. |
| `approve_form` | Acknowledge or approve a returned form on behalf of the principal. |
| `query_records` | Read public records on behalf of the principal. Subject to `data_classes`. |

### 4.5 Action conformance rules

- An action identifier in `scope.actions` MUST be defined for the `scope.vertical`. Resolvers MUST return `AMDP_OUT_OF_SCOPE` for an action-vertical mismatch.
- An action MUST be evaluable by the resolver. Resolvers MAY refuse to verify mandates referencing unknown actions with `AMDP_UNKNOWN_ACTION`.
- Action semantics are owned by the vertical's spec maintainers, not the AMDP spec. AMDP defines only the identifier and the cross-cutting verification surface.

---

## 5. Constraints Taxonomy v0.1

Constraints are conditions a resolver evaluates against a proposed action context. All listed constraints MUST be satisfied for the mandate to authorize the action.

### 5.1 `max_amount` — Monetary cap

```json
{
  "max_amount": {
    "value": 50000,
    "currency": "CHF"
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `value` | number (>0) | Maximum cumulative amount in the specified currency. Resolvers MAY enforce per-action or cumulative semantics; the mandate SHOULD specify which via `mode`. |
| `currency` | ISO 4217 code | Currency. Supported: `USD`, `EUR`, `CHF`, `GBP`, `JPY`, `AUD`, `CAD`. |
| `mode` | enum (optional) | `per_action` (default) or `cumulative`. |

### 5.2 `time_window` — Temporal validity

```json
{
  "time_window": {
    "from": "2026-05-17T00:00:00Z",
    "to": "2026-08-17T23:59:59Z"
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `from` | RFC 3339 timestamp | Earliest moment the action MAY occur. |
| `to` | RFC 3339 timestamp | Latest moment the action MAY occur. MUST be later than `from`. |

`time_window` is in addition to `expires_at` on the mandate itself; the action time MUST be within BOTH windows.

### 5.3 `vendor_whitelist` / `vendor_blacklist` — Counterparty restriction

```json
{
  "vendor_whitelist": ["vendor-a.example", "*.trusted-vendor.example"]
}
```

| Field | Type | Description |
|-------|------|-------------|
| `vendor_whitelist` | array of patterns | Only matching vendors are permitted. Patterns support wildcard `*.` prefix. |
| `vendor_blacklist` | array of patterns | Matching vendors are forbidden. |

A mandate MUST NOT specify both `vendor_whitelist` and `vendor_blacklist`. Resolvers MUST return `AMDP_CONSTRAINT_VIOLATION` if both are present.

### 5.4 `asset_classes` / `categories` — Subject-matter restriction

```json
{
  "asset_classes": ["mining-equity", "energy-equity"]
}
```

```json
{
  "categories": ["office-supplies", "software-subscriptions"]
}
```

Asset-class identifiers (for `equity-research`) and category identifiers (for `procurement`, `advertising`) are vertical-specific. Resolvers MUST return `AMDP_CONSTRAINT_VIOLATION` for an action whose subject is not in the listed set.

### 5.5 `geo_regions` — Geographic restriction

```json
{
  "geo_regions": ["CH", "DE", "AT", "EU"]
}
```

Identifiers are ISO 3166-1 alpha-2 codes, plus the special supranational codes `EU`, `EEA`, `EFTA`, `UK`. The action's geo-context MUST be in the listed set.

### 5.6 `data_classes` — Data-sensitivity restriction (public-services)

```json
{
  "data_classes": ["public", "personal-self-only"]
}
```

| Class | Description |
|-------|-------------|
| `public` | Public records (no sensitivity restriction). |
| `personal-self-only` | Records about the principal themselves. |
| `personal-family` | Records about the principal's declared family members (requires separate proof). |
| `pii` | General PII access (NOT permitted by default; requires explicit class). |
| `phi` | Protected Health Information (NOT permitted by default; requires explicit class). |
| `financial` | Financial records (NOT permitted by default; requires explicit class). |

### 5.7 Constraint conformance rules

- Constraints are AND-combined: every listed constraint MUST be satisfied.
- Unknown constraint keys MUST cause resolvers to return `AMDP_UNKNOWN_CONSTRAINT` (fail-closed).
- Constraint evaluation happens server-side at the resolver. Verifiers MUST NOT bypass the resolver and locally compute constraint satisfaction (see SECURITY.md threat T3).

---

## 6. Signature Algorithms

AMDP supports three signature algorithms. Implementations MUST support `hybrid-ed25519-mldsa65` for new mandates; pure `ed25519` is supported for legacy interop, and pure `ml-dsa-65` is reserved for post-quantum-only environments.

### 6.1 `hybrid-ed25519-mldsa65` (RECOMMENDED)

A composite signature scheme: the mandate is signed with both Ed25519 ([RFC 8032](https://www.rfc-editor.org/rfc/rfc8032)) and ML-DSA-65 ([FIPS 204](https://csrc.nist.gov/pubs/fips/204/final)). Both signatures are concatenated and encoded.

Rationale (per [ADR-025](https://github.com/Baldri/nexbid/blob/main/docs/knowledge-base/adr/025-crypto-agility-and-pqc-migration.md)):

- **Classical-validation-fallback:** If a future weakness is found in ML-DSA-65 before its broad deployment, the Ed25519 signature still provides classical security.
- **PQC-readiness:** When sufficiently capable quantum computers exist (CRQC), the ML-DSA-65 signature remains valid.
- **No window of vulnerability:** A hybrid signature is no weaker than the strongest of its components.

Verifiers MUST validate BOTH signatures. If either fails, the verification result is invalid.

### 6.2 `ed25519` (legacy interop)

Pure Ed25519 signature per RFC 8032. Permitted for compatibility with implementations not yet supporting PQC. Implementations producing new mandates SHOULD use `hybrid-ed25519-mldsa65`.

### 6.3 `ml-dsa-65` (PQC-only)

Pure ML-DSA-65 signature per FIPS 204. Permitted in environments where classical signatures are explicitly disallowed. NOT recommended for general deployment in v0.1 because of limited library availability.

### 6.4 Signing format: COSE_Sign1

All AMDP signatures use COSE_Sign1 ([RFC 9052](https://www.rfc-editor.org/rfc/rfc9052)) as the wrapping format. The payload is the canonical JSON-serialized mandate document (per section 2.3) with the `signature` field removed. The COSE_Sign1 structure carries the algorithm identifier, an optional `kid` (key ID), and the signature value(s).

For `hybrid-ed25519-mldsa65`, the COSE_Sign1 payload contains both signature values in a deterministic order: Ed25519 first, ML-DSA-65 second.

### 6.5 Public-key distribution: JWKS

Principal public keys are distributed via JSON Web Key Sets ([RFC 7517](https://www.rfc-editor.org/rfc/rfc7517)) at `principal.verifier_url`. The JWKS MUST contain a key entry for each algorithm the principal signs with, identified by `kid`.

Verifiers MUST cache JWKS responses per their `Cache-Control` header, but MUST NOT cache for longer than 24 hours. Verifiers MUST re-fetch JWKS on signature verification failure (handles key rotation).

### 6.6 Key rotation

Principals MAY rotate keys at any time by publishing an updated JWKS. Mandates signed with rotated-out keys remain valid until their `expires_at`, unless explicitly revoked.

---

## 7. Resolver Endpoint Spec

A resolver is an HTTP service operated by (or on behalf of) the principal. Its purpose is to verify mandates and answer revocation queries.

### 7.1 OpenAPI 3.1 inline

```yaml
openapi: 3.1.0
info:
  title: AMDP Resolver Endpoint
  version: 0.1.0
paths:
  /.well-known/amdp/verify:
    get:
      summary: Verify a mandate
      parameters:
        - name: mandate_id
          in: query
          required: true
          schema:
            type: string
            pattern: ^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$
        - name: action
          in: query
          required: false
          description: |
            Specific action being proposed. If provided, the resolver checks
            whether this action is within mandate scope.
          schema:
            type: string
        - name: context
          in: query
          required: false
          description: |
            Base64url-encoded JSON of the action context (e.g. amount, vendor,
            geo). Used by the resolver to evaluate constraints.
          schema:
            type: string
      responses:
        '200':
          description: Mandate is valid
          content:
            application/json:
              schema:
                type: object
                required: [valid, constraints_match, remaining_actions]
                properties:
                  valid:
                    type: boolean
                  reason:
                    type: [string, "null"]
                  constraints_match:
                    type: boolean
                  remaining_actions:
                    type: array
                    items:
                      type: string
        '401':
          description: Signature verification failed
        '403':
          description: Mandate has expired
        '404':
          description: Unknown mandate ID
        '410':
          description: Mandate has been revoked
  /.well-known/amdp/revoke:
    post:
      summary: Revoke a mandate (principal-only)
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [mandate_id, principal_signature]
              properties:
                mandate_id:
                  type: string
                principal_signature:
                  type: object
                  required: [algorithm, value]
                  description: |
                    A signature over the canonical revocation-request JSON,
                    produced by the principal's current signing key. The
                    signature scheme MUST match section 6.
      responses:
        '200':
          description: Revocation accepted
        '401':
          description: Revocation request signature invalid
        '404':
          description: Unknown mandate ID
```

### 7.2 Response shape

A `200 OK` response from `/verify` has the following shape:

```json
{
  "valid": true,
  "reason": null,
  "constraints_match": true,
  "remaining_actions": ["make_investment_decision"]
}
```

- `valid` — Boolean. The mandate's signature, freshness, and (if `action` was provided) action-scope check all passed.
- `reason` — String or null. If `valid=false` but the response is still `200`, `reason` explains why (e.g. `"constraints_match=false: amount exceeds max_amount"`).
- `constraints_match` — Boolean. If `context` was provided, this reflects the constraint evaluation outcome.
- `remaining_actions` — Array of actions in the mandate's scope that are still permitted (after subtracting any single-use actions that have been consumed).

### 7.3 Caching

Resolvers SHOULD respond with `Cache-Control: max-age=60, public` on successful verifies and `Cache-Control: no-store` on failed verifies. Verifiers MAY cache successful verifications for the indicated duration, but MUST re-verify on revocation status changes (out-of-band signal via webhook, or polling).

### 7.4 Error response shape

Non-200 responses use the [RFC 9457](https://www.rfc-editor.org/rfc/rfc9457) Problem Details format:

```json
{
  "type": "https://protocol-commerce.dev/amdp/errors/expired",
  "title": "Mandate has expired",
  "status": 403,
  "detail": "Mandate 01904ad8-... expired at 2026-04-30T00:00:00Z",
  "instance": "/verify?mandate_id=01904ad8-..."
}
```

### 7.5 Revocation semantics

A revocation is a one-way transition: once revoked, a mandate cannot return to valid. Revocation MUST be:

- Authenticated — only the principal (proven via signature with a current JWKS key) MAY revoke.
- Atomic — visible to all subsequent `/verify` calls.
- Permanent — recorded in the resolver's persistent state.
- Distributed via the audit-trail endpoint if one is configured.

---

## 8. Discovery Endpoint Spec

Discovery is OPTIONAL. Its purpose is to let an agent find a resolver supporting a specific (vertical, action) pair when the resolver URL is not embedded in the mandate.

### 8.1 OpenAPI 3.1 inline

```yaml
openapi: 3.1.0
info:
  title: AMDP Discovery Endpoint
  version: 0.1.0
paths:
  /.well-known/amdp/discover:
    get:
      summary: Discover resolvers supporting a vertical-action pair
      parameters:
        - name: vertical
          in: query
          required: true
          schema:
            type: string
            enum:
              - advertising
              - procurement
              - equity-research
              - public-services
        - name: action
          in: query
          required: false
          schema:
            type: string
      responses:
        '200':
          description: List of resolvers
          headers:
            Cache-Control:
              schema:
                type: string
                example: "public, max-age=3600"
            ETag:
              schema:
                type: string
          content:
            application/json:
              schema:
                type: object
                required: [resolvers]
                properties:
                  resolvers:
                    type: array
                    items:
                      type: object
                      required: [resolver_url, supported_verticals, jwks_url]
                      properties:
                        resolver_url:
                          type: string
                          format: uri
                        supported_verticals:
                          type: array
                          items:
                            type: string
                        supported_actions:
                          type: array
                          items:
                            type: string
                        jwks_url:
                          type: string
                          format: uri
                        operator:
                          type: string
                          description: Human-readable operator name
```

### 8.2 Federation

Discovery endpoints MAY federate by including resolvers operated by other parties. A discovery endpoint that aggregates entries SHOULD document its aggregation policy.

### 8.3 Caching

`/discover` responses SHOULD be cacheable for up to 1 hour. Discovery endpoints SHOULD support ETag conditional GETs.

---

## 9. Error Codes

AMDP uses a stable set of error codes carried in the `type` field of Problem Details responses (section 7.4) and in resolver-side logging.

| Code | HTTP status | Meaning |
|------|-------------|---------|
| `AMDP_INVALID_SIGNATURE` | 401 | Mandate signature failed verification against the principal's current JWKS. |
| `AMDP_INVALID_SCHEMA` | 400 | Mandate document does not conform to the schema in section 2. |
| `AMDP_EXPIRED` | 403 | Current time is after `expires_at`. |
| `AMDP_NOT_YET_VALID` | 403 | Current time is before `issued_at` (or before `time_window.from` if set). |
| `AMDP_REVOKED` | 410 | Mandate was revoked. |
| `AMDP_NOT_FOUND` | 404 | Resolver has no record of this `mandate_id`. |
| `AMDP_OUT_OF_SCOPE` | 422 | Proposed action is not in `scope.actions` or not valid for `scope.vertical`. |
| `AMDP_CONSTRAINT_VIOLATION` | 422 | Proposed action context fails one or more constraints. |
| `AMDP_UNKNOWN_VERTICAL` | 422 | `scope.vertical` is not in the resolver's known taxonomy. |
| `AMDP_UNKNOWN_ACTION` | 422 | `scope.actions` contains an action the resolver does not recognize for the vertical. |
| `AMDP_UNKNOWN_CONSTRAINT` | 422 | `scope.constraints` contains a constraint key the resolver does not recognize. Fail-closed. |
| `AMDP_VERSION_INCOMPATIBLE` | 426 | `amdp_version` is from a major version the resolver does not support. |
| `AMDP_MANDATE_TOO_LARGE` | 413 | Mandate document exceeds the 16 KiB limit. |
| `AMDP_DELEGATION_WIDENS_SCOPE` | 422 | A delegation-chain link attempts to widen scope vs. its parent. |
| `AMDP_RATE_LIMITED` | 429 | Verifier is sending too many requests. |
| `AMDP_INTERNAL` | 500 | Resolver-side error. Verifiers MAY retry with exponential backoff. |

---

## 10. Versioning Policy

AMDP follows [Semantic Versioning](https://semver.org/) at the spec level.

### 10.1 Version semantics

- **MAJOR (`X.0.0`):** Incompatible schema, transport, or semantics change. Existing mandates may need to be reissued. Resolvers MAY reject mandates with unsupported major versions (`AMDP_VERSION_INCOMPATIBLE`).
- **MINOR (`0.X.0`):** Backward-compatible additions (new verticals, new actions, new constraints, new optional fields). v0.x is in Draft phase; minor versions MAY introduce breaking changes until v1.0.0.
- **PATCH (`0.0.X`):** Clarifications, editorial fixes, non-normative corrections.

### 10.2 Migration path

When a new major version is published:

1. A migration note is added to [CHANGELOG.md](CHANGELOG.md) documenting all breaking changes.
2. The previous major version remains supported by published resolvers for at least 12 months.
3. Mandates with `amdp_version` from the previous major version remain verifiable for the duration of their `expires_at`, even after the support window closes.

### 10.3 Pre-1.0 contract

Until v1.0.0 is published, the following looser rules apply:

- Breaking changes between MINOR versions are explicitly permitted.
- Every MINOR version increment carries a migration note in CHANGELOG.md.
- Examples in [examples/](examples/) are updated atomically with each MINOR version.
- Implementers SHOULD pin to a specific MINOR version and upgrade explicitly.

### 10.4 Negotiating versions across the protocol

A verifier presented with a mandate at `amdp_version=X.Y.Z`:

1. MUST validate the schema for that version.
2. MAY refuse to verify mandates whose major version differs from the resolver's supported major versions.
3. SHOULD accept any minor version within a supported major.

Resolvers SHOULD advertise their supported version range via the `/.well-known/amdp/discover` response (an extension field, planned for v0.2.0).

---

End of normative specification. See [CONFORMANCE.md](CONFORMANCE.md) for testable requirements, and [SECURITY.md](SECURITY.md) for the threat model.
