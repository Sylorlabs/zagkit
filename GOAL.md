# Zagkit master goal checklist

- Goal status: **Active**
- Completion meaning: every item below is checked and carries reviewable evidence
- Scope: Zagkit, upstream Zag prerequisites, and the Zagkit based PrismStudio overhaul
- Rule: an implementation, screenshot, benchmark, or platform claim never checks a box by itself; the named exit condition must pass

This is the durable execution checklist for humans and agents. Stable IDs may be
referenced by issues, commits, result bundles, and release notes. Do not delete,
weaken, or check an item to make a milestone appear complete. Split an item when
more precision is needed and preserve its original ID as the parent.

## 0. Repository and product contract

- [x] `G0-REPOSITORY` Establish the separate Apache-2.0 Zagkit repository. — Evidence: [LICENSE](LICENSE), [governance](GOVERNANCE.md)
- [x] `G0-VERSIONING` Establish semantic versioning and honest preview labels. — Evidence: [VERSIONING.md](VERSIONING.md), [zag.mod](zag.mod)
- [x] `G0-PLATFORMS` Record all five required platform families and fail-closed capability truth. — Evidence: [platform contract](contracts/platforms.json)
- [x] `G0-ARCHITECTURE` Accept the initial declarative, rendering, text, semantics, platform, and quality RFCs. — Evidence: [RFC index](docs/rfcs/README.md)
- [x] `G0-DEPENDENCIES` Forbid foreign UI and rendering engines from Zagkit core. — Evidence: [dependency boundary](DEPENDENCIES.md)
- [x] `G0-TOOLCHAIN` Pin each Zagkit release to an exact clean Zag revision. — Evidence: [toolchain contract](contracts/toolchain.json)
- [x] `G0-UPSTREAM` Record missing Zag prerequisites and native exit gates. — Evidence: [upstream ledger](contracts/upstream-zag.json)
- [x] `G0-BENCHMARKS` Define canonical benchmark scenes and variant axes without claiming results. — Evidence: [benchmark contract](contracts/benchmark-scenes.json)
- [x] `G0-COMPONENTS` Inventory the initial shared component surface. — Evidence: [component contract](contracts/components.json)
- [x] `G0-CI` Validate the product contracts in CI. — Evidence: [contract workflow](.github/workflows/contracts.yml)
- [x] `G0-EXPANDED-SCOPE` Bind Flex, Zagkit Talkback, visual fidelity, and PrismStudio redesign to release gates. — Evidence: [RFC 0006](docs/rfcs/0006-flex-talkback-visual-fidelity-and-prismstudio.md)
- [ ] `G0-VISUAL-DIRECTION` Select one of three accessibility-reviewed visual directions. — Exit: accepted visual-direction RFC with comparison images, risks, and conformance scenes

## 1. Advance Zag at the source

