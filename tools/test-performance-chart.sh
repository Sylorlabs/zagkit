#!/usr/bin/env bash
set -euo pipefail

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
znc=${ZNC:-/home/micah/Desktop/Sylorlabs/zag/zag-poc/znc}

if [ ! -x "$znc" ]; then
    printf 'performance chart contract: FAIL: Zag compiler not executable: %s\n' "$znc" >&2
    exit 2
fi

binary=$(mktemp /tmp/zagkit-test-performance-chart.XXXXXX)
host_binary=$(mktemp /tmp/zagkit-test-performance-chart-host.XXXXXX)
cleanup() { rm -f -- "$binary" "$host_binary"; }
trap cleanup EXIT

"$znc" "$root/tests/performance_chart_contract.zag" --no-zagd \
    --analyze-strict --no-foreground-cache -o "$binary"
"$binary"
"$znc" "$root/tests/performance_chart_host_contract.zag" --no-zagd \
    --analyze-strict --no-foreground-cache -o "$host_binary"
"$host_binary"
