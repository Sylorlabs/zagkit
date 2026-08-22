# Zagkit execution checklist (agent-facing)

- Generated: 2026-08-09T08:59:06-07:00
- Source of truth: GOAL.md
- Evidence inputs: GOAL.md, contracts/upstream-zag.json, contracts/platforms.json

## Blocked items, in checklist order

### 0. Repository and product contract
- [ ] `G0-VISUAL-DIRECTION`: blocked until full visual-matrix + RFC 0007 acceptance and recommendation packet exist

### 1. Advance Zag at the source
- [ ] `G1-LINUX-ARM64`: upstream prerequisite `target-linux-arm64` is `partial`: zag-poc/VERSIONING.md marks ARM64 Linux experimental and cites qemu-user execution, while unsupported numeric, debug, and call cases remain and no physical ARM64 evidence is recorded.
- [ ] `G1-DARWIN`: upstream prerequisite `target-darwin-macho` is `missing`: zag-poc/VERSIONING.md calls macOS not planned yet and requires a Mach-O backend.
- [ ] `G1-WINDOWS`: upstream prerequisite `target-windows-pe-coff` is `missing`: zag-poc/VERSIONING.md calls Windows not planned and requires a PE/COFF backend.
- [ ] `G1-IOS`: upstream prerequisite `target-ios-arm64` is `missing`: No iOS target or native conformance suite exists at the pinned commit.
- [ ] `G1-ANDROID`: upstream prerequisite `target-android-arm64` is `missing`: No Android target or native conformance suite exists at the pinned commit.
- [ ] `G1-OBJC`: upstream prerequisite `abi-objective-c` is `missing`: No Objective C runtime ABI implementation or native conformance exists at the pinned commit.
- [ ] `G1-COM`: upstream prerequisite `abi-com` is `missing`: No COM ABI implementation or native conformance exists at the pinned commit.
- [ ] `G1-JNI`: upstream prerequisite `abi-jni` is `missing`: No JNI ABI implementation or native conformance exists at the pinned commit.
- [ ] `G1-CALLBACKS`: upstream prerequisite `abi-callbacks` is `partial`: The pinned v2 ABI documents executable qsort evidence for one direct captureless scalar and pointer callback, while captures, returned callbacks, floats, aggregates, ownership, and unload contracts remain unsupported.
- [ ] `G1-AGGREGATES`: upstream prerequisite `abi-aggregates` is `missing`: No general foreign aggregate parameter and return ABI conformance exists at the pinned commit.
- [ ] `G1-FFI-LIFETIMES`: requires downstream implementation and native evidence
- [ ] `G1-RUNTIME-RESOURCES`: requires downstream implementation and native evidence
- [ ] `G1-RESOURCES`: upstream prerequisite `resource-embedding` is `partial`: The exact clean pinned commit defines compiler-owned #embed, source-relative identity, binary and empty resources, structured E0017 failures, foreground-cache byte identity, deterministic x86-64 execution, and qemu-user ARM64 execution through zag-poc/tests/run_resource_embed.sh. The clean tree also reached a byte-identical self-host fixpoint.
- [ ] `G1-DYNAMIC-LOAD`: upstream prerequisite `dynamic-platform-loading` is `partial`: zag-poc/docs/DYNAMIC_SYSTEM_ABI.md proves a narrow x86-64 Linux dynamic ELF import path with scalar outbound calls and one captureless callback; other targets, aggregates, unload, TLS, and general callbacks are unsupported.
- [ ] `G1-CONCURRENCY`: upstream prerequisite `main-loop-and-workers` is `partial`: The pinned v2 concurrency guide documents bounded x86-64 atomics, futex wait and wake, and a direct join-only Linux worker slice; general arguments, detach, TLS, cross-platform workers, and a complete memory model remain unsupported.
- [ ] `G1-PACKAGES`: upstream prerequisite `package-resolution` is `partial`: zag.mod parsing and local dependency validation exist, but the language specification excludes package registry and dependency resolution semantics.
- [ ] `G1-RELOAD`: upstream prerequisite `incremental-and-reload-hooks` is `partial`: The pinned zagd architecture documents a checksummed incremental declaration index and background semantic rechecking, but not an in-process incremental parser or stable state-preserving library reload contract.
- [ ] `G1-SOURCE-FIRST`: ongoing invariant: fix reusable compiler, runtime, ABI, package, concurrency, tooling, and language-ergonomics causes in canonical Zag with an upstream regression before resuming a consumer

