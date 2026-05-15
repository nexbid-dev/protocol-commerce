-- ─── Commerce Policy — Formal Verification ───────────────────────────
-- Mirrors: policyCheck from packages/commerce/src/policy.ts
-- Bridges Commerce layer constraints with Auction layer eligibility.

import NexbidVerify.Types
import NexbidVerify.Auction

namespace Nexbid

-- ─── Policy types ──────────────────────────────────────────────────────

structure PolicyConstraint where
  minBidCents : Rat
  allowedCategories : List String

/-- Policy check: bid meets floor AND category is allowed. -/
def policyCheck (bidCents : Rat) (category : String) (policy : PolicyConstraint) : Bool :=
  (decide (bidCents ≥ policy.minBidCents)) && policy.allowedCategories.contains category

-- ─── L4: T17b Category membership proposition ─────────────────────────

/-- **L4 (T17b):** If policyCheck passes, the category is in the allowed list. -/
theorem policy_category_check (bidCents : Rat) (category : String)
    (policy : PolicyConstraint)
    (h : policyCheck bidCents category policy = true) :
    policy.allowedCategories.contains category = true := by
  unfold policyCheck at h
  simp [Bool.and_eq_true] at h
  exact List.contains_iff_mem.mpr h.2

-- ─── L4b: If policyCheck passes, bid meets floor ──────────────────────

/-- **L4b:** If policyCheck passes, the bid is at least the minimum. -/
theorem policy_bid_meets_floor (bidCents : Rat) (category : String)
    (policy : PolicyConstraint)
    (h : policyCheck bidCents category policy = true) :
    bidCents ≥ policy.minBidCents := by
  unfold policyCheck at h
  simp [Bool.and_eq_true] at h
  exact h.1

-- ─── L2: Bridge policyCheck → isEligible ──────────────────────────────

/-- **L2:** If policyCheck passes with floor as minBidCents, and participant has
    sufficient budget, then isEligible holds. This bridges Commerce ↔ Auction. -/
theorem policy_implies_eligible (p : Participant) (floor : Rat) (category : String)
    (policy : PolicyConstraint)
    (h_floor_match : policy.minBidCents = floor)
    (h_budget : p.remainingBudgetCents ≥ p.bidCents)
    (h_policy : policyCheck p.bidCents category policy = true) :
    isEligible p floor := by
  unfold isEligible
  constructor
  · exact h_budget
  · have h_bid := policy_bid_meets_floor p.bidCents category policy h_policy
    rw [h_floor_match] at h_bid
    exact h_bid

end Nexbid
