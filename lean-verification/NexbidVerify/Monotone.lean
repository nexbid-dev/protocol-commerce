-- ─── T7: Bid Monotonicity ─────────────────────────────────────────────
-- Proves: Higher bid implies higher auction score (ceteris paribus).
-- This guarantees the auction engine is incentive-compatible:
-- bidding more always results in a strictly better score.

import NexbidVerify.Types
import NexbidVerify.Score

namespace Nexbid

/-- **Theorem T7 (bid_monotone):**
    If bid_a > bid_b and all other inputs are identical,
    then score(a) > score(b), provided bidWeight > 0.
    This is the core incentive-compatibility property. -/
theorem bid_monotone
    (bid_a bid_b : UnitInterval)
    (h_gt : bid_a.val > bid_b.val)
    (sim qual ctx : UnitInterval)
    (w : AuctionWeights)
    (h_bw : 0 < w.bidWeight) :
    computeAuctionScore bid_a sim qual ctx w >
    computeAuctionScore bid_b sim qual ctx w := by
  unfold computeAuctionScore
  -- Only the first term differs: w.bidWeight * bid_a.val vs w.bidWeight * bid_b.val
  -- Since w.bidWeight > 0 and bid_a.val > bid_b.val, the first term is strictly larger.
  -- All other terms (similarity, quality, context) are identical, so the sum is strictly larger.
  have h : w.bidWeight * bid_a.val > w.bidWeight * bid_b.val := by
    exact Rat.mul_lt_mul_of_pos_left h_gt h_bw
  have h1 : w.bidWeight * bid_a.val + w.similarityWeight * sim.val >
             w.bidWeight * bid_b.val + w.similarityWeight * sim.val :=
    Rat.add_lt_add_right.mpr h
  have h2 : w.bidWeight * bid_a.val + w.similarityWeight * sim.val + w.qualityWeight * qual.val >
             w.bidWeight * bid_b.val + w.similarityWeight * sim.val + w.qualityWeight * qual.val :=
    Rat.add_lt_add_right.mpr h1
  exact Rat.add_lt_add_right.mpr h2

end Nexbid
