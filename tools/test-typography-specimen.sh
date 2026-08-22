#!/usr/bin/env bash
set -euo pipefail

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
znc=${ZNC:-/home/micah/Desktop/Sylorlabs/zag/zag-poc/znc}

if [ "$#" -ne 0 ] && [ "$#" -ne 3 ]; then
    printf '%s\n' \
        'usage: test-typography-specimen.sh [light.ttf regular.ttf bold.ttf]' >&2
    exit 2
fi

light=${ZAGKIT_TYPOGRAPHY_LIGHT_FONT:-${1:-/usr/share/fonts/truetype/dejavu/DejaVuSans-ExtraLight.ttf}}
regular=${ZAGKIT_TYPOGRAPHY_REGULAR_FONT:-${2:-/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf}}
bold=${ZAGKIT_TYPOGRAPHY_BOLD_FONT:-${3:-/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf}}

if [ ! -x "$znc" ]; then
    printf 'typography specimen contract: FAIL: Zag compiler not executable: %s\n' \
        "$znc" >&2
    exit 2
fi

for font in "$light" "$regular" "$bold"; do
    if [ ! -f "$font" ]; then
        printf 'typography specimen contract: FAIL: required font missing: %s\n' \
            "$font" >&2
        exit 2
    fi
done

if cmp -s -- "$light" "$regular" || cmp -s -- "$light" "$bold" ||
    cmp -s -- "$regular" "$bold"; then
    printf '%s\n' \
        'typography specimen contract: FAIL: light regular and bold inputs must be distinct files' >&2
    exit 2
fi

binary=$(mktemp /tmp/zagkit-test-typography-specimen.XXXXXX)
cleanup() { rm -f -- "$binary"; }
trap cleanup EXIT

"$znc" "$root/tests/typography_specimen_contract.zag" --no-zagd \
    --analyze-strict --no-foreground-cache -o "$binary"
"$binary" "$light" "$regular" "$bold"
