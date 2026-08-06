# Zagkit

Zagkit is a first party application platform and UI toolkit built in Zag. It is
being designed for one adaptive product codebase across Linux, macOS, Windows,
iOS, and Android, with precise text, fluid interaction, built in semantics, and
inspectable runtime truth.

The durable, CI-checked execution plan is the [master goal checklist](GOAL.md).
It includes the Flex placement system, Zagkit Talkback native automation,
modern materials and asset fidelity, and a complete PrismStudio UI replacement.

This repository is at **0.1.0-experimental.0**. It currently contains the
accepted product contract, executable Milestone 0 checks, and the first
deterministic state, keyed reconciliation, geometry, intrinsic measurement,
Flex, Grid, Overlay, scroll, virtual-list, semantics, Talkback, display-list,
CPU-oracle, input, replay, and motion
slices. It does not yet
contain a usable renderer, window shell, component library, or supported platform
backend. Nothing in this repository is a Zagkit 1.0 release.

## What Zagkit owns

Zagkit will own the declarative view model, state tracking, reconciliation,
layout, semantics, input, animation, text, display lists, CPU rendering,
components, and developer tools. Public operating system APIs are narrow seams
for lifecycle, surfaces, input methods, accessibility, GPU submission, and
packaging. They do not define Zagkit's architecture.

The deterministic CPU renderer will be the visual oracle. Metal, D3D12, and
public Linux and Android GPU APIs will carry a Zag owned render IR. Backend
selection, fallback, and device loss will always be observable through a
capability record.

Zagkit is not a wrapper around native widgets and will not ship Skia, Flutter,
Qt, FreeType, HarfBuzz, a browser, or a WebView as its UI engine. System fonts
and published Unicode and OpenType data are allowed inputs. The exact boundary
is normative in [DEPENDENCIES.md](DEPENDENCIES.md).

## Status

| Area | Current state | Proof |
|---|---|---|
| Product and architecture contract | accepted | [RFC index](docs/rfcs/README.md) |
| Compiler dependency | pinned, prerequisites incomplete | [toolchain lock](contracts/toolchain.json) |
| Platform shells | unavailable | [support matrix](SUPPORT.md) |
| Headless core | experimental state, reconciliation, intrinsic measurement, geometry, Flex, Grid, Overlay, scroll, virtual collections, collection semantics, Talkback, canonical paths and images, display lists, CPU raster, input, replay, and motion | [headless test](tools/test-headless.sh) |
| Components and visual language | inventory only, visual review pending | [component inventory](contracts/components.json) |
| Flex and Zagkit Talkback | Flex foundation and in-process ID-first Talkback dispatch executing; native transport remains unavailable | [Talkback contract](docs/automation/talkback.md) |
| Benchmarks | scene specifications only, no results | [benchmark contract](benchmarks/README.md) |

Run the repository contract gate with:

```sh
./tools/check-contracts.sh
```

The gate validates the release identity, exact Zag revision, required platform
families, backend truth states, upstream prerequisite ledger, component
inventory, benchmark scene coverage, and the 1.0 block.

The compiled headless contract currently provides revisioned `State<T>`,
action-producing `Binding<T>`, inherited integer environment values, exact
per-node state-read records, fail-visible keyed reconciliation, deterministic
fixed-point geometry, and single-line or wrapped Flex. These APIs are
experimental. A retained intrinsic tree now aggregates leaf, row, column, and
overlay size ranges, rejects invalid ownership and unstable same-revision
measurement, resolves constraints with explicit rules and overflow, and records
exact state-read layout causes. Typed environment values, reconciliation
cancellation, general retained child lifecycle, replay serialization, editable
collection behavior, and full breakpoint policy remain open; the corresponding Milestone
2 checklist items are not complete. See the
[measurement contract](docs/architecture/measurement.md).

