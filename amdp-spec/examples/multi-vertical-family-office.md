# Example — Multi-Vertical Family Office (Sub-Delegated)

**File:** [multi-vertical-family-office.json](multi-vertical-family-office.json)
**Verticals involved:** `equity-research` (parent) + `procurement` (this mandate)
**License:** MIT

## Scenario

Family Office Alpha has already issued the Mining Equity Researcher agent an `equity-research` mandate (see [equity-research-family-office.json](equity-research-family-office.json), `mandate_id: 01904b1a-...`).

The same agent now needs to autonomously subscribe to research-data feeds (Bloomberg, Refinitiv, etc.) to do its research. That's a procurement action — distinct vertical — but tightly coupled to the equity-research mandate's purpose.

Rather than issue a wholly independent mandate, the family office issues a **sub-delegated** procurement mandate that references the equity-research mandate as its parent. This documents the chain of authority and lets verifiers in the procurement vertical see why this mandate exists.

## Constraints

- **`max_amount: 10'000 USD per_action`** — Much smaller cap than the parent equity-research mandate's USD 500'000. Sub-mandates MUST narrow scope, never widen it.
- **`time_window` matches the parent** — Cannot extend beyond the parent's time bounds.
- **`vendor_whitelist`** — Restricted to data-feed and research-data vendors only. No general procurement authority.
- **`categories`** — Restricted to `research-data-subscriptions` and `research-software`. No office supplies, no industrial parts, no anything-else.
- **`geo_regions: [CH, EU, UK]`** — Narrowed from the parent's broader `[CA, AU, CH, EU, UK]`. Procurement happens in the family office's home jurisdiction.

## The delegation chain

```json
"delegation_chain": ["01904b1a-7a3c-7e5d-9c2e-1f8a4b5c6d7e"]
```

This single-element chain points back to the equity-research mandate. A resolver verifying THIS mandate MUST:

1. Verify this mandate's own signature.
2. Resolve every link in the chain (here: just `01904b1a-...`).
3. Verify that this mandate's scope is strictly NARROWER than its parent.

The "narrower" check is non-trivial across verticals. AMDP v0.1.0 takes the conservative position that:

- The vertical MAY differ from parent if the actions are operationally subordinate to the parent's purpose. (Buying research data IS subordinate to making research decisions.)
- The `max_amount` MUST be lower than the parent's.
- The `time_window` MUST be a subset of the parent's.
- Vendor/category/geo restrictions MUST be narrower or equal.

A future v0.2.0 will tighten cross-vertical sub-delegation semantics — see open items in [CHANGELOG.md](../CHANGELOG.md).

## Why use sub-delegation here

- **Audit trail clarity:** A procurement verifier sees both this mandate and its parent, understanding that the data purchase is in service of an equity-research delegation.
- **Single revocation point:** If Family Office Alpha revokes the parent equity-research mandate, this child mandate also becomes ineffective in practice (the agent's reason for procurement disappears). Resolvers MAY treat parent revocation as implicit child revocation.
- **Tighter blast-radius bound:** Even if this sub-mandate is somehow misused, the tight USD 10'000 cap + narrow vendor list limits damage.

## Anti-pattern: scope widening

If this sub-mandate's `max_amount` were USD 1'000'000 instead of USD 10'000, a resolver MUST reject it with `AMDP_DELEGATION_WIDENS_SCOPE` because USD 1'000'000 > the parent's USD 500'000 cap (even though the parent is in a different vertical, both `max_amount` constraints translate to a comparable financial exposure dimension).

If the sub-mandate were `geo_regions: [US, CN, JP]` (none of which appear in the parent's `[CA, AU, CH, EU, UK]`), a resolver MUST reject it.

## Verification flow

A data-feed vendor (e.g. `bloomberg-data.example`) receives an order from the agent for a USD 8'000 quarterly research-data subscription. The verifier:

1. Validates the schema.
2. Fetches the JWKS (one fetch — same principal as the parent).
3. Verifies this mandate's hybrid signature.
4. Notices the `delegation_chain` field. Calls `/verify?mandate_id=01904b1a-...` to confirm the parent is still valid (not revoked, not expired).
5. Verifies that this child's scope is strictly narrower than parent on every dimension.
6. Calls `/verify?mandate_id=01904d3e-...&action=approve_order&context=<base64url of {amount: 8000, currency: USD, category: research-data-subscriptions, vendor: bloomberg-data.example, geo: CH}>`.
7. Receives `200 {"valid": true, "constraints_match": true, ...}`.
8. Accepts the order.
