#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
znc=${ZNC:-/home/micah/Desktop/Sylorlabs/zag/zag-poc/znc}

[ -x "$znc" ] || {
    printf 'visual-system v2 policy: FAIL: Zag compiler not executable: %s\n' "$znc" >&2
    exit 1
}

tmp=$(mktemp -d /tmp/zagkit-visual-v2.XXXXXX)
cleanup() { rm -rf "$tmp"; }
trap cleanup EXIT

cd "$root"
"$znc" tests/visual_system_v2_policy_contract.zag \
    --no-zagd --analyze-strict --no-foreground-cache \
    -o "$tmp/visual-system-v2-policy"
"$tmp/visual-system-v2-policy"

printf 'visual-system v2 policy: PASS\n'
