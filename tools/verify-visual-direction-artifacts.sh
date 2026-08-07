#!/usr/bin/env bash
set -euo pipefail

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
MANIFEST="$ROOT/docs/design/visual-direction-comparison.json"
MATRIX="$ROOT/docs/design/visual-direction-comparison-matrix.md"
OUT_ROOT="$ROOT/artifacts/visual-direction"
MODE="full"
EXACT=0

usage() {
  cat <<'USAGE'
Usage: verify-visual-direction-artifacts.sh [--mode pilot|full] [--exact]

- --mode pilot: verify only the first-pass pilot subset from
  docs/design/visual-direction-comparison-matrix.md
- --mode full: verify the full required variant matrix
- --exact: fail if extra PNG artifacts exist for the selected mode scope
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --mode)
      if [ "$#" -lt 2 ]; then
        echo "missing mode value" >&2
        usage
        exit 1
      fi
      MODE="$2"
      shift 2
      ;;
    --exact)
      EXACT=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [ "$MODE" != "pilot" ] && [ "$MODE" != "full" ]; then
  echo "mode must be pilot or full" >&2
  usage
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq required" >&2
  exit 1
fi

[ -f "$MANIFEST" ] || { echo "missing manifest: $MANIFEST" >&2; exit 1; }
[ -f "$MATRIX" ] || { echo "missing matrix document: $MATRIX" >&2; exit 1; }

if ! jq -e '.candidate_directions and .required_scene_ids and .variant_matrix and .artifact_layout' "$MANIFEST" >/dev/null 2>&1; then
  echo "manifest missing required keys" >&2
  exit 1
fi

mapfile -t directions < <(jq -r '.candidate_directions[]' "$MANIFEST")

if [ "$MODE" = "pilot" ]; then
  mapfile -t scenes < <(jq -r '.required_scene_ids[] | select(. == "type-ramp" or . == "semantic-form" or . == "material-fidelity")' "$MANIFEST")
  mapfile -t locales < <(jq -r '.variant_matrix.locales[] | select(. == "en-US" or . == "ar-EG" or . == "ja-JP")' "$MANIFEST")
  mapfile -t scales < <(jq -r '.variant_matrix.scale_factors[] | select(. == 1.0 or . == 1.5 or . == 2.0)' "$MANIFEST")
  mapfile -t themes < <(jq -r '.variant_matrix.themes[] | select(. == "light")' "$MANIFEST")
  mapfile -t contrasts < <(jq -r '.variant_matrix.contrast[]' "$MANIFEST")
  mapfile -t layout_directions < <(jq -r '.variant_matrix.directions[] | select(. == "ltr")' "$MANIFEST")
  mapfile -t text_scales < <(jq -r '.variant_matrix.text_scales[] | select(. == 1.0 or . == 2.0)' "$MANIFEST")
  mapfile -t motions < <(jq -r '.variant_matrix.motion[] | select(. == "full")' "$MANIFEST")
  mapfile -t transparencies < <(jq -r '.variant_matrix.transparency[] | select(. == "normal")' "$MANIFEST")
else
  mapfile -t scenes < <(jq -r '.required_scene_ids[]' "$MANIFEST")
  mapfile -t locales < <(jq -r '.variant_matrix.locales[]' "$MANIFEST")
  mapfile -t scales < <(jq -r '.variant_matrix.scale_factors[]' "$MANIFEST")
  mapfile -t themes < <(jq -r '.variant_matrix.themes[]' "$MANIFEST")
  mapfile -t contrasts < <(jq -r '.variant_matrix.contrast[]' "$MANIFEST")
  mapfile -t layout_directions < <(jq -r '.variant_matrix.directions[]' "$MANIFEST")
  mapfile -t text_scales < <(jq -r '.variant_matrix.text_scales[]' "$MANIFEST")
  mapfile -t motions < <(jq -r '.variant_matrix.motion[]' "$MANIFEST")
  mapfile -t transparencies < <(jq -r '.variant_matrix.transparency[]' "$MANIFEST")
fi

if [ "${#directions[@]}" -eq 0 ] || [ "${#scenes[@]}" -eq 0 ] || [ "${#locales[@]}" -eq 0 ] || [ "${#scales[@]}" -eq 0 ] || [ "${#themes[@]}" -eq 0 ] || [ "${#contrasts[@]}" -eq 0 ] || [ "${#layout_directions[@]}" -eq 0 ] || [ "${#text_scales[@]}" -eq 0 ] || [ "${#motions[@]}" -eq 0 ] || [ "${#transparencies[@]}" -eq 0 ]; then
  echo "manifest selection for ${MODE} mode produced empty set(s)" >&2
  exit 1
fi


