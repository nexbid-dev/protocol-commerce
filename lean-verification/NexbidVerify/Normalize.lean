-- ─── T2: Bid Normalization ────────────────────────────────────────────
-- Mirrors: normalizedBid = maxBid > 0 ? p.bidCents / maxBid : 0
-- from packages/auction/src/engine.ts:149
--
-- Theorem T2: normalizeBid always returns a value in [0, 1]

import NexbidVerify.Types

namespace Nexbid

/-- Normalize a bid relative to the maximum bid in the auction.
    Returns 0 if maxBid is 0 (no valid bids). -/
def normalizeBid (bidCents : Rat) (maxBid : Rat) : Rat :=
  if maxBid > 0 then bidCents / maxBid else 0

/-- **Theorem T2a:** normalizeBid is always ≥ 0,
    given non-negative bid and positive maxBid. -/
theorem normalizeBid_nonneg (bidCents maxBid : Rat)
    (hbid : 0 ≤ bidCents) (_hmax : 0 ≤ maxBid) :
    0 ≤ normalizeBid bidCents maxBid := by
  unfold normalizeBid
  split
  · next h =>
    rw [Rat.div_def]
    exact Rat.mul_nonneg hbid (Rat.le_of_lt (Rat.inv_pos.mpr h))
  · exact Rat.le_refl

/-- **Theorem T2b:** normalizeBid is always ≤ 1,
    given that bid ≤ maxBid and maxBid ≥ 0. -/
theorem normalizeBid_le_one (bidCents maxBid : Rat)
    (hbid_le_max : bidCents ≤ maxBid) (_hmax : 0 ≤ maxBid) :
    normalizeBid bidCents maxBid ≤ 1 := by
  unfold normalizeBid
  split
  · next h =>
    rw [Rat.div_def]
    calc bidCents * maxBid⁻¹
        ≤ maxBid * maxBid⁻¹ :=
          Rat.mul_le_mul_of_nonneg_right hbid_le_max
            (Rat.le_of_lt (Rat.inv_pos.mpr h))
      _ = 1 := Rat.mul_inv_cancel maxBid (Rat.ne_of_gt h)
  · exact by native_decide

/-- **Theorem T2 (combined):** normalizeBid returns a value in [0, 1]. -/
theorem normalizeBid_bounded (bidCents maxBid : Rat)
    (hbid : 0 ≤ bidCents) (hbid_le_max : bidCents ≤ maxBid) (hmax : 0 ≤ maxBid) :
    0 ≤ normalizeBid bidCents maxBid ∧ normalizeBid bidCents maxBid ≤ 1 :=
  ⟨normalizeBid_nonneg bidCents maxBid hbid hmax,
   normalizeBid_le_one bidCents maxBid hbid_le_max hmax⟩

end Nexbid
