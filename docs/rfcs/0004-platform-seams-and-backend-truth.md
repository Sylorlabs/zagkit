# RFC 0004: Platform seams and backend truth

- Status: Accepted
- Decision date: 2026-08-06
- Owners: Zagkit maintainers

## Platform boundary

Public platform APIs are permitted for lifecycle, windows, surfaces, vsync, GPU
submission, IME, accessibility, clipboard, drag and drop, menus, haptics,
notifications, signing, and packaging. Each adapter is narrow, owned through Zag
types, and independently conformable. Private APIs are prohibited.

Reusable target, ABI, resource, loading, concurrency, and package features live
in Zag. The prerequisite ledger blocks Zagkit milestones until native Zag
conformance exists.

## Capability model

`PlatformCapabilities` is the public immutable snapshot. `BackendEvent` is the
ordered lifecycle record used by diagnostics, replay, tests, and inspectors.

Every runtime feature reports one of:

- `supported`, with complete native evidence for the active target;
- `experimental`, with executable evidence plus a named incomplete gate;
- `unavailable`, with a mandatory reason.

The initial feature set includes shell, CPU renderer, GPU transport, text input,
accessibility, clipboard and drag and drop, multi window, packaging, and backend
selection. Future features use the same vocabulary.

`.auto` records the actual backend chosen and why higher priority candidates
were rejected. Startup fallback, surface loss, device loss, recovery, and
runtime fallback append timestamped events containing source backend, target
backend, cause, resource impact, and whether visual continuity was preserved.

No request setting can override unavailable truth. An informed developer may
explicitly select an experimental backend, but the resulting record remains
experimental.

## GPU boundary

The CPU renderer remains authoritative. GPU discovery is not submission,
submission is not correct readback, and correct readback is not general renderer
conformance. Physical GPU dispatch is explicit and externally bounded when the
device is display bound or fault isolation is unavailable.

## Verification

Capability tests cover priority, explicit selection, unavailable reasons,
startup fallback, mid-frame loss, surface recreation, resource cleanup, event
ordering, and crash recovery. Native platform promotion requires the evidence
bundle defined in RFC 0005.
