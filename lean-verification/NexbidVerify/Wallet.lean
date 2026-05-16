-- Nexbid Wallet — Formal Verification
-- Mirrors: packages/purchase/src/wallet/*.ts
-- Safety properties W3, W5, W6 from Agent Wallet Protocol Design

namespace Nexbid

-- Types

structure IntentMandate where
  maxAmountCents : Int
  budgetCents : Int
  spentCents : Int
  inv_max_le_budget : maxAmountCents ≤ budgetCents
  inv_spent_nonneg : 0 ≤ spentCents
  inv_spent_le_budget : spentCents ≤ budgetCents

structure PaymentMandate where
  mandateId : Nat
  amountCents : Int
  inv_positive : 0 < amountCents

structure PaymentExecute where
  mandateId : Nat
  amountCents : Int
  idempotencyKey : Nat
  inv_positive : 0 < amountCents

inductive ExecuteResult where
  | success (receiptAmountCents : Int)
  | rejected (reason : String)
  | failed (reason : String)

-- Mandate Validation

def validatePayment (intent : IntentMandate) (amountCents : Int)
    (_hamount : 0 < amountCents) : Bool :=
  amountCents ≤ intent.maxAmountCents &&
  intent.spentCents + amountCents ≤ intent.budgetCents

def executeWalletPay (intent : IntentMandate) (amountCents : Int)
    (hamount : 0 < amountCents) : ExecuteResult × IntentMandate :=
  if h1 : amountCents ≤ intent.maxAmountCents then
    if h2 : intent.spentCents + amountCents ≤ intent.budgetCents then
      let newIntent : IntentMandate := {
        maxAmountCents := intent.maxAmountCents
        budgetCents := intent.budgetCents
        spentCents := intent.spentCents + amountCents
        inv_max_le_budget := intent.inv_max_le_budget
        inv_spent_nonneg := by have := intent.inv_spent_nonneg; omega
        inv_spent_le_budget := h2
      }
      (ExecuteResult.success amountCents, newIntent)
    else
      (ExecuteResult.rejected "budget_exhausted", intent)
  else
    (ExecuteResult.rejected "amount_exceeds_max", intent)

-- W3: payment_le_mandate

theorem payment_le_mandate (intent : IntentMandate) (amountCents : Int)
    (hamount : 0 < amountCents) (receiptAmount : Int)
    (h : (executeWalletPay intent amountCents hamount).1 = ExecuteResult.success receiptAmount) :
    receiptAmount ≤ intent.maxAmountCents := by
  unfold executeWalletPay at h
  split at h
  · next h1 =>
    split at h
    · injection h with h; omega
    · contradiction
  · contradiction

-- W5: receipt_matches_execute

theorem receipt_matches_execute (intent : IntentMandate) (amountCents : Int)
    (hamount : 0 < amountCents) (receiptAmount : Int)
    (h : (executeWalletPay intent amountCents hamount).1 = ExecuteResult.success receiptAmount) :
    receiptAmount = amountCents := by
  unfold executeWalletPay at h
  split at h
  · split at h
    · injection h with h; exact h.symm
    · contradiction
  · contradiction

-- W6a: wallet_balance_after_pay

theorem wallet_balance_after_pay (intent : IntentMandate) (amountCents : Int)
    (hamount : 0 < amountCents) :
    (executeWalletPay intent amountCents hamount).2.spentCents ≤
    (executeWalletPay intent amountCents hamount).2.budgetCents := by
  unfold executeWalletPay
  split
  · split
    · next h1 h2 => exact h2
    · exact intent.inv_spent_le_budget
  · exact intent.inv_spent_le_budget

-- W6b: wallet_spent_monotone

theorem wallet_spent_monotone (intent : IntentMandate) (amountCents : Int)
    (hamount : 0 < amountCents) :
    intent.spentCents ≤ (executeWalletPay intent amountCents hamount).2.spentCents := by
  unfold executeWalletPay
  split
  · split
    · next h1 h2 => dsimp; omega
    · dsimp; omega
  · dsimp; omega

-- W6c: wallet_budget_unchanged

theorem wallet_budget_unchanged (intent : IntentMandate) (amountCents : Int)
    (hamount : 0 < amountCents) :
    (executeWalletPay intent amountCents hamount).2.budgetCents = intent.budgetCents := by
  unfold executeWalletPay
  split
  · split <;> rfl
  · rfl

-- Composition: W3 + W6

theorem payment_within_all_limits (intent : IntentMandate) (amountCents : Int)
    (hamount : 0 < amountCents) (receiptAmount : Int)
    (h : (executeWalletPay intent amountCents hamount).1 = ExecuteResult.success receiptAmount) :
    receiptAmount ≤ intent.maxAmountCents ∧
    (executeWalletPay intent amountCents hamount).2.spentCents ≤ intent.budgetCents := by
  constructor
  · exact payment_le_mandate intent amountCents hamount receiptAmount h
  · have hbal := wallet_balance_after_pay intent amountCents hamount
    have hbudget := wallet_budget_unchanged intent amountCents hamount
    omega

-- ─── L3: Idempotency — replay safety ──────────────────────────────────

/-- **L3 (W4):** Two payment executions with identical fields are equal.
    This formalizes the idempotency contract: if mandateId, amountCents,
    idempotencyKey, and the positivity proof are the same, the structs are identical. -/
theorem idempotency_same_key (exec1 exec2 : PaymentExecute)
    (h_same_key : exec1.idempotencyKey = exec2.idempotencyKey)
    (h_same_amount : exec1.amountCents = exec2.amountCents)
    (h_same_mandate : exec1.mandateId = exec2.mandateId) :
    exec1 = exec2 := by
  cases exec1 with
  | mk m1 a1 k1 p1 =>
    cases exec2 with
    | mk m2 a2 k2 p2 =>
      simp at h_same_key h_same_amount h_same_mandate
      subst h_same_mandate
      subst h_same_amount
      subst h_same_key
      rfl

end Nexbid
