#!/usr/bin/env bash
set -euo pipefail

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
MANIFEST="$ROOT/docs/design/visual-direction-comparison.json"
MATRIX="$ROOT/docs/design/visual-direction-comparison-matrix.md"
OUT_ROOT="$ROOT/artifacts/visual-direction"
PILOT_EXPECTED_COUNT=324

if ! command -v jq >/dev/null 2>&1; then
  echo "jq required" >&2
  exit 1
fi

if [ ! -f "$MANIFEST" ] || [ ! -f "$MATRIX" ]; then
  echo "missing manifest or matrix" >&2
  exit 1
fi

mapfile -t directions < <(jq -r '.candidate_directions[]' "$MANIFEST")
mapfile -t scenes < <(
  jq -r '.required_scene_ids[] | select(. == "type-ramp" or . == "semantic-form" or . == "material-fidelity")' "$MANIFEST"
)
mapfile -t locales < <(
  jq -r '.variant_matrix.locales[] | select(. == "en-US" or . == "ar-EG" or . == "ja-JP")' "$MANIFEST"
)
mapfile -t scales < <(
  jq -r '.variant_matrix.scale_factors[] | select(. == 1.0 or . == 1.5 or . == 2.0)' "$MANIFEST"
)
mapfile -t themes < <(jq -r '.variant_matrix.themes[] | select(. == "light")' "$MANIFEST")
mapfile -t contrasts < <(jq -r '.variant_matrix.contrast[]' "$MANIFEST")
mapfile -t layout_directions < <(jq -r '.variant_matrix.directions[] | select(. == "ltr")' "$MANIFEST")
mapfile -t text_scales < <(
  jq -r '.variant_matrix.text_scales[] | select(. == 1.0 or . == 2.0)' "$MANIFEST"
)
mapfile -t motions < <(jq -r '.variant_matrix.motion[] | select(. == "full")' "$MANIFEST")
mapfile -t transparencies < <(
  jq -r '.variant_matrix.transparency[] | select(. == "normal")' "$MANIFEST"
)

if [ "${#directions[@]}" -eq 0 ] || [ "${#scenes[@]}" -eq 0 ] || [ "${#locales[@]}" -eq 0 ] || [ "${#scales[@]}" -eq 0 ] || [ "${#themes[@]}" -eq 0 ] || [ "${#contrasts[@]}" -eq 0 ] || [ "${#layout_directions[@]}" -eq 0 ] || [ "${#text_scales[@]}" -eq 0 ] || [ "${#motions[@]}" -eq 0 ] || [ "${#transparencies[@]}" -eq 0 ]; then
  echo "pilot selection from manifest produced no values" >&2
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

mkdir -p "$OUT_ROOT"
for direction in "${directions[@]}"; do
  for scene in "${scenes[@]}"; do
    find "$OUT_ROOT/$direction/$scene" -type f -name '*.png' -delete 2>/dev/null || true
  done
done

created_count=0
skipped_count=0
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
                    out="$OUT_ROOT/$direction/$scene/$locale/$variant.png"
                    mkdir -p "$(dirname "$out")"
                    if [ -f "$out" ]; then
                      skipped_count=$((skipped_count + 1))
                    else
                      printf 'pilot placeholder direction=%s scene=%s locale=%s variant=%s\n' \
                        "$direction" "$scene" "$locale" "$variant" > "$out"
                      created_count=$((created_count + 1))
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

expected_count=$(( ${#directions[@]} * ${#scenes[@]} * ${#locales[@]} * ${#scales[@]} * ${#themes[@]} * ${#contrasts[@]} * ${#layout_directions[@]} * ${#text_scales[@]} * ${#motions[@]} * ${#transparencies[@]} ))

if [ "$expected_count" -ne "$PILOT_EXPECTED_COUNT" ]; then
  echo "expected pilot count changed: computed=$expected_count manifest_hint=$PILOT_EXPECTED_COUNT" >&2
fi

echo "pilot placeholder outputs ready under $OUT_ROOT"
echo "expected_pilot_count=$expected_count"
echo "created_count=$created_count"
echo "skipped_count=$skipped_count"
