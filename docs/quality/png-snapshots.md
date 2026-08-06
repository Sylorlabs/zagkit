# Deterministic PNG snapshot bytes

Status: experimental headless evidence primitive

`png_encode_surface` converts a verified owned `CpuSurface` into one canonical
PNG byte stream. It writes the PNG signature, RGBA8 noninterlaced `IHDR`, an
explicit perceptual `sRGB` chunk, one `IDAT`, and `IEND`. Rows use PNG filter
zero. Chunk CRC32, the zlib Adler32 trailer, and stored DEFLATE blocks come from
the pinned pure-Zag standard-library primitives rather than foreign codecs.

The encoder writes no timestamps, text, host metadata, or adaptive compression
choices. Identical CPU pixels and dimensions therefore produce byte-identical
PNG evidence. Width, height, pixel byte count, scanline size, zlib input, every
chunk CRC, decompressed scanline bytes, ordering, and absence of trailing data
have executable contracts.

Stored DEFLATE intentionally favors a small deterministic trusted surface over
file size. PNG decoding is not implemented by this encoder, and a valid PNG
file does not by itself certify layout, accessibility, interaction, or native
presentation.

File persistence, manifest naming, golden comparison, tolerances, retained
Talkback evidence bundles, and actual native screenshot capture remain open.
Until those land, this primitive is deterministic snapshot serialization rather
than the complete snapshot runner or screenshot gate.
