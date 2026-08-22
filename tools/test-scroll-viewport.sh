#!/usr/bin/env bash
set -euo pipefail

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
znc=${ZNC:-/home/micah/Desktop/Sylorlabs/zag/zag-poc/znc}

if [ ! -x "$znc" ]; then
    printf 'scroll viewport contract: FAIL: Zag compiler not executable: %s\n' "$znc" >&2
    exit 2
fi

binary=$(mktemp /tmp/zagkit-test-scroll-viewport.XXXXXX)
cleanup() { rm -f -- "$binary"; }
trap cleanup EXIT

"$znc" "$root/tests/scroll_viewport_contract.zag" --no-zagd \
    --analyze-strict --no-foreground-cache -o "$binary"
"$binary"
