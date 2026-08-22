# Experimental performance chart

`PerformanceChart` is one bounded line/scatter component for frame-performance
evidence. It proves chart anatomy, semantic equivalence, token routing,
opt-in focus state, and stable-ID automation. It is not a general chart suite
and is not a production visual-polish claim.

## Scope and input contract

The component accepts one `PerformanceChartSpec` with:

- a positive stable chart `NodeKey` and bounds of at least 640 by 420 logical
  pixels;
- a title and description;
- independently named x and y axes with explicit units;
- bounded integer domains, two to twelve ticks per axis, and one caller-owned
  label for every tick;
- named baseline and deadline values inside the y domain, with display-ready
  labels that include the relevant value and unit;
- one to three named series, each containing two to sixty-four aligned,
  strictly increasing samples; and
- an explicit content state plus an explicit legend interaction policy. The
  compatibility constructor sets `ready` and `read_only`.

Every sample carries its numeric x/y coordinates and its already-formatted
accessible x/y strings. Series in one chart must have the same sample count and
the same x coordinate at each row. This makes the semantic data table exact
instead of asking assistive technology to reverse-engineer pixels.

Names, descriptions, units, tick labels, and cell strings must be valid,
NUL-free UTF-8 within the component bounds. Series IDs must be positive and
unique. Each chart may use the `reference`, `comparison`, and `diagnostic`
series role at most once. Those roles own their color and marker shape; callers
cannot assign an arbitrary palette value or repeat a role to create unexplained
colored dots. New code constructs series with
`performance_chart_series_role`; the earlier color-token constructor remains a
validation-preserving compatibility adapter. Coordinates are bounded to plus
or minus one million before fixed-point mapping, preventing unchecked
multiplication. Duplicate IDs or series roles, role/color mismatches,
malformed text, misaligned samples,
out-of-range references, excessive series, and malformed state fail before
display, hit, or semantic mutation.

## Content states

`PerformanceChartContentState` is a closed contract:

| State | Data contract | Visible anatomy | Semantic truth |
|---|---|---|---|
| `ready` | one to three validated series | axes, references, marks, legend | exact legend plus full data table |
| `loading` | zero series and zero axis ticks | status panel, accent indicator, indeterminate track | `progress`, status value, polite live region |
| `empty` | zero series; axes off unless explicitly preserved | status panel and axis-colored indicator | named zero-data value, polite live region |
| `error` | zero series and zero axis ticks | status panel and error-token indicator | named failure value, assertive live region |

Loading, empty, and error require non-empty `status_name` and `status_value`
strings. They never accept caller-supplied series, never synthesize points, and
publish zero table rows and columns. They contribute no legend group, series
semantics, series hit targets, focus order, or actions, regardless of the
stored legend policy.

`preserve_empty_axes` is the only non-ready axis exception. It is valid only
for `empty`, must be explicitly set to `1`, and requires the same bounded axis
domains, names, units, tick counts, and tick labels as a ready chart. It draws
and publishes axes and ticks, but deliberately omits baseline/deadline
references because there are no samples to compare. Loading, error, and
ordinary empty states require zero tick counts and empty tick-label lists, so
stale axes cannot leak through accidentally.

Every non-ready state uses a retained `PerformanceChartStatusArtifact` as the
single geometry and token authority for its panel, indicator, name, value, and
optional loading track. The two visible status strings are owned text slots;
the status semantic node redundantly carries the same name/value and exact
bounds. Loading uses `color.accent`, empty uses `color.chart.axis`, and error
uses `color.status.error`; all supporting surfaces and text also resolve
semantic tokens rather than local colors.

## Legend interaction policy

Legend interaction is fail-closed. The default `read_only` policy describes
the series as a semantic `list` of `list_item` nodes. Every item retains its
name, description, `Available` / `Selected` / `Unavailable` value, selected
state, disabled state, set size, position, and exact bounds. It has zero focus
order and zero actions, and the legend contributes no hit nodes. The chart's
Canvas root remains the single chart hit node. `focused` and `hovered` series
input is rejected under this policy because the component has no interaction
path that could truthfully produce either state.

`actionable` is an explicit opt-in. It retains the button semantics, per-series
hit nodes, focus order, focus action, activation action, hover treatment, and
focus treatment. This mode does not install an application reducer: the host
must route pointer, keyboard, accessibility, and Talkback activation to real
series-selection state. Choosing `actionable` without that routing is a host
integration defect, not a chart capability.

## Visual anatomy

The retained Canvas emits:

- raised panel, border, shadow, and recessed plot surfaces;
- independently inspectable grid and axis paints;
- ticks on both axes;
- a named baseline reference and a distinct semantic-error deadline reference;
- one filled line ribbon plus one role-shaped mark per sample;
- named series swatches arranged with Flex; and
- separate default, hovered, selected, focused, and disabled legend treatments.

That ready anatomy is state-specific. Non-ready states retain the same raised
outer chart and inset content surface, then replace data marks with the
status artifact described above. A loading track is an availability cue, not
a fabricated performance value; it has no numeric range or sample semantics.

Series styling is a semantic mapping, not decoration:

| Series role | Color role | Non-color marker |
|---|---|---|
| `reference` | `color.chart.series.primary` | circle |
| `comparison` | `color.chart.series.secondary` | rounded square |
| `diagnostic` | `color.chart.series.tertiary` | lozenge |

The marker mapping is used both in the plot and legend. Color is therefore not
the only way to tell series apart.

Legend states also resolve through one documented style function:

| State | Surface treatment | Additional cue |
|---|---|---|
| default | base surface | normal label and marker |
| hover | interactive surface | higher-emphasis marker |
| selected | selected surface | persistent accent underline |
| focused | state surface plus focus token | external focus ring |
| disabled | inset surface | disabled label and reduced marker opacity |

Selected state is meaningful in both policies. Focus and hover are available
only in `actionable`, and selected and focused may coexist there. A disabled
series may not also be hovered, selected, or focused. At most one series in a
chart may own each transient or selection state.

All colors route through semantic roles such as `color.chart.grid`,
`color.chart.axis`, `color.chart.series.primary`, `color.focus`, and
`color.status.error`. Panel depth routes through the raised elevation and panel
radius tokens. Repeated padding, legend gaps, and label spacing resolve through
named Flex spacing tokens.

`performance_chart_x_tick_geometry`,
`performance_chart_y_tick_geometry`, and
`performance_chart_reference_geometry` are the only placement authorities for
grid lines, tick marks, visible text slots, and semantic bounds. The visual
legend resolves Flex exactly once and stores item, focus-ring, marker, text, and
selection-indicator bounds in `PerformanceChartLegendArtifact`; hit testing,
semantics, and text composition consume that artifact instead of running a
second layout pass.

Axis reservations are not a shared square gutter. The horizontal x-axis footer
keeps its Flex-derived 56 logical-pixel height, while the unrotated y-axis label
column uses a separate Flex-derived 112 logical-pixel width. At the minimum
640-by-420 chart size, the focused contract proves that the `Frame time` label
and `milliseconds` unit slots exceed a conservative two-thirds-em width floor
while the plot retains positive width and height. Text slots and semantic
bounds still come from the same `PerformanceChartMetrics` geometry authority.

The implementation uses the public Canvas resource path for each line. A line
is an immutable bounded path of filled segment ribbons because the current CPU
oracle implements path fills but not path strokes. Role-shaped marks and all
other chrome use retained display-list primitives. The complete Canvas seals and
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

Ready charts own 24 slots in the focused three-series fixture. Loading,
ordinary empty, and error own three: title, status name, and status value. The
seven-by-seven meaningful-empty-axis fixture owns 21: title, four axis roles,
fourteen ticks, and two status strings. No non-ready state owns legend,
reference, or table text disguised as data.

