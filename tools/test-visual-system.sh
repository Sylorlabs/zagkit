#!/usr/bin/env bash
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
ZAG_REPO="${ZAG_REPO:-$ROOT/../zag}"
ZNC="${ZNC:-$ZAG_REPO/zag-poc/znc}"
OUT="${TMPDIR:-/tmp}/zagkit-visual-system-contract"

if [[ ! -x "$ZNC" ]]; then
  echo "error: Zag v2 compiler not found at $ZNC" >&2
  echo "set ZNC=/path/to/zag/zag-poc/znc or place zag beside zagkit" >&2
  exit 2
fi

cd "$ROOT"
rm -f "$OUT"
"$ZNC" tests/visual_system_contract.zag -o "$OUT" --run
rm -f "$OUT"

echo "visual-system contract: pass"
