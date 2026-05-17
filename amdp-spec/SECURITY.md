# AMDP — Security Considerations

**Version:** 0.1.0
**Status:** Draft
**License:** MIT (specification)

> This document describes the AMDP threat model, mitigations, the post-quantum cryptography migration strategy, and audit-log requirements.

---

## 1. Threat model

The following six threats define the AMDP security boundary. Each threat is mitigated by specific design decisions in the protocol; mitigations are normative (MUST) unless otherwise noted.

### T1 — Mandate Forgery

**Threat:** An attacker produces a mandate document that appears to authorize an agent for actions the principal did not approve.

**Vectors:**

- Tampering with mandate fields after signing.
- Constructing a new mandate and signing with a stolen or compromised principal key.
- Algorithm-downgrade attacks (force a verifier to validate a weaker signature than the mandate specifies).
- Selection of an obscure or non-standard signature algorithm to bypass verifiers that fall back to "accept".

**Mitigations:**

- **M1.1** All mandates MUST be signed per section 6 of SPECIFICATION.md. Unsigned mandates MUST be rejected.
- **M1.2** Verifiers MUST validate the signature BEFORE any other processing — schema validation comes first, then signature.
- **M1.3** Verifiers MUST refuse algorithms outside the allowed set in section 6.1-6.3. Specifically, an `algorithm: "none"` or any value not in `{ed25519, ml-dsa-65, hybrid-ed25519-mldsa65}` MUST be rejected with `AMDP_INVALID_SIGNATURE`.
- **M1.4** Verifiers MUST canonicalize the mandate per RFC 8785 before signature verification. Implementations MUST NOT verify signatures over non-canonical bytes.
- **M1.5** For `hybrid-ed25519-mldsa65`, BOTH component signatures MUST verify. Either-or fallback is forbidden.
- **M1.6** Principal keys MUST be distributed via JWKS at `principal.verifier_url`. JWKS responses MUST be served over TLS 1.2+ with valid certificate.

### T2 — Replay Attack

**Threat:** An attacker intercepts a valid mandate (e.g., via network capture, leaked log, exposed agent) and re-uses it after the original action was completed, after revocation, or in a different context than intended.

**Vectors:**

- Replaying a mandate after `expires_at`.
- Replaying a mandate that has been revoked but whose verifier had cached a positive verify.
- Re-using a "single-use" mandate (a mandate intended for one specific action).
- Cross-resolver replay (using a mandate against a different resolver than the one whose context it was created for).

**Mitigations:**

- **M2.1** Every mandate has a `mandate_id` (UUID v7) and an `expires_at`. Resolvers MUST check both on every `/verify` call.
- **M2.2** Resolvers SHOULD maintain a server-side cache of consumed actions for single-use mandates, indexed by `mandate_id`. The cache is the source of truth for `remaining_actions`.
- **M2.3** Verifiers MUST NOT cache positive verifications beyond the resolver's advertised `Cache-Control: max-age`. Stale cache hits constitute replay.
- **M2.4** Resolvers MUST treat revocation as an atomic state transition (no soft-delete, no resurrection).
- **M2.5** Mandates SHOULD use the shortest `expires_at` that still allows the intended workflow. Mandates with multi-month windows are explicitly higher-risk and SHOULD use audit-log endpoints.
- **M2.6** Verifiers SHOULD subscribe to resolver revocation webhooks where available, to invalidate cached verifications proactively.

### T3 — Constraint Bypass

**Threat:** An attacker constructs an action that should fail constraint evaluation but succeeds because constraints are evaluated client-side, locally, or with stale data.

**Vectors:**

- An agent computes constraint satisfaction locally and presents only the result to a verifier.
- A verifier accepts the agent's constraint-pass claim without calling the resolver.
- A verifier passes an incomplete or modified `context` to the resolver's `/verify` endpoint.
- An attacker exploits constraint-evaluation race conditions (e.g., cumulative `max_amount` not yet updated when a second concurrent action is verified).

**Mitigations:**

