# Linux typography CPU evidence — 2026-08-09

Status: **owned nominal Latin rendering proof**, not international shaping or a
Linux typography-completion claim.

## Proven path

`tools/render-system-font-reference.sh` resolves an explicit system font,
compiles the renderer in Zag, and generates
`artifacts/evidence/linux-typography-cpu-oracle.png` without FreeType,
HarfBuzz, Skia, browser text, or a native widget renderer.

For the local proof:

- Font: `/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf`
- Font SHA-256:
  `89c3c497f618fdaa0b2d1e98fef93582f28c71debd2c4a8cdf41f190ced2909d`
- Output: 960×320 RGBA PNG
- Output SHA-256:
  `12b8ff5716e8f34da87ea7156addf9aaf6bd1ddd9e7e2a3c2400f00fc2be2809`
- A second independent render was byte-identical.

The path is strict UTF-8 → format 4 cmap → hmtx advances → simple/composite
glyf contours → fixed-point positioned quadratic paths → retained display
resources → eight-by-eight deterministic CPU coverage → canonical PNG.

The screenshot was inspected at original resolution. “Zagkit”, the supporting
line, and the CPU-oracle badge contain real antialiased Noto Sans outlines;
there are no placeholder bars or pixel-font substitutions.

## Renderer correction exposed by the scene

The initial sentence render hit `CpuRasterError.work_limit`. The old safety
estimate charged every path edge to every pixel, and the implementation also
performed that brute-force loop. The CPU oracle now builds the active edge set
for each subpixel scanline, accounts for that actual work before touching the
surface, and reuses bounded row coverage storage. The original adversarial work
limit still fails closed, while a 100-contour/100×100 scanline fixture renders
all 10,000 pixels within the same unchanged 50,000,000-work ceiling.

## Honest limits

This proof is nominal LTR text. It does not certify normalization, grapheme
segmentation, bidi, line breaking, fallback selection, GSUB/GPOS, variation,
CFF/CFF2, color glyphs, hinting, font synthesis, editing, IME, or accessible
text navigation. The checked-in PNG is a local evidence artifact and the
recorded font hash is required to reproduce its exact bytes.
