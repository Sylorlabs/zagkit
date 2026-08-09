# NavigationItem

`NavigationItem` is Zagkit's retained app-navigation and tab primitive. One
stable `NodeKey` owns its display operations, 44-logical-pixel hit target,
focus target, `tab` semantic, and Talkback target. It does not proxy through a
generic Button semantic.

The component is experimental. Its executable contract is implemented, but it
is not yet wired into every shell or certified by native platform accessibility
adapters.

## Interaction contract

`NavigationItemSpec.interaction` is the canonical `ButtonInteraction`, and
`navigation_item_reduce` delegates to `button_reduce` for every `ButtonEvent`.
Pointer cancellation, focus loss, loading precedence, disabled behavior, and
inside-release activation therefore cannot drift between buttons and
navigation. Application state still owns selection: the item reports an
activation and the selected state flows back down.

The eight executable fixtures are default, hover, focus, pressed, selected,
disabled, loading, and error. Their colors resolve only through semantic color,
radius, elevation, and Flex spacing tokens.

## Visible state language

State is not encoded by color alone:

- focus emits a retained outer focus ring;
- selection emits a persistent leading marker and `selected` semantic truth;
- loading emits a two-part progress rail, exposes the value `Loading`, and
  makes actions unavailable while remaining discoverable; and
- error emits a shaped exclamation badge and exposes the value `Error`.

Disabled items remain queryable but expose no activate, select, or focus action
and are removed from pointer and focus routing. Enabled items expose all three
actions. The exact focus order, set size, and one-based position in set are
copied into the parallel semantic tree.

## Placement and Text composition

Visible bounds, hit bounds, semantic bounds, and Talkback bounds are identical.
Both target dimensions must be at least 44 logical pixels; undersized items
fail validation rather than gaining an invisible hit halo. Internal label
padding and trailing status space come from Flex tokens.

The component draws chrome and state treatments, then returns
`label_content_bounds`, `SemanticTypeToken.label`, and the resolved semantic
label color token. The caller composes Zagkit `Text` into that slot. This module
does not approximate glyphs, and it does not claim text shaping, bidi, wrapping,
or native font fallback by itself.

## Failure and evidence contract

Emission checkpoints the caller-owned `DisplayList`, `HitTree`, and
`SemanticsTree`. Display failure, duplicate IDs, missing parents, and semantic
focus collisions restore all three builders. Invalid UTF-8, collection
metadata, geometry, interaction flags, or minimum target size fail before any
mutation.

`NavigationItemArtifact.evidence_hash` deterministically covers stable
identity and parent, geometry, labels, focus and set metadata, Text slot tokens,
interaction state, semantic style tokens, and non-color state-treatment truth.
`tests/navigation_item_contract.zag`
verifies the eight-state matrix, immutable display output, semantic tab state,
Talkback query/action behavior, deterministic evidence, and rollback.