- [ ] `G1-LINUX-ARM64` Complete and natively conform the Linux ARM64 compiler target. — Exit: pure Zag ABI, executable, cleanup, and physical-device suites pass
- [ ] `G1-DARWIN` Implement Mach-O x86-64 and ARM64 targets. — Exit: native macOS executables pass ABI and lifecycle conformance
- [ ] `G1-WINDOWS` Implement PE/COFF x86-64 and ARM64 targets. — Exit: native Windows executables pass ABI, unwind, resource, and lifecycle conformance
- [ ] `G1-IOS` Implement the iOS ARM64 target. — Exit: signed Zag code runs on physical supported iOS devices
- [ ] `G1-ANDROID` Implement the Android ARM64 target. — Exit: Zag output runs on physical supported Android devices
- [ ] `G1-OBJC` Implement typed Objective-C runtime ABI seams. — Exit: message, callback, aggregate, ownership, and failure suites pass on macOS and iOS
- [ ] `G1-COM` Implement typed COM ABI seams. — Exit: lifetime, interface, callback, HRESULT, threading, and aggregate suites pass on Windows
- [ ] `G1-JNI` Implement typed JNI ABI seams. — Exit: calls, references, exceptions, threads, callbacks, and cleanup pass on Android
- [ ] `G1-CALLBACKS` Complete general foreign callback ABI support. — Exit: register, stack, lifetime, reentrancy, and negative suites pass per target
- [ ] `G1-AGGREGATES` Complete foreign aggregate argument and return support. — Exit: structs, unions, vectors, floats, alignment, and register-class suites pass per target
- [ ] `G1-FFI-LIFETIMES` Implement exact per-parameter foreign lifetime contracts in Zag without treating nonretaining inputs as borrowed returns. — Exit: multi-pointer immutable/mutable input, consume, computed/null input, return-escape, formatter, manifest, and native C ABI suites pass with legacy contracts remaining compatible
- [ ] `G1-RUNTIME-RESOURCES` Implement move-capable runtime resource aggregates, exact owned-field cleanup, and explicit foreign acquire/consume transfer in Zag. — Exit: construct, partial initialization, move-return, deinit, field release, null/error cleanup, double-use, copy, leak, and foreign-handle suites pass before the Linux shell stores owned buffers or handles in returned aggregates
- [ ] `G1-RESOURCES` Implement deterministic compiler-owned resource embedding. — Exit: binary, empty, relative, malformed, cache-identity, reproducibility, and target suites pass
- [ ] `G1-DYNAMIC-LOAD` Complete typed cross-platform dynamic loading. — Exit: lookup, version failure, ownership, unload, callback, and aggregate suites pass
- [ ] `G1-CONCURRENCY` Complete main-loop and worker primitives with a documented memory model. — Exit: wakeup, cancellation, affinity, race, shutdown, and platform suites pass
- [ ] `G1-PACKAGES` Complete deterministic package resolution. — Exit: locks, checksums, offline, path, conflict, cache, and reproducibility suites pass
- [ ] `G1-RELOAD` Complete incremental compilation and safe reload hooks. — Exit: invalidation, state preservation, rollback, file-race, and crash-recovery suites pass
- [ ] `G1-SOURCE-FIRST` Treat every reusable compiler, runtime, ABI, package, concurrency, tooling, or language-ergonomics problem exposed by Zagkit or PrismStudio as an upstream Zag side quest; do not preserve consumer workarounds merely because another language normally needs them. Work only in canonical `/home/micah/Desktop/Sylorlabs/zag`, add native regressions there, and resume the consumer at the exact fixed revision. — Exit: every downstream Zag defect or avoidable workaround links to an upstream Zag regression and exact fixed revision

## 2. Declarative and headless core

- [x] `G2-STATE` Implement `State<T>`, `Binding<T>`, actions, environment, and exact dependency reads. — Evidence: [goal progress checkpoint 2026-08-07](docs/evidence/goal-progress-2026-08-07.md)
- [x] `G2-RECONCILE` Implement keyed reconciliation and retained `RenderNode` ownership. — Evidence: [goal progress checkpoint 2026-08-07](docs/evidence/goal-progress-2026-08-07.md)
- [x] `G2-CONSTRAINTS` Implement constraints, intrinsic measurement, size, rect, and invalidation reasons. — Evidence: [goal progress checkpoint 2026-08-07](docs/evidence/goal-progress-2026-08-07.md)
- [x] `G2-FLEX` Implement the Flex placement and spacing system. — Evidence: [goal progress checkpoint 2026-08-07](docs/evidence/goal-progress-2026-08-07.md)
- [x] `G2-FLEX-RTL` Make Flex correct for RTL, safe areas, text scale, density, and platform adaptation. — Evidence: [goal progress checkpoint 2026-08-07](docs/evidence/goal-progress-2026-08-07.md)
- [x] `G2-VIRTUALIZATION` Implement scroll, virtual list, table, tree, and grid. — Evidence: [goal progress checkpoint 2026-08-07](docs/evidence/goal-progress-2026-08-07.md)
- [x] `G2-DISPLAY-LIST` Implement immutable paths, paints, images, glyphs, clips, transforms, layers, and effects. — Evidence: [goal progress checkpoint 2026-08-07](docs/evidence/goal-progress-2026-08-07.md)
- [x] `G2-CPU-RASTER` Implement the deterministic CPU visual oracle. — Evidence: [goal progress checkpoint 2026-08-07](docs/evidence/goal-progress-2026-08-07.md)
- [x] `G2-HIT-TEST` Implement transformed hit testing, capture, focus, and event routing. — Evidence: [goal progress checkpoint 2026-08-07](docs/evidence/goal-progress-2026-08-07.md)
- [x] `G2-SEMANTICS` Implement the parallel semantics tree. — Evidence: [goal progress checkpoint 2026-08-07](docs/evidence/goal-progress-2026-08-07.md)
- [x] `G2-REPLAY` Implement deterministic state, input, time, backend, loss, and recovery replay. — Evidence: [goal progress checkpoint 2026-08-07](docs/evidence/goal-progress-2026-08-07.md)

