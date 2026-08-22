#!/usr/bin/env bash
set -euo pipefail

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ZNC=${ZNC:-${ZAG_BIN:-/home/micah/Desktop/Sylorlabs/zag/zag-poc/znc}}

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <output.png>" >&2
  exit 2
fi

if [ ! -x "$ZNC" ]; then
  echo "render-headless-reference: missing executable $ZNC" >&2
  echo "set ZNC to a valid compiler executable and retry." >&2
  exit 2
fi

TMP=$(mktemp -d /tmp/zagkit-reference.XXXXXX)
trap 'find "$TMP" -depth -delete' EXIT

cd "$ROOT"
"$ZNC" tools/render-headless-reference.zag \
  --no-zagd --analyze-strict --no-foreground-cache \
  -o "$TMP/render-headless-reference"
"$TMP/render-headless-reference" "$1"
