# Typography specimen

Status: `experimental`

`TypographySpecimen` is a reusable headless conformance artifact for Zagkit's
type system. It is intentionally more demanding than a static typography card:
the same artifact owns immutable path rendering, semantic text, stable Talkback
IDs, Flex geometry, adaptive evidence, and explicit failure state.

It does not select Zagkit's 1.0 visual direction. It proves that the current
semantic system can apply a small set of named rules consistently.

## What it proves

The artifact emits thirteen rows in three controlled sections:

| Rows | Variable under test | Fixed inputs |
|---|---|---|
| `0..6` | `display`, `title`, `heading`, `body`, `label`, `caption`, `code` | regular face and `color.text.primary` |
| `7..9` | caller-declared light, regular, and bold faces | `type.body`, identical text, and `color.text.primary` |
| `10..12` | primary, secondary, and disabled text colors | regular face, identical text, and `type.body` |

This isolation matters. A showcase cannot prove a type ramp if size, weight,
and color all change at once. Each section changes one design-system axis and
records the rest as inspectable metadata.

`type.code` is included because it is part of the canonical seven-role ramp.
The current `Text` contract has no font-family routing, so this row uses the
regular face and records `code_family_routing_available = 0`; it proves the
named size role, not a monospace-family implementation.

The successful artifact contains:

- 13 `TypographySpecimenRow` records;
- 26 real `Text` artifacts contributed as OpenType path resources, one label
  and one sample per row;
- 130 retained display operations, because each `Text` contributes the exact
  `save / transform / clip / draw_path / restore` envelope;
- 40 semantic nodes: one specimen group, thirteen row groups, thirteen labels,
  and thirteen samples; and
- one sealed `DisplayList`, one `talkback_tree_hash`, and one aggregate evidence
  hash covering tokens, geometry, font-path evidence, semantics, and display.

There are no placeholder bars, handcrafted SVG glyphs, synthetic bold effects,
or decorative dots standing in for typography.

## Public construction and cleanup

Create a default spec, customize its samples or adaptive context, then build it
with three parsed Zag-owned `OpenTypeFace` values:

```zag
let spec: TypographySpecimenSpec = typography_specimen_spec(
    node_key_scoped(7300, 4),
    rect(0, 0, 1120 * unit_scale(), 720 * unit_scale()));
spec.density = FlexDensity.standard;
spec.direction = LayoutDirection.ltr;
spec.text_scale = unit_scale();

let artifact: TypographySpecimenArtifact = typography_specimen_build(
    spec, &light_face, &regular_face, &bold_face);
if (typography_specimen_valid(&artifact) == 0) {
    // Inspect artifact.error and the subordinate diagnostic fields.
}

typography_specimen_free(&artifact);
```

The three faces are borrowed for the build call. The artifact owns its copied
path resources, semantic strings, row records, and display operations. Call
`typography_specimen_free` on both successful and failed artifacts. The caller
continues to own and eventually free each `OpenTypeFace`.

## Hosting in a larger composition

Build the artifact with the final content rectangle, then host it beneath an
existing semantic group without rebuilding or copying its geometry in the
consumer:

```zag
let hosted: TypographySpecimenHostResult =
    typography_specimen_contribute_hosted(
        &artifact,
        typography_specimen_host_spec(existing_content_group_id),
        &composition_display,
        &composition_semantics);
```

On success the contribution adds exactly 130 display operations, 26 path
resources, and 40 semantic nodes. It reparents only the specimen root to the
declared existing parent. All row, label, and sample IDs, parent links, bounds,
display owners, and resource IDs remain unchanged. There is no hit-tree
contribution because the specimen is intentionally read-only.

The destination display must be valid and unsealed. The semantic parent must be
the semantic root or already exist in the destination tree. The API preflights
semantic IDs, resource IDs, and destination resource capacity, stages a full
copy of the current display, then appends semantics under a checkpoint. Missing
parents, duplicate semantic IDs, resource collisions, resource limits, display
errors, and semantic errors leave both caller destinations unchanged. The
source artifact remains immutable and reusable after either success or failure.

## Stable identity and Talkback

The caller supplies one positive root `NodeKey`. Zagkit derives every child ID
without pixel inference:

```text
root.value * 1000 + 100 + row * 10  -> row group
root.value * 1000 + 101 + row * 10  -> row label
root.value * 1000 + 102 + row * 10  -> row sample
```

The root generation is preserved for every child. These IDs are unchanged by
density, text scale, or layout direction. `TypographySpecimenRow` records the
same rectangles used by Flex, `Text`, semantics, and Talkback queries.

