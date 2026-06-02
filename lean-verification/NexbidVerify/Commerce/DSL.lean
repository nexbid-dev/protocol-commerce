import NexbidVerify.Types

namespace Commerce

/-- A revenue split between two parties, guaranteed to sum to 1. -/
structure RevenueShare where
  publisherShare : Rat
  platformShare : Rat
  shares_nonneg : 0 ≤ publisherShare ∧ 0 ≤ platformShare
  shares_sum_one : publisherShare + platformShare = 1

/-- Default 70/30 revenue share — generic library default.
    Note: This is the example default for the RevenueShare structure,
    NOT the production tier-pricing. Nexbid's production AdCP match-revenue
    split uses 90/10 (PLATFORM_FEE_STANDARD = 0.10 in packages/shared/src/pricing.ts,
    Founding 95/5 via PLATFORM_FEE_FOUNDING = 0.05). Per-customer overrides
    are stored in the platform_pricing DB table. The proofs in this file are
    generic over any valid RevenueShare and do not depend on this default. -/
def defaultRevenueShare : RevenueShare := {
  publisherShare := 7 / 10
  platformShare := 3 / 10
  shares_nonneg := ⟨by native_decide, by native_decide⟩
  shares_sum_one := by native_decide
}

/-- Revenue computed from a bid and a revenue share. -/
structure RevenueResult where
  publisherRevenue : Rat
  platformRevenue : Rat
  totalRevenue : Rat

/-- Compute revenue from a winning bid amount and share. -/
def computeRevenue (bidAmountCents : Rat) (share : RevenueShare) : RevenueResult := {
  publisherRevenue := bidAmountCents * share.publisherShare
  platformRevenue := bidAmountCents * share.platformShare
  totalRevenue := bidAmountCents
}

/-- A policy constraint that a bid must satisfy. -/
structure PolicyConstraint where
  maxBudgetCents : Rat
  spentCents : Rat
  floorCents : Rat
  allowedCategories : List String
  budget_nonneg : 0 ≤ maxBudgetCents
  spent_nonneg : 0 ≤ spentCents
  spent_le_budget : spentCents ≤ maxBudgetCents
  floor_nonneg : 0 ≤ floorCents

/-- Check if a bid satisfies a policy constraint. -/
def policyCheck (bidCents : Rat) (category : String)
    (policy : PolicyConstraint) : Bool :=
  decide (bidCents ≤ policy.maxBudgetCents - policy.spentCents) &&
  decide (policy.floorCents ≤ bidCents) &&
  policy.allowedCategories.contains category

end Commerce
