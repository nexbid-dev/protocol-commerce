# Example — Public-Services Citizen Request

**File:** [public-services-citizen-request.json](public-services-citizen-request.json)
**Vertical:** `public-services`
**License:** MIT

## Scenario

Alice is a Zurich resident filing her 2025 tax return. She uses a tax-helper agent (Claude Sonnet 4.7) to handle the form submission and follow-up correspondence with the cantonal tax authority. She authorizes the agent to:

- Submit tax forms and amendments on her behalf (`submit_request`).
- Acknowledge or approve forms returned by the authority (`approve_form`).
- Query her own tax records to fill in forms accurately (`query_records`).

## Constraints

- **No `max_amount` constraint** — Public-services interactions typically don't involve monetary amounts in the AMDP sense. (Tax owed is computed by the authority; the agent only submits forms.) Omitting `max_amount` is fine.
- **`time_window: 2026-05-17 to 2026-08-31`** — Three-and-a-half months — covering the typical Swiss cantonal tax-filing window.
- **`vendor_whitelist`** — Only the Zurich cantonal tax portal and civil registry. The agent cannot make requests to (say) federal social security or to a tax portal in a different canton.
- **`geo_regions: [CH]`** — Switzerland only.
- **`data_classes: [public, personal-self-only]`** — The agent may read public records and Alice's own personal records. It cannot read records about other family members, third parties, or sensitive classes (PII of others, PHI, financial records of others). This is the critical privacy boundary.

## Why this shape

- **Citizens are principals too.** AMDP works for natural-person principals just as well as for corporate principals. The `did:web:citizen-alice.example` identifier could in practice be backed by a self-hosted or service-provider-hosted DID method (`did:key`, `did:ion`, etc.). The protocol is identifier-agnostic.
- **`data_classes` is the most important constraint here.** Without it, a misbehaving agent could query records the citizen never intended to expose. The fail-closed semantics of `data_classes` (resolvers MUST treat unknown classes as forbidden) protect citizens from over-broad mandates.
- **`vendor_whitelist` for government endpoints** is appropriate. The citizen may want help with cantonal tax but NOT with federal driving-licence records. Whitelisting endpoint domains achieves that.
- **Three-and-a-half month window** matches the practical workflow (filing deadline + reply time + amendment window). Shorter windows would force renewal mid-process; longer windows expand the blast radius.
- **No `audit_trail_endpoint` host operated by the citizen** is realistic — the citizen MAY use a managed audit service (e.g., a digital-identity service provider) and point the endpoint there. The mandate above uses a self-hosted URL for clarity but in practice would point to a managed service.

## Privacy considerations

This is the most privacy-sensitive scenario in the example set. Section 4 of [SECURITY.md](../SECURITY.md) summarizes the relevant principles:

- The mandate carries Alice's DID, but NOT her tax-number, address, AHV-number, or any other identifier. Those are presented to the cantonal portal during action execution, NOT in the mandate.
- The `audit_trail_endpoint` receives action events about Alice's mandates. If a managed audit service is used, that service sees what actions are happening but NOT the contents of tax forms (the verifier — the cantonal portal — has that data, governed by Swiss tax-secrecy law).
- `data_classes: [personal-self-only]` is enforced at the resolver. Alice's resolver MUST refuse to evaluate constraints for queries targeting records that don't belong to Alice.

## Verification flow

The cantonal tax portal (verifier at `tax.gov.zh.ch`) receives a `submit_request` from Alice's Tax Helper Bot, containing a tax-form payload. The verifier:

1. Validates the mandate schema.
2. Fetches Alice's JWKS at `https://citizen-alice.example/.well-known/amdp/jwks`.
3. Verifies the hybrid signature.
4. Calls `/verify?mandate_id=01904e4f-...&action=submit_request&context=<base64url of {vendor: tax.gov.zh.ch, geo: CH, data_class: personal-self-only}>`.
5. Resolver evaluates: time-window OK (current time within 2026-05-17 to 2026-08-31), vendor in list, geo CH, data class allowed. Returns `200 {"valid": true, "constraints_match": true, ...}`.
6. Portal accepts the submission.

The portal then sends an audit event to Alice's `audit_trail_endpoint` documenting the submission.

If the same agent later attempts to use the mandate against `tax.gov.be.ch` (Bern instead of Zurich), the resolver would return `constraints_match: false` with reason `"vendor not in whitelist"`.
