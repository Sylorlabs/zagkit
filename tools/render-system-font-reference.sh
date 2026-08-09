#!/usr/bin/env bash
set -euo pipefail

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
font=${1:-}
output=${2:-$root/artifacts/evidence/linux-typography-cpu-oracle.png}
znc=${ZNC:-/home/micah/Desktop/Sylorlabs/zag/zag-poc/znc}

if [ -z "$font" ] && command -v fc-match >/dev/null 2>&1; then
    font=$(fc-match -f '%{file}\n' 'Noto Sans' | head -n 1)
fi
if [ -z "$font" ] || [ ! -f "$font" ]; then
    printf 'typography reference: FAIL: no font file resolved\n' >&2
    exit 2
fi

mkdir -p "$(dirname -- "$output")"
binary=$(mktemp /tmp/zagkit-render-system-font.XXXXXX)
"$znc" "$root/tools/render-system-font-reference.zag" --no-zagd \
    --analyze-strict --no-foreground-cache -o "$binary"
"$binary" "$font" "$output"
printf 'typography reference: PASS (%s using %s)\n' "$output" "$font"
