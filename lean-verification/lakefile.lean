import Lake
open Lake DSL

package «nexbid-verify» where
  leanOptions := #[
    ⟨`autoImplicit, false⟩
  ]

@[default_target]
lean_lib NexbidVerify where
  srcDir := "."
