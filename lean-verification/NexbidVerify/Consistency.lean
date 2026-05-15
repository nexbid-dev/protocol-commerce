-- ─── T8: Consistency ε-Bound ──────────────────────────────────────────
-- Proves: The difference between scores under two weight sets is bounded
-- by 4 * maxCoeffDiff, provided per-weight differences are bounded.
--
-- Proof strategy:
-- 1. Both scores are linear: score = Σ w_i * x_i
-- 2. Difference = Σ (w1_i - w2_i) * x_i
-- 3. Each (Δw_i * x_i) ∈ [-d, d] when (Δw_i) ∈ [-d, d] and x_i ∈ [0, 1].
--    Proven by case-split on the sign of Δw_i (using Rat.le_total).
-- 4. Sum of 4 such bounded terms is in [-4d, 4d].
--
-- We express the bound without Rat absolute value using two-sided
-- inequalities: -ε ≤ diff ≤ ε. No Mathlib dependency — uses our own
-- RatHelpers module for the few stdlib gaps (sub_mul, four_mul_eq_sum,
-- mul_nonpos_of_nonpos_of_nonneg, one_sub_nonneg_of_le_one).

import NexbidVerify.Types
import NexbidVerify.Score
import NexbidVerify.RatHelpers

namespace Nexbid

open Nexbid.RatHelpers

/-- Maximum per-coefficient difference between KAN and linear weights (0.005). -/
def maxCoeffDiff : Rat := 5 / 1000

-- ─── Helper lemmas ──────────────────────────────────────────────────────

/-- `Δ * x ≤ d` whenever `Δ ≤ d` and `0 ≤ x ≤ 1` and `0 ≤ d`. Case-split on
    the sign of `Δ`. -/
private theorem mul_unit_upper
    (Δ d : Rat) (h_hi : Δ ≤ d) (h_d_nn : 0 ≤ d)
    (x : UnitInterval) :
    Δ * x.val ≤ d := by
  rcases @Rat.le_total 0 Δ with hΔ | hΔ
  · -- Case 0 ≤ Δ: Δ * x ≤ Δ * 1 = Δ ≤ d
    have h1 : Δ * x.val ≤ Δ * 1 := Rat.mul_le_mul_of_nonneg_left x.le_one hΔ
    rw [Rat.mul_one] at h1
    exact Rat.le_trans h1 h_hi
  · -- Case Δ ≤ 0: Δ * x ≤ 0 ≤ d
    have h_nonpos : Δ * x.val ≤ 0 := mul_nonpos_of_nonpos_of_nonneg hΔ x.ge_zero
    exact Rat.le_trans h_nonpos h_d_nn

/-- `-d ≤ Δ * x` whenever `-d ≤ Δ` and `0 ≤ x ≤ 1` and `0 ≤ d`. -/
private theorem mul_unit_lower
    (Δ d : Rat) (h_lo : -d ≤ Δ) (h_d_nn : 0 ≤ d)
    (x : UnitInterval) :
    -d ≤ Δ * x.val := by
  rcases @Rat.le_total 0 Δ with hΔ | hΔ
  · -- Case 0 ≤ Δ: 0 ≤ Δ * x and -d ≤ 0
    have h_pos : 0 ≤ Δ * x.val := Rat.mul_nonneg hΔ x.ge_zero
    exact Rat.le_trans (neg_nonpos_of_nonneg h_d_nn) h_pos
  · -- Case Δ ≤ 0: Δ * x ≥ Δ ≥ -d.
    -- Show via 0 ≤ (-Δ) * (1 - x.val) = Δ * x.val - Δ.
    have h_neg_Δ_nn : 0 ≤ -Δ := neg_nonneg_of_nonpos hΔ
    have h_one_sub_x_nn : 0 ≤ 1 - x.val := one_sub_nonneg_of_le_one x.le_one
    have h_prod_nn : 0 ≤ (-Δ) * (1 - x.val) :=
      Rat.mul_nonneg h_neg_Δ_nn h_one_sub_x_nn
    -- Algebraic identity: (-Δ) * (1 - x.val) = Δ * x.val - Δ.
    have h_id : (-Δ) * (1 - x.val) = Δ * x.val - Δ := by
      rw [mul_sub, Rat.mul_one, Rat.neg_mul, Rat.sub_eq_add_neg, Rat.sub_eq_add_neg,
          Rat.neg_neg, Rat.add_comm]
    rw [h_id] at h_prod_nn
    -- 0 ≤ Δ * x.val - Δ. Add Δ to both sides: Δ ≤ Δ * x.val.
    -- Use Rat.le_iff_sub_nonneg in reverse.
    have h_lhs : Δ ≤ Δ * x.val := (Rat.le_iff_sub_nonneg Δ (Δ * x.val)).mpr h_prod_nn
    exact Rat.le_trans h_lo h_lhs

