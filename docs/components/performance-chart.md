# Experimental performance chart

`PerformanceChart` is one bounded line/scatter component for frame-performance
evidence. It proves chart anatomy, semantic equivalence, token routing, focus
state, and stable-ID automation. It is not a general chart suite and is not a
production visual-polish claim.

## Scope and input contract

The component accepts one `PerformanceChartSpec` with:

- a positive stable chart `NodeKey` and bounds of at least 640 by 420 logical
  pixels;
- a title and description;
- independently named x and y axes with explicit units;
- bounded integer domains, two to twelve ticks per axis, and one caller-owned
  label for every tick;
- named baseline and deadline values inside the y domain; and
- one to eight named series, each containing two to sixty-four aligned,
  strictly increasing samples.

Every sample carries its numeric x/y coordinates and its already-formatted
accessible x/y strings. Series in one chart must have the same sample count and
the same x coordinate at each row. This makes the semantic data table exact
instead of asking assistive technology to reverse-engineer pixels.

Names, descriptions, units, tick labels, and cell strings must be valid,
NUL-free UTF-8 within the component bounds. Series IDs must be positive and
unique. Coordinates are bounded to plus or minus one million before fixed-point
mapping, preventing unchecked multiplication. Duplicate IDs, malformed text,
misaligned samples, out-of-range references, excessive series, and malformed
state fail before display, hit, or semantic mutation.

## Visual anatomy

The retained Canvas emits:

- raised panel, border, shadow, and recessed plot surfaces;
- independently inspectable grid and axis paints;
- ticks on both axes;
- a named baseline reference and a distinct semantic-error deadline reference;
- one filled line ribbon plus one anti-aliased rounded scatter mark per sample;
- named series swatches arranged with Flex; and
- separate selected, focused, available, and disabled legend treatments.

All colors route through semantic roles such as `color.chart.grid`,
`color.chart.axis`, `color.chart.series.primary`, `color.focus`, and
`color.status.error`. Panel depth routes through the raised elevation and panel
radius tokens. Repeated padding, legend gaps, and label spacing resolve through
named Flex spacing tokens.

The implementation uses the public Canvas resource path for each line. A line
is an immutable bounded path of filled segment ribbons because the current CPU
oracle implements path fills but not path strokes. Scatter marks and all other
chrome use retained display-list primitives. The complete Canvas seals and
verifies before its semantic and hit contributions become available.

## Required typography composition

The current shared component architecture does not let Canvas fabricate text.
Like Button, the chart returns caller-owned content placement rather than
drawing placeholder bars. `PerformanceChartArtifact.text_slots` owns the exact
UTF-8 text plus bounds and semantic token provenance for every required label:

- title;
- x-axis name and unit;
- y-axis name and unit;
- every x tick and every y tick;
- every legend series name;
- baseline label; and
- deadline label.

Each slot carries a stable semantic `NodeKey`, `SemanticTypeToken`, and
`SemanticColorToken`. The host must compose a real Zagkit Text child into every
slot. A showcase, screenshot, or native surface is incomplete if any slot is
not rendered. Semantics do not excuse missing visible chart labels.

The focused component test validates slot completeness, stable IDs, positive
bounds, type roles, and color roles. It intentionally rasterizes only the
Canvas-owned chart geometry. Therefore its CPU surface hash is renderer evidence
for the chart chrome, line, scatter, grid, references, legend materials, and
focus ring—not evidence that a native integration rendered the Text children.
The component remains experimental until a Text-composed showcase and native
accessibility execution cover this boundary.

## Hosted composition

`performance_chart_contribute_hosted` atomically contributes an already-built
`PerformanceChartArtifact` into caller-owned `DisplayList`, `SemanticsTree`, and
`HitTree` destinations. `PerformanceChartHostSpec` requires three explicit
values:

- `semantic_parent`, which must be the semantic root or an ID already present in
  the destination semantic tree;
- `hit_parent`, which must be the hit root or an ID already present in the
  destination hit tree; and
- `focus_order_offset`, a non-negative integer whose shifted chart focus orders
  must be no greater than one million and must not collide with any destination
  focus order.

The chart's Canvas group is the only semantic and hit node reparented. Title,
axis, tick, reference, legend, series, row, cell, and table IDs stay unchanged,
and every child retains its existing chart-local parent. Non-zero legend focus
orders become `source order + focus_order_offset`; zero remains zero. The API
never searches for an unused focus range or silently renumbers the host.

The caller must provide an unsealed, internally consistent display list with
enough operation/resource capacity and no resource IDs used by the chart. All
chart semantic and hit IDs must also be absent. Missing parents, duplicate IDs,
resource collisions, invalid offsets, and focus collisions fail closed.

Display contribution is staged in a deep owned clone. The caller's original
display list is replaced only after Canvas, semantics, and hit contribution all
succeed. Semantic mutation uses `SemanticsCheckpoint`; hit mutation uses an
exact length/revision/error checkpoint. Any contribution error restores the
semantic and hit destinations and discards the staged display, so a result with
an error never represents partial chart attachment.

Successful hosted contribution still does not render typography. Before sealing
the destination display list, the host must render every owned `text_slots`
entry through Zagkit Text using its exact ID, bounds, type token, color token,
and text. The host owns any wider transaction that combines chart attachment
with those subsequent Text children. It must keep the artifact alive while
reading slots and call `performance_chart_free` when finished.

## Semantics and data equivalence

The Canvas contributes one named group. Its children provide:

- title, axis-name, axis-unit, tick, baseline, and deadline text nodes with
  exact logical bounds;
- a named legend group whose series buttons expose description, selected,
  disabled, focus order, focus action, and activation action;
- a table with `(sample count + 1)` rows and `(series count + 1)` columns;
- one header row containing the x axis and every named series; and
- one data row per sample with exact row/column coordinates and formatted
  values.

The table is the accessible equivalent of the chart, not a summary. It uses
the same caller-provided names, units, and formatted values as the visible
composition slots.

## Stable IDs and Talkback

The chart ID is caller-owned. Series IDs are caller-owned stable Talkback
targets. Axis, unit, tick, reference, table, row, and cell IDs derive
deterministically from the chart ID through `semantic_generated_key` and public
component ID helpers.

Enabled legend entries expose activate and focus actions; disabled entries are
discoverable but expose neither. Talkback can query every table cell by ID and
receives its exact role, row, column, and owned-text evidence. Pixel fallback
remains disabled in the focused contract.

## Current evidence and limits

Run:

```sh
./tools/test-performance-chart.sh
```

The root-owned contract builds the same chart twice, verifies sealed Canvas
identity, Flex-derived geometry, token roles, complete text slots, semantic table
coordinates, stable-ID Talkback actions, fail-closed duplicate IDs, and
pixel-identical CPU output. The hosted contract additionally verifies explicit
parents, exact contribution counts, root-only reparenting, stable child IDs,
focus-offset collision policy, atomic duplicate/missing-parent failures, and
deterministic caller-owned display content.

This slice does not provide arbitrary chart types, logarithmic/time scales,
locale formatting, axis collision avoidance, zoom, pan, tooltip interaction,
large-data decimation, RTL chart policy, high-contrast adaptation, native
accessibility adapters, GPU comparison, or production typography composition.
Those remain separate work. It also does not select RFC 0007's final visual
direction.
