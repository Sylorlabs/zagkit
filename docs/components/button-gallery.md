# Experimental Button conformance gallery

The Button gallery is an executable component contract, not a proposed 1.0
theme. RFC 0007 remains open, so the scene labels itself `EXPERIMENTAL` in both
visible text and semantics. Its purpose is to prove that the current Button can
carry coherent rules before visual-direction selection.

## What the scene proves

The first matrix repeats the same secondary `Button` and the same `Run build`
label across rest, hover, focus, pressed, selected, disabled, loading, and error
states. The second matrix holds state at rest and varies primary, secondary,
quiet, and destructive roles. Every example calls `button_emit`; there are no
hand-painted Button lookalikes.

All twelve controls contribute to one `DisplayList`, one `HitTree`, and one
`SemanticsTree`. Their caller-owned labels are actual OpenType outlines routed
through Zagkit's nominal glyph run, canonical glyph path, retained path
resource, and deterministic CPU rasterizer. Loading deliberately substitutes
the component progress indicator, so eleven visible Button labels plus every
heading and state caption become glyph-path resources. Placeholder bars are
not accepted as gallery text.

The composition demonstrates the named type ramp and three semantic elevation
tiers. Button material comes exclusively from semantic color, radius, spacing,
and elevation tokens. State is never color-only: focus has a ring, pressed
changes elevation, selected is exposed in semantics, and disabled/loading make
actions unavailable. Headings establish hierarchy; the state and variant
sections are not competing navigation patterns.

## Stable Talkback IDs

These mappings are public experimental fixtures and must remain stable while
the gallery contract is used for regression testing:

| Fixture | `NodeKey.value` |
|---|---:|
| State: rest through error | `4100` through `4107` |
| Variant: primary | `4200` |
| Variant: secondary | `4201` |
| Variant: quiet | `4202` |
| Variant: destructive | `4203` |
| Gallery title | `4300` |
| State section heading | `4301` |
| Variant section heading | `4302` |
| Experimental status | `4303` |

Talkback click and query operations target these semantic IDs. Disabled and
loading clicks fail closed as `action_unavailable`; the contract explicitly
checks that it does not depend on pixel fallback.

## Run the evidence

```sh
./tools/test-button-gallery.sh
./tools/render-button-gallery.sh
```

Both scripts resolve Noto Sans through Fontconfig by default or accept an
explicit `.ttf` path as their first argument. The renderer accepts an optional
PNG path as its second argument. Compilation uses strict analysis with the
canonical Zag compiler and the renderer prints retained-evidence and CPU-pixel
hashes.

## Honest limits

This is a deterministic headless CPU artifact. It does not certify native
hover delivery, keyboard focus traversal, platform accessibility adapters,
GPU parity, animation, reduced motion, or the final visual direction. Text is
currently nominal left-to-right OpenType placement; full shaping, bidi, font
fallback, variable/color fonts, and line layout remain separate roadmap gates.
