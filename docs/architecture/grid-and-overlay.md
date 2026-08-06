# Grid and Overlay placement contract

Status: experimental headless primitive

Grid and Overlay are deterministic retained-placement primitives in Zagkit's
Flex layout system. They operate in signed 26.6 fixed-point logical units and
own their output arrays. They do not select a visual direction, create native
widgets, or imply that the higher-level Grid component is conformant.

## Grid

`GridTrack` has three explicit sizing modes:

- fixed tracks never grow or shrink;
- intrinsic tracks start at their preferred extent and remain between their
  declared minimum and maximum;
- fraction tracks start at their minimum and share remaining space by integer
  weight, assigning division remainder deterministically.

Spanning item minimum and preferred sizes pressure every eligible track in the
span before the container is resolved. Under a finite constraint, fraction
tracks grow first, `stretch` may grow remaining non-fixed tracks, and
non-fixed tracks shrink toward declared minima. Anything still outside the
container is reported by axis; fixed sizes are never silently falsified.

Items use stable positive IDs. A pair of `-1` coordinates requests row-major
auto placement; partial automatic coordinates are invalid. Explicit overlap is
fail-closed unless `allow_overlap` is set, and the result then reports the
number of collided cells. Row and column spans, placement alignment, one-row
baseline alignment, z-order, content distribution, padding, gaps, intrinsic
container sizing, and logical RTL columns are part of the layout hash.

## Overlay

Overlay derives an unconstrained container from the largest child preferred
extent plus child insets and outer padding. Under finite constraints, each
child resolves independently with logical start, center, end, or stretch
alignment. Logical horizontal start and end mirror in RTL. Stable ID, z-order,
baseline output, per-axis minimum-size overflow, and input/output layout hashes
remain observable.

Overlay rejects duplicate IDs, malformed intrinsic ranges, unsafe extents,
unsupported baseline placement requests, invalid constraints, and arithmetic
overflow before returning partial geometry.

## Ownership, replay, and proof

Call `grid_free` or `overlay_free` exactly once for every result, including
typed error results. Deterministic replay mixes Flex wrap, Grid, and Overlay
layout identities into the scene identity, so a placement change cannot hide
behind identical state or pixels.

The focused executable contracts cover fixed, intrinsic, and fraction tracks;
spans; auto placement; collisions; opt-in overlap; baseline; z-order; RTL;
unbounded intrinsic sizing; quantified overflow; malformed input; deterministic
identity; 122 grid widths; and 253 overlay sizes. These tests are headless
correctness evidence. They are not screenshot, native accessibility, native
window, performance, or platform certification.
