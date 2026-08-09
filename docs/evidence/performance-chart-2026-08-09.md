# Experimental performance-chart checkpoint — 2026-08-09

This checkpoint records one bounded component contract. It does not claim a
general chart suite, native accessibility, a selected visual direction, or
production polish.

## Focused result

- Strict executable contract: `Performance chart contract: pass=18 fail=0`.
- Retained evidence hash: `1042463816`.
- Deterministic Canvas-only CPU surface hash: `1813314353`.
- The same spec rebuilt with identical display-list, semantic, typography-slot,
  hit-tree, and CPU identity.

## Proved surface

The executable scene contains three named four-point performance series, seven
ticks per axis, an 8 ms baseline, a 16 ms deadline, line ribbons, scatter
marks, a Flex-positioned legend, selected/focused state, available state, and
disabled state. Semantic tokens own every color, radius, elevation, type, and
spacing role.

The parallel semantic tree names both axes and units, references, all ticks,
all series, and a 5 by 4 data table. Talkback activates and focuses the selected
series at stable ID `7100`, rejects disabled series `7102`, queries an exact
table cell by derived stable ID, and keeps pixel fallback disabled.

Twenty-four owned typography slots cover the title, four axis name/unit roles,
fourteen tick labels, three legend names, baseline, and deadline. Each slot
records exact bounds, stable semantic ID, type token, and color token.

## Honest boundary

The CPU hash covers Canvas-owned visual geometry only. The current component
does not itself draw glyphs; a host must render every text slot through Zagkit
Text. Consequently this checkpoint does not include a screenshot and does not
answer native/showcase typography polish. A later composed showcase must render
all twenty-four slots before it can serve as visual chart evidence.
