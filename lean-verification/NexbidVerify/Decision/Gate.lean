-- ─── Decision Gate Invariant — Formal Verification ───────────────────
-- Mirrors: decide() eligibility filter + winner selection in
-- packages/decision-auction/src/engine.ts.
--
-- THE core theorem (winner_eligible / gated_never_wins): a gated (ineligible)
-- candidate is NEVER selected as the winner. This is the deterministic,
-- machine-checked answer to "the agent provably cannot violate a hard intent
-- gate, regardless of what the LLM proposes."
-- Structure mirrors Auction.lean (T3/T4b/T5). TS bridge: the gate-safety
-- property test in engine.test.ts.

import NexbidVerify.Decision.Types
import NexbidVerify.Decision.Score

namespace Nexbid.Decision

/-- Candidates that survived the IntentProfile gate pass. -/
def filterEligible (cs : List Candidate) : List Candidate :=
  cs.filter (fun c => c.eligible)

/-- Every candidate that survives the filter is eligible. -/
theorem eligibility_correct (cs : List Candidate) :
    ∀ c ∈ filterEligible cs, c.eligible = true := by
  intro c hc
  unfold filterEligible at hc
  simp [List.mem_filter] at hc
  exact hc.2

/-- Recursive argmax by score function `f`; the head wins ties (uses ≥),
    mirroring the deterministic engine ordering. -/
def maxCandidate (f : Candidate → Rat) : (l : List Candidate) → l ≠ [] → Candidate
  | [x], _ => x
  | x :: y :: ys, _ =>
    let rest := maxCandidate f (y :: ys) (by simp)
    if f x ≥ f rest then x else rest

/-- maxCandidate always returns a member of the list. -/
theorem maxCandidate_mem (f : Candidate → Rat) (l : List Candidate) (h : l ≠ []) :
    maxCandidate f l h ∈ l := by
  induction l with
  | nil => exact absurd rfl h
  | cons a as ih =>
    cases as with
    | nil => simp [maxCandidate]
    | cons b bs =>
      simp only [maxCandidate]
      split
      · exact List.Mem.head _
      · exact List.Mem.tail _ (ih (by simp))

/-- The winner is the highest-scoring eligible candidate. -/
def decideWinner (w : DecisionWeights) (cs : List Candidate)
    (h : filterEligible cs ≠ []) : Candidate :=
  maxCandidate (fun c => computeDecisionScore c w) (filterEligible cs) h

/-- **Gate invariant:** the winner is always eligible. -/
theorem winner_eligible (w : DecisionWeights) (cs : List Candidate)
    (h : filterEligible cs ≠ []) :
    (decideWinner w cs h).eligible = true :=
  eligibility_correct cs _ (maxCandidate_mem _ _ h)

/-- **Gate invariant (explicit form):** an ineligible (gated) candidate is
    NEVER equal to the winner — no matter its score. -/
theorem gated_never_wins (w : DecisionWeights) (cs : List Candidate)
    (h : filterEligible cs ≠ [])
    (c : Candidate) (hc : c.eligible = false) :
    decideWinner w cs h ≠ c := by
  intro heq
  have hwin : (decideWinner w cs h).eligible = true := winner_eligible w cs h
  rw [heq, hc] at hwin
  exact absurd hwin (by decide)

-- ─── No-eligible ↔ no-winner (mirror Auction.lean T6) ────────────────

/-- No eligible candidate survives ⟹ no candidate is eligible (mirror of
    Auction.lean T6a; the Bool analog of "no winner possible"). -/
theorem no_eligible_no_winner (cs : List Candidate)
    (h : filterEligible cs = []) :
    ∀ c ∈ cs, ¬ (c.eligible = true) := by
  intro c hc helig
  have hmem : c ∈ filterEligible cs := by
    unfold filterEligible; simp [List.mem_filter]; exact ⟨hc, helig⟩
  rw [h] at hmem; exact List.not_mem_nil hmem

end Nexbid.Decision