- **M3.1** Constraint evaluation MUST happen server-side at the resolver. Agents and verifiers MUST NOT compute constraint satisfaction locally for authorization purposes.
- **M3.2** Verifiers MUST pass the complete action `context` to the resolver. Verifiers MUST NOT redact or transform context fields.
- **M3.3** Resolvers MUST evaluate cumulative constraints (e.g., `max_amount` with `mode=cumulative`) under a serializable transaction or equivalent isolation. Stale-read race conditions on cumulative state MUST be prevented.
- **M3.4** Unknown constraint keys MUST cause resolvers to fail closed (`AMDP_UNKNOWN_CONSTRAINT`). Resolvers MUST NOT silently ignore unrecognized constraints.
- **M3.5** Verifiers SHOULD log the full context passed to the resolver, so post-hoc audit can detect verifier-side constraint stripping.

### T4 — Compromised Principal Key

**Threat:** A principal's private signing key is exposed, allowing an attacker to issue arbitrary mandates in the principal's name.

**Vectors:**

- Key extraction from a poorly secured HSM, software wallet, or signing-service.
- Insider threat at the principal's organization.
- Long-term cryptanalysis (relevant for ed25519 in a post-CRQC world; see T5).

**Mitigations:**

- **M4.1** Principals MUST be able to rotate keys at any time by publishing an updated JWKS at `principal.verifier_url`. Verifiers MUST re-fetch JWKS on signature verification failure to catch rotation.
- **M4.2** Principals SHOULD include `key_id` (`kid`) in the signature object so a specific key can be retired without invalidating all mandates.
- **M4.3** Mandates signed with a rotated-out key remain valid until `expires_at` UNLESS explicitly revoked. Principals SHOULD revoke mandates issued with a compromised key as a separate cleanup step.
- **M4.4** Resolvers MUST honor revocation requests authenticated by a CURRENT (post-rotation) key. The revocation request signature scheme MUST match section 6 of SPECIFICATION.md.
- **M4.5** Principals operating in high-stakes verticals (`equity-research`, `procurement` over a stakeholder threshold) SHOULD use HSM-backed key storage and audit key access.

### T5 — Compromised Agent

**Threat:** An agent is compromised (its code, its runtime, its DID-binding keys) and used to perform unauthorized actions while presenting a valid mandate.

**Vectors:**

- Agent runtime is hijacked (prompt injection, supply-chain attack, container escape).
- Agent's DID-binding keys are extracted and used by an attacker-controlled process.
- An attacker presents a valid mandate to a verifier while masquerading as the legitimate agent.

**Mitigations:**

- **M5.1** Mandates MUST bind to a specific `agent.id` (DID). Verifiers MUST validate that the agent presenting the mandate matches the `agent.id` in the mandate.
- **M5.2** Agent authentication to verifiers is OUT OF SCOPE of AMDP — the verifier MUST establish agent identity through a transport-layer mechanism (mTLS, signed JWT with agent DID, etc.) before accepting a mandate.
- **M5.3** Mandates SHOULD declare `audit_trail_endpoint` so the principal can detect anomalous mandate usage in near-real-time.
- **M5.4** Verifiers SHOULD log enough metadata about each action (verifier identity, action context, timestamp) to support forensic reconstruction.
- **M5.5** Principals SHOULD use short `expires_at` (hours to days, not months) for agent-bound mandates in high-stakes verticals.
- **M5.6** Agent `model` MAY be included in the mandate. Verifiers MAY use this to refuse actions from unexpected models (e.g., a mandate authorizing `anthropic/claude-opus-4-7` should not be honored when the requester identifies as `unknown/jailbroken-fork`).

### T6 — Cross-Vertical Privilege Escalation

**Threat:** An attacker uses a mandate issued for one vertical to perform actions in a different vertical (e.g., a mandate for `advertising.create_media_buy` to attempt `procurement.approve_order`).

**Vectors:**

- A verifier in vertical B accepts a mandate scoped to vertical A by failing to check `scope.vertical`.
- A discovery endpoint routes a request to the wrong resolver, which then accepts the cross-vertical mandate.
- A vertical owner extends the action taxonomy with an action name colliding with another vertical's action.

**Mitigations:**

