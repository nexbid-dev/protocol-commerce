-- ─── Decision Score Monotonicity — Formal Verification ───────────────
-- Mirrors: the monotonicity property test in
-- packages/decision-auction/src/engine.test.ts.
-- Raising a candidate's goal_fit (all else equal) strictly raises its score,
-- provided goalFitWeight > 0. Generalises Monotone.lean's T7 to the decision case.

import NexbidVerify.Types
import NexbidVerify.Decision.Types
import NexbidVerify.Decision.Score

namespace Nexbid.Decision

/-- **goalFit_monotone:** higher goal_fit ⟹ strictly higher decision score
    (ceteris paribus), when goalFitWeight > 0. The core "more aligned with the
    stated goal always scores at least as well" property. -/
theorem goalFit_monotone
    (c1 c2 : Candidate) (w : DecisionWeights)
    (h_gt : c1.goalFit.val > c2.goalFit.val)
    (h_safety : c1.safety.val = c2.safety.val)
    (h_quality : c1.quality.val = c2.quality.val)
    (h_w : 0 < w.goalFitWeight) :
    computeDecisionScore c1 w > computeDecisionScore c2 w := by
  unfold computeDecisionScore
  rw [h_safety, h_quality]
  have h : w.goalFitWeight * c1.goalFit.val > w.goalFitWeight * c2.goalFit.val :=
    Rat.mul_lt_mul_of_pos_left h_gt h_w
  have h1 : w.goalFitWeight * c1.goalFit.val + w.safetyWeight * c2.safety.val >
             w.goalFitWeight * c2.goalFit.val + w.safetyWeight * c2.safety.val :=
    Rat.add_lt_add_right.mpr h
  exact Rat.add_lt_add_right.mpr h1

end Nexbid.Decision
