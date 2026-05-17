# Example — Procurement Cross-Vendor

**File:** [procurement-cross-vendor.json](procurement-cross-vendor.json)
**Vertical:** `procurement`
**License:** MIT

## Scenario

ACME Industries AG runs a Procurement Assistant (Claude Sonnet 4.7) that approves orders for routine operating supplies from a pre-approved vendor list. The agent may:

- Approve orders up to USD 50'000 each (`approve_order`).
- Select among whitelisted vendors for quote requests (`select_vendor`).
- Initiate terms negotiation (`negotiate_terms`) — but final approval still requires principal action because that's the convention in section 4.2.

## Constraints

- **`max_amount: 50'000 USD per_action`** — Each individual order capped at USD 50'000. Larger purchases require a separate manual approval workflow outside the mandate.
- **`time_window: 2026-05-01 to 2027-05-01`** — 12-month delegation matching ACME's fiscal year.
- **`vendor_whitelist`** — Only orders to specifically listed vendors (or wildcard-matched subdomains of trusted vendors) are authorized. Notice the wildcard pattern `*.trusted-saas-vendor.example` which permits any subdomain.
- **`categories`** — Restricted to four standard procurement categories. An order for, say, legal services (category `legal`) would be rejected.
- **`geo_regions: [US, CA, EU, UK]`** — Tax/customs simplicity: only jurisdictions where ACME's procurement department has standing onboarding agreements.

## Why this shape

- **Long `expires_at` (12 months)** is acceptable here because the procurement scope is operationally bounded (vendor whitelist + categories + per-action cap). The blast-radius of compromise is limited.
- **`vendor_whitelist` is the primary security mechanism.** Even if the per-action cap is raised in a future renewal, the whitelist limits where money can go.
- **Wildcard support in vendor patterns** (`*.trusted-saas-vendor.example`) is helpful for vendors with multiple environments (e.g., `prod.trusted-saas-vendor.example`, `staging.trusted-saas-vendor.example`).
- **`per_action` mode** is appropriate; a `cumulative` cap would prevent legitimate ongoing operations.

## Anti-pattern

This mandate does NOT include `vendor_blacklist`. Section 5.3 explicitly forbids combining `vendor_whitelist` and `vendor_blacklist` in the same mandate. A resolver presented with both would return `AMDP_CONSTRAINT_VIOLATION`.

## Verification flow

A vendor's order-acceptance API (verifier) receives an order request from the Procurement Assistant for USD 35'000 of `software-subscriptions` from `prod.trusted-saas-vendor.example`. The verifier:

1. Validates schema.
2. Fetches JWKS.
3. Verifies hybrid signature.
4. Calls `/verify?mandate_id=01904c2d-...&action=approve_order&context=<base64url of {amount: 35000, currency: USD, category: software-subscriptions, vendor: prod.trusted-saas-vendor.example, geo: US}>`.
5. Resolver evaluates: amount OK (under cap), category in list, vendor matches wildcard `*.trusted-saas-vendor.example`, geo in list. Returns `200 {"valid": true, "constraints_match": true, ...}`.
6. Verifier accepts the order.

If the same agent presented an order for `unknown-vendor.example`, the resolver would return `constraints_match: false` with reason `"vendor not in whitelist"`.