declare -A scale_formats
declare -A text_formats
while IFS='|' read -r raw_key raw_value; do
  scale_formats["$raw_key"]="$raw_value"
done < <(jq -r '.artifact_layout.scale_format | to_entries[] | "\(.key)|\(.value)"' "$MANIFEST")
while IFS='|' read -r raw_key raw_value; do
  text_formats["$raw_key"]="$raw_value"
done < <(jq -r '.artifact_layout.text_scale_format | to_entries[] | "\(.key)|\(.value)"' "$MANIFEST")

total_expected=0
missing=0
invalid=0

require_png() {
  local file="$1"
  python3 - "$file" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
data = path.read_bytes()
if data[:8] != b"\x89PNG\r\n\x1a\n":
    raise SystemExit(1)
PY
}

for direction in "${directions[@]}"; do
  for scene in "${scenes[@]}"; do
    for locale in "${locales[@]}"; do
      for scale in "${scales[@]}"; do
        for theme in "${themes[@]}"; do
          for contrast in "${contrasts[@]}"; do
            for layout_dir in "${layout_directions[@]}"; do
              for text_scale in "${text_scales[@]}"; do
                for motion in "${motions[@]}"; do
                  for transparency in "${transparencies[@]}"; do
                    scale_fmt="${scale_formats[$scale]:-$scale}"
                    text_fmt="${text_formats[$text_scale]:-$text_scale}"
                    variant="scale-${scale_fmt}-theme-${theme}-contrast-${contrast}-dir-${layout_dir}-text-${text_fmt}-motion-${motion}-trans-${transparency}"
                    artifact_path="$OUT_ROOT/$direction/$scene/$locale/$variant.png"
                    total_expected=$((total_expected + 1))
                    if [ ! -f "$artifact_path" ]; then
                      missing=$((missing + 1))
                      if [ "$missing" -le 20 ]; then
                        echo "missing: $artifact_path"
                      fi
                    elif ! require_png "$artifact_path" >/dev/null 2>&1; then
                      invalid=$((invalid + 1))
                      if [ "$invalid" -le 20 ]; then
                        echo "invalid artifact: $artifact_path"
                      fi
                    fi
                  done
                done
              done
            done
          done
        done
      done
    done
  done
done

if [ "$missing" -ne 0 ]; then
  echo "mode=$MODE expected=$total_expected missing=$missing"
  echo "FAIL: missing artifacts"
  exit 1
fi

if [ "$invalid" -ne 0 ]; then
  echo "mode=$MODE expected=$total_expected invalid_png=$invalid"
  echo "FAIL: non-PNG artifacts found"
  exit 1
fi

if [ "$EXACT" -eq 1 ]; then
  declare -A expected_files=()
  for direction in "${directions[@]}"; do
    for scene in "${scenes[@]}"; do
      for locale in "${locales[@]}"; do
        for scale in "${scales[@]}"; do
          for theme in "${themes[@]}"; do
            for contrast in "${contrasts[@]}"; do
              for layout_dir in "${layout_directions[@]}"; do
                for text_scale in "${text_scales[@]}"; do
                  for motion in "${motions[@]}"; do
                    for transparency in "${transparencies[@]}"; do
                      scale_fmt="${scale_formats[$scale]:-$scale}"
                      text_fmt="${text_formats[$text_scale]:-$text_scale}"
                      variant="scale-${scale_fmt}-theme-${theme}-contrast-${contrast}-dir-${layout_dir}-text-${text_fmt}-motion-${motion}-trans-${transparency}"
                      artifact_path="$OUT_ROOT/$direction/$scene/$locale/$variant.png"
                      expected_files["$artifact_path"]=1
                    done
                  done
                done
              done
            done
          done
        done
      done
    done
  done

  actual_in_scope=0
  for direction in "${directions[@]}"; do
    for scene in "${scenes[@]}"; do
      while IFS= read -r -d '' file; do
        if [ "${expected_files[$file]:-0}" != "1" ]; then
          echo "extra artifact in scoped run: ${file#${ROOT}/}"
          exit 1
        fi
        actual_in_scope=$((actual_in_scope + 1))
      done < <(find "$OUT_ROOT/$direction/$scene" -type f -name '*.png' -print0)
    done
  done

  if [ "$actual_in_scope" -ne "$total_expected" ]; then
    echo "mode=$MODE expected=$total_expected actual_in_scope=$actual_in_scope"
    echo "FAIL: expected exact scoped artifact count"
    exit 1
  fi
fi


if [ "$EXACT" -eq 0 ]; then
  echo "mode=$MODE expected=$total_expected existing=true"
fi
echo "matrix artifact verification passed for mode=$MODE"
exit 0
