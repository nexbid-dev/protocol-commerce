-- ─── T7: Atomic Budget Decrement — Formal Verification ───────────────
-- Mirrors: atomicBudgetDecrement() from packages/auction/src/atomic-budget.ts

namespace Nexbid

structure BudgetState where
  amountCents : Int
  spentCents : Int
  inv : spentCents ≤ amountCents
  spent_nonneg : 0 ≤ spentCents

theorem BudgetState.remaining_nonneg (b : BudgetState) :
    0 ≤ b.amountCents - b.spentCents := by
  have := b.inv; omega

inductive DecrementResult where
  | success (newState : BudgetState)
  | insufficientBudget

/-- Atomic budget decrement with WHERE guard. -/
def atomicDecrement (state : BudgetState) (deductCents : Int)
    (hdeduct : 0 ≤ deductCents) : DecrementResult :=
  if h : state.amountCents - state.spentCents ≥ deductCents then
    DecrementResult.success {
      amountCents := state.amountCents
      spentCents := state.spentCents + deductCents
      inv := by have := state.inv; have := state.spent_nonneg; omega
      spent_nonneg := by have := state.spent_nonneg; omega
    }
  else
    DecrementResult.insufficientBudget

-- ─── T7 theorems ────────────────────────────────────────────────────

/-- **T7a:** Invariant preserved. -/
theorem decrement_preserves_invariant (state : BudgetState) (deductCents : Int)
    (hdeduct : 0 ≤ deductCents) (newState : BudgetState)
    (_h : atomicDecrement state deductCents hdeduct = DecrementResult.success newState) :
    newState.spentCents ≤ newState.amountCents :=
  newState.inv

/-- **T7b:** Spent increased exactly. -/
theorem decrement_spent_exact (state : BudgetState) (deductCents : Int)
    (hdeduct : 0 ≤ deductCents) (newState : BudgetState)
    (h : atomicDecrement state deductCents hdeduct = DecrementResult.success newState) :
    newState.spentCents = state.spentCents + deductCents := by
  unfold atomicDecrement at h; split at h
  · injection h with h; rw [← h]
  · contradiction

/-- **T7c:** Total unchanged. -/
theorem decrement_total_unchanged (state : BudgetState) (deductCents : Int)
    (hdeduct : 0 ≤ deductCents) (newState : BudgetState)
    (h : atomicDecrement state deductCents hdeduct = DecrementResult.success newState) :
    newState.amountCents = state.amountCents := by
  unfold atomicDecrement at h; split at h
  · injection h with h; rw [← h]
  · contradiction

/-- **T7d:** Failure means insufficient budget. -/
theorem decrement_fail_means_insufficient (state : BudgetState) (deductCents : Int)
    (hdeduct : 0 ≤ deductCents)
    (h : atomicDecrement state deductCents hdeduct = DecrementResult.insufficientBudget) :
    state.amountCents - state.spentCents < deductCents := by
  unfold atomicDecrement at h; split at h
  · contradiction
  · next hn => omega

/-- **T7e:** Spent monotone. -/
theorem decrement_spent_monotone (state : BudgetState) (deductCents : Int)
    (hdeduct : 0 ≤ deductCents) (newState : BudgetState)
    (h : atomicDecrement state deductCents hdeduct = DecrementResult.success newState) :
    state.spentCents ≤ newState.spentCents := by
  have := decrement_spent_exact state deductCents hdeduct newState h; omega

/-- **Theorem T7 (budget_never_overspent):** Main safety property.
    Uses explicit unfolding to avoid match/simp issues. -/
theorem budget_never_overspent (state : BudgetState) (deductCents : Int)
    (hdeduct : 0 ≤ deductCents) :
    ∀ newState : BudgetState,
    atomicDecrement state deductCents hdeduct = DecrementResult.success newState →
    newState.spentCents ≤ newState.amountCents := by
  intro newState _h
  exact newState.inv

end Nexbid
