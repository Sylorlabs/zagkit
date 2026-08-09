# Text engine

Status: **early headless foundation**. Text input and visible glyph rendering
remain unavailable in the platform capability matrix.

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
  tables, and exposes `unitsPerEm`, glyph-count, and horizontal-advance truth.
- Unicode-to-glyph lookup supports bounded `cmap` format 4 and format 12
  subtables. A missing mapping returns glyph zero; it does not invent fallback.
- The parser rejects table escapes, duplicate required tables, malformed
  metrics, unsupported mappings, invalid codepoints, and glyph IDs outside the
  declared font.

## Required before text is visible

1. Parse vertical metrics, `loca`/`glyf` outlines, CFF/CFF2,
   variation axes, color-glyph tables, and font metadata.
2. Implement normalization, grapheme/word/sentence segmentation, script runs,
   bidi resolution, line breaking, fallback, and locale-aware shaping.
3. Implement OpenType GSUB/GPOS and variation application with deterministic
   glyph-run serialization.
4. Flatten/rasterize glyph outlines in the CPU oracle with subpixel-positioned
   antialiasing and documented color-space behavior.
5. Connect glyph runs to intrinsic measurement, selection, editing, semantics,
   IME composition, accessibility text navigation, Talkback, and replay.
6. Prove representative Latin, Arabic, Hebrew, Indic, CJK, emoji, combining,
   malformed-font, RTL, large-text, and fallback suites before changing the
   platform `text_input` capability from unavailable.

Placeholder bars in the Linux preview are not typography evidence and must be
removed once the owned glyph path is available.