The focused component test validates slot completeness, stable IDs, positive
bounds, type roles, and color roles. It intentionally rasterizes only the
Canvas-owned chart geometry. Therefore its CPU surface hash is renderer evidence
for the chart chrome, line, markers, grid, references, legend materials, and
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

For a three-series chart, default read-only hosting contributes one hit node:
the Canvas root. Explicit actionable hosting contributes four: the Canvas root
plus three series hits. Semantic and display contribution counts are otherwise
unchanged by the policy. Host validation checks the policy-specific role,
focus/action fields, collection position, and exact hit count before mutation.
The focused four-sample fixture contributes 52 semantic nodes and owns 24 text
slots in either mode.

Non-ready hosting always contributes one Canvas hit. The focused loading,
ordinary-empty, and error fixtures each contribute three semantic nodes
(Canvas, title, status); meaningful empty axes contribute 21. Host validation
requires zero legend artifacts and table dimensions, a policy-correct status
role/live region/value, exact status geometry, and the one-hit count before it
mutates any destination. Duplicate status IDs fail during preflight with no
display, semantic, or hit mutation.

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
- by default, a named series list whose read-only items expose description,
  selected, disabled, value, set size, and position without actions or focus;
- in explicit actionable mode, a named legend group whose series buttons also
  expose focus order, focused state, focus action, and activation action;
- a table with `(sample count + 1)` rows and `(series count + 1)` columns;
- one header row containing the x axis and every named series; and
- one data row per sample with exact row/column coordinates and formatted
  values.

Those legend and table branches exist only in `ready`. Every non-ready tree has
one status node with its visible status name as `name`, its visible detail as
`value`, and the state-appropriate live-region priority. Meaningful empty axes
add only axis/tick text nodes; they still have no references, legend, or table.

The table is the accessible equivalent of the chart, not a summary. It uses
the same caller-provided names, units, and formatted values as the plotted
samples. The focused contract checks every header and every sample cell, not a
representative cell.

## Stable IDs and Talkback

The chart ID is caller-owned. Series IDs are caller-owned stable Talkback
targets. Axis, unit, tick, reference, table, row, and cell IDs derive
deterministically from the chart ID through `semantic_generated_key` and public
component ID helpers.

Read-only legend entries are queryable by ID but expose no activate or focus
action. In actionable mode, enabled entries expose activate and focus actions;
disabled entries remain discoverable but expose neither. Talkback can query
every table cell by ID and receives its exact role, row, column, and owned-text
evidence. Pixel fallback remains disabled in the focused contract.

## Current evidence and limits

Run:

```sh
./tools/test-performance-chart.sh
```

The root-owned contract builds the same chart twice and verifies sealed Canvas
identity, shared tick/reference geometry records, one-pass Flex legend
geometry, semantic series roles and non-color markers, all five legend state
treatments in actionable mode, the safe read-only default, policy-specific hit
and action truth, split axis extents at the minimum size, complete text slots,
all four content states, token-routed status anatomy, non-ready semantic/live
truth, zero-data suppression, full semantic-table equivalence, named Talkback
state bits, fail-closed
duplicate IDs/roles and invalid state, and
pixel-identical CPU output. The hosted contract additionally verifies explicit
parents, one-hit read-only and four-hit actionable contribution counts,
one-hit non-ready state contribution, root-only reparenting, stable child IDs,
focus-offset collision policy, atomic status/duplicate/missing-parent failures,
and deterministic caller-owned display content.

This slice does not provide arbitrary chart types, logarithmic/time scales,
locale formatting, axis collision avoidance, zoom, pan, tooltip interaction,
large-data decimation, RTL chart policy, high-contrast adaptation, native
accessibility adapters, GPU comparison, or production typography composition.
Those remain separate work. It also does not select RFC 0007's final visual
direction.
