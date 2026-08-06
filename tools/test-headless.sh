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
"$znc" tests/flex_contract.zag --no-zagd --no-analyze --no-foreground-cache -o "$tmp/flex-contract"
"$tmp/flex-contract"

printf 'headless test: PASS (constraints and Flex)\n'
