-- ─── Nexbid Auction Score — Formal Verification ──────────────────────
-- Mirrors: computeAuctionScore() from packages/auction/src/engine.ts
--
-- TypeScript original:
--   score = bw * normalizedBid + sw * similarity + qw * qualityScore + cw * contextRelevance
--
-- Theorem T1 (score_bounded):
--   If all inputs ∈ [0,1] and weights are non-negative summing to 1,
--   then score ∈ [0,1].

import NexbidVerify.Types

namespace Nexbid

/-- Compute the weighted auction score.
    Direct translation of computeAuctionScore() from engine.ts -/
def computeAuctionScore
    (normalizedBid : UnitInterval)
    (similarity : UnitInterval)
    (qualityScore : UnitInterval)
    (contextRelevance : UnitInterval)
    (w : AuctionWeights) : Rat :=
  w.bidWeight * normalizedBid.val +
  w.similarityWeight * similarity.val +
  w.qualityWeight * qualityScore.val +
  w.contextWeight * contextRelevance.val

-- ─── Helper lemmas ───────────────────────────────────────────────────

private theorem rat_add_le_add {a b c d : Rat} (h1 : a ≤ b) (h2 : c ≤ d) : a + c ≤ b + d := by
  have h3 : a + c ≤ a + d := Rat.add_le_add_left.mpr h2
  have h4 : a + d ≤ b + d := Rat.add_le_add_right.mpr h1
  exact Rat.le_trans h3 h4

/-- w * x ≤ w when 0 ≤ w and x ≤ 1 -/
private theorem mul_le_of_le_one (w x : Rat) (hw : 0 ≤ w) (hx : x ≤ 1) : w * x ≤ w := by
  have h1 : w * x ≤ w * 1 := Rat.mul_le_mul_of_nonneg_left hx hw
  simp [Rat.mul_one] at h1
  exact h1

-- ─── T1: Score is bounded in [0, 1] ─────────────────────────────────

/-- **Theorem T1a (score_lower_bound):**
    The auction score is always ≥ 0. -/
theorem score_nonneg
    (normalizedBid similarity qualityScore contextRelevance : UnitInterval)
    (w : AuctionWeights) :
    0 ≤ computeAuctionScore normalizedBid similarity qualityScore contextRelevance w := by
  unfold computeAuctionScore
  apply Rat.add_nonneg
  apply Rat.add_nonneg
  apply Rat.add_nonneg
  · exact Rat.mul_nonneg w.all_nonneg.1 normalizedBid.ge_zero
  · exact Rat.mul_nonneg w.all_nonneg.2.1 similarity.ge_zero
  · exact Rat.mul_nonneg w.all_nonneg.2.2.1 qualityScore.ge_zero
  · exact Rat.mul_nonneg w.all_nonneg.2.2.2 contextRelevance.ge_zero

/-- **Theorem T1b (score_upper_bound):**
    The auction score is always ≤ 1. -/
theorem score_le_one
    (normalizedBid similarity qualityScore contextRelevance : UnitInterval)
    (w : AuctionWeights) :
    computeAuctionScore normalizedBid similarity qualityScore contextRelevance w ≤ 1 := by
  unfold computeAuctionScore
  have hbw := mul_le_of_le_one w.bidWeight normalizedBid.val w.all_nonneg.1 normalizedBid.le_one
  have hsw := mul_le_of_le_one w.similarityWeight similarity.val w.all_nonneg.2.1 similarity.le_one
  have hqw := mul_le_of_le_one w.qualityWeight qualityScore.val w.all_nonneg.2.2.1 qualityScore.le_one
  have hcw := mul_le_of_le_one w.contextWeight contextRelevance.val w.all_nonneg.2.2.2 contextRelevance.le_one
  calc w.bidWeight * normalizedBid.val +
       w.similarityWeight * similarity.val +
       w.qualityWeight * qualityScore.val +
       w.contextWeight * contextRelevance.val
      ≤ w.bidWeight + w.similarityWeight + w.qualityWeight + w.contextWeight := by
        apply rat_add_le_add
        apply rat_add_le_add
        apply rat_add_le_add
        · exact hbw
        · exact hsw
        · exact hqw
        · exact hcw
    _ = 1 := w.sum_eq_one

/-- **Theorem T1 (combined):**
    computeAuctionScore always returns a value in [0, 1],
    given valid inputs and weights. This is a MATHEMATICAL PROOF,
    not a test — it covers ALL possible valid inputs. -/
theorem score_bounded
    (normalizedBid similarity qualityScore contextRelevance : UnitInterval)
    (w : AuctionWeights) :
    0 ≤ computeAuctionScore normalizedBid similarity qualityScore contextRelevance w ∧
    computeAuctionScore normalizedBid similarity qualityScore contextRelevance w ≤ 1 :=
  ⟨score_nonneg normalizedBid similarity qualityScore contextRelevance w,
   score_le_one normalizedBid similarity qualityScore contextRelevance w⟩

-- ─── Sanity checks: concrete computations ───────────────────────────

/-- With all inputs = 1 and default weights, score = 1 -/
example : computeAuctionScore
    ⟨1, by native_decide, by native_decide⟩
    ⟨1, by native_decide, by native_decide⟩
    ⟨1, by native_decide, by native_decide⟩
    ⟨1, by native_decide, by native_decide⟩
    defaultWeights = 1 := by native_decide

/-- With all inputs = 0, score = 0 -/
example : computeAuctionScore
    ⟨0, by native_decide, by native_decide⟩
    ⟨0, by native_decide, by native_decide⟩
    ⟨0, by native_decide, by native_decide⟩
    ⟨0, by native_decide, by native_decide⟩
    defaultWeights = 0 := by native_decide

end Nexbid
