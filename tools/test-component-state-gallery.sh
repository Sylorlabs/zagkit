#!/usr/bin/env bash
set -euo pipefail

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
znc=${ZNC:-/home/micah/Desktop/Sylorlabs/zag/zag-poc/znc}

if [ "$#" -gt 1 ]; then
    printf '%s\n' 'usage: test-component-state-gallery.sh [font.ttf]' >&2
    exit 2
fi

font=${ZAGKIT_COMPONENT_GALLERY_FONT:-${1:-/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf}}

if [ ! -x "$znc" ]; then
    printf 'component state gallery contract: FAIL: Zag compiler not executable: %s\n' \
        "$znc" >&2
    exit 2
fi

if [ ! -f "$font" ]; then
    printf 'component state gallery contract: FAIL: required font missing: %s\n' \
        "$font" >&2
    exit 2
fi

binary=$(mktemp /tmp/zagkit-test-component-state-gallery.XXXXXX)
cleanup() { rm -f -- "$binary"; }
trap cleanup EXIT

"$znc" "$root/tests/component_state_gallery_contract.zag" --no-zagd \
    --analyze-strict --no-foreground-cache -o "$binary"
"$binary" "$font"
