#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
znc=${ZNC:-/home/micah/Desktop/Sylorlabs/zag/zag-poc/znc}
output=${TMPDIR:-/tmp}/zagkit-linux-preview-layout-contract

cd "$root"
"$znc" tests/linux_preview_layout_contract.zag --no-zagd \
    --analyze-strict --no-foreground-cache -o "$output"
"$output"