## 3. Text, assets, materials, and motion

- [ ] `G3-UNICODE` Implement Zag-owned decoding, normalization, bidi, segmentation, and line breaking. — Exit: published-data differential, fuzz, malformed, and locale suites pass
- [ ] `G3-OPENTYPE` Implement Zag-owned OpenType shaping and rasterization. — Exit: fallback, variable, color, emoji, malformed-font, and reference suites pass
- [ ] `G3-EDITING` Implement selection, caret, undo, composition, and text navigation. — Exit: multilingual IME and editing replay suites pass
- [ ] `G3-FONTS` Implement precise typography tokens, fallback policy, hinting, and density-independent rasterization. — Exit: baseline, legibility, large-text, and international type-ramp goldens pass
- [ ] `G3-COLOR` Implement semantic color, wide-gamut conversion, alpha, contrast, and color-management contracts. — Exit: light, dark, high-contrast, and color-space oracle suites pass
- [ ] `G3-SVG` Implement secure scalable SVG decoding and rendering without a foreign UI engine. — Exit: path, gradient, transform, clip, text-policy, malformed, and scale goldens pass
- [ ] `G3-PNG` Implement color-managed PNG decoding and rendering. — Exit: alpha, palette, grayscale, color-profile, malformed, bomb-limit, and scale suites pass
- [ ] `G3-SHADOWS` Implement soft multi-lobe shadows and elevation tokens without pixelated edges. — Exit: CPU goldens and GPU tolerance suites pass across scales and contrast modes
- [ ] `G3-LIGHTING` Implement coherent light, surface, highlight, and depth composition. — Exit: deterministic material scenes preserve hierarchy in light, dark, and high contrast
- [ ] `G3-GLASS` Implement adaptive liquid-glass materials with blur, tint, refraction, highlights, and depth. — Exit: motion, overlap, text-legibility, reduced-transparency, CPU-oracle, and GPU suites pass
- [ ] `G3-MOTION` Implement springs, keyframes, layout, shared, and gesture-driven transitions. — Exit: interruption, reversal, velocity continuity, resize, and deterministic replay pass
- [ ] `G3-REDUCED-MOTION` Implement semantic reduced-motion substitutions. — Exit: every canonical animation has a tested non-motion or reduced-motion equivalent
- [ ] `G3-ASSET-PIPELINE` Implement resource identity, decoding limits, caching, invalidation, and cleanup. — Exit: malformed, replacement, missing, memory-pressure, and repeat-start suites pass

## 4. Input, accessibility, Talkback, and tooling

- [ ] `G4-INPUT` Implement pointer, keyboard, touch, pen, wheel, gamepad, and command routing. — Exit: arbitration, capture-loss, coalescing, focus, and replay suites pass
- [ ] `G4-GESTURES` Implement gesture arbitration, velocity, drag and drop, and handoff. — Exit: nested recognizer continuity and cleanup suites pass
- [x] `G4-TALKBACK-PROTOCOL` Specify the versioned Zagkit Talkback native automation protocol. — Evidence: [protocol contract](contracts/talkback-protocol.json), [talkback contract](tests/talkback_contract.zag), [talkback docs](docs/automation/talkback.md), [headless contract](docs/evidence/goal-progress-2026-08-07.md)
- [x] `G4-TALKBACK-IDS` Expose stable developer-assigned and deterministic generated node IDs. — Evidence: [goal progress checkpoint 2026-08-07](docs/evidence/goal-progress-2026-08-07.md)
- [x] `G4-TALKBACK-ACTIONS` Support semantic query, click, type, scroll, drag, focus, wait, assert, snapshot, and replay actions. — Evidence: [talkback contract](tests/talkback_contract.zag), [goal progress checkpoint](docs/evidence/goal-progress-2026-08-07.md), [current session](docs/evidence/goal-progress-2026-08-07.md)
- [x] `G4-TALKBACK-PIXELS` Provide an explicit pixel-coordinate fallback. — Evidence: [goal progress checkpoint 2026-08-07](docs/evidence/goal-progress-2026-08-07.md)
- [x] `G4-TALKBACK-INSPECT` Ship tree, layout-reason, screenshot, timeline, and capability inspection. — Evidence: [talkback contract](tests/talkback_contract.zag), [talkback docs](docs/automation/talkback.md), [goal progress](docs/evidence/goal-progress-2026-08-07.md), [headless contract](docs/evidence/talkback-contract-2026-08-07.log)
- [x] `G4-TALKBACK-NAME` Keep Zagkit Talkback distinct from Android TalkBack accessibility. — Evidence: [RFC-0006 naming rule](docs/rfcs/0006-flex-talkback-visual-fidelity-and-prismstudio.md), [protocol contract](contracts/talkback-protocol.json), [Talkback docs](docs/automation/talkback.md)
- [ ] `G4-ACCESSIBILITY` Implement Linux AT-SPI, Apple accessibility, Windows UIA, and Android accessibility adapters. — Exit: native assistive-technology suites pass on every promoted platform
- [ ] `G4-CLI` Implement `zagkit init`, `build`, `run`, and `test`. — Exit: reproducible clean-project workflows pass on every promoted target
- [ ] `G4-PREVIEW` Implement live preview and state-safe reload. — Exit: compatible state survives, incompatible changes roll back clearly, and crashes recover
- [ ] `G4-INSPECTORS` Implement semantic, accessibility, layout-reason, frame, theme, and capability inspectors. — Exit: inspectors agree with recorded runtime truth and add no idle work when closed
- [ ] `G4-GALLERY` Implement the component gallery as a conformance surface. — Exit: every conformant component exposes states, variants, semantics, motion, and goldens

