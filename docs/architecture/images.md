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

This is not PNG support yet. PNG parsing, decompression, filters, palettes,
grayscale expansion, profiles, bomb limits, and malformed-stream handling must
produce this canonical image form through their own verified decoder. Linear
light filtering, Display P3 conversion, wide-gamut surfaces, mipmapping,
high-quality downsampling, image tiling, and GPU upload caches also remain
unavailable.
