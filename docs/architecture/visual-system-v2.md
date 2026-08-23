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

The result must look contemporary through typography, continuous-curvature
shape, controlled depth, precise spacing, coherent motion, and high-quality
rasterization—not through indiscriminate blur or decoration.

## No-retro visual requirements

A promoted component must meet all of these requirements:

1. It uses semantic type, color, radius, spacing, elevation, and material roles.
2. It never draws a bevel, embossed border, checkerboard stipple, hard black
   drop shadow, or platform-default 1990s chrome.
3. It has distinct rest, hover, keyboard focus, pressed, selected, disabled,
   loading, and error treatments.
4. State is not communicated by color or motion alone.
5. Dense professional content remains crisp and opaque.
6. Corners and one-pixel edges remain stable at 1.0x, 1.25x, 1.5x, 2.0x,
   and 3.0x display scale.
7. Light, dark, high-contrast, reduced-transparency, reduced-motion, RTL, and
   large-text modes are first-class outputs rather than afterthoughts.

## Material system

### Solid

Solid is the default for content-bearing surfaces. It may use elevation,
scene-light edge treatment, and a restrained ambient tint, but never samples the
backdrop.

### Veil

Veil is persistent chrome that genuinely floats over live content. Its total
screen area is capped at 25 percent of the viewport. Compact density, reduced
transparency, and high contrast demote it to solid.

### Glass

Glass is reserved for transient overlays. One live glass layer is permitted per
interaction. Nested recursive glass is invalid. Foreground text and icons are
composited after backdrop processing and target a 7:1 text contrast floor.

## Lighting and shadows

Every window owns one logical scene light. Components select elevation; they do
not invent shadow direction. Each elevated surface resolves to:

- a tight contact shadow that seats the surface;
- a broad, lower-alpha ambient shadow that communicates height;
- a restrained top/leading edge response derived from the same light.

The CPU oracle must use bounded deterministic fixed-point evaluation. GPU
backends consume the same render data and may accelerate it without changing
visual semantics.

## Efficiency gates

- veil area is limited to 25 percent of the viewport;
- one live glass layer is allowed per interaction;
- dense compact interfaces pay no persistent backdrop-sampling cost;
- unsupported backdrop blur uses an explicit deterministic CPU fallback;
- idle material and shadow state requests no frames;
- steady-state layout, paint, hit testing, and semantics do not allocate;
- effect work is clipped to damage-expanded support bounds;
- effect caches are keyed by content identity, scale, color space, material,
  and backend capability;
- device loss, effect fallback, and cache invalidation remain observable.

## Promotion evidence

A component is not visually complete until deterministic evidence covers:

- every canonical state and variant;
- all declared scale factors;
- light and dark themes;
- normal and high contrast;
- reduced transparency and reduced motion;
- compact, standard, and touch density;
- LTR and RTL;
- large text and seven representative script families;
- CPU snapshot identity;
- GPU comparison tolerance when a GPU backend exists;
- frame time, allocations, damage area, effect samples, and cache behavior.
