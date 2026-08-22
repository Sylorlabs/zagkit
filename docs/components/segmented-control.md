# SegmentedControl

`SegmentedControl` is Zagkit's retained, single-selection control for switching
between a small set of peer views or modes. It is not a row of unrelated
buttons and it is not a decorative tag list. One group `NodeKey` owns a set of
stable tab IDs, exactly one enabled option is selected, and every selection
change is produced by the public reducer before state flows back into the next
frame.

The component is experimental while the public declarative view and native
accessibility adapters are still being connected. Its headless contract is
executable now.

## State and action contract

`SegmentedControlModel` is application-owned state. It records the option
count, selected and roving-tab-stop indices, independent `has_focus` and
`focus_visible` truth, transient hover/press indices, and an enabled bit mask.
`segmented_control_model(count, selected)` creates a valid model with one
selection, one roving target, all options enabled, and no fabricated focus.
Selection and the roving target begin at the same option, but construction does
not paint a focus ring before the native shell delivers a real focus event.

Send pointer, focus, keyboard, semantic-selection, and availability events to
`segmented_control_reduce`. The returned `SegmentedControlTransition` contains
the complete next model plus explicit `selection_changed`, `roving_changed`,
`focus_changed`, `activated`, and `rejected` truth. Roving-target movement is
therefore not misreported as native focus acquisition. The reducer never
mutates application state. It guarantees:

- an enabled option is always selected;
- disabled options cannot be focused, pressed, selected, or activated;
- an inside pointer release selects only the matching pressed option;
- Pointer Cancel and focus loss clear pressed state;
- pointer down acquires focus without forcing a keyboard-style ring;
- host `focus_target` and keyboard navigation acquire visible focus;
- focus loss clears focus ownership and visibility while preserving the roving
  target for deterministic re-entry;
- Left/Up and Right/Down navigation wrap and skip unavailable options;
- Home and End choose the first and last available option;
- Enter/Space activation and semantic selection use the same reducer path; and
- disabling the current selection chooses the next available option atomically
  and rejects removal of the last available option.

The shell maps physical keys to the logical `key_previous`, `key_next`,
`key_home`, `key_end`, and `activate_focused` events. Direction-aware shells
may swap previous/next for RTL without changing selection semantics. If a
keyboard event arrives while the model is unfocused, navigation starts from the
selected option and establishes visible focus. Hover, press, and focus shown in
a native preview must come from actual input/focus events; a gallery may build
an explicit static state matrix, but it is not runtime interaction evidence.

## Retained authoring contract

Create a `SegmentedControlSpec` with `segmented_control_spec`, then set its
description, focus-order base, z-order, density, model, and optional transaction
limits. Provide a caller-owned `ArrayList[SegmentedControlOption]` whose length
equals `model.segment_count`, and call `segmented_control_emit` with the frame's
`DisplayList`, `HitTree`, and `SemanticsTree`.

```zag
let options: ArrayList[SegmentedControlOption] =
    make[SegmentedControlOption](3);
push[SegmentedControlOption](&options, SegmentedControlOption{
    .id = node_key(101), .label = "State", .description = "Inspect state",
});
push[SegmentedControlOption](&options, SegmentedControlOption{
    .id = node_key(102), .label = "Layout", .description = "Inspect layout",
});
push[SegmentedControlOption](&options, SegmentedControlOption{
    .id = node_key(103), .label = "Render", .description = "Inspect rendering",
});

let model = segmented_control_model(3, 0);
let spec = segmented_control_spec(node_key(100), hit_root_key(), bounds,
    "Inspector mode", model);
spec.purpose = SegmentedControlPurpose.value_picker;
let built = segmented_control_emit(spec, &options,
    &display, &hits, &semantics);

let transition = segmented_control_reduce(model,
    segmented_control_event(SegmentedControlEventKind.key_next,
        segmented_control_no_index()));
model = transition.model; // selection, roving, focus, and transient state flow together
free[SegmentedControlOption](&options);
```

The convenience constructor is for static/literal group names in the current
experimental API. If the group name or description is dynamically owned,
construct the `SegmentedControlSpec` literal in the same caller scope as that
backing and keep it alive through emission. Zag intentionally rejects marking a
constructor input as a call-duration borrow and then returning that view; an
explicit returned-borrow relation is a separate future language contract, not
something Zagkit fakes with an unsafe lifetime.

Choose semantics explicitly with `SegmentedControlSpec.purpose`:
`view_switcher` (the default) exposes a `tab_list` with `tab` children for peer
content views; `value_picker` exposes a `radio_group` with `radio` children for
mutually exclusive values or filters. The pixels and reducer are shared, but
Zagkit does not mislabel a value choice as page navigation.

