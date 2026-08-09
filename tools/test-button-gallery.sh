#!/usr/bin/env bash
set -euo pipefail

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
font=${1:-}
znc=${ZNC:-/home/micah/Desktop/Sylorlabs/zag/zag-poc/znc}

if [ -z "$font" ] && command -v fc-match >/dev/null 2>&1; then
    font=$(fc-match -f '%{file}\n' 'Noto Sans' | head -n 1)
fi
if [ -z "$font" ] || [ ! -f "$font" ]; then
    printf 'button gallery contract: FAIL: no font file resolved\n' >&2
    exit 2
fi

binary=$(mktemp /tmp/zagkit-test-button-gallery.XXXXXX)
cleanup() { rm -f -- "$binary"; }
trap cleanup EXIT

"$znc" "$root/tests/button_gallery_contract.zag" --no-zagd \
    --analyze-strict --no-foreground-cache -o "$binary"
"$binary" "$font"
