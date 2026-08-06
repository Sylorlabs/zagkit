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
deterministic state, keyed reconciliation, geometry, Flex, semantics, Talkback,
display-list, CPU-oracle, input, replay, and motion slices. It does not yet
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
| Headless core | experimental state, reconciliation, geometry, Flex, semantics, Talkback, display lists, CPU raster, input, replay, and motion | [headless test](tools/test-headless.sh) |
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
fixed-point geometry, and single-line Flex. These APIs are experimental. Typed
environment values, reconciliation cancellation, child ownership, replay
serialization, intrinsic measurement, wrapping, grid, overlay, and breakpoints
remain open; the corresponding Milestone 2 checklist items are not complete.

The semantics slice owns copied names and values, stable keys, explicit action
capabilities, deterministic focus order, live-region state, ranges, selection,
and text-navigation bounds. Invalid parents, duplicate IDs and focus order,
malformed ranges, and malformed selections fail visibly before tree mutation.
Native accessibility adapters and the Zagkit Talkback protocol remain open.

The first in-process Zagkit Talkback dispatcher now resolves queries and emits
validated actions against those semantic IDs, rejects stale revisions and
unavailable actions, keeps pixel fallback disabled unless explicitly
advertised, applies recorded display scale to pixel bounds, and logs accepted
and rejected requests in one ordered stream.
It is not yet a native automation transport; the exact available and unavailable
surface is documented in [the protocol contract](docs/automation/talkback.md).

The immutable display-list slice records retained ownership, clips, transforms,
fixed-point geometry, RGBA16 paints, paths, images, glyph runs, layers, and
effects as explicit operations. Invalid geometry, resources, parameters, and
stack balance fail before mutation; the builder rejects writes after sealing,
and verification detects out-of-contract raw mutation against deterministic
content identity. Path/resource storage, resource serialization, damage, CPU
rasterization, and GPU transport remain open. The first versioned binary codec
now round-trips sealed lists byte-identically and rejects malformed, truncated,
noncanonical, unknown-version, and hash-mismatched input; schema evolution,
resource payloads, and fuzz coverage remain open.

The first CPU-oracle subset rasterizes fixed-point rectangle fills with exact
clip and axis-aligned transform state, area-based fractional edge coverage, and
deterministic source-over alpha into owned RGBA8 surfaces. Unsupported paths,
images, glyphs, strokes, skew, layers, and effects fail at the exact operation;
this subset is not yet the complete CPU renderer required by Milestone 2.

The first input slice resolves full affine transforms back to local coordinates,
honors local clips and z-order, rejects singular or malformed hit nodes, and
routes pointer phases through explicit capture and focus truth. Capture loss,
pointer-up release, stale targets, misses, and invalid pointers remain visible
in one ordered event stream. Keyboard, touch arbitration, wheel payloads,
gestures, and platform input adaptation remain open.

The first replay slice owns a sealed ordered tape for exact state revisions,
pointer phases, monotonic time, backend activation, device loss, and recovery.
Executing the same tape regenerates identical motion, semantic, Flex,
display-list, and CPU identities; raw mutation, stale revisions, clock
regression, and invalid backend transitions fail before they can become evidence. The current scene is
an executable conformance reference, not yet a general application callback
boundary or a versioned replay-file format, so `G2-REPLAY` remains open.

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
analysis. CI checks out the exact compiler revision from the toolchain contract
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
