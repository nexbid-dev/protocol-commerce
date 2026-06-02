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
| **Mandate** | Authorization is portable and cryptographically signed (Ed25519, post-quantum-ready) | Reference implementation (Nexbid) — format generalizes a per-vertical signed-mandate pattern |
| **Audit** | Every action is appended to a tamper-evident trail | Reference implementation (Nexbid) — append-only logs + signed compliance manifests |
| **Identity** | Agents are registered and verifiable, not anonymous | Reference implementation (Nexbid) — agent registration + verifiable delivery badge |

> **Open-core:** the protocol, the formal proofs, and (over time) the SDK are open
> (MIT). The hosted operational-audit infrastructure is the reference
> implementation's concern. The *math* is public — verify it yourself.

## What is real today

- **Formal verification is public and reproducible.** Clone this repo, install Lean 4
  (`elan`), run `cd lean-verification && lake build`. If it compiles, all 47 theorems
  hold — the compiler is the verifier. No trust in us required.
- The mandate / audit / identity pillars run in the **Nexbid reference
  implementation** ([nexbid.dev](https://nexbid.dev)) and are being lifted into open,
  reusable form here.

## Roadmap (honest — not promises)

The Kit is being packaged from working parts, in stages of increasing openness:

1. **Verified-Agent Badge** — a public "this agent's delivery is verified + auditable" signal. *(reference implementation live)*
2. **SDK** — bring your own policy, get a Lean-checked proof + a signed mandate + an audit hook. *(in design)*
3. **Open standard** — a portable *Verifiable Agent Mandate* governed in the open, with this Lean reference implementation as the differentiator. *(early — see AMDP track)*

Stages are scoped openly; this README will only ever claim what is actually shipped.

## Why formal verification (and why it's rare)

In a world where AI increasingly *writes* and *runs* code, "is this correct?" becomes
the core question. Tests check finitely many cases. Proofs cover **all possible
inputs**. To our knowledge this is the first commerce-agent stack whose core
mechanics are formally verified — inspired by
[Leanstral](https://mistral.ai/news/leanstral) (Mistral AI).

## License

MIT — use it, fork it, build on it. The proofs are there to be checked, not believed.
