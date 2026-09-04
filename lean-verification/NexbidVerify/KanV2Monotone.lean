-- ─── KAN-v2: bid monotonicity + boundedness for the additive [4,1] GAM ──────
--
-- Mirrors packages/auction/src/kan-scorer.ts (v2) + experiments/kan/kan_v2.py:
--   score = clamp01( phi_bid(bid) + phi_sim(sim) + phi_qual(qual) + phi_ctx(ctx) )
--
-- The four edges are modelled abstractly as functions UnitInterval → Rat. The
-- ONLY hypothesis the verification needs about phi_bid is that it is strictly
-- monotone (hmono). The trained ONNX REALISES that hypothesis structurally
-- (cumulative-softplus B-spline control points; checked by the differential
-- property test), so the Lean guarantee and the runtime artefact agree.
--
-- B1 (review): clamp01 destroys STRICT monotonicity in saturation (both bids
-- clamp to 1). So the strict theorem is stated on the UNCLAMPED sum, and the
-- deployed CLAMPED score carries the WEAK (≤) theorem. No Mathlib.

import NexbidVerify.Types

namespace Nexbid

/-- Hard saturating output head, mirroring `Math.max(0, Math.min(1, z))`. -/
def clamp01 (x : Rat) : Rat :=
  if x ≤ 0 then 0 else if 1 ≤ x then 1 else x

theorem clamp01_nonneg (x : Rat) : 0 ≤ clamp01 x := by
  unfold clamp01
  by_cases h0 : x ≤ 0
  · rw [if_pos h0]; native_decide
  · rw [if_neg h0]
    by_cases h1 : (1 : Rat) ≤ x
    · rw [if_pos h1]; native_decide
    · rw [if_neg h1]; exact Rat.le_of_lt (Rat.not_le.mp h0)

theorem clamp01_le_one (x : Rat) : clamp01 x ≤ 1 := by
  unfold clamp01
  by_cases h0 : x ≤ 0
  · rw [if_pos h0]; native_decide
  · rw [if_neg h0]
    by_cases h1 : (1 : Rat) ≤ x
    · rw [if_pos h1]; native_decide
    · rw [if_neg h1]; exact Rat.le_of_lt (Rat.not_le.mp h1)

/-- clamp01 is monotone non-decreasing (weak — ties allowed in the flat
    saturation regions). Proved by case analysis, no min/max lemmas. -/
theorem clamp01_mono {x y : Rat} (h : x ≤ y) : clamp01 x ≤ clamp01 y := by
  simp only [clamp01]
  by_cases hx0 : x ≤ 0
  · by_cases hy0 : y ≤ 0
    · rw [if_pos hx0, if_pos hy0]; native_decide
    · rw [if_pos hx0, if_neg hy0]
      by_cases hy1 : (1 : Rat) ≤ y
      · rw [if_pos hy1]; native_decide
      · rw [if_neg hy1]; exact Rat.le_of_lt (Rat.not_le.mp hy0)
  · by_cases hx1 : (1 : Rat) ≤ x
    · rw [if_neg hx0, if_pos hx1]
      by_cases hy0 : y ≤ 0
      · exact absurd (Rat.le_trans h hy0) hx0
      · rw [if_neg hy0]
        by_cases hy1 : (1 : Rat) ≤ y
        · rw [if_pos hy1]; native_decide
        · exact absurd (Rat.le_trans hx1 h) hy1
    · rw [if_neg hx0, if_neg hx1]
      by_cases hy0 : y ≤ 0
      · exact absurd (Rat.le_trans h hy0) hx0
      · rw [if_neg hy0]
        by_cases hy1 : (1 : Rat) ≤ y
        · rw [if_pos hy1]; exact Rat.le_of_lt (Rat.not_le.mp hx1)
        · rw [if_neg hy1]; exact h

/-- Unclamped additive sum of the four edges. -/
def gamSum (fb fs fq fc : UnitInterval → Rat)
    (bid sim qual ctx : UnitInterval) : Rat :=
  fb bid + fs sim + fq qual + fc ctx

/-- Deployed score: clamp01 of the additive sum. -/
def gamScore (fb fs fq fc : UnitInterval → Rat)
    (bid sim qual ctx : UnitInterval) : Rat :=
  clamp01 (gamSum fb fs fq fc bid sim qual ctx)

/-- **T1-KAN-v2 (boundedness):** the deployed v2 score is always in [0, 1],
    regardless of the edge functions — it is a clamp. -/
theorem kan_v2_score_bounded
    (fb fs fq fc : UnitInterval → Rat) (bid sim qual ctx : UnitInterval) :
    0 ≤ gamScore fb fs fq fc bid sim qual ctx ∧
    gamScore fb fs fq fc bid sim qual ctx ≤ 1 := by
  unfold gamScore
  exact ⟨clamp01_nonneg _, clamp01_le_one _⟩

/-- **T7m-KAN-v2 (strict, unclamped):** if phi_bid is strictly monotone and
    bid increases (other inputs fixed), the unclamped sum strictly increases.
    Structurally identical to the linear T7m (`add_lt_add_right` chain). -/
theorem kan_bid_monotone_unclamped
    (fb fs fq fc : UnitInterval → Rat)
    (hmono : ∀ a b : UnitInterval, a.val < b.val → fb a < fb b)
    (bid_a bid_b sim qual ctx : UnitInterval)
    (h_gt : bid_b.val < bid_a.val) :
    gamSum fb fs fq fc bid_b sim qual ctx <
    gamSum fb fs fq fc bid_a sim qual ctx := by
  unfold gamSum
  have h : fb bid_b < fb bid_a := hmono bid_b bid_a h_gt
  have h1 : fb bid_b + fs sim < fb bid_a + fs sim := Rat.add_lt_add_right.mpr h
  have h2 : fb bid_b + fs sim + fq qual < fb bid_a + fs sim + fq qual :=
    Rat.add_lt_add_right.mpr h1
  exact Rat.add_lt_add_right.mpr h2

/-- **T7m-KAN-v2 (weak, clamped):** the DEPLOYED clamped score is monotone
    non-decreasing in bid. Strict everywhere except the saturation plateau,
    where clamp ties both bids to the same bound — semantically correct (a
    maxed-out score cannot rise further). -/
theorem kan_bid_monotone_clamped
    (fb fs fq fc : UnitInterval → Rat)
    (hmono : ∀ a b : UnitInterval, a.val < b.val → fb a < fb b)
    (bid_a bid_b sim qual ctx : UnitInterval)
    (h_gt : bid_b.val < bid_a.val) :
    gamScore fb fs fq fc bid_b sim qual ctx ≤
    gamScore fb fs fq fc bid_a sim qual ctx := by
  unfold gamScore
  exact clamp01_mono
    (Rat.le_of_lt (kan_bid_monotone_unclamped fb fs fq fc hmono bid_a bid_b sim qual ctx h_gt))

end Nexbid
