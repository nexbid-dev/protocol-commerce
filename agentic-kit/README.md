# Agentic Kit

> The trust layer of Protocol Commerce — building blocks for **verifiable and auditable** AI agents.

As AI agents start to act autonomously on people's behalf, one question becomes
central: *who authorized this agent to do this, and can anyone check what it did?*
The Agentic Kit is the open answer — the components that let anyone run agents whose
decision **rules** are mathematically verified and whose **actions** leave an
auditable trail.

## Read this first — the honest scope

You **cannot** formally verify an LLM. Its output is non-deterministic; that is open
research. What you *can* verify is the **deterministic shell** the agent operates in:
budget arithmetic, category membership, spend floors, mandate limits, revenue splits.

- ✅ "We prove an agent **cannot break the rules** — and every decision leaves an auditable trail."
- ❌ "We guarantee the agent decides **correctly** or wisely." (impossible — don't claim it)

This distinction is the whole point. The Kit makes agent behaviour *accountable*, not *clairvoyant*.

## The trust triad

| Pillar | What it guarantees | Where it lives today |
|--------|--------------------|----------------------|
| **Verify** | Decision rules are mathematically proven (auction scoring, budget safety, payment bounds, policy) | **Public in this repo** → [`../lean-verification`](../lean-verification) — 47 Lean 4 theorems, zero `sorry`, `lake build`-checkable |
| **Mandate** | Authorization is portable and cryptographically signed (hybrid Ed25519 + ML-DSA-65, post-quantum-ready) | **Public in this repo** → [`../amdp-spec`](../amdp-spec) — the open Agent Mandate Discovery Protocol (v0.1); reference impl in Nexbid |
| **Audit** | Every action is appended to a tamper-evident trail | Reference implementation (Nexbid) — append-only logs + signed compliance manifests |
| **Identity** | Agents are registered and verifiable, not anonymous | Reference impl (Nexbid) — agent registration + the [Verified Agent Delivery Badge](./verified-agent-badge.md) |

> **Open-core:** the protocol, the formal proofs, and (over time) the SDK are open
> (MIT). The hosted operational-audit infrastructure is the reference
> implementation's concern. The *math* is public — verify it yourself.

## What is real today

- **Formal verification is public and reproducible.** Clone this repo, install Lean 4
  (`elan`), run `cd lean-verification && lake build`. If it compiles, all 47 theorems
  hold — the compiler is the verifier. No trust in us required.
- The **mandate format** is public as [AMDP v0.1](../amdp-spec) — a signed,
  cross-vertical, third-party-verifiable mandate document. The **audit** and
  **identity** pillars run in the **Nexbid reference implementation**
  ([nexbid.dev](https://nexbid.dev)) and are being lifted into open form here.

## Roadmap (honest — not promises)

The Kit is being packaged from working parts, in stages of increasing openness:

1. **[Verified-Agent Delivery Badge](./verified-agent-badge.md)** — a public "this agent's delivery is verified + auditable" signal, backed by a real delivery event (not a self-assigned sticker). *(live in the reference implementation)*
2. **SDK** — bring your own policy, get a Lean-checked proof + a signed mandate + an audit hook. *(in design)*
3. **Open standard** — a portable *Verifiable Agent Mandate*, governed in the open: **live as [AMDP v0.1](../amdp-spec)**, the cross-vertical mandate-discovery spec submitted to IAB Tech Lab + Linux Foundation. *(draft — breaking changes expected)*

Stages are scoped openly; this README will only ever claim what is actually shipped.

## Why formal verification (and why it's rare)

In a world where AI increasingly *writes* and *runs* code, "is this correct?" becomes
the core question. Tests check finitely many cases. Proofs cover **all possible
inputs**. To our knowledge this is the first commerce-agent stack whose core
mechanics are formally verified — inspired by
[Leanstral](https://mistral.ai/news/leanstral) (Mistral AI).

## License

MIT — use it, fork it, build on it. The proofs are there to be checked, not believed.
