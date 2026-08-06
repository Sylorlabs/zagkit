# Render resource ownership

Status: experimental headless primitive

`RenderResourceStore` is the ownership and identity boundary for bytes that
feed Zagkit paths, decoded images, glyph runs, effects, fonts, SVG, and PNG. It
is not itself a decoder and does not make an opaque payload renderable.
SVG parsing, PNG parsing and color management, font validation, glyph shaping,
and decoded rendering remain separate open contracts. Canonical path payloads
are the first typed schema layered over this store; see [paths](paths.md).

## Identity and metadata

Every resource has a positive stable ID, one explicit kind, a positive format
tag, revision, owned byte payload, optional dimensions, and color-space truth.
Decoded image resources require positive dimensions and a nonempty color space.
The format tag identifies a caller-defined canonical payload schema; it is not
interpreted by this layer.

New IDs begin at revision zero. Replacement retains the same ID and kind and
must advance exactly one revision. Missing replacement targets, stale or
skipped revisions, and kind changes fail before the old payload is released.
Payload bytes are copied at successful add or replacement, so callers retain no
borrowed lifetime obligation.

## Bounds and canonical order

Each store declares resource-count, total-byte, and per-payload ceilings within
hard library maxima. Configuration, empty payload, metadata, per-payload,
aggregate, duplicate-ID, and count errors are checked before ownership changes.
Tests use intentionally small limits to prove each failure without expensive
allocations.

Resources are retained in stable-ID order regardless of insertion order.
Content identity covers configuration, byte accounting, store revision,
resource metadata, per-resource revision, and every payload byte. Two stores
with the same resources therefore have the same identity even when populated
in different orders.

## Immutability and cleanup

Sealing first verifies the complete store. A sealed store rejects add and
replacement. Verification detects order changes, byte mutations, metadata or
revision changes, forged accounting, invalid limits, and aggregate identity
changes. `render_resource_store_free` releases every owned payload and then the
resource array; callers invoke it exactly once for every store, sealed or not.

`DisplayList` now owns this store. Sealing verifies that every resource-bearing
operation resolves an existing resource of the exact required kind. Resource
bytes, metadata, allocation policy, and replacement revisions contribute to
the display-list revision and content identity. `ZKDL` version 2 serializes the
canonical resource section before operations and reconstructs it through the
same bounded validation path; decoding and re-encoding are byte identical.

The current executable contract still does not decode SVG or PNG, validate font
tables, interpret glyph payload schemas, rasterize path strokes or images,
cache platform uploads, or implement memory-pressure eviction. Those
capabilities remain unavailable until their own malformed-input, rendering,
replacement, and cleanup suites pass.
