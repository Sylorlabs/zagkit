# Visual direction selection gate

- Status: Required, not started
- Blocks: visual component production
- Does not block: architecture, headless primitives, semantics, text engines,
  test infrastructure, and benchmark harnesses

Zagkit needs its own adaptive design language before polished components are
implemented. It should feel precise, calm, fluid, and capable, with
SwiftUI-class motion and current Apple-class material coherence, without
copying a private implementation or becoming an imitation of Apple, Material,
Fluent, or a desktop widget theme.

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
