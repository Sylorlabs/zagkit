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

**Status: not started.**

Implement state dependencies, reconciliation, layout, semantics, immutable
display lists, deterministic CPU rasterization, Unicode and OpenType text,
animation clocks, input routing, hit testing, snapshots, and deterministic
replay without a window system. Exit requires unit, property, fuzz,
differential, golden, and replay gates.

## 3. Linux preview

**Status: not started.**

Implement Wayland first with X11 fallback, multi window and monitor handling,
fractional scaling, clipboard, IME, AT-SPI, CPU presentation, and one explicit
public GPU transport. Exit requires live native execution and fail closed
capability reporting on Ubuntu LTS and current Fedora baselines for x86-64 and
ARM64 where the compiler target exists.

## 4. PrismStudio dogfood

**Status: not started.**

Migrate PrismStudio as the first complex consumer. Preserve CAD workflows,
direct manipulation, tables, menus, keyboard control, viewport behavior,
performance evidence, and its explicit physical GPU safety boundary. The
component gallery remains a conformance surface; PrismStudio is the product
proof.

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
