# Scroll and virtual-list contract

Status: experimental headless primitive

The current scroll and virtual-list slice supplies deterministic geometry and
bounded retained work without a window system. It is intended to support later
List, Table, Tree, Talkback, and PrismStudio collection work. It does not claim
native wheel, touch, accessibility, or 120 Hz performance certification.

## Scroll truth

`ScrollState` owns viewport and content sizes, logical offsets, and a revision.
Mutations report old and new offsets, consumed and unconsumed deltas, whether a
revision changed, and deterministic identity. Unconsumed deltas are explicit so
nested scrolling and gesture arbitration can hand pressure to an ancestor
without guessing.

Offsets clamp to the exact content boundary. Repeated pressure at a boundary
does not create a phantom revision. Reveal supports nearest, start, center, and
end alignment. Reconciliation can preserve an explicit content point at its
viewport position while content or viewport sizes change. Logical horizontal
start maps to the opposite physical content edge in RTL.

## Million-row model

`VirtualListModel` represents as many as one billion stable IDs with a uniform
default extent and up to 4,096 sorted sparse extent overrides. It does not
allocate one record per item. Binary range selection finds the visible range;
only visible plus requested overscan placements are owned by the result.

Each layout reports:

- the full semantic item count;
- first and last visible and live indices;
- viewport-local frames and stable IDs;
- content extent, clamped scroll offset, and maximum scroll;
- the number of examined records;
- deterministic input/output identity.

`max_live_items` is a hard allocation ceiling. A viewport that would exceed it
fails with `live_limit_exceeded` before placement allocation. Invalid sparse
ordering, malformed extents, unsafe scrolling, and content extent overflow also
fail with typed reasons. A viewport containing only collection padding reports
no phantom visible item.

## Variable extents and anchors

Sparse overrides carry their own revision. `VirtualAnchor` couples stable ID,
index, and viewport offset. When an extent above the viewport changes,
`virtual_resolve_anchor` computes the new scroll offset that keeps the anchored
item visually stationary. Missing or replaced IDs fail instead of silently
anchoring a different row.

Horizontal lists retain logical order and mirror placement in RTL. Padding
remains physical. Vertical collection direction does not reorder semantic IDs.

## Ownership and evidence boundary

Call `virtual_free` once for every layout result, including failures. The model
borrows its sparse override list; its creator owns that list. Replay mixes
scroll and virtual-list identity with Flex, Grid, and Overlay identity.

The executable suite proves a one-million-row mid-list query with nine live
placements and fewer than 64 examined records, sparse variable extents, anchor
stability, RTL horizontal placement, exact empty and padding-only ranges,
bounded allocation failure, malformed input, overflow rejection, and a
multi-position property sweep. Stopwatch timing in CI is not a 120 Hz claim.
Table and Tree projection, focus retention across eviction, recycling lifecycle,
native input, semantic adapters, and reference-hardware performance remain open.
