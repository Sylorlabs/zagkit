# Architecture map

Zagkit separates product semantics from rendering transport and platform shell:

```text
Application views, state, actions, environment
                    |
          reconciliation and layout
             /                 \
     SemanticsNode tree      DisplayList
       /          \          /         \
accessibility  automation  CPU oracle  GPU transport
       \          /          \         /
      public platform input, lifecycle, and surface seams
```

The semantics and display trees are parallel outputs of the same retained view
state. Accessibility is not reconstructed from pixels. GPU transports do not
receive view nodes. Platform shells do not own component state.

Normative decisions:

- [product and platform](../rfcs/0001-product-and-platform-contract.md)
- [declarative core and rendering](../rfcs/0002-declarative-core-and-rendering.md)
- [text, semantics, and input](../rfcs/0003-text-semantics-and-input.md)
- [platform seams and backend truth](../rfcs/0004-platform-seams-and-backend-truth.md)
- [quality and release](../rfcs/0005-quality-and-release-contract.md)

Detailed experimental contracts:

- [intrinsic measurement and invalidation reasons](measurement.md)
- [Flex placement and adaptive spacing](flex.md)
- [motion scheduler and tracks](motion.md)
- [canonical vector paths](paths.md)
- [canonical decoded images](images.md)
- [deterministic PNG snapshot bytes](../quality/png-snapshots.md)

The first experimental compiled slice now fixes the initial Zag shapes for
`NodeKey`, `State<T>`, `Binding<T>`, `Action`, `Environment`, `ViewContext`,
`ViewSpec`, and `RenderNode`. State reads record their reader and revision;
invalidation reports the exact read and revision edge; keyed reconciliation
preserves retained identity through reorder and fails visibly on duplicate
keys. Ownership, threading, serialization, typed environment values,
cancellation and replay serialization are still open contracts rather than
stable API.

The retained intrinsic measurement tree aggregates leaf, row, column, and
overlay size ranges with exact gaps, padding, baselines, ownership, constraint
rules, overflow, and deterministic input/output identity. Revision witnesses
reject unstable intrinsic results, while `LayoutTrace` maps real state reads to
the exact node, ancestor, phase, and rule that must recompute. The full contract
and incomplete lifecycle boundaries are documented in
[measurement.md](measurement.md).

Flex extends fixed-point constraints with deterministic single-line and wrapped
row or column placement. Its primitive spacing scale adapts to density, safe
areas, text scale, breakpoints, and physical RTL without changing logical ID
order. Wrapped output retains line ranges, exact placement identity, and
fail-visible overflow or malformed input. See [flex.md](flex.md).

The parallel experimental `SemanticsTree` retains owned names, descriptions,
and values plus roles, actions, focus order, live regions, ranges, selection,
text navigation, fixed-point bounds, relationships, collection coordinates,
full collection counts, tree level, set position, and expansion truth. Virtual
Table and Tree output projects only live semantic descendants while preserving
the complete logical range on the root. Stable `NodeKey` identity is shared
with rendering, so accessibility adapters, semantic tests, and Zagkit Talkback
automation query product meaning without reconstructing it from pixels.

Rendering begins with an experimental immutable `DisplayList`. Every operation
retains its owning `NodeKey`; paths, images, glyph runs, clips, transforms,
RGBA16 paints, layers, and effects remain explicit rather than backend calls.
Balanced lists seal with deterministic content identity, and verification
detects mutation outside the builder contract before rendering. Owned resource
payloads participate in sealing and identity; damage and GPU transports remain
open.

The [render resource ownership layer](render-resources.md) copies typed payloads
behind positive stable IDs, canonicalizes insertion order,
enforces configurable byte and count ceilings, requires exact replacement
revisions, and verifies sealed byte-level identity. Display lists own the store.
Path resources additionally require the bounded canonical
[ZKPATH01 contract](paths.md) and are validated once before operation references
seal. Canonical decoded [RGBA8 images](images.md) also have exact dimensional,
schema, color-space, and payload-size validation. SVG, PNG, font, and glyph
decoding remain unavailable.

Display-list replay uses the versioned little-endian `ZKDL` version 2 codec.
Decoding is bounded to one million operations, reconstructs operations through the
same validation path as live building, requires balanced seal state, verifies
the stored content identity and revision, and rejects trailing bytes so one
scene has one canonical encoding. A bounded variable-length resource section
preserves allocation policy, typed metadata, revisions, and exact owned bytes.

The CPU oracle begins with deterministic RGBA8 rectangle fills, centered
rectangle strokes, canonical path fills, and canonical decoded image draws from
26.6 fixed-point geometry. Clip and positive axis-aligned transform state,
analytic rectangle coverage, 8 by 8 path coverage, non-zero and even-odd
winding, fixed curve flattening, premultiplied bilinear image sampling, and
source-over alpha are integer-only.
Explicit edge and work ceilings reject pathological path scenes before pixel
mutation. Every unsupported display operation fails at its exact index instead
of silently degrading or claiming a visual result.

The experimental input router consumes a parallel retained `HitTree`. It uses
integer affine inversion for local coordinates, resolves local clips and
z-order deterministically, and keeps pointer capture and focus explicit.
Accepted, missed, captured, cancelled, and invalid events share one ordered
evidence stream; platform input adaptation remains open.

The first deterministic replay executor consumes an immutable ordered tape of
state revisions, pointer events, monotonic clock samples, backend activation,
loss, and recovery. It rejects stale or impossible transitions at their exact
event index, then rebuilds a conformance scene through the real semantics,
motion, intrinsic measurement, Flex, display-list, and CPU-oracle paths. A
repeated tape must produce identical subsystem and aggregate hashes. A general
application callback contract, versioned tape codec, resource capture, and
platform lifecycle integration are still open.

The motion scheduler consumes an authoritative monotonic clock and advertises
the current refresh interval without deriving motion from callback count.
Integer fixed-step springs and owned keyframe timelines retain stable track
identity, exact position and velocity, explicit frame reasons, interruption,
reversal, resize retargeting, gesture handoff, and reduced-motion substitution.
Settled tracks request no further frame. The full contract and current limits
are documented in [motion.md](motion.md).
