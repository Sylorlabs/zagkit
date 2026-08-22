# ScrollViewport

Status: experimental headless component

`ScrollViewport` is Zagkit's retained scrolling host. It does not own a second
offset model: `src/layout/scroll.zag::ScrollState` is the sole authority for
viewport size, content size, logical offsets, revision, clamping, unconsumed
delta, anchoring, and reveal. The component derives one immutable geometry
record from that state and uses it for rendering, hit testing, semantics,
Talkback, and scrollbar chrome.

This slice proves the reusable headless contract. It is not a claim of native
touch momentum, scrollbar dragging, overscroll effects, or reference-hardware
120 Hz certification. Those remain platform/input scheduler work.

## Public model

`scroll_viewport_spec` creates a `ScrollViewportSpec` with stable semantic and
hit parents, a stable `NodeKey`, exact logical bounds, and an accessible name.
The caller may then set:

- `axis`: `vertical`, `horizontal`, or `both`;
- `direction`: LTR or RTL;
- `density`: the Flex density used for track thickness, margins, thumb minimum,
  keyboard line increments, and page overlap;
- `enabled`, `focused`, and `focus_visible` as separate state truths;
- `focus_order` and `content_focus_order_offset`;
- `z_order` and explicit contribution limits;
- localized `description` and `value` text.

The `ScrollState.viewport` must exactly equal `spec.bounds.size`. This equality
is deliberate: a caller cannot render one viewport, hit-test another, and
publish a third to accessibility.

`scroll_viewport_geometry(spec, state)` returns:

- the world-space viewport/clip rectangle;
- the physical visible content rectangle (mirrored from logical horizontal
  offset under RTL);
- the exact content-to-world transform;
- horizontal and vertical track/thumb rectangles and visibility;
- both logical maxima and values;
- a deterministic evidence hash.

## Hosted contribution

`scroll_viewport_contribute` takes an already-built, sealed `DisplayList`, a
content-space `SemanticsTree`, and a content-space `HitTree`, then contributes
them into caller-owned destination builders.

The display sequence is invariant:

1. `save`;
2. viewport `clip_rect`;
3. content offset `concat_transform`;
4. the complete hosted content display list;
5. `restore`;
6. optional keyboard-focus ring;
7. tokenized horizontal/vertical tracks and thumbs.

Content resources are copied into a staged destination before any caller-owned
builder changes. Resource IDs must not collide. The source display list stays
sealed and unchanged.

Content semantic and hit roots are reparented beneath the viewport's stable ID;
descendant IDs and relationships are preserved. Non-zero content focus orders
receive the explicit offset. The viewport hit is below hosted children, so it
receives wheel input in empty space while children win at their exact higher
z-order.

Hosted hit transforms currently accept translation plus identity scale (no
skew). Their translation is composed with the scroll transform and their local
clip is intersected with the authoritative visible content rectangle. Fully
offscreen hit nodes remain present but disabled, preserving parent topology
without admitting pixel actions outside the clip. General scaled/skewed hit
clip projection is intentionally fail-closed until the hit tree owns an exact
convex clip primitive.

## Semantics and Talkback

The viewport publishes a `group` node at `spec.id`. When enabled and
scrollable, it exposes `scroll`; when focusable, it separately exposes `focus`.
Its primary range is vertical when vertical overflow exists, otherwise
horizontal.

Every visible axis additionally publishes a stable `slider`-role range node:

- `scroll_viewport_horizontal_range_id(spec.id)`;
- `scroll_viewport_vertical_range_id(spec.id)`.

These nodes expose exact minimum, maximum, current value, one-logical-pixel
step, track bounds, and a `scroll` action when enabled. This prevents a
two-axis viewport from collapsing its
accessibility truth into one ambiguous range.

Descendant semantic bounds retain their complete transformed screen geometry;
the viewport ancestor supplies the clip to native adapters. Fully offscreen
descendants retain their transformed bounds, original `hidden` truth, stable
ID, and actions. They are not mislabeled hidden
merely because they are outside this viewport: Talkback can still query the ID,
while ID-derived pixel fallback honestly fails outside the viewport clip.

`scroll_viewport_reveal_hosted_semantic_id` verifies that an ID is a descendant
of this viewport, inverts the artifact's exact transform back to content-space
bounds, and feeds those bounds into `scroll_viewport_reveal_focus`. A
composition may therefore release its source gallery/artifact after hosting;
it does not retain a second ID map or decode ID structure. The source-tree form,
`scroll_viewport_reveal_semantic_id`, remains available before hosting. The host then rebuilds
with the updated `ScrollState`; the same ID becomes visible and pointer
actionable. Keyboard Tab and native accessibility focus must use this reveal
step before dispatching an action to an offscreen target. No pixel guess or
screen-coordinate reverse lookup is involved.

## Input and state flow

All mutations return `ScrollViewportTransition`, containing the underlying
`ScrollMutation`, requested delta, consumed/unconsumed result, rejection reason,
input kind, and deterministic hash.

- `scroll_viewport_wheel` handles two-axis wheel deltas and maps physical
  horizontal direction to logical RTL offset.
- `scroll_viewport_key` supports arrows, Page Up/Down/Left/Right, Home, and End.
- `scroll_viewport_semantic_scroll` routes accessibility commands through the
  same command reducer.
- `scroll_viewport_reveal_focus` performs nearest-edge reveal using exact
  content bounds and RTL conversion.
- `scroll_viewport_reveal_semantic_id` joins ID lookup to focus reveal.

Two Flex `xlarge` spacing units define the line increment; page movement
retains one `xlarge` overlap at each edge. ScrollState still clamps every result and reports
unconsumed boundary pressure for nested-scroll arbitration.

Disabled viewports reject wheel, key, semantic, and reveal mutations without a
phantom revision. Their semantic and hit IDs remain inspectable, but root and
descendant actions are removed. A no-overflow viewport publishes no scroll
action, no range, and no track/thumb while still allowing an independently
configured focus target.

## Token provenance

No component-local RGBA values are accepted. Scrollbar chrome resolves through:

| Part | Token |
|---|---|
| Track | `color.surface.inset` |
| Thumb | `color.border.emphasis` |
| Keyboard focus | `color.focus` |
| Thickness/margin | `FlexSpacingToken.tiny` |
| Minimum thumb | `FlexSpacingToken.xlarge` |

The artifact repeats these token identities so inspectors and snapshot tests
can prove provenance rather than infer it from similar-looking pixels.

## Atomicity, limits, and ownership

Display operations/resources are staged. Semantic and hit destinations use one
checkpoint. Missing parents, duplicate IDs, focus-order collisions, resource
collisions, unsupported hit transforms, and display/resource/node capacity
failures leave every destination unchanged. A late semantic or hit failure
rolls back both node trees and discards the staged display.

`ScrollViewportArtifact` owns no heap allocation. The caller retains ownership
of source and destination builders and frees them with their normal consumed
root destructors. Internal failed stages are always released. Tests use an
explicit `@consumes *ScrollViewportFixture` destructor; no mutable-borrow
destructor workaround is part of this component.

Run the focused contract with:

```sh
tools/test-scroll-viewport.sh
```

The suite covers LTR/RTL, both axes, deterministic wrapper order, token
provenance, exact ranges, Talkback query/scroll, offscreen ID lookup and reveal,
pixel-fallback failure, hit clipping, wheel/key/semantic mutations, boundary
handoff, disabled/no-overflow behavior, visible focus, resource collision,
late semantic/hit rollback, capacity rejection, source preservation, display
verification, deterministic replay identity, and consumed-root cleanup.