## 5. Polished Linux reference platform

- [ ] `G5-WAYLAND` Implement the Wayland shell first. — Exit: lifecycle, windows, surfaces, scaling, input, clipboard, IME, and recovery pass on target distributions
- [ ] `G5-X11` Implement the X11 fallback without claiming Wayland equivalence. — Exit: declared X11 capability and limitation suites pass
- [ ] `G5-ATSPI` Implement and verify native AT-SPI exposure. — Exit: keyboard-only and supported Linux screen-reader scripts pass
- [ ] `G5-LINUX-CPU` Implement CPU presentation as the always-available visual oracle path. — Exit: live resize, multi-monitor, surface-loss, and ten-minute cleanup suites pass
- [ ] `G5-LINUX-GPU` Implement one explicit public Linux GPU transport. — Exit: opt-in physical-device execution, loss recovery, CPU comparison, and cleanup pass
- [ ] `G5-LINUX-POLISH` Make Linux the first no-rough-edges reference experience. — Exit: no known severity-one or severity-two visual, input, text, accessibility, recovery, or packaging defects remain
- [ ] `G5-LINUX-FIDELITY` Eliminate density-dependent and pixelated UI output. — Exit: screenshot comparisons pass at 1.0, 1.25, 1.5, 2.0, and 3.0 scales with crisp type, SVG, PNG, curves, glass, and shadows
- [ ] `G5-SHOWCASE-CONFORMANCE` Make the Linux showcase prove a coherent reusable system rather than a one-off dashboard. — Exit: [showcase conformance](docs/design/showcase-conformance.md) passes token provenance, semantic icon/color mapping, three elevation tiers, full canonical interaction states, type ramp, unambiguous navigation/status roles, real segmented-control behavior, accessible chart anatomy, and one shared Flex placement authority for pixels, semantics, hit targets, and Talkback across expanded, medium, compact, and unsupported-size states, with native screenshots and semantic evidence
- [ ] `G5-LINUX-PACKAGE` Package, install, launch, update, and uninstall Linux artifacts. — Exit: Ubuntu LTS and Fedora x86-64 and ARM64 release matrices pass where target support is declared

## 6. Complete PrismStudio overhaul

