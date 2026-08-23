# ZagKit v2 visual-system contract

Status: **active foundation**

This contract upgrades ZagKit's visual layer without replacing its retained
identity, state, reconciliation, Flex, semantics, input, replay, or display-list
architecture.

## Product rule

ZagKit v2 separates **material role** from **elevation**:

- canvases, content panels, cards, tables, editors, and form fields are solid;
- persistent chrome may use a bounded veil only while floating over live content;
- transient menus, popovers, command palettes, and dialogs may use glass;
- compact density demotes veil to solid;
- reduced transparency and high contrast demote all translucency to solid;
- one scene light derives every contact shadow, ambient shadow, and edge cue.

## Rendering contract

`fill_rounded_shadow` is the first native analytic effect operation. Its
`bounds` and `parameter` describe the source rounded rectangle; paint alpha owns
shadow opacity and `paint.stroke_width` owns the finite blur support radius.
The operation allocates no temporary image, has a hard blur limit, participates
in deterministic display identity and codec transport, and is implemented by
the CPU oracle with fixed-point signed-distance falloff.

Future GPU backends must consume the same operation and remain within the
published CPU tolerance. They may accelerate evaluation but may not reinterpret
the material system.

## Efficiency gates

- veil area is limited to 25% of the viewport;
- one live glass layer is allowed per interaction;
- shadow work is clipped to blur-expanded damage bounds;
- dense compact interfaces pay no persistent backdrop-sampling cost;
- unsupported backdrop blur uses the explicit deterministic CPU fallback;
- idle material and shadow state requests no frames.
