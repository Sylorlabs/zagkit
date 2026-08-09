#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
znc=${ZNC:-/home/micah/Desktop/Sylorlabs/zag/zag-poc/znc}

[ -x "$znc" ] || {
    printf 'headless test: FAIL: Zag compiler not executable: %s\n' "$znc" >&2
    exit 1
}

tmp=$(mktemp -d /tmp/zagkit-headless.XXXXXX)
cleanup() { rm -rf "$tmp"; }
trap cleanup EXIT

cd "$root"
"$znc" tests/platform_capabilities_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/platform-capabilities-contract"
"$tmp/platform-capabilities-contract"
"$znc" tests/unicode_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/unicode-contract"
"$tmp/unicode-contract"
"$znc" tests/segmentation_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/segmentation-contract"
"$tmp/segmentation-contract"
"$znc" tests/opentype_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/opentype-contract"
"$tmp/opentype-contract"
"$znc" tests/opentype_fuzz.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/opentype-fuzz"
"$tmp/opentype-fuzz"
"$znc" tests/glyph_path_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/glyph-path-contract"
"$tmp/glyph-path-contract"
"$znc" tests/glyph_run_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/glyph-run-contract"
"$tmp/glyph-run-contract"
"$znc" tests/glyph_run_codec_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/glyph-run-codec-contract"
"$tmp/glyph-run-codec-contract"
"$znc" tests/flex_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/flex-contract"
"$tmp/flex-contract"
"$znc" tests/flex_adaptive_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/flex-adaptive-contract"
"$tmp/flex-adaptive-contract"
"$znc" tests/design_tokens_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/design-tokens-contract"
"$tmp/design-tokens-contract"
"$znc" tests/button_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/button-contract"
"$tmp/button-contract"
if ! command -v fc-match >/dev/null 2>&1; then
    printf 'headless test: FAIL: Button gallery requires fontconfig fc-match\n' >&2
    exit 1
fi
gallery_font=$(fc-match -f '%{file}\n' 'Noto Sans' | sed -n '1p')
if [ -z "$gallery_font" ] || [ ! -f "$gallery_font" ]; then
    printf 'headless test: FAIL: Button gallery could not resolve a system font\n' >&2
    exit 1
fi
"$znc" tests/button_gallery_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/button-gallery-contract"
"$tmp/button-gallery-contract" "$gallery_font"
"$znc" tests/canvas_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/canvas-contract"
"$tmp/canvas-contract"
"$znc" tests/performance_chart_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/performance-chart-contract"
"$tmp/performance-chart-contract"
"$znc" tests/measure_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/measure-contract"
"$tmp/measure-contract"
"$znc" tests/overlay_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/overlay-contract"
"$tmp/overlay-contract"
"$znc" tests/grid_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/grid-contract"
"$tmp/grid-contract"
"$znc" tests/scroll_virtual_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/scroll-virtual-contract"
"$tmp/scroll-virtual-contract"
"$znc" tests/virtual_collections_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/virtual-collections-contract"
"$tmp/virtual-collections-contract"
"$znc" tests/state_reconcile_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/state-reconcile-contract"
"$tmp/state-reconcile-contract"
"$znc" tests/semantics_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/semantics-contract"
"$tmp/semantics-contract"
"$znc" tests/collection_semantics_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/collection-semantics-contract"
"$tmp/collection-semantics-contract"
"$znc" tests/talkback_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/talkback-contract"
"$tmp/talkback-contract"
"$znc" tests/linux_preview_semantics_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/linux-preview-semantics-contract"
"$tmp/linux-preview-semantics-contract"
"$znc" tests/render_resources_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/render-resources-contract"
"$tmp/render-resources-contract"
"$znc" tests/path_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/path-contract"
"$tmp/path-contract"
"$znc" tests/image_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/image-contract"
"$tmp/image-contract"
"$znc" tests/png_encode_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/png-encode-contract"
"$tmp/png-encode-contract"
"$znc" tests/png_decode_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/png-decode-contract"
"$tmp/png-decode-contract"
"$znc" tests/png_decode_fuzz.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/png-decode-fuzz"
"$tmp/png-decode-fuzz"
"$znc" tools/render-headless-reference.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/render-headless-reference"
"$tmp/render-headless-reference" "$tmp/reference-first.png"
"$tmp/render-headless-reference" "$tmp/reference-second.png"
[ "$(wc -c < "$tmp/reference-first.png")" -gt 100000 ]
[ "$(od -An -tx1 -N8 "$tmp/reference-first.png" | tr -d ' \n')" = "89504e470d0a1a0a" ]
cmp -s "$tmp/reference-first.png" "$tmp/reference-second.png"
printf 'Reference snapshot contract: pass=3 fail=0\n'
"$znc" tools/render-linux-preview-reference.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/render-linux-preview-reference"
"$tmp/render-linux-preview-reference" "$tmp/linux-preview-first.png"
"$tmp/render-linux-preview-reference" "$tmp/linux-preview-second.png"
[ "$(od -An -tx1 -N8 "$tmp/linux-preview-first.png" | tr -d ' \n')" = "89504e470d0a1a0a" ]
cmp -s "$tmp/linux-preview-first.png" "$tmp/linux-preview-second.png"
printf 'Linux preview CPU snapshot contract: pass=2 fail=0\n'
"$znc" tests/display_list_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/display-list-contract"
"$tmp/display-list-contract"
"$znc" tests/display_list_codec_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/display-list-codec-contract"
"$tmp/display-list-codec-contract"
"$znc" tests/cpu_raster_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/cpu-raster-contract"
"$tmp/cpu-raster-contract"
"$znc" tests/input_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/input-contract"
"$tmp/input-contract"
"$znc" tests/replay_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/replay-contract"
"$tmp/replay-contract"
"$znc" tests/motion_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/motion-contract"
"$tmp/motion-contract"

printf 'headless test: PASS (backend truth, state, reconciliation, intrinsic measurement, constraints, Flex, shared Button state/render/hit/semantics/Talkback plus its executable conformance gallery, retained Canvas immediate drawing, bounded accessible performance-chart anatomy, Grid, Overlay, scroll, virtual list, Table, Tree, recycling, Unicode grapheme segmentation, positioned glyph-run transport, collection semantics, Talkback, native-preview semantics, owned render resources, canonical paths and images, bounded PNG decode, display lists, analytic rounded geometry, CPU shape and image raster, deterministic PNG snapshots, input, replay, and motion)\n'
