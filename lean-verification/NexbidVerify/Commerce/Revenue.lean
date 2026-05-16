-- NexbidVerify/Commerce/Revenue.lean
import NexbidVerify.Commerce.DSL

namespace Commerce

/-- T8: Revenue shares always sum to total bid. -/
theorem revenue_share_correct (bidAmountCents : Rat) (share : RevenueShare) :
    let r := computeRevenue bidAmountCents share
    r.publisherRevenue + r.platformRevenue = r.totalRevenue := by
  simp [computeRevenue]
  rw [← Rat.mul_add, share.shares_sum_one, Rat.mul_one]

/-- T9: No negative revenue for non-negative bids. -/
theorem revenue_nonneg (bidAmountCents : Rat) (share : RevenueShare)
    (hbid : 0 ≤ bidAmountCents) :
    let r := computeRevenue bidAmountCents share
    0 ≤ r.publisherRevenue ∧ 0 ≤ r.platformRevenue := by
  simp [computeRevenue]
  exact ⟨Rat.mul_nonneg hbid share.shares_nonneg.1, Rat.mul_nonneg hbid share.shares_nonneg.2⟩

/-- T10: Revenue never exceeds bid amount. -/
theorem revenue_le_bid (bidAmountCents : Rat) (share : RevenueShare)
    (hbid : 0 ≤ bidAmountCents) :
    let r := computeRevenue bidAmountCents share
    r.publisherRevenue ≤ r.totalRevenue ∧ r.platformRevenue ≤ r.totalRevenue := by
  simp [computeRevenue]
  constructor
  · have h1 : share.publisherShare ≤ 1 := by
      have key : share.publisherShare + 0 ≤ share.publisherShare + share.platformShare :=
        Rat.add_le_add_left.mpr share.shares_nonneg.2
      rw [Rat.add_zero] at key
      rw [share.shares_sum_one] at key
      exact key
    calc bidAmountCents * share.publisherShare
        ≤ bidAmountCents * 1 := Rat.mul_le_mul_of_nonneg_left h1 hbid
      _ = bidAmountCents := Rat.mul_one _
  · have h2 : share.platformShare ≤ 1 := by
      have key : share.platformShare + 0 ≤ share.platformShare + share.publisherShare :=
        Rat.add_le_add_left.mpr share.shares_nonneg.1
      rw [Rat.add_zero] at key
      rw [Rat.add_comm] at key
      rw [share.shares_sum_one] at key
      exact key
    calc bidAmountCents * share.platformShare
        ≤ bidAmountCents * 1 := Rat.mul_le_mul_of_nonneg_left h2 hbid
      _ = bidAmountCents := Rat.mul_one _

end Commerce