-- ─── Sum-of-4 bounds ────────────────────────────────────────────────────

private theorem sum4_upper
    (a b c e d : Rat)
    (ha : a ≤ d) (hb : b ≤ d) (hc : c ≤ d) (he : e ≤ d) :
    a + b + c + e ≤ 4 * d := by
  have h1 : a + b ≤ d + d :=
    Rat.le_trans (Rat.add_le_add_right.mpr ha) (Rat.add_le_add_left.mpr hb)
  have h2 : (a + b) + c ≤ (d + d) + d :=
    Rat.le_trans (Rat.add_le_add_right.mpr h1) (Rat.add_le_add_left.mpr hc)
  have h3 : ((a + b) + c) + e ≤ ((d + d) + d) + d :=
    Rat.le_trans (Rat.add_le_add_right.mpr h2) (Rat.add_le_add_left.mpr he)
  have h_eq : (4 : Rat) * d = ((d + d) + d) + d := four_mul_eq_sum d
  rw [h_eq]
  exact h3

private theorem sum4_lower
    (a b c e d : Rat)
    (ha : -d ≤ a) (hb : -d ≤ b) (hc : -d ≤ c) (he : -d ≤ e) :
    -(4 * d) ≤ a + b + c + e := by
  have h1 : -d + -d ≤ a + b :=
    Rat.le_trans (Rat.add_le_add_right.mpr ha) (Rat.add_le_add_left.mpr hb)
  have h2 : (-d + -d) + -d ≤ (a + b) + c :=
    Rat.le_trans (Rat.add_le_add_right.mpr h1) (Rat.add_le_add_left.mpr hc)
  have h3 : ((-d + -d) + -d) + -d ≤ ((a + b) + c) + e :=
    Rat.le_trans (Rat.add_le_add_right.mpr h2) (Rat.add_le_add_left.mpr he)
  have h_eq : -(4 * d) = ((-d + -d) + -d) + -d := neg_four_mul_eq_sum d
  rw [h_eq]
  exact h3

-- ─── T8: Score consistency ─────────────────────────────────────────────

/-- **Theorem T8 (score_consistency):**
    If each weight differs by at most maxCoeffDiff between two weight sets,
    then the scores differ by at most 4 * maxCoeffDiff = 0.02.

    Two-sided bound (no Rat abs):
      -(4 * maxCoeffDiff) ≤ score(w1) - score(w2) ≤ 4 * maxCoeffDiff

    The bound is tight: achieved when all x_i = 1 and all weight diffs = ±maxCoeffDiff. -/
