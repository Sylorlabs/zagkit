# Component state gallery

Status: `experimental`

`ComponentStateGallery` is a reusable headless conformance artifact for
Zagkit's canonical component hierarchy and interaction language. It proves the
rules that a design-system showcase must make inspectable: tier provenance,
state variants, non-color treatments, semantic truth, stable Talkback IDs, and
one shared Flex placement graph.

This artifact is deliberately separate from the Linux preview composition.
Consumers can inspect or host it without teaching a one-off screen how each
component should draw itself.

## Fixture matrix

Every specimen is emitted through its first-party component implementation.
State captions and control labels use the first-party `Text` renderer; the
gallery contains no placeholder bars, decorative status dots, fake icons, or
hand-drawn substitute controls.

| Family | Fixtures | Contract under test |
|---|---:|---|
| `Surface` hierarchy | 4 | `base`, `panel`, `raised`, and `overlay` material and elevation provenance |
| Actionable `Surface` | 8 | `rest`, `hover`, `focus`, `pressed`, `selected`, `disabled`, `loading`, and `error` |
| Secondary `Button` | 8 | the same eight canonical states, including real loading-content substitution |
| `NavigationItem` | 6 | `rest`, `hover`, `focus`, `pressed`, `selected`, and `disabled` |
| `SegmentedControl` | 4 options | selected, disabled, resting, and runtime focus-visible behavior in one real control |

The four hierarchy Surfaces are read-only evidence. Their canonical Surface
display and group semantics are retained, while the component's disabled
inspection-only scratch hit is intentionally not published into the gallery.
They therefore expose no gallery hit and no semantic action. The state
Surfaces, Buttons, NavigationItems, and SegmentedControl are explicit
interactive specimens with canonical hits and actions backed by
`ComponentStateGalleryRuntimeState`. Every accepted activation increments
`activation_count`, records `last_activated`, and advances `revision`. Disabled
and loading specimens remain discoverable by ID but have no semantic action,
have disabled hit nodes, and are rejected by the reducer without changing an
outcome.

## Visible state is semantic state

The matrix does not ask color alone to explain the system. Across the canonical
components, the contract checks the state model, resolved token changes,
semantic flags, action availability, and each non-color treatment the
component actually defines, including:

- Surface hover marker and Button/Navigation hover token resolution;
- keyboard-visible focus ring;
- depressed pressed chrome;
- persistent selected marker;
- disabled treatment and unavailable action;
- loading progress substitution; and
- recoverable-error treatment.

This is not a claim that every component draws every listed geometry. For
example, Button hover is a resolved fill/border change rather than Surface's
trailing marker. The test verifies each family against its own first-party
state contract instead of inventing a showcase-only indicator.

Each fixture has an uppercase visible `Text` caption such as `HOVER` or
`DISABLED`. Its component semantic value also describes the fixture state. The
control label remains the control's accessible name, so a screen reader does
not have to infer the state from paint or from a nearby decorative object.

A retained `SemanticsTree` permits at most one live focused node. Consequently,
the Surface, Button, and NavigationItem focus examples are explicitly labelled
*focus styling snapshots*: their first-party focus rings are retained, but
their hosted semantic `focused` field is cleared and their value is
`Focus fixture`. The native-default runtime starts with `focused = none`, so
the complete tree reports zero live focus. Pointer or keyboard reduction may
assign one enabled component or segment; only that exact ID then publishes
`focused = 1`. This preserves visual comparison without fabricating native
focus or publishing an impossible multi-focus accessibility tree.

The segmented model is not a row of tags. Option zero is selected, option two
is disabled, and options one and three are enabled at rest. A keyboard focus
transition to option one followed by canonical `key_next` skips the disabled
option, selects and focuses option three, and records option three as an
observable activation.

Semantic insertion follows visual reading order: title, section heading, that
section's captions and controls, then the next heading. The five headings are
not emitted as a detached block ahead of the fixtures.

## Runtime state and reducers

The gallery does not infer interaction from its paint. Hosts own a
`ComponentStateGalleryRuntimeState` containing `hovered`, `pressed`, `focused`,
`focus_visible`, the canonical `SegmentedControlModel`, `last_activated`,
`activation_count`, and `revision`. Start native hosting with
`component_state_gallery_runtime_state_default()`, send typed events through
`component_state_gallery_reduce`, then rebuild with
`component_state_gallery_build_with_state`.

`component_state_gallery_runtime_state_valid` checks that transient and focus
IDs name enabled gallery controls, that segment IDs agree with the nested
segmented model, and that focus visibility cannot exist without focus.
`component_state_gallery_runtime_state_hash` is deterministic and is included
in the artifact evidence hash. Accepted transitions advance revision exactly
once; rejected disabled, loading, read-only, or invalid-target transitions
leave the input state unchanged.

