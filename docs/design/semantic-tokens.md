# Semantic token contract

Zagkit components consume semantic roles, never screen-local RGBA values. The
current token set is experimental while RFC 0007 remains open, but its role
boundaries are already strict: a similar resolved color does not make two
tokens interchangeable.

## Color roles

| Family | Tokens | Meaning |
|---|---|---|
| Canvas and surfaces | `color.canvas`, `color.surface.base`, `color.surface.panel`, `color.surface.raised`, `color.surface.inset` | Structural depth from the application backdrop through recessed content. |
| Interaction surfaces | `color.surface.interactive`, `color.surface.selected` | Transient pointer response and retained selection. Neither means focus. |
| Edges | `color.border.subtle`, `color.border.emphasis`, `color.edge.highlight` | Separation, emphasized boundaries, and material lighting edges. |
| Text | `color.text.primary`, `color.text.secondary`, `color.text.disabled` | Content emphasis and availability. |
| Actions | `color.accent`, `color.accent.emphasis` | Primary action identity and its pressed/emphasized treatment. |
| Focus | `color.focus` | Keyboard-visible focus only. Actual focus also exists independently in semantics. |
| Runtime status | `color.status.healthy`, `color.status.experimental`, `color.status.error` | Health or availability state. Status always has redundant visible text and semantic value. |
| Showcase category | `color.category.performance`, `color.category.semantics`, `color.category.motion`, `color.category.input`, `color.category.renderer` | Stable subject classification. Category never implies health, selection, or action. |
| Chart series | `color.chart.series.primary`, `color.chart.series.secondary`, `color.chart.series.tertiary` | Dataset identity scoped to a chart legend and semantic table. |
| Chart structure | `color.chart.grid`, `color.chart.axis` | Non-data chart anatomy. |
| Material lighting | `color.shadow`, `color.ambient.cool`, `color.ambient.warm` | Depth and environmental lighting. These never carry application state. |

The status rail uses category colors only as redundant classification beside
the category name. Its value text carries current runtime status. It owns no
selection, focus order, action, or enabled hit target. The canonical Surface
retains disabled inspection bounds, while normal input routing misses the rail;
it therefore cannot masquerade as a second navigation pattern. It contains no
navigation actions; the native semantics publish that same contract.

## Type, shape, depth, and material

The type ramp is `type.display`, `type.title`, `type.heading`, `type.body`,
`type.label`, `type.caption`, and `type.code`. A showcase route must render the
complete ramp with visible role names; source enumeration alone is not proof.

Shape uses `radius.control`, `radius.card`, `radius.panel`, and `radius.pill`.
Depth uses ordered `elevation.base`, `elevation.panel`, `elevation.raised`, and
`elevation.overlay` roles. Materials bind a fill, tint, edge, radius, elevation,
and an honest deterministic CPU fallback reason. A blur radius recorded by a
material is not a claim that backdrop blur executed.

## Inspector evidence

The native Linux showcase now has an experimental, stateful token-inspector
overlay for the retained main Surface. It visibly reports the selected
`NodeKey`, canonical component and tier, material, fill, type, spacing,
radius/elevation, environment, and deterministic CPU fallback. The same stable
IDs are present in semantics and Talkback, and the toggle becomes unavailable
when the overlay's Flex minimum cannot fit.

This is the first executable inspector slice, not completion of the inspector
contract. Selection is currently pinned to the main Surface; resolved numeric
values, arbitrary-node picking, interaction-state provenance, and the complete
shared Flex trace remain required before showcase conformance can pass. See the
[executable boundary](../showcase/token-inspector.md).
