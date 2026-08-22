#!/usr/bin/env bash
set -euo pipefail

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
znc=${ZNC:-/home/micah/Desktop/Sylorlabs/zag/zag-poc/znc}
light=${1:-}
regular=${2:-}
bold=${3:-}

if [ ! -x "$znc" ]; then
    printf 'Linux preview composition: FAIL: Zag compiler not executable: %s\n' "$znc" >&2
    exit 2
fi
if [ "$#" -ne 0 ] && [ "$#" -ne 3 ]; then
    printf '%s\n' \
        'usage: tools/test-linux-preview-composition.sh [light regular bold]' >&2
    exit 2
fi
if [ -z "$regular" ] && command -v fc-match >/dev/null 2>&1; then
    light=$(fc-match -f '%{file}\n' 'Fira Sans:style=Light' | head -n 1)
    regular=$(fc-match -f '%{file}\n' 'Fira Sans:style=Regular' | head -n 1)
    bold=$(fc-match -f '%{file}\n' 'Fira Sans:style=Bold' | head -n 1)
fi
if [ -z "$light" ] || [ -z "$regular" ] || [ -z "$bold" ] ||
    [ ! -f "$light" ] || [ ! -f "$regular" ] || [ ! -f "$bold" ]; then
    printf 'Linux preview composition: SKIP: three font weights were not resolved\n'
    exit 77
fi
if cmp -s -- "$light" "$regular" || cmp -s -- "$regular" "$bold" ||
    cmp -s -- "$light" "$bold"; then
    printf 'Linux preview composition: SKIP: resolved font weights are not distinct\n'
    exit 77
fi

binary=$(mktemp /tmp/zagkit-test-linux-preview-composition.XXXXXX)
cleanup() { rm -f -- "$binary"; }
trap cleanup EXIT

"$znc" "$root/tests/linux_preview_composition_contract.zag" --no-zagd \
    --analyze-strict --no-foreground-cache -o "$binary"
"$binary" "$light" "$regular" "$bold"
