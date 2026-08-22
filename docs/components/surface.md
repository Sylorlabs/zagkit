# Surface

`Surface` is Zagkit's first-party retained container for cards, panels, and
floating content. It is not a one-off rectangle helper. The same component
contract owns hierarchy, interaction state, Flex content placement, semantics,
hit testing, and stable-ID automation.

Status: `experimental`. The deterministic CPU material is authoritative. The
current material resolver uses translucent fills, edge highlights, and tokenized
shadows; its documented CPU fallback reason remains visible until real backdrop
blur is implemented and certified.

## Hierarchy tiers and token provenance

Every tier resolves through the shared semantic token registry. A returned
`SurfaceArtifact` records both the material's base tokens and any state override,
so inspection never has to infer provenance from pixels.

| Surface tier | Material | Base fill | Radius | Material elevation | Flex content spacing |
|---|---|---|---|---|---|
| `base` | `material.glass.shell` | `color.surface.base` | `radius.panel` | `elevation.base` | `medium` |
| `panel` | `material.glass.panel` | `color.surface.panel` | `radius.panel` | `elevation.panel` | `large` |
| `raised` | `material.glass.raised` | `color.surface.raised` | `radius.card` | `elevation.raised` | `xlarge` |
| `overlay` | `material.glass.overlay` | `color.surface.raised` | `radius.card` | `elevation.overlay` | `xlarge` |

The contract deliberately records two elevation fields:

- `material_elevation_token` is the hierarchy tier's stable provenance.
- `elevation_token` is the current rendered state. A pressed or unavailable
  card can flatten to `elevation.base` without lying about its material tier.

Likewise, `material_fill_token` records the tier's base fill while `fill_token`
records the current hover, selected, pressed, loading, error, or disabled fill.
`edge_token`, `border_token`, `content_color_token`, `focus_token`, and
`state_token` complete the inspectable color chain. Use
`semantic_material(...)`, `semantic_color(...)`, `semantic_radius_name(...)`,
and `semantic_elevation(...)` to resolve their stable names and values.

## Modes

`SurfaceMode.group` is a structural content group. It emits:

- a visible material owned by the Surface `NodeKey`;
- a non-actionable hit node with the same key, retained for inspection and
  ID-to-pixel fallback but excluded from normal input routing;
- a `group` semantic node with no action mask or focus order.

`SurfaceMode.actionable` is a card that represents one real action. It emits a
focusable hit node and a semantic `button` with `activate` and `focus` only while
the card is available. Loading and disabled cards remain queryable by ID but
their actions fail closed.

The constructors are:

```zag
let panel: SurfaceSpec = surface_spec(
    node_key(1200), hit_root_key(), bounds,
    "Inspector", SurfaceTier.panel);

let card: SurfaceSpec = surface_action_spec(
    node_key(1201), hit_root_key(), bounds,
    "Open renderer", SurfaceTier.raised);
card.focus_order = 4;
```

For actionable surfaces, feed events through `surface_reduce`. It delegates the
actual transition law to Zagkit's canonical Button reducer, so cards and buttons
cannot drift on press, cancellation, loading, disabling, or error precedence.
Groups reject every event without mutation.

## Interaction state language

The canonical states are `rest`, `hover`, `focus`, `pressed`, `selected`,
`disabled`, `loading`, and `error`. Color is never the sole carrier:

| State | Geometric or semantic treatment beyond color |
|---|---|
| `rest` | semantic value `Ready`; tier material, edge, radius, and elevation |
| `hover` | trailing geometric marker; semantic value `Hovered` |
| `focus` | retained semantic `focused = 1`; outer ring only for keyboard-visible focus |
| `pressed` | two-pixel depressed chrome and flattened elevation; value `Pressed` |
| `selected` | persistent underline; semantic `selected = 1` and value `Selected` |
| `disabled` | two-line unavailable mark; disabled hit/action/focus truth; value `Disabled` |
| `loading` | two-part progress rail; disabled action; value `Loading` |
| `error` | trailing state rail sized by Flex `tiny` and `xlarge`; value `Error` |

