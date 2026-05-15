-- ─── Rat Helpers — pure-stdlib lemmas for T8 ──────────────────────────
-- Mathlib alternatives we cannot use here (per design decision in
-- lean-verification/README.md "Kein Mathlib"):
--   ring     → write algebraic identities as explicit chained rewrites
--   linarith → use Rat.add_le_add_left/right + Rat.le_trans manually
--   nlinarith→ case-split on signs via Rat.le_total
--
-- This file contains the small set of Rat lemmas we need that are NOT
-- in Lean's standard library so far. Keeping them isolated means future
-- proofs can import the same helpers without chasing stdlib gaps.

namespace Nexbid.RatHelpers

-- ─── Distributivity over subtraction ────────────────────────────────────

/-- Right-distributivity over subtraction: `(a - b) * c = a * c - b * c`. -/
theorem sub_mul (a b c : Rat) : (a - b) * c = a * c - b * c := by
  rw [Rat.sub_eq_add_neg, Rat.add_mul, Rat.neg_mul, ← Rat.sub_eq_add_neg]

/-- Left-distributivity over subtraction: `a * (b - c) = a * b - a * c`. -/
theorem mul_sub (a b c : Rat) : a * (b - c) = a * b - a * c := by
  rw [Rat.sub_eq_add_neg, Rat.mul_add, Rat.mul_neg, ← Rat.sub_eq_add_neg]

-- ─── Sign reasoning ─────────────────────────────────────────────────────

/-- If `a ≤ 0` then `0 ≤ -a`. -/
theorem neg_nonneg_of_nonpos {a : Rat} (h : a ≤ 0) : 0 ≤ -a := by
  have := Rat.neg_le_neg h
  simpa using this

/-- If `0 ≤ a` then `-a ≤ 0`. -/
theorem neg_nonpos_of_nonneg {a : Rat} (h : 0 ≤ a) : -a ≤ 0 := by
  have := Rat.neg_le_neg h
  simpa using this

/-- If `a ≤ 0` and `0 ≤ b` then `a * b ≤ 0`. -/
theorem mul_nonpos_of_nonpos_of_nonneg {a b : Rat} (ha : a ≤ 0) (hb : 0 ≤ b) :
    a * b ≤ 0 := by
  have h_neg : 0 ≤ -a := neg_nonneg_of_nonpos ha
  have h_pos : 0 ≤ (-a) * b := Rat.mul_nonneg h_neg hb
  -- (-a) * b = -(a * b), so 0 ≤ -(a * b), so a * b ≤ 0.
  rw [Rat.neg_mul] at h_pos
  have := Rat.neg_le_neg h_pos
  simpa using this

/-- If `1 - x ≥ 0`. Holds for any `x ≤ 1`. -/
theorem one_sub_nonneg_of_le_one {x : Rat} (h : x ≤ 1) : 0 ≤ 1 - x := by
  -- 0 ≤ 1 - x  ↔  x ≤ 1  (Rat.le_iff_sub_nonneg, swapped sides)
  rw [Rat.sub_eq_add_neg]
  -- Show 0 ≤ 1 + (-x), i.e. -x + 1 ≥ 0, i.e. -x ≥ -1.
  have h1 : -1 ≤ -x := Rat.neg_le_neg h
  -- Add 1 to both sides: -1 + 1 ≤ -x + 1, i.e. 0 ≤ -x + 1.
  have h2 : (-1 : Rat) + 1 ≤ -x + 1 := Rat.add_le_add_right.mpr h1
  have h3 : (-1 : Rat) + 1 = 0 := Rat.neg_add_cancel 1
  rw [h3] at h2
  rwa [Rat.add_comm]

-- ─── 4 = 1 + 1 + 1 + 1 distribution ────────────────────────────────────

/-- `4 * d = d + d + d + d` for any rational `d`. -/
theorem four_mul_eq_sum (d : Rat) : (4 : Rat) * d = d + d + d + d := by
  -- 4 = 1 + 1 + 1 + 1, then distribute.
  have h4 : (4 : Rat) = 1 + 1 + 1 + 1 := by native_decide
  rw [h4, Rat.add_mul, Rat.add_mul, Rat.add_mul, Rat.one_mul]

/-- `-(4 * d) = (-d) + (-d) + (-d) + (-d)`. -/
theorem neg_four_mul_eq_sum (d : Rat) :
    -(4 * d) = -d + -d + -d + -d := by
  rw [four_mul_eq_sum, Rat.neg_add, Rat.neg_add, Rat.neg_add]

end Nexbid.RatHelpers
