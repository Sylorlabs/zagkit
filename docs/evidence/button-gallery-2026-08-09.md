# Experimental Button gallery checkpoint — 2026-08-09

This checkpoint records executable component-system evidence, not acceptance
of RFC 0007 and not a conformant or production-ready Button claim.

## Result

- Focused strict contract: `Button gallery contract: pass=22 fail=0`.
- The focused contract passed twice with retained evidence hash
  `-2919151821371210844` and deterministic CPU surface hash `1920018921`.
- The renderer produced `artifacts/evidence/button-gallery-experimental.png`,
  a 1280 by 900 RGBA PNG with SHA-256
  `72ad2dec7484c34ec252aa64ad835fe966b5859c29c9fa43dbf7b9aca61032f2`.
- The gallery contract is part of `tools/test-headless.sh` and resolves an
  explicit system font through Fontconfig rather than drawing placeholder text.

## System proof

The scene builds twelve controls through the public retained Button: the same
secondary variant in rest, hover, focus, pressed, selected, disabled, loading,
and error states, followed by primary, secondary, quiet, and destructive role
variants. Named Flex metrics drive repeated visual placement and the matching
semantic heading bounds. Semantic color, radius, typography, and elevation
tokens remain inspectable; the scene shows base, panel, and raised depth tiers.

All visible labels are owned OpenType outline paths rendered by the CPU oracle.
The same stable `NodeKey` owns each Button's display operations, hit target,
semantics, focus order, and Talkback target. IDs `4100` through `4107` name the
state fixtures and `4200` through `4203` name the variants. Disabled and loading
clicks fail as `action_unavailable`; the gallery's Talkback proof keeps pixel
fallback disabled.

Visual inspection of the final PNG confirmed the exterior focus ring, dropped
pressed elevation, selected treatment, recessed disabled control, loading
progress mark, explicit error label and outline, variant separation, type
hierarchy, and section hierarchy. This answers the state-matrix, token,
elevation, typography, and ambiguous-control concerns in the showcase review.

## Honest limits

The artifact is a deterministic headless CPU scene. It does not prove native
hover or keyboard delivery, animation, reduced motion, native accessibility,
GPU parity, international shaping, final contrast matrices, or a selected
liquid-glass direction. Button therefore remains `implementing`, and
`G4-GALLERY`, `G5-SHOWCASE-CONFORMANCE`, and `G5-LINUX-POLISH` remain open.
