#!/usr/bin/env bash
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
ZAG_REPO="${ZAG_REPO:-$ROOT/../zag}"
ZNC="${ZNC:-$ZAG_REPO/zag-poc/znc}"
TMP="${TMPDIR:-/tmp}"

if [[ ! -x "$ZNC" ]]; then
  echo "error: Zag v2 compiler not found at $ZNC" >&2
  echo "set ZNC=/path/to/zag/zag-poc/znc or place zag beside zagkit" >&2
  exit 2
fi

cd "$ROOT"

run_contract() {
  local source="$1"
  local output="$TMP/zagkit-${source##*/}"
  output="${output%.zag}"
  rm -f "$output"
  "$ZNC" "$source" -o "$output" --run
  rm -f "$output"
}

run_contract tests/visual_system_contract.zag
run_contract tests/effect_plan_contract.zag

echo "native visual-system contracts: pass"