Flex now also provides an experimental primitive spacing scale, compact,
standard, and touch density resolution, physical safe-area composition,
text-scale-aware compact/medium/expanded breakpoints, and deterministic row or
column wrapping. Wrapped lines preserve logical stable-ID order while resolving
physical RTL placement, per-line growth and shrinkage, baseline-safe extents,
line alignment, overflow truth, and layout identity. These are headless
placement primitives rather than the still-unselected visual design language.
Grid now resolves fixed, intrinsic, and weighted fraction tracks, spans,
row-major auto placement, explicit collision policy, baseline placement,
content distribution, quantified overflow, and logical RTL columns. Overlay
resolves intrinsic containers, padding, child insets, alignment, z-order,
baseline output, overflow, and RTL start/end. Both contribute deterministic
identity to replay. End-to-end retained invalidation coverage and the full
adaptive matrix remain open, so `G2-FLEX` and `G2-FLEX-RTL` are not complete.
See the [Flex contract](docs/architecture/flex.md) and
[Grid and Overlay contract](docs/architecture/grid-and-overlay.md).

Scroll now retains exact logical offsets, consumed and unconsumed gesture
deltas, reveal alignment, anchor-preserving content reconciliation, RTL visible
coordinates, revisions, and deterministic identity. Virtual List performs
binary visible-range selection across up to one billion stable IDs, supports
sparse variable extents and anchor correction, and hard-limits live placement
allocation. The focused proof queries the middle of one million rows with nine
live placements and fewer than 64 examined records. This is correctness and
bounded-work evidence, not a 120 Hz hardware result. See the
[scroll and virtualization contract](docs/architecture/scroll-and-virtualization.md).

Table now composes bounded row and column virtualization with pinned logical
columns, exact resize consumption, composite stable cell IDs, RTL placement,
and hard cell residency limits. Tree validates preorder ownership and expansion
before projecting collapsed descendants into the virtual range. A retained
recycling store preserves offscreen focus and restores the exact instance and
generation when its logical ID returns. These identities participate in replay.
Sorting, selection, editing, drag reordering, component semantics, and native
interaction remain open.

The semantics slice owns copied names, descriptions, and values; stable keys;
logical bounds; label, description, and control relationships; explicit action
capabilities; deterministic focus order; live-region state; ranges; selection;
text navigation; collection coordinates and counts; tree levels; set position;
and expansion truth. Invalid geometry, dangling relationships, collection
metadata, parents, IDs, focus order, ranges, and selections fail visibly before
tree mutation. Virtual Table and Tree projection retain full logical counts
while materializing only live semantic rows and cells. Composite collection
identities are deterministically mapped to `NodeKey` and collision-preflighted
before any tree mutation. Native accessibility adapters remain open.

The in-process Zagkit Talkback dispatcher resolves queries and emits validated
actions against those semantic IDs. Query responses expose role, actions,
fixed-point bounds, collection coordinates and counts, tree state, owned-text
lengths, state flags, and a deterministic semantic evidence hash. Dispatch
rejects stale revisions and unavailable actions, keeps pixel fallback disabled
unless explicitly advertised, applies recorded display scale to pixel bounds,
and logs accepted and rejected requests in one ordered stream.
It is not yet a native automation transport; the exact available and unavailable
surface is documented in [the protocol contract](docs/automation/talkback.md).

The immutable display-list slice records retained ownership, clips, transforms,
fixed-point geometry, RGBA16 paints, paths, images, glyph runs, layers, and
effects as explicit operations. Invalid geometry, resources, parameters, and
stack balance fail before mutation; the builder rejects writes after sealing,
and verification detects out-of-contract raw mutation against deterministic
content identity. An integrated experimental resource store owns opaque typed
payload bytes with stable IDs, canonical order, bounded allocation, exact
replacement revisions, sealing, and mutation verification. Display-list seal
requires every reference to resolve the exact resource kind. Path resources use
a bounded immutable command builder and canonical `ZKPATH01` version 1 payload;
fill rules, moves, lines, quadratic and cubic curves, contour closure, sequence,
geometry, identity, truncation, and trailing bytes are validated before use.
The version 2
binary codec round-trips resource metadata, payloads, revisions, allocation
policy, and operations byte-identically and rejects malformed, truncated,
noncanonical, unknown-version, and hash-mismatched input. Scale-adaptive path
coverage, encoded image and glyph interpretation, damage, complete CPU
rasterization, GPU transport, schema evolution, and fuzz coverage remain open.
See the [path contract](docs/architecture/paths.md) and
[image contract](docs/architecture/images.md).

