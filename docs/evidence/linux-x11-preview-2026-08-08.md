# Linux X11 preview evidence — 2026-08-08

Status: **experimental transport proof**, not a polished component or Linux beta.

## What passed

- Zagkit built a native dynamic ELF with an explicit `libX11.so.6` dependency.
- `.auto` selected the X11 fallback and reported `active backend=x11`.
- The shell created and mapped a native window, presented Zagkit's CPU pixels,
  synchronized the X connection, encoded a bounded capture, and cleaned up.
- `artifacts/launch/linux-preview-native.png` is 1120×720 RGBA and has SHA-256
  `d16554081823f93f8d36186a76037473b5e79ea4b5f663daf493c9ba8b255a3a`.
- The native capture is byte-identical to
  `artifacts/launch/linux-preview-reference.png`, the deterministic CPU oracle.
- The mapped window was discovered as XID `0x06c00001`, resized to 1400×800,
  rerendered across the full surface, and captured from the X server at
  `artifacts/evidence/linux-x11-window-2026-08-08.png` (SHA-256
  `ceb68c9f800e34f596f9375c2eef86a50959ac53d89561aeaef09cfc128dec04`).
- The legacy title is ASCII-safe and `_NET_WM_NAME` contains the intended UTF-8
  title `Zagkit — Linux Preview`.

## Upstream Zag issue fixed

The first X11 launch exposed a compiler defect in nested dynamic C calls. When
a foreign call appeared under field assignment, Zag's expression stack could
leave `rsp` misaligned; aligning after pushing C stack arguments then displaced
argument seven and later. The fix lives in Zag's native lowering: preserve the
exact expression-stack pointer, align before System V argument placement, and
restore it after the call. Focused nine-argument field-assignment and deep X11
aggregate-return fixtures both exited `42` with the fixed compiler stage.
The source repair is committed directly in the canonical Zag checkout as
`590501f` (`Fix nested System V calls and memory-class aggregates`). On
2026-08-09 Zag then reached the bounded byte-identical self-hosting fixpoint,
installed `./znc` with SHA-256
`f52b0167d7d0644531e76e5eebb6560a61b2a5a06d3b7a82211e5617d2924090`,
and that installed compiler passed all 36 dynamic ABI checks plus this native
X11 create/present/capture/cleanup gate.

## Honest limits

This frame is an early renderer/shell witness. It does not yet contain real
typography, icons, text shaping, controls, semantics, accessibility, IME,
clipboard, drag and drop, multi-window behavior, GPU presentation, Wayland, or
production materials and motion. Its visual quality does not satisfy the Linux
polish gate or the SwiftUI/Web UI competitive target. Those remain checked by
the project goal and agent checklist rather than being inferred from this image.