- [ ] `G6-INVENTORY` Inventory every existing PrismStudio workflow, command, screen, and safety boundary. — Exit: migration map has no unowned visible or keyboard-accessible behavior
- [ ] `G6-DESIGN` Select and approve one of three PrismStudio visual directions using representative CAD states. — Exit: maintainers choose a reviewed target with light, dark, contrast, large-text, and reduced-effects variants
- [ ] `G6-SHELL` Replace the entire visible PrismStudio shell with Zagkit. — Exit: no legacy app-owned widget, layout, or styling path remains in the supported Linux product
- [ ] `G6-WORKFLOWS` Preserve and modernize all CAD workflows and direct manipulation. — Exit: canonical task scripts pass by keyboard, pointer, and Zagkit Talkback IDs
- [ ] `G6-VIEWPORT` Migrate viewport chrome, overlays, tools, and input while retaining the explicit GPU safety boundary. — Exit: CPU-safe suite and separately authorized GPU evidence pass without weakening safety
- [ ] `G6-DENSE-UI` Migrate tables, trees, properties, menus, toolbars, dialogs, and command palette. — Exit: density, focus, virtualization, editing, semantics, and responsive-layout suites pass
- [ ] `G6-MATERIALS` Apply production typography, color, lighting, shadows, and liquid-glass materials coherently. — Exit: approved comparison screenshots pass at representative scales and states
- [ ] `G6-ASSETS` Migrate icons and imagery to crisp SVG, PNG, and font-backed assets. — Exit: no placeholder, ASCII, emoji, pixel-stretched, or missing production asset remains
- [ ] `G6-AUTOMATION` Give every actionable PrismStudio node a stable Talkback ID. — Exit: the canonical regression suite uses IDs for all normal actions and records every pixel fallback
- [ ] `G6-ACCESSIBILITY` Make the complete redesigned UI semantic and keyboard operable. — Exit: AT-SPI, focus, large-text, high-contrast, and keyboard-only suites pass
- [ ] `G6-SCREENSHOTS` Verify the actual native app with repeatable reference screenshots. — Exit: matched-state comparisons pass for startup, editing, menus, dialogs, viewport, long sessions, and recovery
- [ ] `G6-PERFORMANCE` Meet frame, idle, input-latency, memory, and stall budgets in real CAD scenes. — Exit: ten-minute reference traces pass with no unexplained two-frame stalls
- [ ] `G6-POLISH` Resolve all known rough edges in the supported Linux PrismStudio experience. — Exit: reviewed bug inventory has no open severity-one or severity-two product-quality issue

## 7. Desktop, mobile, and shared 1.0

- [ ] `G7-MACOS` Ship the adaptive macOS shell, Metal transport, IME, VoiceOver, menus, drag and drop, and signed packaging. — Exit: macOS beta and stable gates pass on supported versions
- [ ] `G7-WINDOWS` Ship the adaptive Windows shell, D3D12 transport, Core Text input, Narrator, menus, drag and drop, and signed packaging. — Exit: Windows beta and stable gates pass on supported versions
- [ ] `G7-IOS` Ship the touch-first iOS shell, Metal transport, lifecycle restoration, IME, VoiceOver, haptics, and signed packaging. — Exit: iOS beta and stable gates pass on physical supported devices
- [ ] `G7-ANDROID` Ship the touch-first Android shell, GPU transport, lifecycle restoration, IME, Android TalkBack, haptics, and signed packaging. — Exit: Android beta and stable gates pass on physical supported devices
- [ ] `G7-MOBILE-REFERENCE` Ship and verify a focused mobile reference application. — Exit: shared components, navigation, text, semantics, recovery, performance, and packaging pass on iOS and Android
- [ ] `G7-COMPONENT-PARITY` Complete the shared adaptive component suite on all five families. — Exit: every inventory row is conformant with platform adaptation evidence
- [ ] `G7-TEXT-PARITY` Pass international text, IME, editing, fonts, and asset fidelity on all five families. — Exit: common text and visual matrices pass without hidden system-engine substitution
- [ ] `G7-RECOVERY` Pass device, surface, process, suspend, resume, loss, and cleanup gates on all five families. — Exit: live platform result bundles contain no unexplained leak or unrecovered loss
- [ ] `G7-PERFORMANCE` Pass common p99, 120 Hz reference, idle, memory, and stall gates. — Exit: reviewed result bundles pass on declared reference hardware
- [ ] `G7-PACKAGING` Install, launch, update, and uninstall signed artifacts on every supported OS. — Exit: reproducible packaging matrices and artifact hashes pass
- [ ] `G7-ONE-POINT-ZERO` Release Zagkit 1.0 only as one shared five-platform product. — Exit: every checklist item is checked, capability truth is supported, and no required waiver is expired

## Checklist maintenance

`./tools/check-contracts.sh` verifies that this file remains active, keeps stable
unique IDs, retains the non-negotiable requirements, and gives every checked
item evidence and every unchecked item an exit condition. That check validates
the plan's integrity; it does not certify the unfinished work.

Run `./tools/report-goal-progress.sh` for a current checkpoint snapshot used by
the live coordination sessions and by release readiness reviews. It outputs:
`docs/evidence/goal-progress-live.md` and
`docs/evidence/goal-progress-live.json` with live checklist counts, upstream
prerequisite status, and platform capability blockers.

Run `./tools/report-goal-milestones.sh` for per-milestone progress:
total/completed/blocked counts and exact blocked item IDs per milestone section.
