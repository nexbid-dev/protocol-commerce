# The Seven Principles of Protocol Commerce

These principles guide the design of open commerce protocols. They are not aspirational — they are constraints. Any protocol claiming to be "open" should be evaluated against these criteria.

## 1. Open by Default

The protocol specification, reference schemas, and client libraries are MIT-licensed. Any entity can read, implement, fork, or extend the protocol without permission, payment, or partnership agreements.

**Test:** Can a developer build a compliant server this weekend using only public documentation?

## 2. Publisher Parity

Publishers are first-class protocol participants — not an afterthought. The protocol must provide mechanisms for publishers to:

- Register their content and inventory
- Set floor prices and revenue share terms
- Receive attribution when their content informs agent recommendations
- Maintain control over their brand environment

**Test:** Does the protocol have a publisher-facing message type, or only merchant-facing ones?

## 3. Privacy Native

The protocol does not require, transmit, or store user-identifying information. Context signals (page topic, search intent, brand affinity) replace user profiles. There are no cookies, no fingerprinting, no cross-site tracking.

**Test:** Can the protocol function with zero knowledge of the end user's identity?

## 4. Agent Agnostic

The protocol works with any MCP-compatible AI agent. It does not privilege a specific agent vendor (OpenAI, Google, Anthropic, or others). An AdCP-compatible server serves Claude, ChatGPT, Gemini, and custom agents through the same interface.

**Test:** Does switching from Agent A to Agent B require any server-side changes?

## 5. Transparent Scoring

The ranking algorithm is public and verifiable. Commerce participants can calculate their expected score given their inputs (bid, relevance, quality). There are no hidden boosters, undisclosed fees, or opaque re-ranking.

**Reference formula:**
```
score = (weight_bid × normalized_bid) + (weight_relevance × similarity) + (weight_quality × quality_signal)
```

Default weights: `bid = 0.4`, `relevance = 0.4`, `quality = 0.2`. Weights are configurable per deployment but must be disclosed.

**Test:** Given the same inputs, do two independent implementations produce the same ranking?

## 6. Attribution Without Surveillance

The protocol tracks value contribution, not user behavior. Attribution is based on which content sources contributed to an agent's recommendation — not on following users across sessions.

Attribution events use one-time, non-reversible identifiers (UUID v7) that connect a query to an outcome without creating a persistent user profile.

**Test:** Can the attribution system function without any user identifier?

## 7. Interoperable

The protocol bridges to existing standards where useful. OpenRTB 2.6 compatibility allows integration with programmatic advertising infrastructure. ARTF compatibility enables IAB-compliant real-time bidding. GPP/TCF integration ensures regulatory compliance.

Interoperability is additive — the core protocol functions independently, and bridges are optional adapters.

**Test:** Can an existing OpenRTB buyer participate in an AdCP auction through an adapter?

---

## Applying the Principles

When evaluating protocol design decisions, apply the principle tests. If a proposed change fails any test, it requires explicit justification for why the principle is being violated and what constraint makes compliance impossible.

Principles are ordered by priority. In case of conflict, lower-numbered principles take precedence. For example, Privacy Native (3) overrides Interoperable (7) — the protocol will not add user tracking to achieve OpenRTB compatibility.
