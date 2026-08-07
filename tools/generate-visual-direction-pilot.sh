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

render_placeholder() {
  local output_path="$1"
  local direction="$2"
  local scene="$3"
  local locale="$4"
  local variant="$5"

  python3 - "$output_path" "$direction" "$scene" "$locale" "$variant" <<'PY'
import sys
import struct
import zlib
from pathlib import Path

output_path, direction, scene, locale, variant = sys.argv[1:6]
width, height = 960, 540
Path(output_path).parent.mkdir(parents=True, exist_ok=True)

signature = b"\x89PNG\r\n\x1a\n"

accent_map = {
    "direction-a-glass-clarity": (124, 123, 255),
    "direction-b-precision-fabric": (59, 130, 246),
    "direction-c-vector-utility": (16, 185, 129),
}
base = accent_map.get(direction, (148, 163, 184))
base = tuple(int(v) for v in base)

def crc32(data):
    return zlib.crc32(data) & 0xFFFFFFFF

def chunk(type_, data):
    return struct.pack('>I', len(data)) + type_ + data + struct.pack('>I', crc32(type_ + data))

ihdr = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)
ihdr_chunk = chunk(b"IHDR", ihdr)

seed = 0
for b in direction.encode():
    seed = (seed * 131 + b) & 0xFFFFFFFF
for b in scene.encode():
    seed = (seed * 131 + b) & 0xFFFFFFFF
for b in locale.encode():
    seed = (seed * 131 + b) & 0xFFFFFFFF
for b in variant.encode():
    seed = (seed * 131 + b) & 0xFFFFFFFF

rows = []
for y in range(height):
    row = bytearray()
    row.append(0)  # filter method
    for x in range(width):
        phase = (x * 3 + y * 7 + seed) % 256
        r = (base[0] + (x % 16) * 7 + phase // 4) % 256
        g = (base[1] + (y % 12) * 9 + phase // 2) % 256
        b = (base[2] + ((x + y) % 11) * 5 + phase) % 256
        row.extend((r, g, b))
    rows.append(bytes(row))

idat = zlib.compress(b''.join(rows), level=9)
idat_chunk = chunk(b"IDAT", idat)

png = signature + ihdr_chunk + idat_chunk + chunk(b"IEND", b"")

Path(output_path).write_bytes(png)
PY
}

created_count=0
overwritten_count=0
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
                      overwritten_count=$((overwritten_count + 1))
                    fi
                    render_placeholder "$out" "$direction" "$scene" "$locale" "$variant"
                    created_count=$((created_count + 1))
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
echo "overwritten_count=$overwritten_count"
