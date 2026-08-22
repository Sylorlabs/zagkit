#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
znc=${ZNC:-/home/micah/Desktop/Sylorlabs/zag/zag-poc/znc}
font=${1:-}

if [ -z "$font" ] && command -v fc-match >/dev/null 2>&1; then
    font=$(fc-match -f '%{file}\n' sans | head -n 1)
fi
if [ -z "$font" ] || [ ! -f "$font" ]; then
    printf 'system font smoke: SKIP: no system sans font was resolved\n'
    exit 77
fi

tmp=$(mktemp -d /tmp/zagkit-system-font.XXXXXX)
cleanup() { rm -rf "$tmp"; }
trap cleanup EXIT

"$znc" "$root/tools/test-system-font.zag" --no-zagd --analyze-strict \
    --no-foreground-cache -o "$tmp/test-system-font"
"$tmp/test-system-font" "$font"
printf 'system font smoke: PASS (%s)\n' "$font"
