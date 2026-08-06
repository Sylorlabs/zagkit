# Canonical decoded images

Status: experimental headless primitive

Zagkit separates encoded assets from renderer-ready pixels. Canonical decoded
image resources use format tag 1, explicit positive width and height, explicit
color-space metadata, and exactly `width * height * 4` owned RGBA8 bytes in
row-major order. Channels use straight alpha at the ownership boundary.

Dimension and byte-count arithmetic is overflow checked before allocation or
indexing. Unknown schemas, absent color-space truth, mismatched payload size,
zero dimensions, and dimensions above the shared hard limits fail during
display-list resource validation, before draw operations seal.

## CPU sampling

The current CPU oracle renders canonical sRGB images into positive
axis-aligned destination rectangles. It maps destination and source pixel
centers, performs deterministic 8-bit bilinear interpolation in premultiplied
form to avoid transparent-edge color fringes, then converts back to straight
color for source-over composition. A 4 by 4 coverage grid handles fractional
destination edges and clips separately from texture filtering, so one-to-one
integer placement preserves exact texels. Operation alpha is the only paint
modulation; unused paint channels must remain canonical.

Transformed destination geometry and pixel-sample work have explicit ceilings.
Unsupported color-space conversion fails at the exact draw operation before
pixels are touched. The deterministic replay scene exercises the owned image,
display-list, and CPU route.

## PNG ingestion

`png_decode(bytes)` is the owned, fail-closed path from encoded PNG assets to
the canonical image form. It validates the signature, chunk type spelling and
reserved bit, chunk ordering, duplicate single-instance metadata, every CRC32, IEND,
and absence of trailing data before trusting image content. IDAT payloads are
joined under an encoded-input ceiling and decoded by the pinned pure-Zag
stored/fixed/dynamic DEFLATE inflater with the exact expected scanline byte
count as its output ceiling.

The decoder reverses None, Sub, Up, Average, and Paeth filters. It accepts the
legal grayscale, RGB, indexed, grayscale-alpha, and RGBA bit-depth combinations,
including packed 1/2/4-bit samples, PLTE, and tRNS. Noninterlaced rows and all
seven bounded Adam7 passes reconstruct into the same canonical pixels.
Renderer-owned output is always straight-alpha sRGB RGBA8. Sixteen-bit samples
use their high byte as the current deterministic conversion policy;
transparency comparisons use the original full sample before conversion. Files
without explicit color
metadata use Zagkit's documented sRGB fallback policy; this is an assumption
recorded by the asset pipeline, not a claim that the source declared sRGB. An
explicit `sRGB` chunk, or the exact standard sRGB `gAMA` plus `cHRM` pair,
records a declared profile. A matching gamma without declared primaries still
records the fallback as assumed.
`png_decode_resource_spec`
adapts a successful owned result to the normal copying resource-store API, so
the decoder can be freed immediately after insertion.

Dimension, encoded-data, decompressed-scanline, output-pixel, palette-index,
filter, and arithmetic limits fail before out-of-bounds access. Explicit iCCP,
non-sRGB chromaticity conversion, and non-sRGB gAMA values fail as unsupported
color profiles. Unknown interlace methods fail before decompression. These
unavailable paths keep `G3-PNG` open until general profile conversion, scale
suites, and broader malformed-input fuzzing land.

Linear-light filtering, Display P3 conversion, wide-gamut surfaces, mipmapping,
high-quality downsampling, image tiling, and GPU upload caches also remain
unavailable.
