# Zagkit v2 quickstart

Zagkit v2 is the native Zag visual-system surface. It does not require a browser,
WebView, JavaScript runtime, garbage collector, Skia, Flutter, Qt, or native
widget wrapper.

## Import

```zag
@import("src/zagkit_v2.zag")
```

The current public surface includes:

- semantic solid, veil, and glass material roles;
- bounded renderer effect plans;
- deterministic analytic contact and ambient shadows;
- deterministic RGBA16 material composition;
- dark, light, and high-contrast schemes;
- semantic reduced-motion material targets;
- locale-aware typography metrics;
- continuous-curvature shape resolution;
- Button v2 and Surface v2 visual resolvers.

## Basic setup

```zag
let environment: VisualEnvironment = visual_environment();
environment.backdrop_blur_available = 1;
environment.quality = VisualQualityTier.high;

let state: ButtonInteraction = button_interaction();
let button: ButtonV2ResolvedStyle = button_v2_resolve_style(
    ButtonVariant.primary,
    state,
    VisualColorScheme.dark,
    environment,
    VisualMotionPreference.normal,
);
```

Components select semantic meaning. They do not provide arbitrary shadow,
lighting, blur, RGBA, easing, or local radius values.

## Surfaces

```zag
let state: ButtonInteraction = surface_interaction();

let panel: SurfaceV2VisualStyle = surface_v2_resolve_visual(
    SurfaceTier.panel,
    SurfaceMode.group,
    0, // not floating chrome
    state,
    VisualColorScheme.dark,
    environment,
    VisualMotionPreference.normal,
);

let command_bar: SurfaceV2VisualStyle = surface_v2_resolve_visual(
    SurfaceTier.panel,
    SurfaceMode.group,
    1, // explicit floating chrome
    state,
    VisualColorScheme.dark,
    environment,
    VisualMotionPreference.normal,
);
```

The distinction is intentional:

- content panels and cards are solid;
- persistent floating chrome may become veil;
- transient overlays may become glass;
- compact density and reduced transparency demote effects to solid.

## Effect planning

```zag
let budget: VisualEffectBudget = VisualEffectBudget{
    .viewport_width = 1440,
    .viewport_height = 900,
    .veil_area = 180000,
    .live_glass_layers = 1,
};

let bounds: VisualEffectRect = visual_effect_rect(
    360 * unit_scale(),
    160 * unit_scale(),
    720 * unit_scale(),
    520 * unit_scale(),
);

let plan: VisualEffectPlan = visual_effect_plan(
    bounds,
    VisualSurfaceRole.transient_overlay,
    SemanticElevationToken.overlay,
    environment,
    budget,
    visual_effect_limits(),
);

if (plan.valid == 0) {
    return 1;
}
```

The plan exposes capture bounds, damage bounds, downsample factor, blur passes,
temporary-pixel use, operation count, cache identity, and failure reason before a
renderer changes pixels.

## Visual rules

1. Content-bearing surfaces stay solid.
2. Veil is reserved for persistent floating chrome.
3. Glass is reserved for transient overlays.
4. One scene light controls every edge highlight and shadow.
5. Each elevation uses a contact and ambient shadow pair.
6. Combined veil area may not exceed 25% of the viewport.
7. Only one live glass layer may exist per interaction.
8. Saturated color carries action, focus, status, selection, or data meaning.
9. Keyboard focus is visually independent from hover and selection.
10. Reduced motion removes translation, scale, and blur animation rather than
    globally slowing the interface.

## Verify

```sh
ZNC=/path/to/zag/zag-poc/znc bash tools/test-native-visual-system.sh
```

The suite compiles and executes the public example plus material, effect,
shadow, compositor, theme, motion, typography, shape, Button, and Surface
contracts.