### 3. Text, assets, materials, and motion
- [ ] `G3-UNICODE`: foundation contracts are in place; Unicode normalization, scripts, and locale logic are not yet implemented end to end
- [ ] `G3-OPENTYPE`: headless contracts do not yet include full shaping, fallback, and OpenType asset coverage
- [ ] `G3-EDITING`: text editing, selection, caret, and IME-aware model are not yet implemented
- [ ] `G3-FONTS`: font fallback policy, precision typography, and legibility matrix are not yet implemented
- [ ] `G3-COLOR`: wide-gamut conversion and color-management contracts are not yet implemented
- [ ] `G3-SVG`: secure SVG decode/render contract is not yet implemented
- [ ] `G3-PNG`: full PNG color-profile, malformed, and safety contracts are not yet implemented
- [ ] `G3-SHADOWS`: material shadow primitives and shadow test suite are not yet implemented
- [ ] `G3-LIGHTING`: lighting and depth contracts are not yet implemented
- [ ] `G3-GLASS`: glass material contracts are not yet implemented
- [ ] `G3-MOTION`: advanced motion contract beyond replay is not yet implemented
- [ ] `G3-REDUCED-MOTION`: reduced-motion replacement matrix and assertions are not yet implemented
- [ ] `G3-ASSET-PIPELINE`: asset lifecycle, missing asset behavior, and cleanup contracts are not yet implemented

### 4. Input, accessibility, Talkback, and tooling
- [ ] `G4-INPUT`: input routing across pointer/keyboard/touch/pen/gamepad host seams is not yet implemented
- [ ] `G4-GESTURES`: gesture arbitration and handoff contracts are not yet implemented
- [ ] `G4-TALKBACK-ACTIONS`: the in-process protocol validates and records events, but no native transport executes the full command set against live applications
- [ ] `G4-TALKBACK-PIXELS`: the in-process dispatcher and ID-derived resolver exist, but no capability-backed native driver executes and records pixel fallback yet
- [ ] `G4-TALKBACK-INSPECT`: tree and timeline data are partial; native layout-reason, screenshot, and complete capability inspection remain unavailable
- [ ] `G4-ACCESSIBILITY`: `linux` capability `accessibility` unavailable: No AT-SPI adapter exists or has assistive technology evidence.
- [ ] `G4-CLI`: CLI host workflow is currently headless-only and lacks promoted-target clean-workflow verification
- [ ] `G4-PREVIEW`: live preview and reload contracts are not yet implemented
- [ ] `G4-INSPECTORS`: inspector surfaces are not yet implemented
- [ ] `G4-GALLERY`: component gallery conformance surface is not yet implemented

### 5. Polished Linux reference platform
- [ ] `G5-WAYLAND`: `linux` capability `platform_shell` unavailable: A native X11 fallback creates, resizes, presents, synchronizes, and cleans up one window; Wayland and production lifecycle coverage remain unavailable.
- [ ] `G5-X11`: `linux` capability `platform_shell` unavailable: A native X11 fallback creates, resizes, presents, synchronizes, and cleans up one window; Wayland and production lifecycle coverage remain unavailable.
- [ ] `G5-ATSPI`: `linux` capability `accessibility` unavailable: No AT-SPI adapter exists or has assistive technology evidence.
- [ ] `G5-LINUX-CPU`: `linux` capability `cpu_renderer` unavailable: The deterministic CPU oracle covers the current retained display-list subset, including analytic rounded rectangles, and presents byte-identical output through X11; complete text, effects, and operation coverage remain unfinished.
- [ ] `G5-LINUX-GPU`: `linux` capability `gpu_transport` unavailable: No Zagkit Linux GPU transport exists or has device evidence.
- [ ] `G5-LINUX-POLISH`: `linux` capability `packaging` unavailable: No installable Linux artifact or packaging gate exists.
- [ ] `G5-LINUX-FIDELITY`: `linux` capability `cpu_renderer` unavailable: The deterministic CPU oracle covers the current retained display-list subset, including analytic rounded rectangles, and presents byte-identical output through X11; complete text, effects, and operation coverage remain unfinished.
- [ ] `G5-SHOWCASE-CONFORMANCE`: the experimental preview does not yet pass token provenance, semantic symbol/color, elevation, interaction-state, typography-ramp, chart, segmented-control, and navigation-role proof
- [ ] `G5-LINUX-PACKAGE`: `linux` capability `packaging` unavailable: No installable Linux artifact or packaging gate exists.