Specimen nodes are intentionally non-actionable. Talkback can discover and
query them by ID, but click fails with `action_unavailable`. The disabled
contrast sample also carries semantic disabled state; it is not merely dimmer
paint.

## Flex spacing and adaptive behavior

All repeated geometry resolves through Flex tokens:

| Purpose | Token |
|---|---|
| outer inset | `FlexSpacingToken.large` |
| row gap | `FlexSpacingToken.small` |
| row internal padding | `FlexSpacingToken.small` |
| label-to-sample gap | `FlexSpacingToken.large` |

`FlexDensity.compact`, `standard`, and `touch` resolve those tokens through the
canonical density function. An outer column owns row placement. Each row owns
an inner two-column Flex layout. A layout that cannot honor minimum content
width or required row height returns `layout_overflow`; it does not silently
overlap or compress text into unreadable geometry.

At standard density and `1x` text, `typography_specimen_required_height`
returns `666 px`. The structural two-column minimum is `344 px`, but the
default display sample in DejaVu Sans needs a `705 px` useful width after the
current equal-shrink Flex allocation. Therefore the existing `1120 x 720`
medium content region fits the default specimen. The two-step large-text
fixture requires `814.5 px` of height and is tested in the `1360 x 900`
expanded reference window. Custom strings and fonts can require more width;
`TextError.overflow` remains the authoritative fail-closed result.

RTL mirrors the two logical columns and their edge alignment while preserving
the same IDs. This is **RTL layout evidence only**. The current `Text` component
uses nominal LTR glyph runs, so the artifact records:

- `rtl_layout_applied = 1` when requested;
- `nominal_ltr_text_only = 1`;
- `bidi_shaping_available = 0`; and
- `font_fallback_available = 0`.

Do not use this specimen to claim Arabic, Hebrew, mixed-direction shaping, or
font fallback support. Those remain upstream text-engine work.

## Large text

The current text engine has named semantic sizes but no continuous font-scale
primitive. The specimen therefore uses an explicit, deterministic semantic-role
substitution policy:

| Effective scale | Substitution |
|---|---|
| `1.0 .. <1.25` | requested role |
| `1.25 .. <1.75` | one step larger |
| `1.75 .. 4.0` | two steps larger |

Roles cap at `type.display`. For example, two steps map `body -> title` and
`caption -> body`. Flex recomputes row height from the resolved role, while IDs
remain stable. Both requested and resolved roles are stored in every row.

This policy is real adaptive behavior, but it is not continuous scaling. The
artifact keeps `continuous_text_scaling_available = 0` so screenshots and
automation cannot overstate the implementation.

## Weight truth

Zagkit does not synthesize bold by stroking or offsetting glyphs. The caller
must provide three distinct font faces. Before emitting any semantics or display
operations, the build renders the same text, size, ID, and bounds through each
face and hashes the encoded path payload. All three hashes must be nonzero and
pairwise different. Otherwise the build returns `weight_not_visible` with an
empty showcase output.

The current OpenType parser does not yet expose or validate the `OS/2` weight
class, so `weight_metadata_verified` remains `0`. Distinct outline evidence
proves that the visual weight slots are not aliases; the caller-declared labels
remain an explicit boundary until metadata parsing lands upstream.

## Font and text failure

All three faces are validated before layout publication. A missing or invalid
face returns `missing_font` and identifies light (`0`), regular (`1`), or bold
(`2`) in `missing_face_index`. No rows, semantic nodes, or display operations
are emitted in that case.

Malformed UTF-8, missing glyph coverage, invalid outlines, and line-box overflow
remain strict `Text` failures. Zagkit does not inject replacement glyphs, borrow
an OS text renderer, or silently choose a different font.

## Verification

Run the focused contract with the default DejaVu Sans family:

```sh
tools/test-typography-specimen.sh
```

Or provide three exact TrueType files:

```sh
tools/test-typography-specimen.sh \
  /path/to/Light.ttf /path/to/Regular.ttf /path/to/Bold.ttf
```

The runner rejects missing files and byte-identical face inputs before compile.
Environment overrides are also available as
`ZAGKIT_TYPOGRAPHY_LIGHT_FONT`, `ZAGKIT_TYPOGRAPHY_REGULAR_FONT`, and
`ZAGKIT_TYPOGRAPHY_BOLD_FONT`.

The contract covers the complete semantic ramp, single-variable weight and
contrast strips, exact Flex-to-semantics geometry, stable IDs across compact RTL
and large text, Talkback queries, deterministic CPU pixels, atomic hosted
contribution and collision rollback, missing fonts, fake weight aliases, layout
overflow, and cleanup.
