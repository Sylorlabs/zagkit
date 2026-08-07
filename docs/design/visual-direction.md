# Visual direction selection gate

- Status: Required, in progress
- Blocks: visual component production
- Does not block: architecture, headless primitives, semantics, text engines,
  test infrastructure, and benchmark harnesses

Zagkit needs its own adaptive design language before polished components are
implemented. It should feel precise, calm, fluid, and capable, with
SwiftUI-class motion and current Apple-class material coherence, without
copying a private implementation or becoming an imitation of Apple, Material,
Fluent, or a desktop widget theme.

## Decision package status

This section is now a complete comparison blueprint.

All three visual directions must be implemented as complete token-sets and full
scene captures, then compared against the same conformance matrix before one
direction can be accepted by RFC.

Deliverables:

- Three direction token manifests committed in one auditable bundle.
- One side-by-side comparison review packet using the same deterministic
  benchmark scenes and content across all directions.
- One written risk log naming readability, contrast, motion, and implementation
  risk for each direction.
- A single accepted RFC that references the comparison packet and names the
  final target.


A machine-readable comparison manifest now lives at
`docs/design/visual-direction-comparison.json` and records exact scenes,
variants, states, and decision questions.

Run:

```sh
./tools/visual-direction-matrix-report.sh
```

to print expected scope and detect missing recommendation fields.

## Required decision package

At least three materially different directions must be evaluated using the same
content and interactions. Each direction includes:

- semantic color, typography, spacing, shape, elevation, material, motion, and
  icon token proposals;
- physically coherent lighting, soft-shadow, and liquid-glass proposals with
  reduced-transparency and CPU-oracle equivalents;
- crisp font, curve, SVG, and color-managed PNG evidence at every declared
  scale factor;
- compact, medium, and expanded density behavior;
- desktop pointer and keyboard plus mobile touch examples;
- light, dark, high contrast, RTL, large text, reduced transparency, and reduced
  motion variants;
- text field, button, menu, dialog, navigation, list, table, and viewport chrome;
- interrupt, reversal, gesture handoff, focus, error, disabled, selection, and
  loading states;
- typography evidence across Latin, Arabic, Hebrew, Indic, CJK, Thai, and emoji;
- representative PrismStudio viewport, properties, table, menu, dialog, and
  command-palette states using identical content in all three directions.

## Candidate direction sets

### A — Glass Clarity

- Token manifest: `docs/design/visual-direction-tokens/direction-a-glass-clarity.json`

- Focus language: depth-first, translucent surfaces, restrained color, soft motion.
- Spacing model: clear two-token cadence (`inline-x`, `inline-y`) with compact
  and expanded multipliers.
- Typography: high legibility stack with large letter clarity under large-text.
- Motion: kinetic continuity, snap for reduced-motion, and restrained parallax.
- Glass: blur + tint + vignette with explicit contrast floor and glare caps.
- Intended strengths: premium feel, smooth transitions, strong depth cues.
- Implementation risk: highest overdraw and sampling complexity in dense scenes.

### B — Precision Fabric

- Token manifest: `docs/design/visual-direction-tokens/direction-b-precision-fabric.json`

- Focus language: matte surfaces, sharp edge hierarchy, strict typographic rhythm,
  measurable density.
- Spacing model: linear micro-rhythm with explicit rhythm tokens for every
  structural level.
- Typography: high contrast with strict cap heights and fixed rhythm across locales.
- Motion: minimal but explicit easing and spring continuity.
- Glass: restrained; glass reserved for chrome-only overlays.
- Intended strengths: high readability, predictable geometry, easy conformance.
- Implementation risk: can feel sterile without strong material compensation.

### C — Vector Utility

- Token manifest: `docs/design/visual-direction-tokens/direction-c-vector-utility.json`

- Focus language: token-first industrial palette, dense data surfaces, clear control
  states.
- Spacing model: algorithmic density bands with strong table/list focus behavior.
- Typography: neutral and dense with explicit locale-specific stack fallbacks.
- Motion: direct gesture continuity and short transitions, no flourish.
- Glass: very limited use in command bars and transient overlays.
- Intended strengths: strongest information density and keyboard workflow clarity.
- Implementation risk: reduced “premium” affordance and more difficult glass
  parity across all views.

## Acceptance evidence matrix

Each direction must be captured identically across the same scene set and variant
axes. All captures must be deterministic and comparable by checksum.

- Scenes: all component families in the initial inventory and representative
  PrismStudio flows.
- Variants: scale (`1.0`, `1.25`, `1.5`, `2.0`, `3.0`), theme (light/dark),
  contrast (`normal`, `high`), direction (`ltr`, `rtl`), large-text,
  reduced-transparency, reduced-motion, and locale set from seven scripts.
- Inputs: pointer, keyboard, gamepad focus, touch where applicable, and
  interrupted animation handoff.
- Proof fields: text legibility, focus visibility, contrast floor, selection
  state readability, error clarity, disabled-state certainty, and viewport
  density stability.
- Output bundle: comparison packet with one row per direction per scene per variant
  and a single final recommendation memo in
  [docs/design/visual-direction-comparison-matrix.md](./visual-direction-comparison-matrix.md).

## Selection criteria

The chosen direction must preserve information hierarchy at large text, meet
contrast and target size requirements, expose unmistakable focus, avoid motion
as the only carrier of meaning, remain coherent from CAD density to touch
density, and stay implementable through semantic tokens rather than per-screen
exceptions.

## Acceptance

Maintainer and accessibility review accept one direction through an RFC. The
review names known risks and required conformance scenes. Until then,
[the component inventory](../../contracts/components.json) remains `planned` and
no screenshot can promote a component.

Selection is exactly three directions. After selection, visual production must
match the accepted target; style is not improvised independently per component
or PrismStudio screen.