The first CPU-oracle subset rasterizes fixed-point rectangle fills, centered
rectangle strokes, and canonical path fills with exact clip and axis-aligned
transform state, analytic rectangle coverage, deterministic 8 by 8 path
coverage, non-zero and even-odd winding, bounded curve flattening, and
source-over alpha into owned RGBA8 surfaces. Path edge and work budgets fail
before pixel mutation. Canonical decoded sRGB RGBA8 images render with exact
one-to-one texels, premultiplied bilinear scaling, fractional-edge coverage,
clip and transform state, and operation opacity. Unsupported color conversion,
glyphs, path strokes, skew, layers, and effects fail at the exact operation;
this subset is not yet the complete CPU renderer required by Milestone 2.

Verified CPU surfaces now serialize to deterministic PNG snapshot bytes with
an explicit sRGB chunk, exact RGBA8 rows, valid CRC32 chunks, and a pure-Zag
stored-zlib IDAT stream. Identical pixels produce byte-identical files without
timestamps or host metadata. Persistence, manifests, golden comparison,
Talkback evidence bundles, and native screenshot capture remain open, so this
does not yet claim the snapshot runner or screenshot release gate. See the
[PNG snapshot contract](docs/quality/png-snapshots.md).

The first input slice resolves full affine transforms back to local coordinates,
honors local clips and z-order, rejects singular or malformed hit nodes, and
routes pointer phases through explicit capture and focus truth. Capture loss,
pointer-up release, stale targets, misses, and invalid pointers remain visible
in one ordered event stream. Keyboard, touch arbitration, wheel payloads,
gestures, and platform input adaptation remain open.

The first replay slice owns a sealed ordered tape for exact state revisions,
pointer phases, monotonic time, backend activation, device loss, and recovery.
Executing the same tape regenerates identical motion, semantic, measurement,
Flex, display-list, and CPU identities; raw mutation, stale revisions, clock
regression, and invalid backend transitions fail before they can become
evidence. The current scene is an executable conformance reference, not yet a
general application callback boundary or a versioned replay-file format, so
`G2-REPLAY` remains open.

The experimental motion kernel uses supplied monotonic microseconds and the
same 26.6 logical units as layout. Its refresh-aware scheduler records why
frames exist, stops requesting frames when every track settles, and refuses
clock advances that would skip live motion. Fixed-step integer springs preserve
position and velocity through interruption, reversal, resize, and gesture
handoff. Owned keyframe timelines expose exact segment velocity. Reduced motion
uses explicit snap or bounded opacity-fade substitutions rather than a global
duration multiplier. Layout/shared-transition orchestration, easing curves,
platform vsync adapters, retained event-log bounds, and performance evidence
remain open, so `G3-MOTION` and `G3-REDUCED-MOTION` are not complete. See the
[motion contract](docs/architecture/motion.md).

Run the deterministic headless foundation test with:

```sh
./tools/test-headless.sh
```

The script compiles every executable contract with strict Zag semantic
analysis. CI checks out the exact compiler revision from the toolchain contract,
self-hosts that pinned source to a byte-identical compiler fixed point, and runs
the same suite before validating repository metadata. The committed upstream
seed is bootstrap authority, not evidence that it already contains later
compiler-source fixes.

CI allows 30 minutes for a cold fixed-point rebuild and caches only `znc` and
`zagd` under the exact operating system and Zag source SHA. A source-revision
change cannot reuse an older compiler cache; warm runs still execute every
strict Zagkit contract.

## Build order

1. Advance reusable compiler, ABI, concurrency, package, and platform features
   in [Zag](https://github.com/Sylorlabs/zag), each with native executable proof.
2. Build Zagkit's deterministic headless core.
3. Ship a polished Linux reference, then completely rebuild PrismStudio's UI on Zagkit.
4. Reach desktop parity on macOS and Windows.
5. Reach mobile parity on iOS and Android.
6. Call the shared product 1.0 only after all five families pass the same gate.

See [ROADMAP.md](ROADMAP.md) for milestone exit conditions and
[CONTRIBUTING.md](CONTRIBUTING.md) before proposing implementation work.

## License

Apache License 2.0. See [LICENSE](LICENSE).
