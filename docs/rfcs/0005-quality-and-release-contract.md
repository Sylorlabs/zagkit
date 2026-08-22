# RFC 0005: Quality and release contract

- Status: Accepted
- Decision date: 2026-08-06
- Owners: Zagkit maintainers

## Decision

Quality, performance, accessibility, tooling, recovery, and packaging are
release requirements. They are not post-1.0 polish.

The normative gates are listed in
[release-gates.md](../quality/release-gates.md). A result bundle identifies the
Zagkit and Zag commits, target, device, OS, backend capability record, commands,
durations, artifacts, and cleanup outcome.

## Performance

Canonical interactions meet the active display deadline at p99 and preserve
120 Hz scrolling on supported reference hardware. Idle scenes perform no
continuous layout or paint work. Ten minute scripted runs contain no unexplained
two frame stalls. A regression over 5 percent requires a reviewed waiver with
scope, reason, owner, expiry, and recovery plan.

## Visual correctness

CPU goldens run across scale, theme, contrast, direction, text scale, reduced
motion, and representative locale axes. GPU output is compared to the CPU oracle
using documented per-operation tolerances. Screenshots alone do not certify
input, semantics, text editing, accessibility, recovery, or performance.

## Release truth

Experimental, alpha, and beta releases state their missing gates. 1.0 is
blocked until Linux, macOS, Windows, iOS, and Android pass the common component,
consumer, mobile reference, text, accessibility, recovery, performance,
packaging, and reproducibility requirements.
