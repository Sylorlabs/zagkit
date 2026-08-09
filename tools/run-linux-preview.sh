#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ZAG_BIN=${ZAG_BIN:-${ZNC:-/home/micah/Desktop/Sylorlabs/zag/zag-poc/znc}}
BUILD_DIR="$ROOT_DIR/.zagkit"
PREVIEW_BINARY="$BUILD_DIR/linux-preview"

if ! [ -x "$ZAG_BIN" ]; then
  printf 'zagkit linux preview: missing compiler executable: %s\n' "$ZAG_BIN" >&2
  exit 2
fi
if ! ldconfig -p 2>/dev/null | grep -F 'libX11.so.6' >/dev/null; then
  printf 'zagkit linux preview: libX11.so.6 is unavailable\n' >&2
  exit 2
fi

mkdir -p "$BUILD_DIR"
printf 'zagkit: building native Linux X11 fallback preview\n'
"$ZAG_BIN" "$ROOT_DIR/examples/linux_preview.zag" --dynamic \
  --needed libX11.so.6 --no-zagd --analyze-strict --no-foreground-cache \
  -o "$PREVIEW_BINARY"
printf 'zagkit: launching native Linux preview (%s)\n' "$PREVIEW_BINARY"
exec "$PREVIEW_BINARY" "$@"
