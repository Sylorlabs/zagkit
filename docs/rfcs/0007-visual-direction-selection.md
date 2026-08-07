# RFC 0007: Visual direction selection

- Status: Proposed
- Decision date: pending
- Owners: Zagkit maintainers

## Background

Milestone 0 blocks visual production until one visual direction is selected. A
comparison between three materially different directions is required so component
implementation and PrismStudio redesign can proceed from one approved target.

This RFC is the final selection mechanism tied to
`docs/design/visual-direction.md` and
`docs/design/visual-direction-comparison-matrix.md`.

## Decision to make

Select exactly one direction:

- `direction-a-glass-clarity`
- `direction-b-precision-fabric`
- `direction-c-vector-utility`

Selection is final when the comparison packet and risk log are reviewed by
maintainers and accessibility review.

## Comparison evidence required

The comparison packet must be complete for all of the following before acceptance:

- 3 directions × required scenes × full variant matrix described in
  `visual-direction-comparison.json`.
- Proof packets for all interaction states listed in the comparison matrix.
- Locale samples for all seven required scripts.
- Accessibility and readability annotations for standard and high contrast modes.
- A final recommendation section with selected direction, known risks,
  justification, and required waivers.

The manifest defines the exact comparison scope:

- `docs/design/visual-direction-comparison.json`
- `docs/design/visual-direction-comparison-matrix.md`

Execution command:

```sh
./tools/visual-direction-matrix-report.sh
```

Use `./tools/visual-direction-matrix-report.sh --require-existing` once captures
exist to validate a complete pass.

## Acceptance criteria for this RFC

This RFC is accepted only if:

1. The selected direction preserves information hierarchy at large text.
2. Contrast and target-size requirements are met and documented per scene.
3. Focus visibility is clear without using motion as the sole state cue.
4. The selected direction can be represented with semantic tokens without
   per-screen escape hatches.
5. A maintainer + accessibility review signs off on risks and waivers.
6. The component inventory remains `planned` until the selected direction is
   implemented in a follow-up production RFC.

Until this RFC is accepted, visual production is paused and component state must
remain `planned`.