Combined state fields are allowed only when their truth is coherent. A disabled
surface cannot remain hovered, focused, pressed, or loading. Loading and error
cannot both be set. Invalid combinations fail before any retained destination is
changed.

`live_region` defaults to `off`; a generic card does not assume that a loading
or error change is urgent enough to interrupt assistive technology. Authors can
set `polite` or `assertive` deliberately for either group or actionable mode.
The contract fixtures exercise both explicit choices and include that choice in
deterministic evidence.

Actual focus and focus-ring modality are separate truth. Pointer focus sets
`focused = 1` for semantics, Talkback, and focus ownership while keeping
`focus_visible = 0`; keyboard focus sets both fields. Only `focus_visible`
paints the outer ring. A standalone ring with no actual focus is an invalid
interaction state.

## Flex placement and minimums

`SurfaceArtifact.content_bounds` is the only supported placement rectangle for
children. It is derived from `content_spacing_token` and the selected
`FlexDensity`; consumers must not reproduce its padding with literals. Status
treatments reserve trailing space when possible and retain at least one logical
pixel of content width under tight constraints.

Actionable cards enforce a minimum target of 44 logical pixels on both axes.
Tier padding can require more: a raised or overlay surface at standard density
needs 56 logical pixels to preserve two `xlarge` insets and an eight-pixel
content extent. Structural groups enforce the same content-preservation rule
without pretending to be pointer targets.

The visual radius is resolved from the named radius token, then clamped to the
actual rectangle. The artifact records both `radius_token` and
`resolved_radius`, preserving token provenance while keeping small valid
surfaces geometrically valid.

## One ID, four consumers

The Surface `id` is used unchanged for:

1. every emitted `DisplayOp.owner`;
2. the retained `HitNode.id`;
3. the retained `SemanticsNode.id`;
4. Talkback query/action lookup and explicit semantic-ID-derived pixel fallback.

The component never manufactures a parallel accessibility or automation ID.
The semantic bounds and hit bounds are the same `SurfaceSpec.bounds`, while
pixels use that geometry plus documented focus/shadow extents. Disabled and
group hits stay inspectable through the explicit disabled-inclusive inspection
path but never enter normal input routing.

## Capacity, atomicity, and evidence

`SurfaceBuildLimits` provides explicit per-build budgets for display operations,
hit nodes, and semantic nodes. Zero is a valid fail-closed test budget; negative
limits are invalid specs. Exhaustion reports the exact
`SurfaceCapacityError`.

Emission checkpoints the DisplayList, HitTree, and SemanticsTree before its
first contribution. Display errors, duplicate IDs, focus-order collisions,
semantic errors, and capacity failures restore all lengths, revisions, hashes,
error state, and newly copied semantic text. A build is either fully present in
all three retained trees or absent from all of them.

`SurfaceArtifact.evidence_hash` deterministically covers identity, geometry,
parent, mode, tier, Flex density, state, token provenance, resolved radius,
visible treatment flags, role, name, and description. Identical inputs must
produce identical component, DisplayList, and semantic-tree evidence.

## Text lifetime

Surface names are caller-owned views. Both constructors declare
`name: @retained_by_return []u8` because the returned `SurfaceSpec` retains that
view until emission. The caller's backing must remain alive through the last use
of the spec. `surface_emit` copies name and description into the retained
SemanticsTree; the caller can release its backing after emission.

This is enforced by Zag rather than hidden behind a component copy. The focused
test runner includes both a positive dynamic-name case and a negative strict
compile case that releases backing before `surface_emit`; the negative case must
be rejected with the resource/lifetime diagnostic.

## Verification

Run:

```sh
tools/test-surface.sh
```

The contract covers hierarchy/token resolution, Flex geometry, group and button
semantics, retained focus truth, all eight interaction states, non-color state
treatments, hit and Talkback routing, minimum targets, invalid inputs,
determinism, dynamic returned-view lifetime, explicit capacity failures, and
atomic rollback.
