# Quality and release gates

This is the common evidence contract. Milestones select the applicable rows but
cannot weaken their meaning.

## Headless correctness

- Unit and property tests for state dependency tracking, bindings, keys,
  reconciliation, constraints, intrinsic measurement, geometry, hit testing,
  focus, gesture arbitration, and animation clocks.
- Fuzz tests for state event streams, malformed fonts, Unicode, bidi, line
  breaking, display lists, semantics, resources, and replay files.
- Differential tests against published Unicode and OpenType data plus internal
  slow reference implementations where possible.
- Deterministic replay with state, input, time, platform, backend, loss, and
  recovery events.
- Resource ownership tests for creation failure, partial initialization,
  cancellation, replacement, device loss, shutdown, and repeated startup.

## Visual oracle

CPU goldens cover every axis in
[the benchmark manifest](../../contracts/benchmark-scenes.json): scale factors,
light and dark themes, standard and high contrast, LTR and RTL, normal and large
text, full and reduced motion, and representative locales.

GPU output is compared to CPU output with versioned tolerance rules by display
list operation, pixel format, color space, and device. An unexplained mismatch
fails. Updating a golden requires a reviewed intent record.

Native screenshot comparisons cover crisp typography, curves, SVG, PNG,
lighting, shadows, and transparent materials at every declared scale. Each
comparison records viewport, state, backend, color space, scale, fonts, theme,
contrast, direction, text scale, motion, and transparency preferences.
Screenshots remain necessary visual evidence, not complete product evidence.

## Flex and Zagkit Talkback

Flex conformance covers gap, padding, alignment, distribution, baseline, wrap,
intrinsic size, constraints, grid tracks and spans, overlay placement,
breakpoints, safe areas, density, RTL, and large text. Grid collisions fail
closed unless overlap is explicit, and every primitive reports quantified
overflow plus deterministic identity. Every layout change reports its exact
state read and rule.

Zagkit Talkback conformance drives canonical applications by stable ID and
checks discovery, query, action, wait, assertion, screenshot, timeline,
capability, snapshot, and replay behavior. Pixel fallback is separately
reported, scale-aware, and forbidden where a required actionable semantic node
should exist. This automation never replaces native assistive-technology runs.

## Live platform suite

Each promoted target runs resize, suspend and resume, background and foreground,
surface and device loss, multi window, multi monitor or display movement,
scaling, clipboard, drag and drop, IME composition, missing fonts, keyboard only
operation, focus restoration, shutdown, and crash recovery.

Native assistive technology runs are mandatory:

- AT-SPI on Linux;
- VoiceOver on macOS and iOS;
- Narrator on Windows;
- TalkBack on Android.

Automation through the semantics tree does not replace these runs.

## Motion and input

Canonical tests cover interruption, reversal, gesture handoff, capture loss,
reduced motion substitution, resize during transition, refresh rate changes,
coalesced input, and deterministic replay. Position and velocity continuity are
measured where applicable.

## Performance

- Active interactions meet the display deadline at p99.
- Scrolling sustains 120 Hz on supported reference hardware.
- Idle scenes perform zero continuous layout and paint work.
- Ten minute canonical runs contain zero unexplained two frame stalls.
- CPU time, GPU time, memory, allocations, cache size, resource counts, input
  latency, and frame reasons are captured.
- A regression over 5 percent fails unless a reviewed, expiring waiver exists.

Reference hardware, thermal state, power mode, OS build, display configuration,
compiler revision, backend, warmup, sample count, and raw results are retained.

## Packaging and release

Signed artifacts install, launch, update, and uninstall on every supported OS.
Reproducible builds record exact source and tool inputs plus artifact hashes.
Release notes include capability records, reference hardware, benchmark results,
known unsupported features, and untested hardware.

## Promotion levels

| Level | Minimum evidence |
|---|---|
| Experimental | bounded executable slice or specification with explicit unavailable boundaries |
| Alpha | coherent end to end slice with repeatable native tests and known recovery gaps |
| Beta | intended API plus native accessibility, text input, recovery, performance, and packaging evidence |
| Stable | complete common gates, supported version policy, reproducible signed artifacts, and support process |
| 1.0 | Stable gate on all five required platform families plus PrismStudio and mobile reference proof |

The PrismStudio proof is a complete UI replacement on Zagkit, not a sample
screen or partial shell migration. Linux polish additionally requires zero open
severity-one or severity-two visual, spacing, text, input, accessibility,
automation, recovery, performance, or packaging defects.
