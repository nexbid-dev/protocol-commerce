# Example — Advertising Publisher Mandate

**File:** [advertising-publisher-mandate.json](advertising-publisher-mandate.json)
**Vertical:** `advertising`
**License:** MIT

## Scenario

Brand X Marketing GmbH wants to delegate Q2 2026 media-buying decisions to an autonomous agent (Media Buyer Bot 7, running on Claude Opus 4.7). The agent is authorized to:

- Create paid media placements (`create_media_buy`).
- Upload creative assets (`submit_creative`).
- Approve publisher invoices (`approve_invoice`).

The agent is NOT authorized to pause campaigns — that requires a separate mandate (or principal action).

## Constraints

- **`max_amount: 5000 CHF cumulative`** — Total spend across all actions over the mandate lifetime cannot exceed CHF 5'000. This is the strictest version of the constraint; once exhausted, further actions are denied with `AMDP_CONSTRAINT_VIOLATION` even if other constraints pass.
- **`time_window: 2026-04-01 to 2026-06-30`** — The agent may only act during Q2 2026. Note that `time_window` is independent of `expires_at`, which here happens to coincide.
- **`categories: [food-beverages, household-goods]`** — Only campaigns in these product categories are authorized. A campaign targeting (say) electronics or pharmaceuticals is denied.
- **`geo_regions: [CH, DE, AT]`** — Campaigns may only target Switzerland, Germany, or Austria (DACH region).

## Why this shape

This mandate models a realistic mid-market brand-agent scenario:

- **Vertical-scoped:** Only `advertising` actions. A publisher-side `approve_form` action from `public-services` would be rejected with `AMDP_OUT_OF_SCOPE`.
- **Bounded financial risk:** CHF 5'000 cumulative cap caps total exposure even if the agent or its runtime is compromised.
- **Time-bounded:** Three-month window matches a Q2 campaign cycle. Renewal requires a fresh mandate (and a fresh principal-side review).
- **Audit-trail-enabled:** The `audit_trail_endpoint` lets Brand X monitor agent actions in near-real-time, which is good practice for high-frequency action verticals like advertising.

## Verification flow

A publisher's auction server (verifier) receives an agent request to create a CHF 200 media buy for category `food-beverages` in Switzerland. The verifier:

1. Validates the mandate against the JSON Schema in SPECIFICATION.md section 2.1.
2. Fetches the JWKS at `https://brand-x.example/.well-known/amdp/jwks`.
3. Verifies the hybrid signature (both Ed25519 and ML-DSA-65 components).
4. Calls `GET https://brand-x.example/.well-known/amdp/verify?mandate_id=01904ad8-...&action=create_media_buy&context=<base64url-encoded JSON of {amount: 200, currency: CHF, category: food-beverages, geo: CH}>`.
5. Receives `200 {"valid": true, "constraints_match": true, "remaining_actions": [...]}`.
6. Proceeds with the auction.

The verifier also sends an audit event to `https://brand-x.example/.well-known/amdp/audit` with `event_type=verify_accepted`.
