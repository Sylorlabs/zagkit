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
"$znc" tests/state_reconcile_contract.zag --no-zagd --no-analyze --no-foreground-cache -o "$tmp/state-reconcile-contract"
"$tmp/state-reconcile-contract"
"$znc" tests/semantics_contract.zag --no-zagd --no-analyze --no-foreground-cache -o "$tmp/semantics-contract"
"$tmp/semantics-contract"
"$znc" tests/talkback_contract.zag --no-zagd --no-analyze --no-foreground-cache -o "$tmp/talkback-contract"
"$tmp/talkback-contract"
"$znc" tests/display_list_contract.zag --no-zagd --no-analyze --no-foreground-cache -o "$tmp/display-list-contract"
"$tmp/display-list-contract"

printf 'headless test: PASS (state, reconciliation, constraints, Flex, semantics, Talkback, and display lists)\n'
