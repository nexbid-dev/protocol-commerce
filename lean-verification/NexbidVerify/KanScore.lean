-- ─── T1-KAN: KAN Score Boundedness ────────────────────────────────────
-- Proves: The KAN Variant A (quasi-linear extraction) score is bounded in [0,1].
--
-- KAN Variant A raw coefficients: bid=0.204, sim=0.300, qual=0.197, ctx=0.154
-- Sum = 0.855 (not 1.0, because 4 features use default 0.5 inputs).
-- Normalized: each / 0.855, giving weights that sum to exactly 1.
-- Since normalized weights form valid AuctionWeights, T1 (score_bounded) applies directly.

import NexbidVerify.Types
import NexbidVerify.Score

namespace Nexbid

/-- KAN Variant A: normalized weights summing to 1.
    Raw: bid=0.204, sim=0.300, qual=0.197, ctx=0.154 (sum=0.855)
    Normalized: each / 0.855 → 204/855 + 300/855 + 197/855 + 154/855 = 855/855 = 1 -/
def kanWeightsNormalized : AuctionWeights where
  bidWeight := 204 / 855       -- ~0.2386
  similarityWeight := 300 / 855 -- ~0.3509
  qualityWeight := 197 / 855    -- ~0.2304
  contextWeight := 154 / 855    -- ~0.1801
  all_nonneg := ⟨by native_decide, by native_decide, by native_decide, by native_decide⟩
  sum_eq_one := by native_decide

/-- **Theorem T1-KAN (kan_score_bounded):**
    The KAN-derived score is always in [0, 1].
    Follows directly from T1 since kanWeightsNormalized is a valid AuctionWeights instance. -/
theorem kan_score_bounded
    (bid sim qual ctx : UnitInterval) :
    0 ≤ computeAuctionScore bid sim qual ctx kanWeightsNormalized ∧
    computeAuctionScore bid sim qual ctx kanWeightsNormalized ≤ 1 :=
  score_bounded bid sim qual ctx kanWeightsNormalized

-- ─── Sanity checks ──────────────────────────────────────────────────

/-- With all inputs = 1, KAN score = 1 -/
example : computeAuctionScore
    ⟨1, by native_decide, by native_decide⟩
    ⟨1, by native_decide, by native_decide⟩
    ⟨1, by native_decide, by native_decide⟩
    ⟨1, by native_decide, by native_decide⟩
    kanWeightsNormalized = 1 := by native_decide

/-- With all inputs = 0, KAN score = 0 -/
example : computeAuctionScore
    ⟨0, by native_decide, by native_decide⟩
    ⟨0, by native_decide, by native_decide⟩
    ⟨0, by native_decide, by native_decide⟩
    ⟨0, by native_decide, by native_decide⟩
    kanWeightsNormalized = 0 := by native_decide

end Nexbid
