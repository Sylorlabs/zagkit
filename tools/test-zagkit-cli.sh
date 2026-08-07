#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP_ROOT=$(mktemp -d /tmp/zagkit-cli-smoke.XXXXXX)
BIN_PATH="$TMP_ROOT/headless-ref"
PNG_PATH="$TMP_ROOT/headless-reference.png"
SCAFFOLD_DIR="$TMP_ROOT/project"
PROJECT_BIN="$TMP_ROOT/project.bin"
PROJECT_PNG="$TMP_ROOT/project.png"

printf 'zagkit-cli-smoke: using temporary workspace %s\n' "$TMP_ROOT"
printf 'zagkit-cli-smoke: scaffolding a sample project\n'
"$ROOT_DIR/zagkit" init "$SCAFFOLD_DIR"
if [ ! -f "$SCAFFOLD_DIR/zag.mod" ] || [ ! -f "$SCAFFOLD_DIR/src/main.zag" ] || [ ! -f "$SCAFFOLD_DIR/.gitignore" ]; then
  echo 'zagkit-cli-smoke: scaffold did not emit required files'
  exit 1
fi

# Replace scaffolded source with a runnable scene so project mode can be
# validated without changing project initialization defaults.
cp "$ROOT_DIR/tools/render-headless-reference.zag" "$SCAFFOLD_DIR/src/main.zag"
sed -i "s#@import(\\\"../src/render/png_encode.zag\\\")#@import(\\\"$ROOT_DIR/src/render/png_encode.zag\\\")#" "$SCAFFOLD_DIR/src/main.zag"

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

printf 'zagkit-cli-smoke: building sample project\n'
"$ROOT_DIR/zagkit" build --path "$SCAFFOLD_DIR" --output "$PROJECT_BIN" >/tmp/zagkit-cli-project-build.log 2>&1
if [ ! -x "$PROJECT_BIN" ]; then
  echo 'zagkit-cli-smoke: expected sample project binary to be created'
  exit 1
fi

printf 'zagkit-cli-smoke: running sample project with project path\n'
"$ROOT_DIR/zagkit" run --headless-only --project "$SCAFFOLD_DIR" --output "$PROJECT_PNG" >/tmp/zagkit-cli-project-run.log 2>&1
if [ ! -s "$PROJECT_PNG" ]; then
  echo 'zagkit-cli-smoke: expected sample project output PNG to be generated'
  exit 1
fi

if [ ! -s "$PNG_PATH" ]; then
  echo 'zagkit-cli-smoke: expected output PNG to be generated'
  echo '--- zagkit run log ---'
  cat /tmp/zagkit-cli-run.log
  exit 1
fi

printf 'zagkit-cli-smoke: PASS (build, run, run output)\n'
