# Native visual system v2

- Status: implementation in progress
- Implementation: `src/design/visual_system.zag`
- Conformance: `tests/visual_system_contract.zag`
- Runtime language: native Zag v2

This document is the executable visual contract for Zagkit's production design
language. It evolves Glass Clarity A2 into a bounded system rather than an
unrestricted collection of effects.

## Non-negotiable principles

1. **Content is solid.** Tables, editors, forms, cards, panels, charts, canvases,
   and document surfaces are opaque semantic materials.
2. **Veil is floating chrome.** Persistent navigation and command chrome may use
   a restrained backdrop veil when density, accessibility preferences, and the
   effect budget allow it.
3. **Glass is transient.** Menus, popovers, command palettes, and modal overlays
   may use one live glass layer per interaction. Nested glass is invalid.
4. **Depth is truth.** Elevation communicates actual stacking. Decoration never
   invents elevation.
5. **One physical light.** Every edge highlight and shadow derives from the same
   window scene light. RTL changes logical layout, not physical lighting.
6. **Meaning owns chroma.** Saturated color is reserved for action, focus,
   selection, status, and data series.
7. **Fallbacks stay honest.** The CPU oracle records exactly which deterministic
   opaque/tint fallback rendered. A blur token is not evidence that blur ran.
8. **No hidden work.** Material resolution is allocation-free and bounded before
   any renderer receives work.

## Semantic roles

| Role | Normal material | Compact density | Reduced transparency |
|---|---|---|---|
| Content | solid | solid | solid |
| Floating chrome | veil | solid | solid |
| Transient overlay | glass | glass | solid |

Elevation is independent of material. A solid card can be raised, and a veil
can remain low-elevation chrome. This prevents ordinary application content from
becoming translucent merely because it is visually elevated.

## Lighting and shadow model

The scene light is fixed at 40 degrees azimuth and 60 degrees zenith. Every
non-base elevation resolves to two analytic shadow layers:

- a tight contact layer that seats the surface;
- a broad ambient layer that communicates height;
- one top/leading edge highlight derived from the same light.

The resolved shadow extent is explicit so damage, clipping, temporary surfaces,
and GPU capture regions can be bounded before rendering.

## Effect budget

A valid frame obeys both limits:

- combined veil area is no more than 25% of viewport area;
- no more than one live glass layer exists for an interaction.

The policy rejects invalid budgets before pixels are changed. Dense professional
screens therefore remain crisp and predictable instead of accumulating blur,
overdraw, and large intermediate textures.

## Blur plans

| Material | Downsample | Passes | Nominal radius |
|---|---:|---:|---:|
| solid | 1x | 0 | 0dp |
| veil | 2x | 3 | 20dp |
| glass | 4x | 4 | 36dp |

These are bounded render-IR plans, not permission for a component to invoke a
backend effect directly. The deterministic CPU oracle uses the documented
fallback; accelerated backends may execute backdrop blur only when the capability
record says it is available.

## Performance contract

The policy kernel performs no allocation, IO, platform call, runtime lookup, or
hidden caching. Equal inputs produce the same evidence hash. Renderers must:

- cache unchanged backdrop captures;
- restrict captures and damage to the resolved inflated bounds;
- flatten overlapping material captures rather than recursively blur them;
- request no frames when material and motion tracks are settled;
- preserve CPU-oracle semantics and remain within declared pixel tolerance;
- expose fallback, downsample, pass count, shadow extent, and budget use through
  the inspector.

## Verification

Run:

```sh
bash tools/test-visual-system.sh
```

The contract verifies semantic material selection, compact and accessibility
demotion, truthful CPU fallback, accelerated blur plans, the global scene light,
monotonic shadow extent, veil-area limits, nested-glass rejection, and
deterministic evidence.
