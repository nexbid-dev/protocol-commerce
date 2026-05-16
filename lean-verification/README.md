# Nexbid Auction Engine — Formale Verifikation in Lean 4

Mathematischer Beweis der Korrektheit der Nexbid Auction Engine.
Nicht Tests (endlich viele Fälle), sondern **Beweise (alle möglichen Inputs)**.

## Was ist das?

Die Kern-Algorithmen der Nexbid Auction Engine — Scoring, Normalisierung,
Eligibility-Filter, Winner-Selection und Budget-Management — wurden in
[Lean 4](https://lean-lang.org/) nachgebaut und formal verifiziert.

**Wenn `lake build` erfolgreich ist, sind alle Beweise korrekt.**
Es gibt keine false positives — der Lean-Compiler ist der Verifier.

## Bewiesene Eigenschaften

| Theorem | Eigenschaft | Datei | Geschäftskritisch |
|---------|-------------|-------|-------------------|
| **T1** | `computeAuctionScore` ∈ [0,1] | Score.lean | Score-Overflow verhindern |
| **T2** | `normalizeBid` ∈ [0,1] | Normalize.lean | Normalisierung korrekt |
| **T3** | Gefilterte Teilnehmer sind eligible | Auction.lean | Keine bankrotten Bieter |
| **T4** | Winner hat höchsten Score | Auction.lean | Fairness der Auktion |
| **T4b** | Winner ist Listenmitglied | Auction.lean | Kein Phantom-Winner |
| **T5** | Winner ist eligible | Auction.lean | Winner ist zahlungsfähig |
| **T6a** | Keine eligible → kein Winner | Auction.lean | Kein Phantom-Winner |
| **T6b** | Eligible existiert → Liste nicht leer | Auction.lean | Konsistenz |
| **T7a** | Budget-Invariante erhalten | Budget.lean | Kein Overspend |
| **T7b** | Spent steigt exakt um deductCents | Budget.lean | Exakte Abrechnung |
| **T7c** | Total-Budget ändert sich nie | Budget.lean | Budget-Integrität |
| **T7d** | Failure = Insufficient Budget | Budget.lean | Korrekte Fehlermeldung |
| **T7e** | Spent ist monoton steigend | Budget.lean | Kein Budget-Reset |
| **T7m** | Bid-Monotonie | Monotone.lean | Höheres Gebot → höherer Score (Incentive-kompatibel) |
| **T8** | KAN-↔-linear ε-Bound (vollständig bewiesen via RatHelpers, 2026-04-26) | Consistency.lean | KAN-Shadow-Score weicht max. 0.02 ab |

**Stand 2026-05-15 (Audit verifiziert):** 47 öffentliche Theoreme über 15 `.lean`-Dateien, **null** `sorry`/`admit`/`axiom`. Die Tabelle oben zeigt die geschäftskritischen Kern-Theoreme; vollständige Liste mit Wallet-, Commerce- und EndToEnd-Theoremen siehe Sektion "Vollständiger Theorem-Index" unten.

## Vollständiger Theorem-Index (47 Theoreme, Audit 2026-05-15)

| Datei | Anzahl | Theoreme (Auszug) |
|-------|--------|-------------------|
| `Score.lean` | 6 | score_nonneg, score_le_one, score_bounded |
| `Normalize.lean` | 4 | normalizeBid_nonneg, normalizeBid_le_one |
| `Auction.lean` | 10 | eligibility_correct, maxParticipant_is_max, winner_is_eligible, no_eligible_no_winner |
| `Monotone.lean` | 1 | bid_monotone |
| `Budget.lean` | 8 | T7a-T7e, budget_never_overspent, BudgetState.remaining_nonneg |
| `Wallet.lean` | 9 | payment_le_mandate (W3), receipt_matches_execute (W5), wallet_balance_after_pay (W6a), idempotency_same_key (L3), wallet_spent_monotone |
| `KanScore.lean` | 4 | kan_score_bounded (T1-KAN) |
| `Consistency.lean` | 2 | score_consistency (T8, KAN-↔-linear) |
| `EndToEnd.lean` | 3 | T18 eligible_winner_budget_safe, T19 full_auction_invariants |
| `RatHelpers.lean` | 8 | sub_mul, mul_sub, mul_nonpos_of_nonpos_of_nonneg, four_mul_eq_sum (Stdlib-Lücken) |
| `Commerce/Revenue.lean` | 3 | revenue_share_correct, revenue_nonneg, revenue_le_bid |
| `Commerce/Policy.lean` | 4 | policy_implies_eligibility, policy_category_check |
| `Commerce/DSL.lean` | 3 | (siehe Hinweis zu `defaultRevenueShare` unten) |
| `Types.lean` | 1 | one_sub_le_one_helper |
| **Total** | **47** | alle `sorry`-frei, alle via `lake build` mechanisch verifiziert |

### Hinweis zur `defaultRevenueShare`-Konstante (70/30)

Die in `Commerce/DSL.lean` definierte Konstante `defaultRevenueShare = 7/10 + 3/10` ist ein **Library-Default für generische Theorem-Anwendbarkeit**, NICHT die Produktions-Tier-Konfiguration der Nexbid AdCP-Auktion.

| Schicht | Wert | Quelle |
|---------|------|--------|
| **Lean-4 Library-Default** | 70/30 | `Commerce/DSL.lean::defaultRevenueShare` (diese Codebase) |
| **Produktions-Standard-Tier** | 90/10 (Publisher behält 90%) | `packages/shared/src/pricing.ts::PLATFORM_FEE_STANDARD` (= 0.10) |
| **Founding-Tier (12 Monate)** | 95/5 | `packages/shared/src/pricing.ts::PLATFORM_FEE_FOUNDING` (= 0.05) |
| **Per-Customer-Override** | beliebig | `platform_pricing` DB-Tabelle |

Die Theoreme T8-T10 (`revenue_share_correct`, `revenue_nonneg`, `revenue_le_bid`) sind **generisch über jede `share : RevenueShare`-Instanz** — sie gelten unabhängig vom Default-Wert. Die Wahl `70/30` ist ausschliesslich ein neutraler Library-Default; die Public-Communication von Nexbid sagt korrekt 90/10 (Standard) bzw. 95/5 (Founding).

## Was NICHT bewiesen ist (Audit-Disclaimer 2026-05-15)

Diese Verifikation deckt die **algorithmische Kern-Logik** der Auction-Engine, Budget-Sicherheit, Wallet-Payment-Bounds und KAN-Konsistenz ab. Die folgenden Schichten sind **nicht** durch Lean-4-Theoreme abgesichert, sondern durch Code-Reviews, Tests, etablierte Engineering-Standards und (für sicherheitskritische Pfade) Red-Team-Tests:

- **Authentifizierung und Authorization (RBAC)** — abgesichert via Clerk + scoped OAuth-Scopes (ADR-036), nicht via Lean
- **CORS, SSRF, Input-Validation** — abgesichert via Engineering-Standards + Red-Team-Tests (`packages/mcp-server/src/__tests__/tier2/red-team.test.ts`, 23 Tests)
- **SQL-Query-Konstruktion und Network-Safety** — abgesichert via Parametrized-Queries (Neon-Driver) + Statement-Splitter (Migration-System)
- **Concurrency unter Real-DB-Load** — Postgres handhabt Atomarität (atomic Budget-Decrement nutzt SQL-Transaktionen)
- **TypeScript-zu-Lean-Implementation-Konformität** — verifiziert durch gespiegelte Funktions-Strukturen + Code-Review, nicht durch verified compiler

Diese Trennung ist absichtlich: Lean-4-Beweise sind sinnvoll, wo Eigenschaften für **alle möglichen Inputs** garantiert werden müssen (Score-Boundedness, Budget-Invariante). Auth, CORS, Network-Safety hingegen sind Verifikations-Domänen mit anderen Methoden (Red-Team, Pen-Test, Standards-Compliance).

## Mapping: Lean ↔ TypeScript

| Lean 4 | TypeScript (Original) |
|--------|----------------------|
| `NexbidVerify/Score.lean` | `packages/auction/src/engine.ts:84-97` |
| `NexbidVerify/Normalize.lean` | `packages/auction/src/engine.ts:143-149` |
| `NexbidVerify/Auction.lean` | `packages/auction/src/engine.ts:109-183` |
| `NexbidVerify/Budget.lean` | `packages/auction/src/atomic-budget.ts:38-69` |

## Projektstruktur

```
lean-verification/
├── lakefile.lean              # Build-Config
├── lean-toolchain             # Lean 4 Version (stable)
├── NexbidVerify.lean          # Root-Import
└── NexbidVerify/
    ├── Types.lean             # UnitInterval, AuctionWeights, defaultWeights
    ├── Score.lean             # T1: computeAuctionScore bounded [0,1]
    ├── Normalize.lean         # T2: normalizeBid bounded [0,1]
    ├── Auction.lean           # T3-T6: Eligibility, Winner-Selection
    └── Budget.lean            # T7: Atomic Budget Decrement safety
```

## Voraussetzungen

```bash
# Lean 4 installieren (elan = Version Manager)
curl -sSf https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh | sh -s -- -y
```

## Build & Verify

```bash
# Aus dem Lean-Verzeichnis:
cd lean-verification
lake build

# ODER aus dem Repo-Root via npm-Skript:
npm run lean:build       # nur lake build
npm run lean:verify      # lake build + sorry-allowlist guard
```

Keine Ausgabe = alle Beweise verifiziert. Bei Fehlern zeigt Lean exakt welcher
Beweis fehlschlägt und warum.

## Quality-Gate-Integration

Die formale Verifikation ist Teil des Quality-Gates und läuft auf jedem PR:

| Gate | Tool | Was wird geprüft |
|------|------|------------------|
| `lake build` | Lean 4 Compiler | Alle Theoreme typchecken — Compiler ist der Verifier |
| `check:lean-sorries` | `scripts/check-lean-sorries.mjs` | Keine neuen `sorry`-Stubs ausser dokumentierten in der Allowlist |
| GitHub Actions | `.github/workflows/lean-verify.yml` | Beides läuft cached + automatisiert auf jedem PR der Lean-Code berührt |

**Sorry-Allowlist:** Theoreme mit unabgeschlossenem Beweis müssen explizit in
`scripts/check-lean-sorries.mjs` stehen — mit Begründung und Pfadangabe. Ein
verlorener `sorry` (ohne Allowlist-Eintrag) bricht die CI; ein abgeschlossener
Beweis ohne Allowlist-Update bricht ebenfalls (verhindert Stale-Listen).

**Aktuelle Allowlist (Stand 2026-04-26 abends):**
*leer* — alle Theoreme inkl. T8 sind vollständig bewiesen. T8 wurde via
**Custom-Rat-Helper-Library** (`NexbidVerify/RatHelpers.lean`) komplettiert:
acht eigene Lemmas (`sub_mul`, `mul_sub`, `mul_nonpos_of_nonpos_of_nonneg`,
`one_sub_nonneg_of_le_one`, `four_mul_eq_sum`, `neg_four_mul_eq_sum`,
`neg_nonneg_of_nonpos`, `neg_nonpos_of_nonneg`) ersetzen die fehlenden
Stdlib-Identitäten ohne Mathlib-Dependency.

## Design-Entscheidungen

### Rationale Zahlen statt Floats
Lean's `Rat` (exakte Brüche) statt IEEE 754 Floats. `0.3` ist in Floats nicht
exakt darstellbar, aber `3/10` in `Rat` schon. Beweise über exakte Arithmetik
sind stärker als Beweise über Gleitkomma-Approximationen.

### Int für Budget (Cents)
Budget-Werte sind immer ganzzahlig (Cents). `Int` erlaubt `omega` — Lean's
mächtigen Taktik-Solver für lineare Ganzzahl-Arithmetik. Damit werden
Budget-Beweise fast trivial.

### Kein Mathlib
Bewusst ohne Mathlib (Lean's grosse Mathematik-Bibliothek) geschrieben.
Vorteil: keine Dependency, schneller Build. Nachteil: mehr manuelle Beweisarbeit
für `Rat`-Lemmas (z.B. `div_nonneg`, `add_le_add`).

### T8 — vollständig bewiesen via Custom Rat-Helper-Library (2026-04-26)

`NexbidVerify/Consistency.lean` enthielt ursprünglich ein `sorry` in
`score_consistency`. Lean 4 Stdlib hat drei konkrete Lücken die den Beweis
ohne Mathlib mühsam machen:

- `ring` / `linarith` / `nlinarith` Tactics fehlen → algebraische Identitäten brauchen explizite Lemma-Ketten
- `Rat.sub_mul` (Distributivität über Subtraktion) ist nicht im Lean-Core
- `Rat.le_total` ist eine `Or`-Proposition mit impliziten Argumenten — `@Rat.le_total 0 Δ` benötigt expliziten Aufruf

**Holger 2026-04-26 abends entschied: Option 2 — Custom Rat-Helper-Library.**

`NexbidVerify/RatHelpers.lean` füllt die Lücken mit acht eigenen Lemmas:
- `sub_mul`, `mul_sub` — Distributivität über Subtraktion
- `mul_nonpos_of_nonpos_of_nonneg` — Vorzeichenregel für Produkte
- `one_sub_nonneg_of_le_one` — `0 ≤ 1 - x` wenn `x ≤ 1`
- `neg_nonneg_of_nonpos`, `neg_nonpos_of_nonneg` — Vorzeichen-Negation
- `four_mul_eq_sum`, `neg_four_mul_eq_sum` — `4d = d+d+d+d` Distribution

Mit diesen Helpers kompiliert T8 sauber (Build-Zeit unter 1 s zusätzlich,
keine externen Dependencies). Die Sorry-Allowlist in
`scripts/check-lean-sorries.mjs` ist jetzt leer — jedes neue `sorry`
bricht die CI.

## Kontext

Dies ist vermutlich die erste formale Verifikation einer Ad-Auction-Engine.
Inspiriert durch [Leanstral](https://mistral.ai/news/leanstral) (Mistral AI),
ein spezialisiertes 6B-Parameter-Modell für Lean-4-Beweise.

**Relevanz:** In einer Welt, in der KI zunehmend Code generiert, wird die
Frage "Ist dieser Code korrekt?" zur Kernfrage. Formale Verifikation gibt
eine mathematische Garantie — nicht nur ein "Tests sind grün".
