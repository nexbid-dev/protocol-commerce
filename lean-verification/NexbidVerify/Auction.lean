-- ─── T3-T6: Auction Logic — Formal Verification ──────────────────────
-- Mirrors: runAuction() from packages/auction/src/engine.ts

import NexbidVerify.Types
import NexbidVerify.Score

namespace Nexbid

structure Participant where
  campaignId : String
  bidCents : Rat
  qualityScore : UnitInterval
  remainingBudgetCents : Rat
  similarity : UnitInterval
  contextRelevance : UnitInterval

def isEligible (p : Participant) (floorPriceCents : Rat) : Prop :=
  p.remainingBudgetCents ≥ p.bidCents ∧ p.bidCents ≥ floorPriceCents

instance (p : Participant) (floor : Rat) : Decidable (isEligible p floor) := by
  unfold isEligible; exact instDecidableAnd

def filterEligible (ps : List Participant) (floor : Rat) : List Participant :=
  ps.filter (fun p => decide (isEligible p floor))

-- ─── T3 ──────────────────────────────────────────────────────────────

/-- **Theorem T3:** Every filtered participant is eligible. -/
theorem eligibility_correct (ps : List Participant) (floor : Rat) :
    ∀ p ∈ filterEligible ps floor, isEligible p floor := by
  intro p hp
  unfold filterEligible at hp
  simp [List.mem_filter] at hp
  exact hp.2

-- ─── Max selection ───────────────────────────────────────────────────

def maxParticipant (f : Participant → Rat) : (l : List Participant) → l ≠ [] → Participant
  | [x], _ => x
  | x :: y :: ys, _ =>
    let rest := maxParticipant f (y :: ys) (by simp)
    if f x ≥ f rest then x else rest

-- ─── L1: Tie-breaking uniqueness ────────────────────────────────────

/-- **L1:** If two participants have equal scores, the one appearing first in the list wins.
    maxParticipant uses ≥ in the if-branch, so when f x = f rest, the head x is returned. -/
theorem maxParticipant_head_wins_tie (f : Participant → Rat) (x : Participant) (xs : List Participant)
    (h : (x :: xs) ≠ []) (hx_in : xs ≠ [])
    (h_tie : f x = f (maxParticipant f xs hx_in)) :
    maxParticipant f (x :: xs) h = x := by
  cases xs with
  | nil => exact absurd rfl hx_in
  | cons y ys =>
    show (let rest := maxParticipant f (y :: ys) (by simp); if f x ≥ f rest then x else rest) = x
    have h_eq : maxParticipant f (y :: ys) hx_in = maxParticipant f (y :: ys) (by simp) := by congr 1
    rw [h_eq] at h_tie
    have hge : f x ≥ f (maxParticipant f (y :: ys) (by simp)) := by
      show f (maxParticipant f (y :: ys) (by simp)) ≤ f x
      rw [← h_tie]  -- goal becomes f x ≤ f x
      exact Rat.le_refl
    simp [if_pos hge]

-- ─── T4: maxParticipant returns the maximum ──────────────────────────

/-- **Theorem T4:** maxParticipant returns element with highest f-value. -/
theorem maxParticipant_is_max (f : Participant → Rat)
    (l : List Participant) (h : l ≠ []) :
    ∀ x ∈ l, f x ≤ f (maxParticipant f l h) := by
  induction l with
  | nil => exact absurd rfl h
  | cons a as ih =>
    intro x hx
    cases as with
    | nil =>
      simp [maxParticipant]
      have heq : x = a := by
        cases List.mem_cons.mp hx with
        | inl h => exact h
        | inr h => exact absurd (List.not_mem_nil h) (by simp)
      rw [heq]
      exact Rat.le_refl
    | cons b bs =>
      simp only [maxParticipant]
      split
      · -- f a ≥ f rest
        next hge =>
        cases List.mem_cons.mp hx with
        | inl heq => rw [heq]; exact Rat.le_refl
        | inr hmem => exact Rat.le_trans (ih (by simp) x hmem) hge
      · -- f a < f rest
        next hlt =>
        cases List.mem_cons.mp hx with
        | inl heq =>
          rw [heq]
          simp [GE.ge, Rat.not_le] at hlt
          exact Rat.le_of_lt hlt
        | inr hmem => exact ih (by simp) x hmem

/-- **T4b:** maxParticipant returns a member of the list. -/
theorem maxParticipant_mem (f : Participant → Rat)
    (l : List Participant) (h : l ≠ []) :
    maxParticipant f l h ∈ l := by
  induction l with
  | nil => exact absurd rfl h
  | cons a as ih =>
    cases as with
    | nil => simp [maxParticipant]
    | cons b bs =>
      simp only [maxParticipant]
      split
      · exact List.Mem.head _
      · exact List.Mem.tail _ (ih (by simp))

-- ─── T5: Winner is eligible ──────────────────────────────────────────

/-- **Theorem T5:** Winner from filtered list is eligible. -/
theorem winner_is_eligible (ps : List Participant) (floor : Rat)
    (f : Participant → Rat) (h : filterEligible ps floor ≠ []) :
    isEligible (maxParticipant f (filterEligible ps floor) h) floor :=
  eligibility_correct ps floor _ (maxParticipant_mem f _ h)

-- ─── T6: No winner ↔ no eligible ────────────────────────────────────

/-- **T6a:** No eligible → no winner possible. -/
theorem no_eligible_no_winner (ps : List Participant) (floor : Rat)
    (h : filterEligible ps floor = []) :
    ∀ p ∈ ps, ¬ isEligible p floor := by
  intro p hp helig
  have : p ∈ filterEligible ps floor := by
    unfold filterEligible; simp [List.mem_filter]; exact ⟨hp, helig⟩
  rw [h] at this; exact List.not_mem_nil this

/-- **T6b:** Eligible → non-empty filtered list. -/
theorem eligible_exists_nonempty (ps : List Participant) (floor : Rat)
    (p : Participant) (hp : p ∈ ps) (helig : isEligible p floor) :
    filterEligible ps floor ≠ [] := by
  intro hempty
  exact absurd helig (no_eligible_no_winner ps floor hempty p hp)

end Nexbid
