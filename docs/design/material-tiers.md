# Material tier contract (experimental, pre-RFC-0007)

- Status: experimental draft, evolves candidate direction A
- Token manifest: `visual-direction-tokens/direction-a2-glass-clarity.json`
- Blocks nothing; RFC 0007 remains the acceptance authority

Zagkit's glass language is only sustainable if translucency is architecturally
bounded. This contract makes depth a semantic statement instead of a decorative
knob: **a surface may only be translucent when it genuinely floats over live
content.**

## The three tiers

| Tier | Meaning | Translucency | Area budget | Examples |
|---|---|---|---|---|
| `solid` | Content-bearing surfaces | none | unbounded | canvas, panels, cards, insets, tables |
| `veil` | Persistent chrome floating over app content | blur 20dp, tint 0.18 | combined veil area ≤ 25% of viewport | header bar, navigation rail, command palette, toasts |
| `glass` | Transient overlays | blur 36dp, tint 0.22 | one live glass layer per interaction | menus, popovers, dialog scrims |

Rules that follow from the tiers:

- A `solid` surface never records a blur radius. A recorded blur radius on a
  `veil` or `glass` material is not a claim that backdrop blur executed; the
  deterministic CPU fallback reason stays honest, exactly as the existing
  material contract requires.
- Reduced transparency is a tier demotion, not a per-screen special case:
  `veil → color.surface.panel` opaque, `glass → color.surface.raised` opaque,
  each with a recorded fallback reason.
- Compact density demotes `veil` to `solid` and reduces every radius token by
  one step. Dense professional layouts (CAD, tables) therefore never pay
  glass sampling cost, which retires direction A's named overdraw risk.

## One scene light

Every window has exactly one key light (azimuth 40°, zenith 60°). All depth
cues derive from it; no component invents its own lighting:

- **Edge lighting replaces borders on elevated surfaces.** An elevated surface
  receives a 1dp `color.edge.highlight` hairline on its top edge and a shadow
  falloff below. Stroked `color.border.subtle` outlines are reserved for flat
  and inset elements (inputs, wells, separators).
- **Two-layer analytic shadows.** Every elevated surface casts a pair:
  - a tight *contact* layer (small offset, small spread, higher alpha) that
    seats the surface, and
  - a soft *ambient* layer (larger offset, wide spread, lower alpha) that
    communicates height.
  Both are analytic rounded rectangles with alpha falloff, so the CPU oracle
  rasterizes them exactly; no gaussian pass is required for correctness.
- Elevation transitions animate the shadow pair, never the fill.

## Luminance ladder

Structural depth is encoded as ordered relative luminance so hierarchy
survives high contrast and reduced transparency:

```
dark:  inset < canvas < base < panel < raised   (~+1.5% L per step)
light: raised > panel > base > canvas > inset
```

Chroma is reserved for meaning: accent, focus, status, and chart series own
all saturated color. Structural surfaces stay near-neutral with only a
cool-to-warm ambient drift (recessed cool, raised warm) using the existing
`color.ambient.cool` / `color.ambient.warm` roles.

## Motion

Springs only, three temperaments (`motion.snappy`, `motion.gentle`,
`motion.expressive` in `src/design/tokens.zag`). Material-specific rules:

- Glass **condenses** in: blur radius and tint animate together on entrance.
  Opacity-only fades are the reduced-motion substitution.
- Press drops elevation to `base` with the snappy spring; release restores it
  with the gentle spring, preserving velocity through interruption.

## Mapping to executable tokens

`src/design/tokens.zag` currently exposes `SemanticMaterialToken`
{`showcase_backdrop`, `shell`, `panel`, `raised`, `overlay`}. Tier assignment:

| Material token | Tier |
|---|---|
| `material.showcase.backdrop` | solid |
| `material.glass.shell` | veil |
| `material.glass.panel` | solid |
| `material.glass.raised` | solid |
| `material.glass.overlay` | glass |

The two-layer shadow is executable through `ResolvedElevationToken`'s
contact/ambient fields; the edge highlight is executable through the existing
`color.edge.highlight` role at per-elevation alpha.

## Non-claims

This document does not select the 1.0 visual direction, does not claim
backdrop blur executes anywhere, and does not modify the comparison matrix
required by `visual-direction.md`. It exists so the showcase evidence for
direction A reflects a disciplined glass system rather than an unbounded one.
