-- ─── Decision Score — Formal Verification ────────────────────────────
-- Mirrors: scoreCandidate() / computeDecisionScore in
-- packages/decision-auction/src/engine.ts.
--   score = goalFitWeight*goal_fit + safetyWeight*safety + qualityWeight*quality
-- Theorem (decisionScore_bounded): inputs ∈ [0,1] + weights non-negative
-- summing to 1 ⟹ score ∈ [0,1]. Generalises Score.lean's T1 to the decision case.
--
-- TS bridge — both halves are needed, and only one of them is a test:
--   hypothesis: unit()/clamp01() (unit.ts) enforce features ∈ [0,1] at the
--     adapter boundary, and loadProfile() enforces wᵢ > 0 with Σwᵢ = 1. Without
--     these the theorem is a conditional whose condition nobody checks — a
--     feature of 1.5 once scored 1.25 with this proof green.
--   conclusion: the boundedness property test in engine.test.ts.

import NexbidVerify.Types
import NexbidVerify.Decision.Types

namespace Nexbid.Decision

/-- Weighted decision score. Direct translation of scoreCandidate() over the
    (goal_fit, safety, quality) triple. -/
def computeDecisionScore (c : Candidate) (w : DecisionWeights) : Rat :=
  w.goalFitWeight * c.goalFit.val +
  w.safetyWeight * c.safety.val +
  w.qualityWeight * c.quality.val

-- ─── Helper lemmas (mirror Score.lean) ───────────────────────────────

private theorem rat_add_le_add {a b c d : Rat} (h1 : a ≤ b) (h2 : c ≤ d) : a + c ≤ b + d := by
  have h3 : a + c ≤ a + d := Rat.add_le_add_left.mpr h2
  have h4 : a + d ≤ b + d := Rat.add_le_add_right.mpr h1
  exact Rat.le_trans h3 h4

private theorem mul_le_of_le_one (w x : Rat) (hw : 0 ≤ w) (hx : x ≤ 1) : w * x ≤ w := by
  have h1 : w * x ≤ w * 1 := Rat.mul_le_mul_of_nonneg_left hx hw
  simp [Rat.mul_one] at h1
  exact h1

-- ─── Boundedness: score ∈ [0,1] ──────────────────────────────────────

/-- The decision score is always ≥ 0. -/
theorem decisionScore_nonneg (c : Candidate) (w : DecisionWeights) :
    0 ≤ computeDecisionScore c w := by
  unfold computeDecisionScore
  apply Rat.add_nonneg
  apply Rat.add_nonneg
  · exact Rat.mul_nonneg w.all_nonneg.1 c.goalFit.ge_zero
  · exact Rat.mul_nonneg w.all_nonneg.2.1 c.safety.ge_zero
  · exact Rat.mul_nonneg w.all_nonneg.2.2 c.quality.ge_zero

/-- The decision score is always ≤ 1. -/
theorem decisionScore_le_one (c : Candidate) (w : DecisionWeights) :
    computeDecisionScore c w ≤ 1 := by
  unfold computeDecisionScore
  have hg := mul_le_of_le_one w.goalFitWeight c.goalFit.val w.all_nonneg.1 c.goalFit.le_one
  have hs := mul_le_of_le_one w.safetyWeight c.safety.val w.all_nonneg.2.1 c.safety.le_one
  have hq := mul_le_of_le_one w.qualityWeight c.quality.val w.all_nonneg.2.2 c.quality.le_one
  calc w.goalFitWeight * c.goalFit.val +
       w.safetyWeight * c.safety.val +
       w.qualityWeight * c.quality.val
      ≤ w.goalFitWeight + w.safetyWeight + w.qualityWeight := by
        apply rat_add_le_add
        apply rat_add_le_add
        · exact hg
        · exact hs
        · exact hq
    _ = 1 := w.sum_eq_one

/-- **Boundedness (combined):** the decision score lies in [0,1] for all valid
    inputs and weights. A mathematical proof over ALL inputs, not a test. -/
theorem decisionScore_bounded (c : Candidate) (w : DecisionWeights) :
    0 ≤ computeDecisionScore c w ∧ computeDecisionScore c w ≤ 1 :=
  ⟨decisionScore_nonneg c w, decisionScore_le_one c w⟩

end Nexbid.Decision
