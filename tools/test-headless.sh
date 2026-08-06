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
"$znc" tests/flex_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/flex-contract"
"$tmp/flex-contract"
"$znc" tests/flex_adaptive_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/flex-adaptive-contract"
"$tmp/flex-adaptive-contract"
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
"$znc" tests/render_resources_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/render-resources-contract"
"$tmp/render-resources-contract"
"$znc" tests/path_contract.zag --no-zagd --analyze-strict --no-foreground-cache -o "$tmp/path-contract"
"$tmp/path-contract"
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

printf 'headless test: PASS (state, reconciliation, intrinsic measurement, constraints, Flex, Grid, Overlay, scroll, virtual list, Table, Tree, recycling, collection semantics, Talkback, owned render resources, canonical paths, display lists, CPU path raster, input, replay, and motion)\n'
