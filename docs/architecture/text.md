# Text engine

Status: **early headless foundation with an implementing Text component**.
Bounded nominal-LTR glyph paths now render through the headless CPU oracle.
General product typography, text input, and native platform integration remain
unavailable in the platform capability matrix.

Zagkit owns the complete text pipeline. System font files and published
Unicode/OpenType data are inputs; FreeType, HarfBuzz, Skia, browser text, and
native widget text engines are not runtime dependencies.

## Implemented truth

- `src/text/unicode.zag` strictly decodes UTF-8 into Unicode scalars while
  retaining each scalar's exact source byte span.
- Malformed leads, continuations, truncation, overlong sequences, surrogates,
  and values above `U+10FFFF` fail at an explicit byte offset.
- `src/text/opentype.zag` copies and owns bounded SFNT/OpenType bytes, validates
  the table directory and required `cmap`, `head`, `maxp`, `hhea`, and `hmtx`
  tables, and exposes `unitsPerEm`, glyph-count, horizontal advances, ascender,
  descender, and line-gap truth.
- TrueType `loca`, simple `glyf` contours, and recursively bounded composite
  components decode into exact
  font-unit points with explicit on-curve flags and contour ends. Empty glyphs
  are valid; malformed locations, flags, coordinates, and bounds fail closed.
- Composite translation, point attachment, uniform/axis/two-by-two F2Dot14
  transforms, and optional instruction bounds are interpreted without executing
  font bytecode. Cycles, excessive depth, and excessive component work fail.
- CFF/CFF2 outlines remain explicitly unsupported rather than being flattened
  incorrectly.
- `src/text/glyph_path.zag` converts simple TrueType contours into immutable
  quadratic Zagkit paths at an exact fixed-point font size and baseline,
  including implied midpoints between consecutive off-curve points.
- Those canonical paths already execute through the deterministic CPU oracle;
  the shaped-run resource and text antialiasing policy remain open.
- `src/text/glyph_run.zag` provides an explicitly nominal LTR stage: strict
  UTF-8 cluster byte spans map to glyph IDs, cumulative `hmtx` advances produce
  drift-free fixed-point origins, and the positioned contours assemble into
  one immutable path executable by the CPU oracle. Missing coverage returns a
  fallback request instead of a fabricated glyph.
- `src/components/text.zag` composes that nominal run into one sealed Canvas
  path resource with exact bounds and clipping, semantic type and color token
  provenance, OpenType-derived baseline metrics, start/center/end placement,
  explicit reject-or-clip overflow, and owned or parent-owned semantics. Its
  parent-owned mode renders every PerformanceChart text slot without creating
  duplicate chart semantics. See the [bounded Text contract](../components/text.md).
- The CPU path oracle indexes active edges per subpixel scanline, preserving
  exact eight-by-eight coverage while avoiding all-edges-per-pixel sentence
  work. It preflights the actual bounded scanline work before touching pixels.
- Unicode-to-glyph lookup supports bounded `cmap` format 4 and format 12
  subtables. A missing mapping returns glyph zero; it does not invent fallback.
- The parser rejects table escapes, duplicate required tables, malformed
  metrics, unsupported mappings, invalid codepoints, and glyph IDs outside the
  declared font.

## Required before general typography is available

1. Parse CFF/CFF2 outlines, variation axes, color-glyph tables, and font
   metadata beyond the current required metric subset.
2. Implement normalization, grapheme/word/sentence segmentation, script runs,
   bidi resolution, line breaking, fallback, and locale-aware shaping. The
   nominal LTR stage is not a substitute for any of these operations.
3. Implement OpenType GSUB/GPOS and variation application with deterministic
   glyph-run serialization.
4. Promote shaped glyph runs to a canonical render resource and define the
   subpixel antialiasing and color-space policy used by the CPU oracle.
5. Connect shaped runs to intrinsic measurement, selection, editing, IME
   composition, accessibility text navigation, and replay. The bounded Text
   slice proves only basic whole-node semantics and in-process Talkback query.
6. Prove representative Latin, Arabic, Hebrew, Indic, CJK, emoji, combining,
   malformed-font, RTL, large-text, and fallback suites before changing the
   platform `text_input` capability from unavailable.

Placeholder bars in the Linux preview are not typography evidence. Replacing
them requires explicit host composition of this Text component; their presence
does not count as a text backend or platform-typography result.