`component_state_gallery_build_frozen_conformance` exists only for a fixed
inspection fixture that preserves the earlier focus-visible segmented example.
It is marked by `artifact.frozen_conformance = 1`. Native routes must use the
zero-focus default or application-owned runtime state, never the frozen wrapper.

## One Flex authority

`component_state_gallery_layout` is the only placement authority. An outer
Flex column owns the title and five sections; nested Flex columns own headings
and content; repeated rows own fixture cells; each cell owns its caption and
component rectangle. Component display bounds, hit bounds, semantic bounds,
and Talkback geometry all come from those recorded placements.

The graph uses named `FlexSpacingToken` values and supports compact, standard,
and touch density plus LTR and RTL direction. Its exact useful bounds are:

| Density | Minimum width | Required height |
|---|---:|---:|
| compact | `1044` | `1119` |
| standard | `1072` | `1192` |
| touch | `1100` | `1265` |

The default contract uses `1440 x 1280`. RTL mirrors gallery Flex row order
without changing any ID. `SegmentedControlSpec` does not yet expose layout
direction, so its internal option geometry remains LTR; this artifact does not
claim otherwise. The artifact intentionally has no responsive column-count
mode: it keeps four columns for hierarchy, Surface, and Button rows and three
columns for NavigationItem rows, then fails closed below the useful width.
Hosts that offer a narrower viewport must use a canonical scroll or viewport
primitive rather than silently shrinking targets or inventing another layout.

One logical unit below either minimum fails with `layout_overflow` before any
display, hit, or semantic contribution is published.

## Stable identity and Talkback

Given root key `R`, child values are derived as `R.value * 10000 + offset` and
preserve `R.generation`:

| Node | Offset |
|---|---:|
| title | `100` |
| section heading `i` | `200 + i` |
| hierarchy Surface `i` | `1000 + i * 10` |
| hierarchy caption `i` | `1001 + i * 10` |
| state Surface `i` | `2000 + i * 10` |
| state caption `i` | `2001 + i * 10` |
| Button `i` | `3000 + i * 10` |
| Button caption `i` | `3001 + i * 10` |
| NavigationItem `i` | `4000 + i * 10` |
| NavigationItem caption `i` | `4001 + i * 10` |
| SegmentedControl group | `5000` |
| segment option `i` | `5010 + i` |

The same component ID owns display operations, the hit node, the semantic node,
and Talkback query/action lookup. Captions have their own stable IDs. The
contract proves that Talkback resolves and emits an action for an enabled
specimen, queries selected and focused flags, and rejects disabled or read-only
activation without falling back to pixel coordinates. Emitting an action is
not itself an outcome: the host feeds the resolved ID through the gallery
reducer, retains the resulting state, and rebuilds. Tests prove that this path
changes activation evidence rather than claiming completion from dispatch
alone.

## Retained output and failure behavior

A successful zero-focus default gallery and frozen conformance fixture both
have the following exact retained shape:

- 61 real `Text` artifacts and 61 OpenType path resources;
- 407 display operations in one sealed immutable `DisplayList`;
- 27 hit nodes;
- 64 semantic nodes, of which 32 are independently named text nodes; and
- deterministic display, hit, Talkback, CPU-raster, and aggregate evidence
  hashes for identical inputs.

Component output is first built into isolated scratch display, hit, and
semantic trees. Hosting preflights the expected shape, reparents semantics under
the gallery root, and checkpoints all three retained destinations. Duplicate
IDs or any display, hit, or semantic error roll every destination back to its
prior length, revision, hash, and error state. The SegmentedControl plus its
four Text labels is one larger transaction: a late label/resource failure also
releases previously contributed path payloads and restores counters and focus
state. Missing fonts, invalid root IDs, and undersized layouts similarly fail
before partial output is exposed.

Always call `component_state_gallery_free` on successful and failed artifacts.
The caller continues to own and eventually free the borrowed `OpenTypeFace`.

## Verification

Run the focused contract with a Zag-owned OpenType input:

```sh
tools/test-component-state-gallery.sh
```

The runner compiles with strict resource analysis and no `zagd` or foreground
cache. The contract covers the complete fixture matrix, token and treatment
truth, exact geometry, zero native-default focus, one real runtime focus owner,
observable enabled activations, rejected unavailable actions,
SegmentedControl input reduction, Talkback action dispatch, touch-density RTL,
deterministic CPU rasterization, atomic scratch-host rollback, invalid runtime
truth, invalid identity, missing font, and one-unit overflow boundaries.

This artifact is headless proof, not Linux platform certification. It does not
claim native event delivery, assistive-technology bridging, GPU equivalence,
animation behavior, international bidi shaping, or final visual-direction
approval. Those require their own live platform and visual gates.
