#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP_ROOT=$(mktemp -d /tmp/zagkit-cli-smoke.XXXXXX)
BIN_PATH="$TMP_ROOT/headless-ref"
PNG_PATH="$TMP_ROOT/headless-reference.png"

printf 'zagkit-cli-smoke: using temporary workspace %s\n' "$TMP_ROOT"
printf 'zagkit-cli-smoke: checking command help output\n'
"$ROOT_DIR/zagkit" --help >/tmp/zagkit-cli-help.log 2>&1 || {
  cat /tmp/zagkit-cli-help.log
  exit 1
}

printf 'zagkit-cli-smoke: building headless reference binary\n'
"$ROOT_DIR/zagkit" build --output "$BIN_PATH" >/tmp/zagkit-cli-build.log 2>&1

if [ ! -x "$BIN_PATH" ]; then
  echo 'zagkit-cli-smoke: expected build output binary to exist'
  exit 1
fi
if [ ! -s "$BIN_PATH" ]; then
  echo 'zagkit-cli-smoke: expected build output binary to be non-empty'
  exit 1
fi

printf 'zagkit-cli-smoke: running headless reference command\n'
"$ROOT_DIR/zagkit" run --headless-only --binary "$BIN_PATH" --output "$PNG_PATH" >/tmp/zagkit-cli-run.log 2>&1

if [ ! -s "$PNG_PATH" ]; then
  echo 'zagkit-cli-smoke: expected output PNG to be generated'
  echo '--- zagkit run log ---'
  cat /tmp/zagkit-cli-run.log
  exit 1
fi

printf 'zagkit-cli-smoke: PASS (build, run, run output)\n'
