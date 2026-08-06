# Delivery roadmap

The milestones are ordered by evidence dependency. Public previews may ship
incrementally. A milestone is complete only when every exit condition is linked
to executable evidence.

## 0. Product contract

**Status: implemented in this branch, pending review.**

- Separate Apache 2.0 repository and governance.
- Semantic version and honest experimental label.
- Accepted architecture, dependency, backend truth, semantics, and release
  RFCs.
- Machine readable platform matrix, component inventory, benchmark scene
  inventory, compiler pin, and upstream Zag prerequisite ledger.
- Executable contract validation in CI.
- Explicit visual direction and accessibility review gate.
- CI-checked master goal checklist covering Flex, Zagkit Talkback, visual and
  asset fidelity, and the complete PrismStudio overhaul.

This milestone creates no runtime support. Its completion cannot promote any
platform capability.

## 1. Advance Zag

**Status: blocked by the entries in
[contracts/upstream-zag.json](contracts/upstream-zag.json).**

Upstream native object targets and ABI seams for Darwin, Windows, iOS, Android,
Objective C, COM, JNI, callbacks, and aggregates. Add resource embedding,
dynamic platform loading, event loop and worker primitives, package resolution,
incremental compilation, and reload hooks. Every slice requires a Zag source
regression, native executable conformance on its target, cleanup evidence, and
affected Zagkit conformance.

## 2. Headless core

**Status: experimental foundation in progress.**

Strict native Zag contracts currently execute state and dependency tracking,
keyed reconciliation, bounded geometry, retained intrinsic measurement,
adaptive and wrapped Flex, semantics, ID-first in-process Talkback dispatch,
immutable display lists and their codec, a shape and image CPU-oracle subset,
transformed pointer routing, deterministic replay, and motion kernels. This is
real headless execution but does not satisfy the milestone exit gate yet.

Implement state dependencies, reconciliation, layout, semantics, immutable
display lists, deterministic CPU rasterization, Unicode and OpenType text,
animation clocks, input routing, hit testing, snapshots, and deterministic
replay without a window system. Exit requires unit, property, fuzz,
differential, golden, and replay gates.

Flex is the common placement and spacing system. Zagkit Talkback is built over
retained node and semantic identity with ID-first interaction and observable,
scale-aware pixel fallback. Fonts, semantic colors, SVG, PNG, lighting, soft
shadows, and adaptive liquid-glass materials are renderer and asset-pipeline
requirements, including designed reduced-effects variants.

## 3. Linux preview

**Status: not started.**

Implement Wayland first with X11 fallback, multi window and monitor handling,
fractional scaling, clipboard, IME, AT-SPI, CPU presentation, and one explicit
public GPU transport. Exit requires live native execution and fail closed
capability reporting on Ubuntu LTS and current Fedora baselines for x86-64 and
ARM64 where the compiler target exists.

Linux is the first polish reference: modern density-independent output, exact
spacing, crisp curves and assets, coherent motion and glass, native
accessibility, Talkback automation, recovery, screenshots at all declared
scales, and packaging must have no known severity-one or severity-two defects.

## 4. PrismStudio dogfood

**Status: not started.**

Replace the complete visible PrismStudio UI with Zagkit as the first complex
consumer. Preserve and modernize every CAD workflow, direct manipulation path,
table, tree, menu, keyboard command, dialog, viewport behavior, performance
contract, and explicit physical GPU safety boundary. Apply the selected Zagkit
direction, Flex spacing, production fonts and colors, SVG and PNG assets,
lighting, soft shadows, motion, and liquid-glass materials. Every actionable
node receives a stable Talkback ID. Native screenshot comparisons are required
alongside semantics, AT-SPI, interaction, recovery, and performance evidence.

## 5. Desktop parity

**Status: not started.**

Add macOS and Windows shells, desktop adaptation, native IME and accessibility,
menus, clipboard, drag and drop, packaging, signing, Metal, and D3D12. Public
betas require device execution with VoiceOver and Narrator plus recovery and
packaging gates.

## 6. Mobile parity

**Status: not started.**

Add iOS and Android shells, lifecycle restoration, rotation, safe areas,
touch-first navigation, gestures, soft keyboard, haptics, mobile accessibility,
Metal and Android GPU transports, packaging, and a focused reference app.
Public betas require device execution with VoiceOver and TalkBack.

## 7. All platform 1.0

**Status: blocked.**

Freeze the initial API only after the shared component suite, PrismStudio,
mobile reference app, international text, accessibility, recovery, performance,
native packaging, and reproducible release gates pass across Linux, macOS,
Windows, iOS, and Android. Unsupported and untested hardware stays visibly
unavailable.
