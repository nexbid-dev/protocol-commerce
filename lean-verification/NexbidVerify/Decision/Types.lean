-- ─── Decision Auction Types — Formal Verification ────────────────────
-- Mirrors: packages/decision-auction/src/types.ts (PreparedCandidate, WeightVector).
-- Generalises the ad-auction types (NexbidVerify/Types.lean) to arbitrary
-- agent decisions. Uses rational numbers (Rat) for exact arithmetic.

import NexbidVerify.Types

namespace Nexbid.Decision

/-- Decision score weights over the (goal_fit, safety, quality) feature triple —
    non-negative and summing to 1. Mirrors the Dev/Ops adapter's scored features
    and the `Σ wᵢ = 1, wᵢ > 0` invariant validated by loadProfile() in TS. -/
structure DecisionWeights where
  goalFitWeight : Rat
  safetyWeight : Rat
  qualityWeight : Rat
  all_nonneg : 0 ≤ goalFitWeight ∧ 0 ≤ safetyWeight ∧ 0 ≤ qualityWeight
  sum_eq_one : goalFitWeight + safetyWeight + qualityWeight = 1

/-- A prepared candidate action. `eligible` is set by the IntentProfile gate pass
    BEFORE the engine runs (mirrors PreparedCandidate.eligible in types.ts). -/
structure Candidate where
  id : String
  goalFit : UnitInterval
  safety : UnitInterval
  quality : UnitInterval
  eligible : Bool

end Nexbid.Decision
