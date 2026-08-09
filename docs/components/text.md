# Text

`Text` is an experimental, bounded, single-line composition component. It
turns strict UTF-8 into one nominal left-to-right glyph run using Zagkit's
owned OpenType parser, converts every TrueType outline through the owned glyph
path pipeline, and publishes the whole run as one immutable path resource in a
sealed `Canvas`. There is no shell text helper, OS text API, FreeType,
HarfBuzz, Skia, browser engine, or foreign shaping library in this path.

The component inventory status is `implementing`. The focused contract is real
headless CPU evidence, but this is not general product typography and does not
raise any platform text capability to supported.

## Authoring contract

Create a `TextSpec` with:

```zag
let spec: TextSpec = text_spec(
    node_key(42), semantic_parent, exact_bounds, "Status",
    SemanticTypeToken.label, SemanticColorToken.text_primary
);
```

The stable `NodeKey`, semantic parent, exact positive bounds, nonempty text,
semantic type token, and semantic color token are required. Text is limited to
4,096 UTF-8 bytes and 1,024 decoded scalars. UTF-8 must be canonical and
NUL-free. Missing font coverage, malformed input, unsupported outlines, and
empty combined outline paths fail explicitly; the component never fabricates
a replacement glyph.

`TextAlignment.start`, `.center`, and `.end` place the measured advance inside
the exact bounds. These are physical nominal-LTR positions in this bounded
slice, not bidi-aware logical alignment.

`TextOverflowPolicy.reject` fails before publishing a resource when the
typographic advance or line height exceeds the bounds. `.clip` retains the
same metrics, reports `artifact.clipped = 1`, and uses the exact `TextSpec`
bounds as the Canvas clip. It does not silently resize text or bounds.

## Metrics and token provenance

The font size is resolved only through `SemanticTypeToken`; there is no
untracked literal-size override. The paint is resolved only through
`SemanticColorToken`. A successful artifact records both enum values and their
stable IDs, such as `type.caption` and `color.text.primary`.

The line metrics are deterministic fixed-point values:

```text
ascender   = hhea.ascender  * token_size / units_per_em
descender  = hhea.descender * token_size / units_per_em
line_gap   = hhea.lineGap   * token_size / units_per_em
line_height = ascender - descender + line_gap
baseline = bounds.y + (bounds.height - line_height) / 2
         + line_gap / 2 + ascender
```

Integer division follows Zag's deterministic integer rules. Horizontal glyph
origins come from cumulative font-unit advances, so rounding cannot drift per
glyph.

The artifact also exposes exact advance, origin, baseline, scalar and glyph
counts, a path count fixed to one, combined path-command count, path resource
ID, clipping truth, exact bounds, and a content evidence hash. The Canvas owns
a copy of the encoded path bytes and seals its resource store and display list
before build success.

## Semantics ownership

`TextSemanticsMode.own` contributes one `SemanticRole.text` node with the same
stable ID as the Canvas, copied text, scalar count, disabled state, semantic
parent, and exact bounds. Zagkit Talkback therefore queries the same ID and
bounds that identify the visible glyph path.

`TextSemanticsMode.parent_owned` contributes display content only. This is for
components that already own richer semantics for the same visible string. It
does not add a hidden or duplicate text node.

`PerformanceChart` uses this mode. Every `PerformanceChartTextSlot` already
contains the stable ID, owned text, exact bounds, type token, and color token
needed by `text_spec`. The chart's semantic node with that slot ID supplies the
semantic parent:

```zag
let semantic_index: i32 = semantics_find_index(chart.semantics, slot.id);
let spec: TextSpec = text_spec(
    slot.id,
    chart.semantics.nodes.data[semantic_index].parent,
    slot.bounds,
    slot.text.data[0..slot.text.len],
    slot.type_token,
    slot.color_token
);
spec.semantics_mode = TextSemanticsMode.parent_owned;
```

That mapping applies to title, axis name and unit, tick, legend, baseline, and
deadline slots without duplicating the chart's semantic hierarchy or table
representation.

## Caller-owned contribution and failure atomicity

`text_contribute` accepts mutable caller-owned `DisplayList` and
`SemanticsTree` builders. It validates the sealed artifact, semantic parent and
ID, destination capacity, and resource identity before publication. Display
work is applied to a staged owned copy. Only after optional semantics succeed
does the function replace the caller display list.

Duplicate semantic IDs, missing semantic parents, sealed or malformed display
destinations, and path-resource collisions leave both caller-owned builders
unchanged. Disabled owned text follows the same validation path; disabled state
never bypasses duplicate or parent checks. Resource identity is deterministically
namespaced by the Text `NodeKey`, so two visual contributions using the same ID
correctly collide instead of aliasing bytes.

Call `text_free` for every build result, including failed results. It releases
the owned UTF-8 copy and the Canvas-owned display/resource storage. Caller
display lists, semantic trees, Talkback sessions, and CPU raster results retain
their existing explicit cleanup functions.

## Evidence and limits

Run:

```sh
./tools/test-text.sh
```

The focused contract uses Zagkit's synthetic TrueType fixture. It covers strict
input rejection, OpenType-derived baseline metrics, all alignments, semantic
type hierarchy, semantic color provenance, reject and clip overflow, one
combined immutable path, exact clips, owned Text semantics, stable-ID Talkback
querying, chart-compatible parent-owned visual mode, disabled duplicate and
missing-parent atomicity, resource collisions, deterministic CPU pixels, and
cleanup.

This implementation does **not** provide OpenType shaping, GSUB/GPOS, kerning,
normalization, grapheme-aware editing, script itemization, bidirectional text,
logical RTL alignment, wrapping, line breaking, font fallback, CFF/CFF2,
variation axes, color glyphs, locale handling, editable selection, or native
accessibility adapters. It is nominal LTR TrueType outline composition only.
Those exclusions are architectural boundaries, not implied future behavior of
the current artifact.
