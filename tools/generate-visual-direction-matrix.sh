#!/usr/bin/env bash
set -euo pipefail

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
MANIFEST="$ROOT/docs/design/visual-direction-comparison.json"
OUT_ROOT="$ROOT/artifacts/visual-direction"

MODE="pilot"
MAX_ITEMS=0
START_INDEX=0
ALLOW_FULL=0
DRY_RUN=0
VERBOSE="${VD_VERBOSE:-0}"
usage() {
  cat <<'USAGE'
Usage: generate-visual-direction-matrix.sh [--mode pilot|full] [--max-items N] [--start-index N] [--allow-full] [--dry-run]

- mode pilot: default small scope (same set as 324-capture pilot gate).
- mode full: renders every required manifest combination (currently 100,800 artifacts).
  Full mode requires --allow-full because it can be expensive.
  - max-items: stop after writing this many captures (0 = unlimited).
  - start-index: zero-based index into scope before writing begins (default 0).
- dry-run: report counts and target artifact paths without writing.
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
    --max-items)
      if [ "$#" -lt 2 ]; then
        echo "missing max-items value" >&2
        usage
        exit 1
      fi
      MAX_ITEMS="$2"
      if ! [[ "$MAX_ITEMS" =~ ^[0-9]+$ ]]; then
        echo "--max-items must be a non-negative integer" >&2
        exit 1
      fi
      shift 2
      ;;
    --start-index)
      if [ "$#" -lt 2 ]; then
        echo "missing start-index value" >&2
        usage
        exit 1
      fi
      START_INDEX="$2"
      if ! [[ "$START_INDEX" =~ ^[0-9]+$ ]]; then
        echo "--start-index must be a non-negative integer" >&2
        exit 1
      fi
      shift 2
      ;;
    --allow-full)
      ALLOW_FULL=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
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

if [ "$MODE" = "full" ] && [ "$ALLOW_FULL" -ne 1 ]; then
  echo "full mode requires --allow-full" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq required" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 required" >&2
  exit 1
fi

[ -f "$MANIFEST" ] || { echo "missing manifest: $MANIFEST" >&2; exit 1; }

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

scope_expected=$(( ${#directions[@]} * ${#scenes[@]} * ${#locales[@]} * ${#scales[@]} * ${#themes[@]} * ${#contrasts[@]} * ${#layout_directions[@]} * ${#text_scales[@]} * ${#motions[@]} * ${#transparencies[@]} ))

if [ "$START_INDEX" -ge "$scope_expected" ]; then
  echo "start-index ($START_INDEX) is outside scope ($scope_expected)"
  exit 0
fi

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
target_index=0
written_this_run=0

if [ "$DRY_RUN" -eq 0 ]; then
  mkdir -p "$OUT_ROOT"
fi

if [ "$MODE" = "pilot" ]; then
  for direction in "${directions[@]}"; do
    for scene in "${scenes[@]}"; do
        find "$OUT_ROOT/$direction/$scene" -type f -name '*.png' -delete 2>/dev/null || true
    done
  done
fi

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
                    if [ "$target_index" -lt "$START_INDEX" ]; then
                      target_index=$((target_index + 1))
                      continue
                    fi

                    if [ "$MAX_ITEMS" -gt 0 ] && [ "$written_this_run" -ge "$MAX_ITEMS" ]; then
                      break 10
                    fi

                    scale_fmt="${scale_formats[$scale]:-$scale}"
                    text_fmt="${text_formats[$text_scale]:-$text_scale}"
                    variant="scale-${scale_fmt}-theme-${theme}-contrast-${contrast}-dir-${layout_dir}-text-${text_fmt}-motion-${motion}-trans-${transparency}"
                    out="$OUT_ROOT/$direction/$scene/$locale/$variant.png"
                    if [ "$DRY_RUN" -eq 0 ]; then
                      if [ -f "$out" ]; then
                        overwritten_count=$((overwritten_count + 1))
                      fi
                      render_placeholder "$out" "$direction" "$scene" "$locale" "$variant"
                      created_count=$((created_count + 1))
                    fi

                    if [ "$VERBOSE" -ne 0 ]; then
                      echo "target: ${direction}/${scene}/${locale}/${variant}.png"
                    fi

                    target_index=$((target_index + 1))
                    written_this_run=$((written_this_run + 1))
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

if [ "$DRY_RUN" -ne 0 ]; then
  echo "visual-direction generation dry-run"
  echo "mode=$MODE expected_total=$scope_expected"
  echo "start_index=$START_INDEX"
  if [ "$MAX_ITEMS" -gt 0 ]; then
    echo "requested_end_index=$((START_INDEX + MAX_ITEMS))"
  else
    echo "requested_end_index=$scope_expected"
  fi
  echo "max_items=${MAX_ITEMS:-0}"
  echo "max_items_stops_at=$(( MAX_ITEMS > 0 ? MAX_ITEMS : scope_expected ))"
  exit 0
fi

if [ "$DRY_RUN" -eq 0 ] && [ "$MAX_ITEMS" -gt 0 ] && [ "$written_this_run" -ge "$MAX_ITEMS" ] && [ "$written_this_run" -lt "$scope_expected" ]; then
  echo "visual-direction generation complete with limit reached"
else
  echo "visual-direction generation complete"
fi
echo "mode=$MODE expected_total=$scope_expected"
echo "requested_max_items=$MAX_ITEMS"
echo "created_count=$created_count"
echo "overwritten_count=$overwritten_count"
echo "actual_targets=$written_this_run"
