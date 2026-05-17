# Example — Equity-Research Family Office

**File:** [equity-research-family-office.json](equity-research-family-office.json)
**Vertical:** `equity-research`
**License:** MIT

## Scenario

Family Office Alpha delegates mining/energy/rare-earth equity research to an external research firm's agent (Mining Equity Researcher, on Claude Opus 4.7). The agent may:

- Execute buy/sell/hold decisions (`make_investment_decision`).
- Rebalance the portfolio within the policy (`rebalance_portfolio`).
- Subscribe to or unsubscribe from research reports (`subscribe_research_report`).

This is the canonical use case discussed in ADR-040: cross-vertical mandate clarity for high-stakes financial agent delegation.

## Constraints

- **`max_amount: 500'000 USD per_action`** — Each individual trade decision is capped at USD 500'000. The `mode=per_action` semantics differ from `cumulative`: the agent could execute many CAD 500'000 trades over six months, as long as no single decision exceeds the cap.
- **`time_window: 2026-05-17 to 2026-11-17`** — Six-month delegation, matching a typical research-engagement cycle.
- **`asset_classes: [mining-equity, energy-equity, rare-earth-equity]`** — Sector-bounded. A decision on (say) software equity would be rejected with `AMDP_CONSTRAINT_VIOLATION`.
- **`geo_regions: [CA, AU, CH, EU, UK]`** — Restricted to jurisdictions where Family Office Alpha holds custody arrangements.

## Why this shape

- **`mode=per_action` for max_amount** is appropriate here because individual investment decisions are discrete and reviewable. A `cumulative` cap would prevent the agent from running an active strategy over a six-month window.
- **Sector-bounded by `asset_classes`** keeps the agent inside its declared competence area. A research firm specializing in mining equity should not be authorized to trade software equity, even within the cap.
- **Geographic constraint** reflects custody / regulatory realities. The Family Office's prime broker may only support specific jurisdictions.
- **Audit trail is critical** for regulated verticals; the `audit_trail_endpoint` lets the principal monitor trade signals against this mandate alongside their internal compliance system.
- **Six-month `expires_at`** is at the upper end of advisable for high-stakes mandates. SECURITY.md recommends shorter windows for highest-stakes scenarios; six months is a pragmatic compromise here.

## Verification flow

The research firm's execution platform (verifier) receives an agent request to make a `make_investment_decision` for USD 480'000 in `mining-equity` traded on the TSX (Canada, CA). The verifier:

1. Validates schema.
2. Fetches JWKS.
3. Verifies hybrid signature.
4. Calls `/verify?mandate_id=01904b1a-...&action=make_investment_decision&context=<base64url of {amount: 480000, currency: USD, asset_class: mining-equity, geo: CA, ticker: ABC.TO}>`.
5. Receives `200 {"valid": true, "constraints_match": true, ...}`.
6. Routes the order to the broker.

If the agent had instead proposed USD 600'000 (above the cap), the resolver would return `200 {"valid": false, "reason": "constraints_match=false: amount exceeds max_amount", "constraints_match": false, ...}` and the verifier would deny the trade.

## Note on sub-delegation

This mandate is the parent in [multi-vertical-family-office.json](multi-vertical-family-office.json) — see that example for how Family Office Alpha sub-delegates a narrow procurement scope while keeping this equity-research scope intact.
