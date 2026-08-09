# Button

`Button` is a retained interaction contract, not a drawing helper. One stable
`NodeKey` owns its display operations, hit target, focusability, semantic node,
and Zagkit Talkback target. A successful build therefore cannot produce a
clickable shape with missing semantics, or accessible metadata with no hit
geometry.

The implementation is experimental while the Zagkit component API is still
pre-1.0. Its invariants are release requirements.

## Authoring contract

Create a `ButtonSpec` with `button_spec(id, parent, bounds, label)`, then set its
variant, density, description, focus order, z-order, and `ButtonInteraction`.
Call `button_emit` with the frame's mutable `DisplayList`, `HitTree`, and
`SemanticsTree` builders. On success, the returned `ButtonArtifact` records:

- the shared stable ID and exact bounds;
- caller-owned text content bounds resolved from Flex spacing;
- every semantic color and elevation token selected for the state;
- effective enabled and content visibility truth;
- display operation, hit-node, and semantic-node locations; and
- a deterministic evidence hash over identity, geometry, state, and tokens.

Emission is atomic. A duplicate ID, missing parent, focus-order collision,
sealed display list, or invalid spec restores every builder to its checkpoint
and returns the concrete subsystem error.
Labels are required, strict UTF-8, NUL-free, and bounded to 4,096 bytes;
descriptions follow the same text rules and are bounded to 16,384 bytes.
Validation occurs before display or tree mutation.

## Text ownership

The component draws its material chrome and loading indicator. It deliberately
does not approximate label text. The caller renders a real Zagkit `Text` child
inside `artifact.content_bounds`, using `artifact.style.text_token`. The
button's label is copied into its semantic node during emission, so assistive
technology and Talkback never depend on whether glyphs happen to be visible.

This boundary will be composed by the public declarative `Button` view once the
shared `Text` component and reconciliation layer are connected. Placeholder
bars and shell-specific text are not a supported Button implementation.

## State model

`ButtonInteraction` uses independent flags because selected+focused and
error+focused are valid combinations. `button_canonical_state` provides the
eight showcase fixtures: rest, hover, focus, pressed, selected, disabled,
loading, and error. Styling resolves with documented precedence:

1. variant establishes the base material;
2. hover, selection, and press change interactive emphasis;
3. error changes the semantic error edge;
4. loading makes actions unavailable and substitutes a progress mark; and
5. disabled overrides material, text, focus, hit, and action availability.

Focus is a separate visible ring and never relies on fill color. Selection is
also exposed through `SemanticsNode.selected`; loading and error expose text
values. Color is therefore supplementary state evidence.

`button_reduce` accepts pointer, focus, selection, availability, loading, and
error events. It emits `activate` only for an enabled press followed by an
inside release. It never mutates application state: state still flows down and
the emitted action flows up.

## Variants and tokens

The current variants are `primary`, `secondary`, `quiet`, and `destructive`.
They resolve only through semantic tokens, including `color.accent`,
`color.surface.interactive`, `color.status.error`, `color.focus`, named border
roles, named text roles, semantic radii, and elevation tiers. Similar-looking
literal colors are not component API.

## Measurement and placement

`button_measure` accepts measured label size, optional-leading-visual truth,
constraints, and `FlexDensity`. Horizontal/vertical padding and visual gap come
from public Flex spacing tokens. Minimum targets are 32 logical pixels in
compact density, 40 in standard density, and 48 in touch density. The result
reports constraint clipping rather than silently changing content metrics.

The visual bounds, hit bounds, semantic bounds, and Talkback bounds are exact
matches. Focus and shadow may paint outside those bounds but never enlarge the
action target invisibly.

## Accessibility and automation

Enabled buttons expose `activate` and `focus`; disabled and loading buttons
remain discoverable but expose neither action. Selection, disabled state,
loading/error value, description, focus order, and exact bounds share the
parallel semantics tree. Zagkit Talkback clicks the same ID and semantic action
that platform accessibility adapters consume. Pixel targeting is unnecessary
for Button.

The executable contract in `tests/button_contract.zag` covers measurement,
state reduction, all eight showcase states, token mapping, immutable display
verification, hit identity, semantic state, Talkback activation, fail-closed
disabled behavior, and atomic rollback.