- **M6.1** Resolvers MUST enforce strict (vertical, action) pair validation. A mandate with `vertical=A` listing an action defined for `vertical=B` MUST be rejected with `AMDP_OUT_OF_SCOPE`.
- **M6.2** Verifiers MUST check that the mandate's `scope.vertical` matches the vertical in which the action is being attempted.
- **M6.3** Action identifiers are scoped to their vertical. Two verticals MAY define identically-named actions; resolvers MUST treat them as distinct.
- **M6.4** Discovery endpoints MUST return only resolvers whose `supported_verticals` includes the queried vertical. Discovery responses MUST NOT include resolvers for unrelated verticals as "fallback".
- **M6.5** Sub-delegated mandates (with `delegation_chain`) MUST NOT change the vertical from their parent. Resolvers MUST reject vertical-changing delegation as scope-widening (`AMDP_DELEGATION_WIDENS_SCOPE`).

---

## 2. Post-quantum cryptography migration strategy

AMDP v0.1.0 uses `hybrid-ed25519-mldsa65` as the RECOMMENDED signature scheme. This section explains the migration path and the rationale, with explicit reference to [ADR-025 — Crypto-Agility and PQC Migration](https://github.com/Baldri/nexbid/blob/main/docs/knowledge-base/adr/025-crypto-agility-and-pqc-migration.md).

### 2.1 Hybrid signatures, why now

A "harvest now, decrypt later" attacker captures signed payloads today and waits for a sufficiently capable quantum computer (CRQC) to break Ed25519. For data with long validity (e.g., a 12-month mandate authorizing financial decisions), the relevant horizon is the mandate's `expires_at` PLUS the audit-retention window of the relying party. Realistic timelines for CRQC range from 5 to 20 years; the conservative posture is to begin hybrid signing now.

ML-DSA-65 (NIST FIPS 204, standardized August 2024) is the current PQC signature standard. Pure ML-DSA-65 deployments have limited library and HSM support as of 2026; hybrid Ed25519 + ML-DSA-65 deployments combine the maturity of classical signing with the future-proofing of PQC.

### 2.2 Migration phases

| Phase | Period | Verifier behavior | Issuer behavior |
|-------|--------|--------------------|-----------------|
| **Phase 0 (current)** | v0.1.0 | MUST support hybrid; MAY support pure Ed25519 for legacy. | SHOULD use hybrid. |
| **Phase 1** | TBD (v0.x — based on adoption) | MUST support hybrid; SHOULD warn on pure Ed25519. | MUST use hybrid for any mandate with `expires_at > issued_at + 90d`. |
| **Phase 2** | TBD (after CRQC plausible) | MUST reject pure Ed25519. | MUST use hybrid or pure ML-DSA-65. |
| **Phase 3** | TBD (post-CRQC) | MUST reject all classical-only signatures. | MUST use pure ML-DSA-65 or successor. |

Phase transitions are governed by:

- NIST PQC guidance (FIPS updates, CRQC threat assessments).
- AMDP governance consensus.
- A 12-month notice period before each transition.

### 2.3 Library and HSM support

Implementers SHOULD reference the AMDP wiki (planned) for a current list of:

- Libraries supporting `hybrid-ed25519-mldsa65` in their target language.
- HSMs offering ML-DSA-65 hardware-backed signing.
- Test vectors for cross-implementation interoperability.

### 2.4 Cryptographic algorithm registry

AMDP MAY add new signature algorithms via the same IANA-style registry process used for verticals and actions. Proposed criteria for new algorithms:

- NIST-approved or equivalent national-standard approval (e.g., BSI, ETSI).
- Library availability in at least three production-grade implementations.
- Hybrid composition with at least one currently-supported algorithm.
- Community review through the AMDP governance process.

---

## 3. Audit-log requirements

Audit logging is the protocol's primary defense against undetected misuse after a mandate has been issued. This section defines what implementations MUST, SHOULD, and MAY log.

### 3.1 Resolver audit logging

A Resolver MUST log:

- **AL-R1** Every `/verify` call: timestamp, `mandate_id`, requesting verifier identity (IP / API key / DID), proposed `action`, redacted `context`, response status and reason.
- **AL-R2** Every `/revoke` call: timestamp, `mandate_id`, requester identity, signature verification outcome.
- **AL-R3** Every JWKS rotation event: timestamp, retired `kid`, added `kid`.

A Resolver SHOULD log:

- **AL-R4** Sub-delegation chain resolution (which links were followed, which rejected).
- **AL-R5** Constraint evaluation details for failed evaluations (which constraint failed, with what context value).

Resolver logs MUST be retained per the principal's data-retention policy, with a minimum of 90 days for the regulated verticals (`equity-research`, `procurement` over a stakeholder threshold, `public-services`).

### 3.2 Verifier audit logging

A Verifier SHOULD log:

- **AL-V1** Every mandate it accepts: `mandate_id`, action, context, resolver response.
- **AL-V2** Every mandate it rejects: `mandate_id`, reason, agent identity.
- **AL-V3** Every JWKS fetch result.

If the mandate has an `audit_trail_endpoint`, the Verifier MUST forward AL-V1 and AL-V2 events to that endpoint, fire-and-forget, with retry on failure.

### 3.3 Audit-trail endpoint format

Audit events sent to a principal's `audit_trail_endpoint` use the following shape:

```json
{
  "amdp_version": "0.1.0",
  "event_type": "verify_accepted",
  "event_id": "01904ad8-5e1e-7d2a-8b1c-4f5e6a7b8c9d",
  "mandate_id": "01904ad8-5e1e-7d2a-8b1c-4f5e6a7b8c9e",
  "timestamp": "2026-05-17T10:23:45Z",
  "verifier": {
    "id": "did:web:merchant.example",
    "ip": "203.0.113.42"
  },
  "agent": {
    "id": "did:web:agent.example/agents/research-bot-1"
  },
  "action": "make_investment_decision",
  "context": {
    "amount": 49500,
    "currency": "USD",
    "asset": "ABC.LON"
  },
  "outcome": "accepted"
}
```

`event_type` values:

- `verify_accepted` — Verifier received a 200 `valid=true` response and proceeded with the action.
- `verify_denied` — Verifier received a 200 `valid=false` or non-200 response.
- `verify_error` — Verifier encountered an error reaching the resolver.

Principals MAY use audit events for fraud monitoring, anomaly detection, billing reconciliation, and regulatory reporting.

### 3.4 Audit-event signing

Audit events SHOULD be signed by the verifier (using the verifier's DID-bound key) so the principal can detect tampering. The signing scheme is the same as section 6 of SPECIFICATION.md. This is not strictly required at v0.1.0 and is a candidate for hardening in v0.2.0.

---

## 4. Privacy considerations

While AMDP is an authorization protocol (not a privacy protocol), several privacy-relevant choices are intentional:

- **No user-identifying payload.** Mandates carry DIDs (which MAY be self-managed) and explicit fields. They do NOT require government IDs, biometric data, or tracking identifiers.
- **Principal-controlled JWKS distribution.** Key distribution is principal-hosted, not platform-hosted. There is no central registry collecting principal metadata.
- **No cross-vertical correlation by the protocol.** A single agent acting under separate mandates in different verticals presents separate `mandate_id`s; the protocol provides no mechanism to link them unless the principal chooses to.
- **Audit-log scope.** The audit-trail endpoint receives events about the principal's OWN mandates. There is no third-party aggregation by default.

Implementers handling PII alongside AMDP (e.g., `public-services` verticals with `data_classes=["pii"]`) MUST comply with applicable data-protection law (GDPR, nDSG, etc.). AMDP itself imposes no PII obligations beyond the structural choices above.

---

## 5. Reporting security issues

Security issues in the AMDP specification (not implementations) should be reported to `security@nexbid.dev` (PGP key TBD) or via private vulnerability disclosure on `nexbid-dev/protocol-commerce`.

- DO NOT open a public issue for an undisclosed vulnerability.
- DO include a description, reproduction steps if applicable, and any proposed mitigation.
- A response is committed within 7 days.

For implementation-specific vulnerabilities, contact the implementation's maintainers directly.

---

End of security considerations.