theorem score_consistency
    (x1 x2 x3 x4 : UnitInterval)
    (w1 w2 : AuctionWeights)
    (h_b_lo : -(maxCoeffDiff) ≤ w1.bidWeight - w2.bidWeight)
    (h_b_hi : w1.bidWeight - w2.bidWeight ≤ maxCoeffDiff)
    (h_s_lo : -(maxCoeffDiff) ≤ w1.similarityWeight - w2.similarityWeight)
    (h_s_hi : w1.similarityWeight - w2.similarityWeight ≤ maxCoeffDiff)
    (h_q_lo : -(maxCoeffDiff) ≤ w1.qualityWeight - w2.qualityWeight)
    (h_q_hi : w1.qualityWeight - w2.qualityWeight ≤ maxCoeffDiff)
    (h_c_lo : -(maxCoeffDiff) ≤ w1.contextWeight - w2.contextWeight)
    (h_c_hi : w1.contextWeight - w2.contextWeight ≤ maxCoeffDiff) :
    -(4 * maxCoeffDiff) ≤
      (computeAuctionScore x1 x2 x3 x4 w1 - computeAuctionScore x1 x2 x3 x4 w2) ∧
    (computeAuctionScore x1 x2 x3 x4 w1 - computeAuctionScore x1 x2 x3 x4 w2) ≤
      4 * maxCoeffDiff := by
  -- maxCoeffDiff = 5/1000 ≥ 0
  have h_d_nn : (0 : Rat) ≤ maxCoeffDiff := by
    unfold maxCoeffDiff; native_decide
  -- Bound each (Δw_i * x_i).
  have b_lo := mul_unit_lower (w1.bidWeight - w2.bidWeight) maxCoeffDiff h_b_lo h_d_nn x1
  have b_hi := mul_unit_upper (w1.bidWeight - w2.bidWeight) maxCoeffDiff h_b_hi h_d_nn x1
  have s_lo := mul_unit_lower (w1.similarityWeight - w2.similarityWeight) maxCoeffDiff h_s_lo h_d_nn x2
  have s_hi := mul_unit_upper (w1.similarityWeight - w2.similarityWeight) maxCoeffDiff h_s_hi h_d_nn x2
  have q_lo := mul_unit_lower (w1.qualityWeight - w2.qualityWeight) maxCoeffDiff h_q_lo h_d_nn x3
  have q_hi := mul_unit_upper (w1.qualityWeight - w2.qualityWeight) maxCoeffDiff h_q_hi h_d_nn x3
  have c_lo := mul_unit_lower (w1.contextWeight - w2.contextWeight) maxCoeffDiff h_c_lo h_d_nn x4
  have c_hi := mul_unit_upper (w1.contextWeight - w2.contextWeight) maxCoeffDiff h_c_hi h_d_nn x4
  -- Sum the four bounded terms.
  have sum_lo := sum4_lower
    ((w1.bidWeight - w2.bidWeight) * x1.val)
    ((w1.similarityWeight - w2.similarityWeight) * x2.val)
    ((w1.qualityWeight - w2.qualityWeight) * x3.val)
    ((w1.contextWeight - w2.contextWeight) * x4.val)
    maxCoeffDiff
    b_lo s_lo q_lo c_lo
  have sum_hi := sum4_upper
    ((w1.bidWeight - w2.bidWeight) * x1.val)
    ((w1.similarityWeight - w2.similarityWeight) * x2.val)
    ((w1.qualityWeight - w2.qualityWeight) * x3.val)
    ((w1.contextWeight - w2.contextWeight) * x4.val)
    maxCoeffDiff
    b_hi s_hi q_hi c_hi
  -- Show that the score difference equals the sum of these four products.
  have eq_diff :
      computeAuctionScore x1 x2 x3 x4 w1 - computeAuctionScore x1 x2 x3 x4 w2
      = (w1.bidWeight - w2.bidWeight) * x1.val
      + (w1.similarityWeight - w2.similarityWeight) * x2.val
      + (w1.qualityWeight - w2.qualityWeight) * x3.val
      + (w1.contextWeight - w2.contextWeight) * x4.val := by
    unfold computeAuctionScore
    -- Per-term factoring: (a - b) * c = a*c - b*c via sub_mul.
    rw [show (w1.bidWeight - w2.bidWeight) * x1.val
            = w1.bidWeight * x1.val - w2.bidWeight * x1.val from sub_mul _ _ _,
        show (w1.similarityWeight - w2.similarityWeight) * x2.val
            = w1.similarityWeight * x2.val - w2.similarityWeight * x2.val from sub_mul _ _ _,
        show (w1.qualityWeight - w2.qualityWeight) * x3.val
            = w1.qualityWeight * x3.val - w2.qualityWeight * x3.val from sub_mul _ _ _,
        show (w1.contextWeight - w2.contextWeight) * x4.val
            = w1.contextWeight * x4.val - w2.contextWeight * x4.val from sub_mul _ _ _]
    -- Now both sides are sums of (w1_i * x_i) - (w2_i * x_i) terms.
    -- Use Rat.sub_eq_add_neg + commutativity to massage into matching form.
    simp [Rat.sub_eq_add_neg, Rat.neg_add, Rat.add_left_comm, Rat.add_assoc]
  rw [eq_diff]
  exact ⟨sum_lo, sum_hi⟩

end Nexbid
