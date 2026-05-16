-- ─── Nexbid Types ─────────────────────────────────────────────────────
-- Mirrors TypeScript types from packages/auction/src/engine.ts
-- Uses rational numbers (Rat) for exact arithmetic in proofs.

namespace Nexbid

/-- A value known to be in the closed interval [0, 1]. -/
structure UnitInterval where
  val : Rat
  ge_zero : 0 ≤ val
  le_one : val ≤ 1

instance : Repr UnitInterval where
  reprPrec u _ := repr u.val

/-- Auction score weights — must be non-negative and sum to 1. -/
structure AuctionWeights where
  bidWeight : Rat
  similarityWeight : Rat
  qualityWeight : Rat
  contextWeight : Rat
  all_nonneg : 0 ≤ bidWeight ∧ 0 ≤ similarityWeight ∧ 0 ≤ qualityWeight ∧ 0 ≤ contextWeight
  sum_eq_one : bidWeight + similarityWeight + qualityWeight + contextWeight = 1

/-- Default weights: 0.3 / 0.3 / 0.2 / 0.2 (matches TypeScript DEFAULT_*_WEIGHT) -/
def defaultWeights : AuctionWeights where
  bidWeight := 3 / 10
  similarityWeight := 3 / 10
  qualityWeight := 2 / 10
  contextWeight := 2 / 10
  all_nonneg := ⟨by native_decide, by native_decide, by native_decide, by native_decide⟩
  sum_eq_one := by native_decide

end Nexbid
