# Experimental intrinsic measurement contract

Zagkit measurement is retained, deterministic, and independent of a window
system or rendering backend. The current contract operates in signed 26.6
logical units and gives layout caches an inspectable identity for both inputs
and outputs. It advances `G2-CONSTRAINTS`; it does not complete that checklist
item by itself.

## Retained tree

`IntrinsicTree` owns stable `IntrinsicNode` records and parent-child edges.
Leaf nodes declare minimum, preferred, and maximum width and height, a baseline,
and a content revision. Container nodes aggregate those declarations as a row,
column, or overlay with explicit gap and physical padding.

Rows sum widths, take the largest height, and reserve the largest ascent plus
largest descent. Columns take the largest width and sum heights. Overlays take
the largest extent on both axes. Rows and columns include gaps only between
children. Every form composes padding after child aggregation.

A valid retained measurement tree has:

- one positive stable ID per node;
- exactly one owner for every non-root node;
- no orphan, missing, duplicate, or leaf-owned edges;
- monotonic minimum, preferred, and maximum ranges;
- a baseline inside preferred height;
- bounded gap, padding, revision, and fixed-point geometry;
- no ownership cycle.

The current executable bound is 4,096 nodes, 16,384 ownership edges, and 512
retained levels per measured tree. Inputs beyond those limits fail before
unbounded allocation or native call-stack growth.

Malformed trees fail before returning usable size. `MeasureResult` retains the
exact error node and edge where applicable, the count of nodes reached before
failure, and no partial success claim.

## Constraint resolution

The intrinsic preferred size is resolved independently on each axis against
normalized `Constraints`. `MeasureRule` records whether intrinsic preference,
the minimum constraint, or the maximum constraint selected the final extent.
If the authoritative constraint is smaller than intrinsic minimum, width and
height overflow remain separate and explicit. Baselines clamp to the resolved
height instead of escaping the result bounds.

Measurement identity includes the full retained tree, node revisions,
ownership edges, intrinsic result, normalized constraints, resolved size,
baseline, overflow, rules, and visited-node count. A constraint or hidden
overlay-child change therefore cannot masquerade as a cache hit merely because
the final rectangle happens to stay the same.

## Stability and revisions

`IntrinsicStability` retains the input hash observed for each stable node and
content revision. A node that returns different intrinsic inputs without
advancing its revision fails as `unstable_measurement`. A changed input is
accepted only after an explicit newer revision. Regressing a revision also
fails. This turns intrinsic instability into inspectable evidence rather than
layout jitter.

Call `intrinsic_stability_free` and `intrinsic_tree_free` for every owned
instance.

## Flex priorities

`flex_item_intrinsic` converts intrinsic metrics into a Flex item while
retaining main-axis minimum, preferred, and maximum bounds plus preferred cross
extent and baseline truth.
`FlexPriority` maps to explicit grow and shrink resistance:

| Priority | Grow weight | Shrink weight |
|---|---:|---:|
| `lowest` | 0 | 8 |
| `low` | 1 | 4 |
| `normal` | 2 | 2 |
| `high` | 4 | 1 |
| `required` | 0 | 0 |

Required content neither grows nor yields under pressure. Lower-priority
content yields more of a deficit than higher-priority content. Intrinsic bounds
remain authoritative during distribution, and unresolved pressure is reported
as Flex overflow.

## Exact invalidation reasons

The separate `invalidation.zag` module keeps authoring-state dependencies out
of low-level intrinsic and Flex code. Its `LayoutTrace` copies actual
`ViewContext` state reads into retained layout dependencies. Every record names
the reader `NodeKey`, retained ancestor,
state ID and read revision, affected phase, and rule. Current phases are
measure, layout, paint, and semantics. Current rules cover intrinsic content,
constraints, child measurement, Flex priority, gap, padding, direction, safe
area, density, text scale, and breakpoint selection.

One `StateChange` produces every matching `LayoutInvalidationCause`, including
the exact old and new revision edge. Unread state produces no cause. Repeated
identical reads collapse without losing phase or rule truth.

## Current boundary

The following remain before `G2-CONSTRAINTS` can complete:

- retained `RenderNode` lifecycle and cancellation integration;
- incremental subtree cache replacement and cleanup under reconciliation;
- component and text measurement producers;
- cross-axis intrinsic bounds in Flex item distribution;
- exact non-state environment and platform-input revision dependencies;
- serialized measurement and invalidation evidence;
- property and fuzz coverage across the complete component layout matrix.

Table and Tree projection, recycled retained-node lifecycle, and platform-driven
adaptive conformance remain separate Flex and virtualization work. Grid,
Overlay, Scroll, and Virtual List now have experimental placement contracts;
their existence does not complete the full component layout matrix.
