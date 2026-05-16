import NexbidVerify.Types

namespace Commerce

/-- A revenue split between two parties, guaranteed to sum to 1. -/
structure RevenueShare where
  publisherShare : Rat
  platformShare : Rat
  shares_nonneg : 0 ≤ publisherShare ∧ 0 ≤ platformShare
  shares_sum_one : publisherShare + platformShare = 1

/-- Default 70/30 revenue share. -/
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
