#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$root"

fail() {
    printf 'showcase conformance check: FAIL: %s\n' "$1" >&2
    exit 1
}

require_file() {
    [ -f "$1" ] || fail "missing required file: $1"
}

require_text() {
    path=$1
    pattern=$2
    reason=$3
    grep -Fq -- "$pattern" "$path" || fail "$reason"
}

for path in \
    docs/design/showcase-conformance.md \
    docs/design/semantic-tokens.md \
    docs/components/surface.md \
    docs/components/segmented-control.md \
    docs/components/performance-chart.md \
    docs/showcase/component-state-gallery.md \
    docs/showcase/typography-specimen.md \
    src/design/tokens.zag \
    src/components/surface.zag \
    src/components/segmented_control.zag \
    src/components/performance_chart.zag \
    src/showcase/component_state_gallery.zag \
    src/showcase/typography_specimen.zag \
    src/showcase/linux_preview_composition.zag \
    tests/component_state_gallery_contract.zag \
    tests/typography_specimen_contract.zag; do
    require_file "$path"
done

# Screen and component code may resolve semantic roles, but may not create a
# private color scale. The renderer and token authority are the only places
# where literal channel values belong.
if rg -n 'paint_rgba16[[:space:]]*\(' src/components src/showcase >/tmp/zagkit-showcase-rgba.txt; then
    sed -n '1,20p' /tmp/zagkit-showcase-rgba.txt >&2
    fail "component/showcase source contains local RGBA literals"
fi

require_text src/design/tokens.zag 'enum SemanticColorToken' \
    "semantic color-token authority is missing"
require_text src/design/tokens.zag 'enum SemanticTypeToken { display, title, heading, body, label, caption, code }' \
    "complete visible typography ramp is missing"
require_text src/design/tokens.zag 'enum SemanticElevationToken { base, panel, raised, overlay }' \
    "ordered elevation tiers are missing"
require_text src/design/tokens.zag 'enum ShowcaseCategory { frame_pacing, semantics, motion, input, renderer }' \
    "status/category meaning is not declared"
require_text docs/design/semantic-tokens.md 'Category never implies health, selection, or action.' \
    "category color semantics are not documented"
require_text docs/design/semantic-tokens.md 'It contains no' \
    "read-only status-rail truth is not documented"

for tier in base panel raised overlay; do
    require_text src/showcase/component_state_gallery.zag "SurfaceTier.$tier" \
        "component gallery does not render Surface tier: $tier"
done
for state in REST HOVER FOCUS PRESSED SELECTED LOADING ERROR DISABLED; do
    require_text src/showcase/component_state_gallery.zag "\"$state\"" \
        "component gallery does not visibly name canonical state: $state"
done
for primitive in \
    '@import("../components/button.zag")' \
    '@import("../components/navigation_item.zag")' \
    '@import("../components/segmented_control.zag")' \
    '@import("../components/surface.zag")' \
    '@import("../components/text.zag")'; do
    require_text src/showcase/component_state_gallery.zag "$primitive" \
        "component gallery is not composed from canonical primitive: $primitive"
done

require_text src/components/performance_chart.zag \
    'enum PerformanceChartContentState { ready, loading, empty, error }' \
    "chart does not expose ready/loading/empty/error states"
for anatomy in x_axis_name x_axis_unit y_axis_name y_axis_unit \
    baseline_value deadline_value; do
    require_text src/components/performance_chart.zag "$anatomy" \
        "chart contract is missing anatomy: $anatomy"
done
require_text src/components/performance_chart.zag 'SemanticRole.table' \
    "chart has no semantic table equivalent"
require_text src/components/performance_chart.zag \
    'PerformanceChartLegendInteractionPolicy { read_only, actionable }' \
    "chart legend cannot distinguish read-only evidence from actions"

require_text src/components/segmented_control.zag 'selected_index' \
    "segmented control has no retained selection model"
require_text src/components/segmented_control.zag 'roving_index' \
    "segmented control has no roving keyboard target"
require_text src/components/segmented_control.zag 'focus_visible' \
    "segmented control cannot distinguish actual and visible focus"

for primitive in performance_chart segmented_control surface text; do
    require_text src/showcase/linux_preview_composition.zag \
        "@import(\"../components/$primitive.zag\")" \
        "native showcase composition does not import canonical $primitive"
done
require_text src/showcase/linux_preview_composition.zag \
    '@import("typography_specimen.zag")' \
    "native showcase does not host the typography specimen"
require_text src/showcase/linux_preview_composition.zag \
    'struct LinuxPreviewInteractionState' \
    "native showcase has no shared NodeKey interaction state"
require_text tools/test-linux-interaction.sh \
    'INSPECT_PRESS_PATTERN=' \
    "native gate does not prove a real pressed component state"
require_text tools/test-linux-interaction.sh \
    'TYPOGRAPHY_FOCUS_PATTERN=' \
    "native gate does not prove keyboard-visible navigation focus"
if grep -Fq '@import("linux_preview_scene.zag")' \
    src/showcase/linux_preview_composition.zag examples/linux_preview.zag \
    tools/render-linux-preview-reference.zag; then
    fail "native or CPU-reference entrypoint still imports the legacy one-off scene"
fi

require_text docs/design/showcase-conformance.md \
    'Rendering, semantics, hit testing, and Talkback consume one shared Flex' \
    "single placement-authority rule is missing"
require_text docs/design/showcase-conformance.md \
    'A translucent rounded rectangle or' \
    "showcase contract no longer rejects fake liquid-glass claims"
require_text docs/design/showcase-conformance.md \
    'soft multi-lobe shadows' \
    "showcase contract no longer requires modern shadow composition"
require_text docs/design/showcase-conformance.md \
    'Screenshot review is necessary but insufficient.' \
    "showcase contract no longer distinguishes screenshots from QA"

printf 'showcase conformance check: PASS (static system invariants only)\n'