### 6. Complete PrismStudio overhaul
- [ ] `G6-INVENTORY`: PrismStudio migration work requires replacement of visible shell and inventory mapping
- [ ] `G6-DESIGN`: PrismStudio visual direction must be selected and accepted before migration
- [ ] `G6-SHELL`: PrismStudio shell replacement is not implemented in this repository
- [ ] `G6-WORKFLOWS`: PrismStudio workflows have not yet been migrated to Zagkit-native equivalents
- [ ] `G6-VIEWPORT`: PrismStudio viewport chrome and interactions remain unmigrated
- [ ] `G6-DENSE-UI`: PrismStudio dense UI surfaces remain unmigrated
- [ ] `G6-MATERIALS`: Materials and visual tokens for PrismStudio have not been migrated
- [ ] `G6-ASSETS`: PrismStudio production asset migration remains incomplete
- [ ] `G6-AUTOMATION`: PrismStudio actions must expose stable IDs through a native UI migration
- [ ] `G6-ACCESSIBILITY`: PrismStudio accessibility polish is blocked on full migration
- [ ] `G6-SCREENSHOTS`: PrismStudio native screenshot comparison cannot run before full UI migration
- [ ] `G6-PERFORMANCE`: PrismStudio performance gates depend on migrated native UI and runtime
- [ ] `G6-POLISH`: PrismStudio polish requires full migration and defect closure

### 7. Desktop, mobile, and shared 1.0
- [ ] `G7-MACOS`: depends on completed upstream targets, linux parity, and migration evidence
- [ ] `G7-WINDOWS`: depends on completed upstream targets, linux parity, and migration evidence
- [ ] `G7-IOS`: depends on completed upstream targets, linux parity, and migration evidence
- [ ] `G7-ANDROID`: depends on completed upstream targets, linux parity, and migration evidence
- [ ] `G7-MOBILE-REFERENCE`: depends on native mobile runtime, text/IME, and component migration
- [ ] `G7-COMPONENT-PARITY`: depends on component suite migration across all five targets
- [ ] `G7-TEXT-PARITY`: depends on Unicode, font, IME, and text rendering completion
- [ ] `G7-RECOVERY`: depends on recovery/lifecycle evidence across all five platforms
- [ ] `G7-PERFORMANCE`: depends on 120Hz/idle/stall/recovery evidence on reference hardware
- [ ] `G7-PACKAGING`: depends on install/update/uninstall coverage on all supported platforms
- [ ] `G7-ONE-POINT-ZERO`: depends on every remaining milestone and unexpired waivers

## Immediate next actions

- Advance upstream prerequisites in `/home/micah/Desktop/Sylorlabs/zag` until no required G1 entries are `missing`/`partial`.
- Complete RFC 0007 full-direction acceptance after full visual matrix evidence is generated.
- Implement Linux shell/AT-SPI and capability-backed backends only after capability blockers are reduced.
- Remove PrismStudio consumer workarounds only after their reusable causes have upstream Zag regressions and fixed compiler revisions.
- Continue the inventory-driven PrismStudio overhaul in the canonical repository, with native tests and screenshot evidence for every promoted surface.