Options are borrowed for the call and never retained. Labels are required,
strict UTF-8, NUL-free, and bounded to 4,096 bytes; descriptions use the same
text rules and are bounded to 16,384 bytes. IDs must be stable and unique within
the group. The component supports 2 through 12 options; larger navigation sets
belong in tabs, a sidebar, or a menu rather than an unreadable segmented rail.

On success, `SegmentedControlArtifact` reports the exact group bounds, selected
ID/index/bounds, roving index, focus ownership/visibility, retained operation
range, group tree locations, Text token, inspectable rail tokens, and a
deterministic evidence hash.

## Placement and Text

Flex owns spacing. The rail uses `spacing.micro` for its inset and connected-item
gap. Every segment has a minimum 44-by-44 logical-pixel target. Width is divided
in fixed-point units and the remainder is distributed deterministically, so the
first edge, every gap, and the final edge conserve the full rail width.
Undersized controls fail validation instead of gaining an invisible hit halo.

The component emits material chrome and returns deterministic label slots via
`segmented_control_content_bounds(spec, index)`. Callers render Zagkit `Text`
inside that rect with `SemanticTypeToken.label` and
`segmented_control_style(spec, index).label_color_token`. Semantics copy the
option label during emission, so accessibility and Talkback do not depend on
glyph visibility. Placeholder bars are not a supported label implementation.

## Token and visible-state system

Every visual choice has semantic-token provenance. The rail exposes
`color.surface.inset`, `color.border.subtle`, `radius.control`, and
`elevation.base` through the artifact. Per-option style resolution uses named
roles only:

- default: `color.surface.base`;
- hover: `color.surface.interactive`;
- visible keyboard focus: `color.focus` with a geometrically thicker retained
  ring;
- press: `color.accent.emphasis` with a two-pixel inset treatment;
- disabled: `color.surface.inset` and `color.text.disabled`; and
- selected: `color.surface.selected` with `color.border.emphasis` and an
  `elevation.panel` thumb shadow.

Selection never relies on fill color. A selected option also emits a persistent
three-logical-pixel underline owned by the same stable ID, and its semantic node
sets `selected` with the text value `Selected`. Focus and press also change
geometry, not just hue. This state matrix is verified from the public style and
retained display operations. `has_focus` is independent from
`focus_visible`: pointer focus is real semantic focus but does not inherit the
keyboard focus ring, while keyboard or explicit host focus sets both.
Focus-ring modality participates in visual/component evidence, while the
semantic tree remains identical for pointer and keyboard focus on the same ID.

## Accessibility and Talkback

The parent is a named semantic `tab_list` or `radio_group`; each option is a
matching `tab` or `radio` with one-based position, set size, and exact bounds.
Exactly one enabled option—the model's roving target—has the group's sequential
focus order and focusable hit-node bit. All enabled options still expose
`activate`, `select`, and programmatic `focus`, so assistive technology and
Talkback can address them directly by stable ID. Disabled options remain
discoverable and queryable but expose no action and are removed from pointer and
focus routing.

The semantic `focused` state follows actual focus ownership and the roving ID,
not focus-ring modality. Consequently pointer-focused controls report semantic
focus while keeping `focus_visible = 0`; Talkback exposes that independent state
in its focused flag. Blur removes semantic focus but leaves the roving tab stop
ready for the next traversal.

For every option, its outer visual operation, hit node, semantic node, focus
target, and Talkback response use the exact same `NodeKey` and `Rect`. Talkback
can therefore query and key-activate a segment by ID; pixel targeting is not
needed. The reducer remains the application-side authority that turns the
emitted action into a new selected index.

## Atomic failure and capacity

Emission checkpoints all three caller-owned builders. Invalid geometry or
content fails before mutation. Display errors, duplicate/missing hit IDs,
semantic focus collisions, and display-, hit-, or semantic-transaction capacity
exhaustion restore every builder, including copied semantic text and diagnostic
state.

`SegmentedControlBuildLimits` are deterministic per-emission transaction
budgets, not a claim that process allocator OOM is recoverable. Defaults cover
the maximum supported control. A host using fixed frame arenas can lower them
and receive a structured `SegmentedControlCapacityError` without partial UI.

The executable contract in `tests/segmented_control_contract.zag` covers model
invariants, all 180,224 enabled-mask/directional-key cases for 2 through 12
options, default/hover/focus/pressed/disabled/selected styles, resting selection
without false focus, pointer-versus-keyboard focus visibility, one roving tab
stop, every supported count and fixed-point placement remainder, token
provenance, non-color state geometry, retained-tree identity, keyboard actions,
Talkback, immutable display evidence, determinism, input validation, and rollback
for all three capacity classes.

The suite also builds label and description views from caller-owned dynamic
byte buffers, emits the control, releases the option list and both caller
buffers, and only then queries the retained semantic node through Talkback.
Compilation proves no aggregate loan survives the call; runtime assertions
prove the semantic tree owns its independent text copy. Literal-only fixtures
are not accepted as sufficient borrow evidence.
