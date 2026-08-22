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

## Typography activation — 2026-08-09

The native preview now requires an explicit `ZAGKIT_FONT_FILE`; the launcher
resolves Noto Sans with fontconfig when the caller did not provide one. Missing
or invalid font bytes fail before the window claims truthful typography.

Using Noto Sans Regular SHA-256
`89c3c497f618fdaa0b2d1e98fef93582f28c71debd2c4a8cdf41f190ced2909d`,
the X11 fallback rendered and captured real owned outlines for navigation,
titles, actions, status chips, and activity labels. Two independent native
captures were byte-identical. The current 1120×720 evidence is
`artifacts/evidence/linux-x11-typography-2026-08-09.png`, SHA-256
`60d27685be55360d505e3b3fd9b487c46b49330764e1961ec5be7f1d82d754b9`.
Original-resolution inspection caught and removed the previous placeholder bars
under the main title before this hash was accepted.

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

This frame is still an early renderer/shell witness. It now contains real
nominal LTR typography, but not shaping, fallback, icons, wired controls,
platform accessibility, IME, clipboard, drag and drop, multi-window behavior,
GPU presentation, Wayland, or production materials and motion. Its visual
quality is improved but does not yet satisfy the Linux polish gate or the
SwiftUI/Web UI competitive target. Those remain checked by the project goal and
agent checklist rather than being inferred from this image.
