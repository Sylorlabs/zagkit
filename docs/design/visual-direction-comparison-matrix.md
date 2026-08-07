# Visual direction comparison matrix (required for `G0-VISUAL-DIRECTION`)

All captures in this document must be identical across the same scene fixture,
variant tuple, and interaction state.

- Directions: `direction-a-glass-clarity`, `direction-b-precision-fabric`,
  `direction-c-vector-utility`.
- Variant tuple: `scale` x `theme` x `contrast` x `direction` x `text_scale` x
  `motion` x `transparency` x `locale`.
- Locale set: `en-US`, `ar-EG`, `he-IL`, `hi-IN`, `ja-JP`, `th-TH`,
  `zh-Hant-TW`.

## Capture naming convention

`artifacts/visual-direction/<direction-id>/<scene-id>/<locale>/<variant-key>.png`

`variant-key` is canonicalized as:

`scale-{1p0|1p25|1p5|2p0|3p0}-theme-{light|dark}-contrast-{standard|high}-dir-{ltr|rtl}-text-{1p0|1p3|2p0}-motion-{full|reduced}-trans-{normal|reduced}`

## Required comparison scenes

- `type-ramp`
- `bidi-editor`
- `adaptive-dashboard`
- `semantic-form`
- `layer-effects`
- `material-fidelity`
- `asset-fidelity`
- `gesture-handoff`
- `cad-viewport`
- `prismstudio-complete-ui`

## Required interaction states per direction

- baseline
- hover
- focus
- active/press
- selected
- disabled
- error
- loading
- dragging

## Required evidence fields per capture

- legibility score notes by locale
- contrast floor checks
- focus visibility notes
- state legibility notes
- failure or fallback cases
- deterministic checksum hash

## Candidate matrix (initial)

This table starts as empty and fills only after each complete scene sweep.

| Direction | Scene | Variant | Proof packet | Notes |
| --- | --- | --- | --- | --- |
| direction-a-glass-clarity | | | | |
| direction-b-precision-fabric | | | | |
| direction-c-vector-utility | | | | |

## Recommendation memo template

When the comparison is complete, this section becomes the final recommendation:

### Final accepted direction

- Candidate:
- Reason-to-choose:
- Tradeoffs accepted:
- Known risks:
- Additional waivers required:
