# Experimental Linux shell

Zagkit's first native Linux execution slice is an experimental X11 fallback.
It exists to prove the platform seam and CPU presentation path while the
required Wayland-first shell is still under construction. It is not promoted
as Wayland equivalence or as a polished Linux backend.

The shell uses public Xlib entry points only for display connection, window and
graphics-context lifetime, event delivery, and CPU pixel presentation. Zagkit
owns the immutable display list, analytic rounded geometry, RGBA8 CPU surface,
backend selection record, rendering, and cleanup policy. No Xlib widget,
layout, text, theme, or rendering engine enters the toolkit architecture.

Run the live shell with:

```sh
./zagkit run --linux-preview
```

Run the bounded native conformance capture with:

```sh
./tools/test-linux-preview.sh
```

The reference client area is 1360 by 900 logical pixels so the expanded
placement can host the chart, labelled status evidence, and the measured
Typography specimen without clipping. The shell requires three distinct
Zag-owned OpenType faces: `ZAGKIT_FONT_LIGHT_FILE`, `ZAGKIT_FONT_FILE`, and
`ZAGKIT_FONT_BOLD_FILE`. The launcher resolves Fira Sans weights with
Fontconfig when they are unset, validates that the files exist and differ, and
otherwise stops before opening a window.

The deeper native interaction gate is:

```sh
./tools/test-linux-interaction.sh --evidence-dir <directory>
```

It associates one exact-title window with the launched PID, resolves controls
from stable Talkback IDs to recorded scale-aware pixel fallbacks, verifies
disabled navigation, token-inspector state, segmented pointer and keyboard
state, the real Typography route, unsupported-size and compact resize states,
idle CPU work, native close, and cleanup. Screenshots from this runner remain
review evidence, not a substitute for the semantic and lifecycle assertions.

Primary navigation and the token-inspector Button consume one retained
`LinuxPreviewInteractionState`. X11 pointer motion/down/up drives real hover
and pressed styles; pointer focus is semantic without a keyboard ring. Tab and
Shift-Tab traverse the semantic `focus_order` values, including the segmented
control's single roving stop, while Enter and Space activate the focused
destination. Resize clears a focus owner that becomes unavailable rather than
leaving invisible focus behind. Rendering, semantics, hit testing, trace
output, and Zagkit Talkback therefore observe one NodeKey-based state truth.

`PlatformCapabilities` records `.auto` selection. When a Wayland endpoint is
visible but the Wayland shell is unavailable, choosing X11 records a fallback
event and reason. X11 window and CPU presentation report `experimental`; GPU,
IME, and accessibility remain `unavailable`. A failed display connection
reports headless operation rather than claiming a native surface.

The current event loop handles expose, live resize, and `WM_DELETE_WINDOW`.
Resize rerasterizes the retained scene at the new surface size. The transport
converts the CPU oracle's RGBA8 bytes to the common little-endian X11 BGRX
layout and detaches Zag-owned pixel memory before destroying the XImage.

The bounded capture proves create, present, sync, deterministic PNG emission,
and cleanup on the executing X server. It does not complete the checklist exits
for Wayland, multi-monitor scaling, input/IME, clipboard, AT-SPI, recovery,
ten-minute cleanup, GPU transport, packaging, or Linux polish.
