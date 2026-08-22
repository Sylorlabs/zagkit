# Dependency and ownership boundary

Zagkit is built in Zag and owns the product layers above public operating system
and driver seams. This policy is normative.

## Zagkit owned layers

- state, bindings, actions, environment, view context, and stable node identity;
- reconciliation, layout, invalidation reasons, hit testing, and focus;
- semantics and automation trees;
- input routing, gestures, commands, animation, and frame scheduling;
- Unicode processing, OpenType shaping, font fallback, editing, and glyph
  rasterization;
- render IR, immutable display lists, deterministic CPU rendering, GPU resource
  ownership, and backend recovery;
- components, design tokens, adaptive behavior, inspectors, preview, reload,
  snapshots, and command line tools.

## Allowed operating system seams

Public OS and GPU APIs may provide lifecycle, windows, surfaces, vsync, GPU
submission, IME, accessibility, clipboard, drag and drop, system menus, haptics,
notifications, and packaging. System fonts plus published Unicode and OpenType
data are allowed inputs.

These seams must be isolated behind Zag interfaces, report capability truth,
clean up resources, and have native conformance tests. A platform seam does not
own Zagkit's view tree, layout, semantics, text model, or renderer architecture.

## Prohibited runtime architecture

The core and platform product may not depend on:

- native widget proxy frameworks;
- browser or WebView runtimes;
- Skia, Flutter, Qt, FreeType, HarfBuzz, or another UI, text, or render engine;
- private Apple APIs;
- an LLVM based renderer;
- a C, C++, Zig, Rust, or other foreign implementation shim used to hide a Zag
  compiler or runtime gap.

Host tools used only to package, sign, drive a platform SDK, or validate
repository metadata are not runtime dependencies. They must be declared,
versioned where practical, and cannot implement product behavior.

## Source first rule

A reusable Zag language, compiler, ABI, concurrency, package, platform, or
runtime defect is fixed in the Zag repository with native conformance before
Zagkit consumes it. Zagkit may keep a failing reproducer and dependency record,
but not a permanent workaround. The upstream change is checked in separately,
and Zagkit pins the exact proven commit before relying on it. Patterns that
would normally be hidden behind a shim, reduced feature, unsafe escape, or
ecosystem workaround in another language are still Zag defects to solve at the
source. The authoritative queue is
[contracts/upstream-zag.json](contracts/upstream-zag.json).

Vendor driver replacement can remain experimental and does not block 1.0.
Supported public GPU transports and the CPU visual oracle remain authoritative.
