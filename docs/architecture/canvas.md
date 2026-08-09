# Canvas retained and immediate drawing contract

Status: experimental headless component primitive

`Canvas` is Zagkit's public immediate drawing escape hatch. It lets a retained
view such as a CAD viewport record paths, images, glyph runs, clips, transforms,
layers, and effects without inventing an application-owned rendering or input
subsystem. It does not bypass Zagkit's display-list validation, resource
ownership, semantics, hit testing, limits, or deterministic replay.

The implementation is [`src/components/canvas.zag`](../../src/components/canvas.zag).
The focused executable proof is
[`tests/canvas_contract.zag`](../../tests/canvas_contract.zag).

## Retained identity and immediate frames

Every Canvas is created with one positive, stable `NodeKey`. That exact key is
used for:

- the retained `ViewSpec` returned by `canvas_retained_spec`;
- every contributed `DisplayOp.owner`;
- the Canvas `SemanticsNode`;
- the Canvas `HitNode`; and
- namespacing local render-resource IDs.

A Canvas value owns one immediate frame. Record commands and resources, call
`canvas_seal`, consume its immutable contributions, and finally call
`canvas_free` exactly once. Build the next frame with the same `NodeKey`.
`canvas_retained_spec` then lets reconciliation reuse the existing
`RenderNode`; a changed frame updates its fingerprint instead of replacing its
identity.

This frame model deliberately has no mutable resource replacement API. Resource
payloads and operations cannot change after sealing. Rebuild a frame under the
same key when viewport content changes.

## Minimal API

```zag
@import("src/components/canvas.zag")

let spec: CanvasSpec = canvas_spec(
    node_key_scoped(4100, window_generation),
    rect(0, 0, viewport_width, viewport_height),
    CanvasSemanticsPolicy.named_group,
    "Model viewport",
);
spec.description = "Interactive assembly editing surface";
spec.hit_testable = 1;
spec.focusable = 1;
spec.focus_order = 4;
spec.transform.translate_x = viewport_x;
spec.transform.translate_y = viewport_y;

let canvas: Canvas = canvas_make(spec, canvas_limits_default());

let background: DisplayOp = canvas_op(canvas, DisplayOpKind.fill_rect);
background.bounds = spec.bounds;
background.paint = paint_rgba16(4000, 5000, 7000, 65535);
_ = canvas_push(&canvas, background);

if (canvas_seal(&canvas) == CanvasError.none) {
    _ = canvas_contribute_display(&canvas, &frame_display_list);
    _ = canvas_contribute_semantics(&canvas, &semantics_tree);
    _ = canvas_contribute_hit(&canvas, &hit_tree);
}

_ = canvas_free(&canvas);
```

Production code must inspect every returned `CanvasError`. `last_error` plus
`display_error`, `resource_error`, `semantics_error`, `hit_error`,
`error_index`, and `error_resource_id` preserve the exact failing boundary.

## Bounds, clip, and transform

Geometry uses Zagkit's signed 26.6 fixed-point logical units. `bounds` and an
optional `clip` are Canvas-local. A declared clip must be positive and wholly
inside bounds; no implicit intersection hides malformed geometry. Even without
an explicit clip, Canvas content is clipped to bounds.

`transform` maps local coordinates into the parent/window coordinate space.
Display contribution emits one explicit sequence:

1. `save`;
2. `concat_transform`;
3. `clip_rect` using the effective local clip;
4. the sealed immediate operations; and
5. `restore`.

The transformed clip's axis-aligned bounds become the semantic bounds. Singular,
unsafe, zero-area, or out-of-range interactive transforms fail during Canvas
construction. `canvas_local_from_world` uses the same affine inverse and clip
rules as `HitTree`, so platform input and declared Canvas pixel fallback cannot
disagree about local coordinates.

## Semantics policy

Every Canvas must select exactly one policy:

| Policy | Semantic output | Requirements |
|---|---|---|
| `named_image` | visible `SemanticRole.image` | nonempty accessible name |
| `named_group` | visible `SemanticRole.group` | nonempty accessible name |
| `decorative` | hidden, unnamed `SemanticRole.group` | no name, description, hit target, or focus |

An interactive CAD viewport should normally be a `named_group`. A read-only
rendered preview may be a `named_image`. Decoration is explicit rather than
implemented by omitting semantic truth. A decorative Canvas cannot silently
become an agent-controlled pixel target.

Setting `focusable` requires `hit_testable` and a positive `focus_order`; Canvas
then emits the same focus capability to semantics and hit testing. More detailed
viewport controls, selections, handles, and actions should be semantic child
nodes with their own stable IDs rather than one opaque Canvas action.
When the Canvas is disabled, it remains discoverable with disabled semantic
state but exposes no focus action and cannot win hit testing.

Zagkit Talkback should target those IDs first. Scale-aware pixel fallback is
appropriate only for direct coordinates inside a declared Canvas and must be
reported as pixel fallback, never as an ID action.

