#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP_ROOT=$(mktemp -d /tmp/zagkit-linux-preview.XXXXXX)
CAPTURE="$TMP_ROOT/linux-preview.png"

cleanup() { rm -rf "$TMP_ROOT"; }
trap cleanup EXIT

if [ -z "${DISPLAY:-}" ]; then
  printf 'linux preview test: SKIP: DISPLAY is unavailable\n'
  exit 77
fi

"$ROOT_DIR/zagkit" run --linux-preview --output "$CAPTURE"
if [ ! -s "$CAPTURE" ]; then
  printf 'linux preview test: FAIL: native capture was not written\n' >&2
  exit 1
fi
if [ "$(od -An -tx1 -N8 "$CAPTURE" | tr -d ' \n')" != "89504e470d0a1a0a" ]; then
  printf 'linux preview test: FAIL: capture is not a PNG\n' >&2
  exit 1
fi
dimensions=$(file "$CAPTURE")
case "$dimensions" in
  *"1120 x 720"*) ;;
  *) printf 'linux preview test: FAIL: unexpected capture: %s\n' "$dimensions" >&2; exit 1 ;;
esac
printf 'linux preview test: PASS (native X11 create, CPU present, sync, capture, cleanup)\n'
