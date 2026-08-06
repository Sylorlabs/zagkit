# Experimental Flex placement contract

Flex is Zagkit's public placement and spacing foundation. It works entirely in
signed 26.6 logical units and preserves stable item IDs in logical order. The
current implementation covers single-line rows and columns plus deterministic
multi-line wrapping; it is not yet the complete `G2-FLEX` contract.

## Primitive spacing scale

`FlexSpacingToken` resolves to this standard-density scale:

| Token | Logical pixels |
|---|---:|
| `none` | 0 |
| `micro` | 2 |
| `tiny` | 4 |
| `small` | 8 |
| `medium` | 12 |
| `large` | 16 |
| `xlarge` | 24 |
| `xxlarge` | 32 |

Compact density resolves each primitive to three quarters of its standard
value. Touch density resolves to five quarters. All results remain exact 26.6
values. Text scale does not silently multiply gaps; it affects adaptive
composition through breakpoint selection.

These are experimental layout primitives, not accepted component styling. The
three-direction visual review will decide which semantic component tokens map
to the scale before visual component production begins.

## Safe areas and breakpoints

`FlexAdaptiveContext` carries viewport size, physical safe-area insets,
density, text scale, and layout direction. Safe areas are normalized before
arithmetic and can be added to tokenized padding. They remain physical: left
and right do not swap under RTL.

Breakpoints use safe content width divided by effective text scale:

- compact below 600 logical pixels;
- medium from 600 through 1,023 logical pixels;
- expanded from 1,024 logical pixels.

Text scale is bounded from 1x through 4x for breakpoint calculation. Larger
text therefore selects a roomier composition without distorting the primitive
spacing scale.

## Wrapping

`FlexWrapStyle` adds line gap, line alignment, and a wrapping switch to a
normal `FlexStyle`. Row and column wrapping use the constrained inner main
extent after padding. Items remain in logical insertion order and retain stable
IDs across line changes.

Each line independently runs the same grow, shrink, main alignment, cross
alignment, and baseline rules as single-line Flex. Baseline lines reserve the
largest ascent plus largest descent, avoiding clipping when equal-height items
have different baselines.

Line alignment supports start, center, end, space-between, space-around,
space-evenly, and stretch. RTL rows place logical starts at the physical right.
RTL columns also advance line bands from right to left while preserving item
order and physical safe-area edges.

`FlexWrapResult` owns placements and line ranges. It reports main and cross
overflow separately, duplicate IDs, whether wrapping occurred, and a
deterministic layout hash over line and placement truth.

## Failure and ownership

Single-line and wrapped layout reject malformed IDs or geometry, unsafe style
extents, and arithmetic that would exceed Zagkit's bounded logical extent.
Single-line failures return `FlexError`; wrapping additionally rejects more than
one million input items and returns `FlexWrapError`. Both identify the exact
item when applicable and return empty placement ownership. Wrapped failures
also retain a deterministic failure identity. No partial placement is reported
as success.

Grow and shrink weights are nonnegative and bounded to 4,096 so weighted
distribution cannot overflow the fixed-point extent contract.

Call `flex_wrap_free` for every result, including failures. It releases both
the placement and line arrays.

## Current boundary

The following remain required before either Flex checklist item can complete:

- intrinsic measurement and priorities;
- grid and overlay placement;
- safe-area and density matrices driven by real platform shells;
- exact state-read and rule reasons for every layout invalidation;
- layout-transition orchestration;
- full RTL, large-text, and adaptive component conformance;
- visual-direction acceptance and screenshot goldens.