## Resource ownership

Use `CanvasResourceSpec` and `canvas_add_resource`. `local_id` is positive and
stable within the Canvas. `canvas_resource_id(canvas.key, local_id)` derives the
positive display-list resource ID; `canvas_resource_op` records that identity
on a resource-backed operation.

Canvas copies caller payload bytes immediately. Display contribution copies
the sealed Canvas resources again into the destination `DisplayList`, so the
destination stays valid after `canvas_free`. The destination rejects a scoped
ID collision before any contribution operation or resource is added. Resource
kind, format, dimensions, color space, payload size, canonical path/image
payload, and referenced-resource validation remain the existing
`RenderResourceStore` and `DisplayList` contracts.

This copy-owned experimental contract favors deterministic lifetime truth over
zero-copy upload. Future cache or transport work may optimize storage without
weakening ownership, identity, or replay.

## Display contribution and failure atomicity

`canvas_contribute_display` requires a sealed, verified Canvas and an unsealed
destination. Before mutation it checks:

- destination seal and resource-store state;
- operation count;
- resource count, total bytes, and per-payload bytes; and
- every resource-ID collision.

All contract-defined destination failures therefore leave the destination
unchanged. A successful contribution remains unsealed so the parent can append
other retained nodes before sealing the complete frame.

Semantics and hit contributions use the transactional add behavior of their
respective trees. Missing parents, duplicate IDs, duplicate focus order, or
invalid tree state remain visible without a partial node.

## Deterministic replay

`canvas_replay_hash` verifies the sealed display list and then returns an
identity covering:

- `NodeKey`, parents, bounds, clip, transform, and z-order;
- semantic policy, owned name and description, focus, hit, and enabled state;
- allocation and destination-operation limits; and
- the complete sealed display-list resource and operation identity.

Identical Canvas frames produce the same hash. A key generation, semantic,
geometry, paint, command, resource, or limit change changes it. Raw mutation of
sealed operations or resources makes verification fail and returns no replay
hash.

## Fail-closed limits

`canvas_limits_default` currently resolves to:

| Limit | Default | Hard ceiling |
|---|---:|---:|
| Immediate operations | 262,144 | 1,000,000 |
| Owned resources | 4,096 | 65,536 |
| Total owned resource bytes | 256 MiB | 512 MiB |
| One resource payload | 32 MiB | 64 MiB |
| Parent operations after contribution | 1,000,000 | 1,000,000 |
| Accessible name bytes | 4,096 | 4,096 |
| Accessible description bytes | 16,384 | 16,384 |

Nonpositive resource IDs, malformed UTF-8 or embedded-NUL semantic text,
invalid flag states,
foreign operation owners, malformed geometry, singular transforms, unbalanced
display state, unsupported resource payloads, and writes after sealing all fail
before the rejected mutation. Borrowed semantic text and limits are validated
before any proportional copy is allocated. Existing stricter path, image,
CPU-raster, and codec limits still apply.

## Current boundaries

This contract is a headless component primitive, not a platform or renderer
completion claim:

- it does not make currently unsupported CPU or GPU display operations work;
- it does not provide a native Talkback transport, IME, AT-SPI, or window input;
- it does not grant physical-GPU execution or weaken PrismStudio's explicit GPU
  certification boundary;
- it does not infer semantic children from pixels;
- it is not thread-safe and does not accept arbitrary callbacks; and
- it does not make unbounded frame allocation acceptable.

The CPU oracle and public backend capability record remain authoritative.

## PrismStudio integration order

The first PrismStudio bridge should keep the existing CAD domain and viewport
algorithms while replacing application-owned UI seams:

1. Assign the viewport a stable app/window-scoped `NodeKey` and use
   `named_group` with an explicit Talkback ID mapping.
2. Feed the viewport's canonical CPU output through Canvas display operations
   and owned path/image resources. Do not borrow framebuffer pointers or add a
   sibling-path/package workaround.
3. Contribute Canvas display, semantics, and hit nodes to the same Zagkit frame.
4. Route pointer coordinates through `canvas_local_from_world`; keep ordinary
   tools, buttons, selections, and commands ID-addressable, with pixel fallback
   limited to declared viewport coordinates.
5. Compare Canvas CPU output to PrismStudio's current CPU oracle before changing
   transport or enabling any separately authorized GPU path.
6. Preserve the current GPU safety policy and run focused Canvas, PrismStudio
   CPU/X11, semantics, Talkback, screenshot, and cleanup gates before removing
   the legacy viewport host.

The focused contract compiles with Zag strict analysis and covers retained
reuse, replay mutation detection, transformed display/semantic/hit agreement,
all three semantic policies, resource lifetime independence, transactional
destination failures, malformed construction, bounded allocation, and repeated
cleanup. It is correctness evidence, not native accessibility, visual fidelity,
120 Hz, or release certification.
