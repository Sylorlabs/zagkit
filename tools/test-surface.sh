#!/usr/bin/env bash
set -euo pipefail

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
znc=${ZNC:-/home/micah/Desktop/Sylorlabs/zag/zag-poc/znc}

if [ ! -x "$znc" ]; then
    printf 'surface contract: FAIL: Zag compiler not executable: %s\n' "$znc" >&2
    exit 2
fi

binary=$(mktemp /tmp/zagkit-test-surface.XXXXXX)
negative="$root/tests/negative/surface_return_lifetime.zag"
negative_binary=$(mktemp /tmp/zagkit-test-surface-negative.XXXXXX)
negative_log=$(mktemp /tmp/zagkit-test-surface-negative.XXXXXX.log)
cleanup() {
    rm -f -- "$binary" "$negative_binary" "$negative_log"
}
trap cleanup EXIT

"$znc" "$root/tests/surface_contract.zag" --no-zagd \
    --analyze-strict --no-foreground-cache -o "$binary"
"$binary"

if "$znc" "$negative" --no-zagd --analyze-strict --no-foreground-cache \
    -o "$negative_binary" >"$negative_log" 2>&1; then
    printf '%s\n' \
        'surface lifetime negative: FAIL: released backing compiled successfully' >&2
    exit 1
fi

if ! grep -q 'E0204' "$negative_log" ||
    ! grep -Eqi 'borrow|retain|release|lifetime' "$negative_log"; then
    printf '%s\n' \
        'surface lifetime negative: FAIL: expected structured lifetime rejection' >&2
    sed -n '1,120p' "$negative_log" >&2
    exit 1
fi

printf '%s\n' \
    'surface lifetime negative: ok: backing release rejected before retained spec use'
