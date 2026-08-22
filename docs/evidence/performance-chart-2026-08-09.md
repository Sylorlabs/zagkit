# Experimental performance-chart checkpoint — 2026-08-09

This checkpoint records one bounded component contract. It does not claim a
general chart suite, native accessibility, a selected visual direction, or
production polish.

## Current verification status

The previous retained and CPU hashes are intentionally retired because the
chart display list now contains role-specific marker geometry and explicit
legend state treatments. Reusing those hashes would certify an obsolete image.

Focused command:

```sh
ZNC=/tmp/znc-resource-flow-stage6 ./tools/test-performance-chart.sh
```

The Stage 6 compiler has SHA-256
`74868c0f1e61c978afaf1daf97bf2dea20fd357cd8bed75200d4b816a661501d`.
The strict command reached typed declaration analysis with no parse, import,
name, or ordinary type diagnostic, then mandatory ownership checking failed
with 713 `E0204` diagnostics before binary emission. The exact family totals
are: 427 owners falsely reported as neither released, moved, nor returned; 117
false read/write-after-move reports; 50 false argument-after-move reports; 29
false named-owner requirements at existing `@consumes` calls; 15 false
release-after-move or partial-path reports; 15 false initialization-source
reports; 15 false `ArrayList` element-move reports; 12 false partial-path
release reports; 11 false empty-move reports; seven false unavailable move
sources; five borrowed-view escapes; four scope-end ownership reports; four
borrowed-value escapes; one return-borrow report; and one live-overwrite report.

The complete output is retained locally at
`/tmp/zagkit-performance-chart-stage6-strict.log`. Because the first component
contract did not compile, neither that binary nor the hosted contract ran.
This is a fail-closed upstream Zag result, not chart evidence. The canonical
checker is being fixed in `/home/micah/Desktop/Sylorlabs/zag`; Zagkit does not
weaken the contract or add ownership annotations around a broken checker. No
new executable pass count, retained hash, CPU hash, hosted result, or screenshot
is claimed until the next strict compiler gate reaches runtime.

Static review after the Stage 6 attempt passed `git diff --check` across the
component, both focused contracts, and both chart documents. It also confirmed
the closed four-state enum, non-ready series rejection, empty-only axis
preservation, loading/error live-region mapping, non-ready legend/table
suppression, policy-specific hit counts, and absence of local color literals.
These are source invariants only; they do not replace executable evidence.

## Proved by the source contract

The bounded scene defines three named four-point performance series, seven
ticks per axis, an 8 ms baseline, a 16 ms deadline, retained line ribbons,
role-specific marks, and one Flex-positioned legend. Its series system is
closed and semantic:

- `reference` maps to the primary chart color and circle marker;
- `comparison` maps to the secondary chart color and rounded-square marker;
- `diagnostic` maps to the tertiary chart color and lozenge marker.

Roles cannot repeat within a chart and role/color mismatches fail before any
retained output. The scene covers selected plus focused, hovered, and disabled
legend entries. A separate style contract covers the default state and checks
all five treatments from the same resolver.

The component now has a closed `ready`, `loading`, `empty`, and `error` content
state contract. Ready retains the exact series/table behavior above. Every
non-ready state requires zero series and publishes zero table dimensions,
legend nodes, series hits, focus order, and actions. Loading and error also
require zero axis ticks. Empty axes are retained only through the explicit
`preserve_empty_axes` flag and omit baseline/deadline references. Invalid
combinations fail before retained display, semantics, or hit mutation.

Loading, empty, and error resolve a retained status artifact for panel,
indicator, name, value, and optional loading-track geometry. Loading publishes
a polite `progress` status, empty a polite named zero-data status, and error an
assertive failure status. Accent, chart-axis, error, surface, and text colors
all come from semantic tokens. The visual status strings and semantic
name/value deliberately carry the same truth; no sample points are synthesized.

Tick, grid, reference-line, text-slot, and semantic placement consume shared
geometry records. Legend Flex runs once; its resolved item, focus, marker,
text, and selection bounds are stored in the artifact and reused by display,
hit testing, semantics, and typography composition.

The parallel semantic tree names both axes and units, references, all ticks,
all series, and a 5 by 4 data table. The focused contract checks every header
and sample cell against the plotted source, queries named Talkback selected,
focused, and disabled state bits, and keeps pixel fallback disabled.

Twenty-four owned ready typography slots cover the title, four axis name/unit roles,
fourteen tick labels, three legend names, baseline, and deadline. Each slot
records exact bounds, stable semantic ID, type token, and color token.
Loading, ordinary empty, and error own three slots (title plus two status
strings); the seven-by-seven meaningful-empty-axis fixture owns 21.

## Hosted boundary

The hosted contract contributes the same built artifact beneath explicit caller
semantic and hit parents. It preserves chart-local IDs and child parentage,
offsets focus order through a caller-selected collision-checked range, stages
display ownership, and fails atomically on duplicate IDs or missing parents.
For the focused fixture, ready contribution is exactly 52 semantic nodes and
one read-only or four actionable hits. Loading, ordinary empty, and error are
exactly three semantic nodes and one hit; meaningful empty axes are 21 and one.
A duplicate status ID is preflighted atomically with no destination mutation.

The CPU oracle covers Canvas-owned geometry only. The component does not itself
draw glyphs; a host must render every text slot through Zagkit Text. Therefore
this checkpoint includes no screenshot and makes no native typography-polish
claim. A composed showcase must render all twenty-four slots before it can be
used as visual chart evidence.
