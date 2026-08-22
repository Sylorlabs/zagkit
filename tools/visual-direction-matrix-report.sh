#!/usr/bin/env bash
set -euo pipefail

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
MANIFEST="$ROOT/docs/design/visual-direction-comparison.json"
MATRIX="$ROOT/docs/design/visual-direction-comparison-matrix.md"
MODE="pilot"
REQUIRE_EXISTING=0

MANIFEST_SET=0
MATRIX_SET=0

usage() {
    cat <<'USAGE'
Usage: visual-direction-matrix-report.sh [--mode pilot|full] [--require-existing] [manifest-path] [matrix-path]

- --require-existing: verify every expected artifact file exists.
- --mode pilot|full: choose the variant scope (default: pilot).
- manifest-path: defaults to docs/design/visual-direction-comparison.json
- matrix-path: defaults to docs/design/visual-direction-comparison-matrix.md
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
        --require-existing)
            REQUIRE_EXISTING=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            if [ "$MANIFEST_SET" -eq 0 ]; then
                MANIFEST="$1"
                MANIFEST_SET=1
            elif [ "$MATRIX_SET" -eq 0 ]; then
                MATRIX="$1"
                MATRIX_SET=1
            else
                echo "too many positional arguments: $1" >&2
                usage
                exit 1
            fi
            shift
            ;;
    esac
done

[ "$MODE" = "pilot" ] || [ "$MODE" = "full" ] || {
    echo "mode must be pilot or full" >&2
    usage
    exit 1
}

[ -f "$MANIFEST" ] || { echo "missing manifest: $MANIFEST" >&2; usage; exit 1; }
[ -f "$MATRIX" ] || { echo "missing matrix document: $MATRIX" >&2; usage; exit 1; }

if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required" >&2
    exit 1
fi

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
  mapfile -t layout_dirs < <(jq -r '.variant_matrix.directions[] | select(. == "ltr")' "$MANIFEST")
  mapfile -t text_scales < <(jq -r '.variant_matrix.text_scales[] | select(. == 1.0 or . == 2.0)' "$MANIFEST")
  mapfile -t motions < <(jq -r '.variant_matrix.motion[] | select(. == "full")' "$MANIFEST")
  mapfile -t transparencies < <(jq -r '.variant_matrix.transparency[] | select(. == "normal")' "$MANIFEST")
  mapfile -t contrasts < <(jq -r '.variant_matrix.contrast[]' "$MANIFEST")
else
  mapfile -t scenes < <(jq -r '.required_scene_ids[]' "$MANIFEST")
  mapfile -t locales < <(jq -r '.variant_matrix.locales[]' "$MANIFEST")
  mapfile -t scales < <(jq -r '.variant_matrix.scale_factors[]' "$MANIFEST")
  mapfile -t themes < <(jq -r '.variant_matrix.themes[]' "$MANIFEST")
  mapfile -t contrasts < <(jq -r '.variant_matrix.contrast[]' "$MANIFEST")
  mapfile -t layout_dirs < <(jq -r '.variant_matrix.directions[]' "$MANIFEST")
  mapfile -t text_scales < <(jq -r '.variant_matrix.text_scales[]' "$MANIFEST")
  mapfile -t motions < <(jq -r '.variant_matrix.motion[]' "$MANIFEST")
  mapfile -t transparencies < <(jq -r '.variant_matrix.transparency[]' "$MANIFEST")
fi

declare -A scale_formats
declare -A text_formats
while IFS='|' read -r raw_key raw_value; do
    scale_formats["$raw_key"]="$raw_value"
done < <(jq -r '.artifact_layout.scale_format | to_entries[] | "\(.key)|\(.value)"' "$MANIFEST")

while IFS='|' read -r raw_key raw_value; do
    text_formats["$raw_key"]="$raw_value"
done < <(jq -r '.artifact_layout.text_scale_format | to_entries[] | "\(.key)|\(.value)"' "$MANIFEST")

root_dir="$(jq -r '.artifact_layout.root // "artifacts/visual-direction"' "$MANIFEST")"

if [ "${#directions[@]}" -eq 0 ] \
  || [ "${#scenes[@]}" -eq 0 ] \
  || [ "${#scales[@]}" -eq 0 ] \
  || [ "${#themes[@]}" -eq 0 ] \
  || [ "${#contrasts[@]}" -eq 0 ] \
  || [ "${#layout_dirs[@]}" -eq 0 ] \
  || [ "${#text_scales[@]}" -eq 0 ] \
  || [ "${#motions[@]}" -eq 0 ] \
  || [ "${#transparencies[@]}" -eq 0 ] \
  || [ "${#locales[@]}" -eq 0 ]; then
    echo "manifest contains empty required arrays" >&2
    exit 1
fi

total_expected=0
missing_files=0

for direction in "${directions[@]}"; do
  for scene in "${scenes[@]}"; do
    for locale in "${locales[@]}"; do
      for scale in "${scales[@]}"; do
        for theme in "${themes[@]}"; do
          for contrast in "${contrasts[@]}"; do
            for layout_dir in "${layout_dirs[@]}"; do
              for text_scale in "${text_scales[@]}"; do
                for motion in "${motions[@]}"; do
                  for transparency in "${transparencies[@]}"; do
                    scale_fmt="${scale_formats[$scale]:-$scale}"
                    text_fmt="${text_formats[$text_scale]:-$text_scale}"
                    variant="scale-${scale_fmt}-theme-${theme}-contrast-${contrast}-dir-${layout_dir}-text-${text_fmt}-motion-${motion}-trans-${transparency}"
                    artifact_path="$root_dir/$direction/$scene/$locale/$variant.png"
                    total_expected=$((total_expected + 1))
                    if [ "$REQUIRE_EXISTING" -eq 1 ] && [ ! -f "$ROOT/$artifact_path" ]; then
                        if [ "$missing_files" -lt 20 ]; then
                            echo "missing: $artifact_path"
                        fi
                        missing_files=$((missing_files + 1))
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

if [ "$REQUIRE_EXISTING" -eq 1 ] && [ "$missing_files" -gt 0 ]; then
    echo "expected=$total_expected missing=$missing_files"
    echo "mode=$MODE"
    echo "FAIL: missing visual-direction captures; for full-gate verification run with --mode full and verify capture availability separately."
    exit 1
fi

if [ "$REQUIRE_EXISTING" -ne 1 ]; then
    echo "No artifact existence check requested."
    echo "mode=$MODE"
    echo "expected_total_artifacts=$total_expected"
    echo "artifact_root=$root_dir"
    echo "direction_count=${#directions[@]} scene_count=${#scenes[@]} locale_count=${#locales[@]}"
fi

if [ "$REQUIRE_EXISTING" -eq 1 ] && [ "$total_expected" -eq 0 ]; then
    echo "mode=$MODE"
    echo "artifact scope is empty"
    exit 1
fi

if ! grep -q "Final accepted direction" "$MATRIX"; then
    echo "matrix file does not yet contain recommendation section"
    exit 2
fi

echo "visual direction comparison matrix document exists and includes recommendation placeholder"
exit 0
