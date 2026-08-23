#!/usr/bin/env bash
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
ZAG_REPO="${ZAG_REPO:-$ROOT/../zag}"
ZNC="${ZNC:-$ZAG_REPO/zag-poc/znc}"
OUT="${TMPDIR:-/tmp}/zagkit-surface-v2-policy-contract"

if [[ ! -x "$ZNC" ]]; then
  echo "error: Zag v2 compiler not found at $ZNC" >&2
  exit 2
fi

cd "$ROOT"
rm -f "$OUT"
"$ZNC" tests/surface_v2_policy_contract.zag -o "$OUT" --run
rm -f "$OUT"

echo "surface v2 policy contract: pass"
