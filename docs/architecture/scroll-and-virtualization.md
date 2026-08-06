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

## Table projection

Virtual Table composes the million-row model with up to 256 stable columns.
Logical-leading pinned columns remain resident while the remaining columns
scroll and overscan independently. Header and body cells carry a collision-free
composite identity of table, row, column, and header state; a single lossy hash
is never presented as the authoritative cell ID.

Table results expose semantic row and column counts, visible and live row
ranges, visible scrolling columns, pinned count, both scroll maxima, and every
live cell frame. `max_live_cells` fails before allocation. Column resize retains
minimum and maximum bounds, reports consumed and unconsumed delta, and advances
both column and model revisions only when width changes. Pinned columns must be
one contiguous logical-leading region and mirror physically under RTL.

## Tree projection

Tree input is canonical preorder with stable ID, explicit parent ID, depth,
child capability, expansion state, extent, and revision. Projection validates
duplicate IDs, depth jumps, parent ownership, and leaf ownership before hiding
collapsed descendants. The visible projection retains source index and parent
identity, then uses the same bounded virtual range engine as List.

Indentation applies to the content frame at logical start while the complete
row frame remains available for selection and hit testing. RTL moves indentation
to the right without changing semantic order. An open-addressed stable-ID index
keeps duplicate validation linear; the current retained projection remains
capped at 16,384 source nodes as an explicit allocation bound.

## Focus and recycling lifecycle

`VirtualRetainedStore` separates logical IDs from recyclable retained instances.
Evicted nonfocused entries may be rebound with an incremented generation;
logical identity never inherits the previous item's generation. A focused
offscreen entry is pinned against recycling. When it returns, the exact instance
and generation are restored. Clearing focus makes it recyclable again.

Residency has an explicit capacity. Live IDs plus an offscreen focus pin must
fit or reconciliation fails before mutation. Duplicate IDs and unknown focus
requests also fail. Identical live membership performs no revision, timestamp,
or identity churn.

## Ownership and evidence boundary

Call `virtual_free` once for every layout result, including failures. The model
borrows its sparse override list; its creator owns that list. Replay mixes
scroll and virtual-list identity with Flex, Grid, and Overlay identity.

The executable suites prove a one-million-row mid-list query with nine live
placements and fewer than 64 examined records, a million-row two-axis Table,
collapsed and expanded Tree projections, sparse variable extents, anchor and
offscreen-focus stability, RTL placement, exact empty and padding-only ranges,
bounded allocation failures, malformed input, overflow rejection, and scroll,
expansion, and 100-window recycling sweeps. Replay incorporates List, Table,
Tree, scroll, and lifecycle identities. Stopwatch timing in CI is not a 120 Hz
claim. Native input, semantic adapters, editable cells, sorting, selection,
drag reordering, general Tree indexing, and reference-hardware performance
remain open.
