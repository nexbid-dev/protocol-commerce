# Verified Agent Delivery Badge

> The first usable Agentic Kit feature — a trust signal backed by a real, auditable
> delivery event, not a claim you can self-assign.

## What it proves

The Verified Agent Delivery Badge answers one question for anyone visiting a publisher
or brand page: **was this content actually delivered to an AI agent through an open,
auditable commerce protocol — or is "AI-ready" just a marketing sticker?**

The badge is backed by a real delivery record (an *enriched-snippet impression*: a row
recording that a specific piece of content met a specific product at a specific intent,
and was served to an agent). **No delivery, no badge.** This is the Kit's **Audit**
pillar made visible: the proof is the event, not the assertion.

## How to use it (reference implementation)

The badge runs live in the [Nexbid](https://nexbid.dev) reference implementation. Two
endpoints, both on the bot-friendly API domain (they are fetched from `<img>` tags and
by crawlers, so no bot-blocking):

### JSON status

```
GET https://api.nexbid.dev/v1/badge/{id}/verify
```

```json
{
  "verified": true,
  "last_delivery_at": "2026-05-19T07:23:11.000Z",
  "total_deliveries_7d": 142,
  "tier": "founding"
}
```

`{id}` accepts either the customer UUID or a publisher slug (e.g. `pub_bettybossi`).

### SVG embed (drop into any page)

```html
<a href="https://nexbid.dev/" target="_blank" rel="noopener">
  <img src="https://api.nexbid.dev/v1/badge/pub_bettybossi/embed.svg"
       alt="Verified Agent Delivery via Nexbid" width="240" height="56" />
</a>
```

## The honest failure mode (this is the point)

A page that has had **no** verified agent delivery does **not** get a misleading "verified"
badge. The endpoint returns an error (e.g. HTTP 403 for tiers without enriched-snippet
delivery), and the `<img>` simply shows a broken-image icon rather than a false green
checkmark. Showing "verified" where nothing was delivered would be exactly the dishonesty
the Agentic Kit exists to prevent.

## What it is — and isn't

- ✅ Proof of a **real, auditable** agent-delivery event
- ✅ Self-correcting — it reflects live delivery data, not a one-time grant
- ❌ **Not** a quality rating, an endorsement, or a score
- ❌ **Not** self-assignable — you cannot mint a badge without an actual delivery

## Where it sits in the Kit

The badge is the **Identity / Audit** surface of the [Agentic Kit](./README.md): it turns
the otherwise invisible audit trail into a public, verifiable signal. It is **Stage A**
(the Trust-Badge) of the Kit's roadmap — the fastest path from "we log deliveries" to
"anyone can verify a delivery happened."

## Reference implementation

- JSON endpoint, SVG endpoint, and shared tier-eligibility resolver ship in the Nexbid
  reference implementation ([nexbid.dev](https://nexbid.dev)).
- Backed by an append-only delivery-impression table (the audit source of truth).
- Open-core: the *concept and contract* are documented here; the hosted endpoint is the
  reference implementation's concern.
