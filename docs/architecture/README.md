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

The first experimental compiled slice now fixes the initial Zag shapes for
`NodeKey`, `State<T>`, `Binding<T>`, `Action`, `Environment`, `ViewContext`,
`ViewSpec`, and `RenderNode`. State reads record their reader and revision;
invalidation reports the exact read and revision edge; keyed reconciliation
preserves retained identity through reorder and fails visibly on duplicate
keys. Ownership, threading, serialization, typed environment values,
cancellation, and deterministic replay are still open contracts rather than
stable API.

The parallel experimental `SemanticsTree` retains owned names and values plus
roles, actions, focus order, live regions, ranges, selection, and text
navigation. Its stable `NodeKey` identity is shared with rendering, so future
accessibility adapters, semantic tests, and Zagkit Talkback automation can
query product meaning without reconstructing it from pixels.

Rendering begins with an experimental immutable `DisplayList`. Every operation
retains its owning `NodeKey`; paths, images, glyph runs, clips, transforms,
RGBA16 paints, layers, and effects remain explicit rather than backend calls.
Balanced lists seal with deterministic content identity, and verification
detects mutation outside the builder contract before rendering. Resource
storage, serialization, damage, the CPU oracle, and GPU transports remain open.

Display-list replay uses the versioned little-endian `ZKDL` codec. Decoding is
bounded to one million operations, reconstructs operations only through the
same validation path as live building, requires balanced seal state, verifies
the stored content identity and revision, and rejects trailing bytes so one
scene has one canonical encoding. Resource payload serialization remains open.

The CPU oracle begins with deterministic RGBA8 rectangle rasterization from
26.6 fixed-point geometry. Clip and positive axis-aligned transform state,
fractional edge coverage, and source-over alpha are integer-only. Every
unsupported display operation fails at its exact index instead of silently
degrading or claiming a visual result.
