# Canonical vector paths

Status: experimental headless primitive

Zagkit paths use a Zag-owned immutable command stream rather than backend path
objects. `PathData` records one explicit fill rule and ordered `move_to`,
`line_to`, `quad_to`, `cubic_to`, and `close` commands in the same signed 26.6
fixed-point coordinate domain as layout and display lists.

## Builder and sequence rules

Every contour starts with `move_to`. Line and curve commands require an open
contour; `close` closes exactly one open contour, and more geometry then
requires another move. A new move may begin a new contour without an explicit
close because open contours are legal path input. Empty paths, commands before
a move, duplicate closes, noncanonical unused point fields, out-of-domain
coordinates, and more than 65,536 commands fail before builder mutation.

Sealing computes deterministic identity over the fill rule and every command
field. Sealed builders reject writes, while verification detects direct command
or identity mutation. Callers own each `PathData` and release it with
`path_free`.

## ZKPATH01 bytes

`ZKPATH01` version 1 is the canonical little-endian resource payload. Its
40-byte header contains magic, version, fill rule, command count, and content
hash. Each command occupies 56 bytes: verb plus three fixed-point points.
Unused points must be zero, so one path has one encoding. Decoding is bounded,
reuses the live builder validation path, produces a sealed path, and rejects
bad magic, versions, fill rules, verbs, sequences, geometry, hashes,
truncation, and trailing bytes with an exact offset.

Path render resources use format tag 1. Display-list sealing validates every
owned path payload once, then validates operation references by stable ID,
resource kind, and format. This avoids both opaque-path acceptance and repeated
decode work when one path is drawn many times.

This contract does not yet flatten curves, compute analytic curve extrema,
rasterize fills or strokes, apply dashes, perform boolean path operations, or
decode SVG path syntax. Those remain unavailable until their deterministic,
malformed-input, golden, and cleanup suites pass.
