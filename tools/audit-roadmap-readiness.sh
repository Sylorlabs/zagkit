#!/usr/bin/env bash
set -euo pipefail

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

DATE_STAMP=${1:-$(date +%Y-%m-%d)}
OUT_MD="docs/evidence/goal-readiness-audit-${DATE_STAMP}.md"
OUT_JSON="docs/evidence/goal-readiness-audit-${DATE_STAMP}.json"
OUT_AGENT_CHECKLIST="docs/evidence/agent-checklist-${DATE_STAMP}.md"
AGENT_CHECKLIST_LINK="$(basename "$OUT_AGENT_CHECKLIST")"
RUN_RUNTIME_CHECKS="${ZAGKIT_AUDIT_RUN_RUNTIME_CHECKS:-1}"
RUN_VISUAL_FULL_CHECK="${ZAGKIT_AUDIT_RUN_VISUAL_FULL_CHECK:-1}"
RUN_VISUAL_PILOT_CHECK="${ZAGKIT_AUDIT_RUN_VISUAL_PILOT_CHECK:-1}"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 1
fi

if [ ! -f GOAL.md ]; then
  echo "missing GOAL.md" >&2
  exit 1
fi

goal_total=$(grep -Ec '^- \[[ x]\] `[^`]+` ' GOAL.md || true)
goal_completed=$(grep -Ec '^- \[x\] ' GOAL.md || true)
goal_blocked=$((goal_total - goal_completed))
goal_ids=$(grep -E '^- \[ \] `[^`]+` ' GOAL.md | sed -E 's/^- \[ \] `([^`]+)`.*/\1/' || true)

upstream_total=$(jq '.entries | length' contracts/upstream-zag.json)
upstream_available=$(jq '[.entries[] | select(.state=="available")] | length' contracts/upstream-zag.json)
upstream_partial=$(jq '[.entries[] | select(.state=="partial")] | length' contracts/upstream-zag.json)
upstream_missing=$(jq '[.entries[] | select(.state=="missing")] | length' contracts/upstream-zag.json)
upstream_missing_ids=$(jq -r '[.entries[] | select(.state=="missing") | .id] | join(", ")' contracts/upstream-zag.json)

platform_total=$(jq '[.platforms[].capabilities[]] | length' contracts/platforms.json)
platform_unavailable=$(jq '[.platforms[].capabilities[] | select(.state=="unavailable")] | length' contracts/platforms.json)
platform_blockers=$(jq -r '[.platforms[].capabilities[] | select(.state=="unavailable") | "\(.id) / \(.reason)" ] | .[:40]' contracts/platforms.json)

check_binary_existence() {
  local path=$1
  local yes_no="missing"
  if [ -f "$path" ]; then
    yes_no="present"
  fi
  printf '%s:%s' "$path" "$yes_no"
}

can_write_path() {
  local path=$1
  local probe="${path%/}/.zagkit_write_probe_$$"
  if python3 - "$path" "$probe" <<'PY'
import sys, os
probe = sys.argv[2]
try:
    with open(probe, 'w', encoding='utf-8'):
        pass
    os.unlink(probe)
except Exception as err:
    print(f'err:{type(err).__name__}:{err}')
    sys.exit(1)
else:
    print('ok')
PY
  then
    :
  else
    return 1
  fi
}

visual_expected_count() {
  local mode="$1"
  local count
  local arr_directions
  local arr_scenes
  local arr_locales
  local arr_scales
  local arr_themes
  local arr_contrasts
  local arr_directions_layout
  local arr_text_scales
  local arr_motions
  local arr_transparencies

  arr_directions=$(jq -r '.candidate_directions | length' contracts/../docs/design/visual-direction-comparison.json 2>/dev/null || echo 0)
  if [ "$arr_directions" = "null" ]; then
    echo 0
    return 0
  fi

  if [ "$mode" = "pilot" ]; then
    arr_scenes=$(jq -r '[.required_scene_ids[] | select(. == "type-ramp" or . == "semantic-form" or . == "material-fidelity")] | length' contracts/../docs/design/visual-direction-comparison.json)
    arr_locales=$(jq -r '[.variant_matrix.locales[] | select(. == "en-US" or . == "ar-EG" or . == "ja-JP")] | length' contracts/../docs/design/visual-direction-comparison.json)
    arr_scales=$(jq -r '[.variant_matrix.scale_factors[] | select(. == 1.0 or . == 1.5 or . == 2.0)] | length' contracts/../docs/design/visual-direction-comparison.json)
    arr_themes=$(jq -r '[.variant_matrix.themes[] | select(. == "light")] | length' contracts/../docs/design/visual-direction-comparison.json)
    arr_contrasts=$(jq -r '.variant_matrix.contrast | length' contracts/../docs/design/visual-direction-comparison.json)
    arr_directions_layout=$(jq -r '[.variant_matrix.directions[] | select(. == "ltr")] | length' contracts/../docs/design/visual-direction-comparison.json)
    arr_text_scales=$(jq -r '[.variant_matrix.text_scales[] | select(. == 1.0 or . == 2.0)] | length' contracts/../docs/design/visual-direction-comparison.json)
    arr_motions=$(jq -r '[.variant_matrix.motion[] | select(. == "full")] | length' contracts/../docs/design/visual-direction-comparison.json)
    arr_transparencies=$(jq -r '[.variant_matrix.transparency[] | select(. == "normal")] | length' contracts/../docs/design/visual-direction-comparison.json)
  else
    arr_scenes=$(jq -r '.required_scene_ids | length' contracts/../docs/design/visual-direction-comparison.json)
    arr_locales=$(jq -r '.variant_matrix.locales | length' contracts/../docs/design/visual-direction-comparison.json)
    arr_scales=$(jq -r '.variant_matrix.scale_factors | length' contracts/../docs/design/visual-direction-comparison.json)
    arr_themes=$(jq -r '.variant_matrix.themes | length' contracts/../docs/design/visual-direction-comparison.json)
    arr_contrasts=$(jq -r '.variant_matrix.contrast | length' contracts/../docs/design/visual-direction-comparison.json)
    arr_directions_layout=$(jq -r '.variant_matrix.directions | length' contracts/../docs/design/visual-direction-comparison.json)
    arr_text_scales=$(jq -r '.variant_matrix.text_scales | length' contracts/../docs/design/visual-direction-comparison.json)
    arr_motions=$(jq -r '.variant_matrix.motion | length' contracts/../docs/design/visual-direction-comparison.json)
    arr_transparencies=$(jq -r '.variant_matrix.transparency | length' contracts/../docs/design/visual-direction-comparison.json)
  fi

  if [ -z "$arr_scenes" ] || [ -z "$arr_locales" ] || [ -z "$arr_scales" ] || [ -z "$arr_themes" ] || [ -z "$arr_contrasts" ] || [ -z "$arr_directions_layout" ] || [ -z "$arr_text_scales" ] || [ -z "$arr_motions" ] || [ -z "$arr_transparencies" ]; then
    echo 0
    return 0
  fi

  count=$((arr_directions * arr_scenes * arr_locales * arr_scales * arr_themes * arr_contrasts * arr_directions_layout * arr_text_scales * arr_motions * arr_transparencies))
  echo "$count"
}

count_existing_visual_artifacts() {
  local mode="$1"
  local manifest=contracts/../docs/design/visual-direction-comparison.json
  local scope_count=0
  declare -A scale_formats
  declare -A text_formats

  while IFS='|' read -r raw_key raw_value; do
    scale_formats["$raw_key"]="$raw_value"
  done < <(jq -r '.artifact_layout.scale_format | to_entries[] | "\(.key)|\(.value)"' "$manifest")
  while IFS='|' read -r raw_key raw_value; do
    text_formats["$raw_key"]="$raw_value"
  done < <(jq -r '.artifact_layout.text_scale_format | to_entries[] | "\(.key)|\(.value)"' "$manifest")

  mapfile -t directions < <(jq -r '.candidate_directions[]' "$manifest")

  if [ "$mode" = "pilot" ]; then
    mapfile -t scenes < <(jq -r '.required_scene_ids[] | select(. == "type-ramp" or . == "semantic-form" or . == "material-fidelity")' "$manifest")
    mapfile -t locales < <(jq -r '.variant_matrix.locales[] | select(. == "en-US" or . == "ar-EG" or . == "ja-JP")' "$manifest")
    mapfile -t scales < <(jq -r '.variant_matrix.scale_factors[] | select(. == 1.0 or . == 1.5 or . == 2.0)' "$manifest")
    mapfile -t themes < <(jq -r '.variant_matrix.themes[] | select(. == "light")' "$manifest")
    mapfile -t contrasts < <(jq -r '.variant_matrix.contrast[]' "$manifest")
    mapfile -t layout_dirs < <(jq -r '.variant_matrix.directions[] | select(. == "ltr")' "$manifest")
    mapfile -t text_scales < <(jq -r '.variant_matrix.text_scales[] | select(. == 1.0 or . == 2.0)' "$manifest")
    mapfile -t motions < <(jq -r '.variant_matrix.motion[] | select(. == "full")' "$manifest")
    mapfile -t transparencies < <(jq -r '.variant_matrix.transparency[] | select(. == "normal")' "$manifest")
  else
    mapfile -t scenes < <(jq -r '.required_scene_ids[]' "$manifest")
    mapfile -t locales < <(jq -r '.variant_matrix.locales[]' "$manifest")
    mapfile -t scales < <(jq -r '.variant_matrix.scale_factors[]' "$manifest")
    mapfile -t themes < <(jq -r '.variant_matrix.themes[]' "$manifest")
    mapfile -t contrasts < <(jq -r '.variant_matrix.contrast[]' "$manifest")
    mapfile -t layout_dirs < <(jq -r '.variant_matrix.directions[]' "$manifest")
    mapfile -t text_scales < <(jq -r '.variant_matrix.text_scales[]' "$manifest")
    mapfile -t motions < <(jq -r '.variant_matrix.motion[]' "$manifest")
    mapfile -t transparencies < <(jq -r '.variant_matrix.transparency[]' "$manifest")
  fi

  local out_root="artifacts/visual-direction"
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
                      variant_key="scale-${scale_formats[$scale]:-${scale}}-theme-${theme}-contrast-${contrast}-dir-${layout_dir}-text-${text_formats[$text_scale]:-${text_scale}}-motion-${motion}-trans-${transparency}"
                      artifact_path="${out_root}/${direction}/${scene}/${locale}/${variant_key}.png"
                      if [ -f "$artifact_path" ]; then
                        scope_count=$((scope_count + 1))
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

  echo "$scope_count"
}

zag_upstream_access="read-only"
if can_write_path /home/micah/Desktop/Sylorlabs/zag >/dev/null 2>&1; then
  zag_upstream_access="writable"
fi

prismstudio_access="read-only"
if can_write_path /home/micah/Desktop/Sylorlabs/PrismStudio >/dev/null 2>&1; then
  prismstudio_access="writable"
fi

pilot_artifacts_ok="false"
pilot_artifacts_count=0
if [ "$RUN_VISUAL_PILOT_CHECK" = "1" ]; then
  echo "audit: running pilot visual-direction verification"
  if ./tools/verify-visual-direction-artifacts.sh --mode pilot >/dev/null 2>&1; then
    pilot_artifacts_ok="true"
    pilot_artifacts_count=$(count_existing_visual_artifacts pilot)
  fi
fi

full_artifacts_ok="false"
full_artifacts_count=0
if [ "$RUN_VISUAL_FULL_CHECK" = "1" ]; then
  echo "audit: running full visual-direction verification"
  if ./tools/verify-visual-direction-artifacts.sh --mode full >/dev/null 2>&1; then
    full_artifacts_ok="true"
    full_artifacts_count=$(count_existing_visual_artifacts full)
  fi
fi

pilot_expected_count=$(visual_expected_count pilot)
full_expected_count=$(visual_expected_count full)
if [ -z "$pilot_expected_count" ]; then
  pilot_expected_count=0
fi
if [ -z "$full_expected_count" ]; then
  full_expected_count=0
fi

matrix_has_recommendation="false"
if rg -n "Final accepted direction" docs/design/visual-direction-comparison-matrix.md >/dev/null 2>&1; then
  matrix_has_recommendation="true"
fi

headless_ok="false"
if [ "$RUN_RUNTIME_CHECKS" = "1" ]; then
  echo "audit: running tools/test-headless.sh"
  if ./tools/test-headless.sh >/tmp/zh-check.log 2>&1; then
    headless_ok="true"
  fi
else
  if grep -q "headless test: PASS" /tmp/zh-check.log 2>/dev/null; then
    headless_ok="true"
  fi
fi

cli_smoke_ok="false"
if [ "$RUN_RUNTIME_CHECKS" = "1" ]; then
  echo "audit: running tools/test-zagkit-cli.sh"
  if ./tools/test-zagkit-cli.sh >/tmp/zc-check.log 2>&1; then
    cli_smoke_ok="true"
  fi
else
  if grep -q "zagkit-cli-smoke: PASS" /tmp/zc-check.log 2>/dev/null; then
    cli_smoke_ok="true"
  fi
fi
headless_tail="$(test -f /tmp/zh-check.log && tail -n 1 /tmp/zh-check.log || echo 'not run')"
cli_tail="$(test -f /tmp/zc-check.log && tail -n 1 /tmp/zc-check.log || echo 'not run')"

mapfile -t blocked_items < <(printf '%s\n' "$goal_ids")
if [ ${#blocked_items[@]} -eq 0 ]; then
  blocked_ids_json="[]"
else
  blocked_ids_json=$(printf '%s\n' "${blocked_items[@]}" | jq -R . | jq -sc '.')
fi

cat > "$OUT_MD" <<MD
# Zagkit roadmap readiness audit

- Date: $(date -Iseconds)
- Repo: $ROOT
- Objective: Milestone 0 through all-platform 1.0

## High-level status

- Checklist total: $goal_total
- Completed: $goal_completed
- Blocked: $goal_blocked
- Headless contracts: $headless_ok
- CLI smoke: $cli_smoke_ok
- Platform capability slots total: $platform_total
- Platform unavailable slots: $platform_unavailable
- Upstream prerequisites total: $upstream_total
- Upstream available: $upstream_available
- Upstream partial: $upstream_partial
- Upstream missing: $upstream_missing
- Visual-direction pilot captures: $pilot_artifacts_ok
- Visual-direction full captures: $full_artifacts_ok
- Visual-direction recommendation field: $matrix_has_recommendation
- External write access to /home/micah/Desktop/Sylorlabs/zag: $zag_upstream_access
- External write access to /home/micah/Desktop/Sylorlabs/PrismStudio: $prismstudio_access

## Evidence check summary

  - ./tools/test-headless.sh output: ${headless_tail}
  - ./tools/test-zagkit-cli.sh output: ${cli_tail}
  - ./tools/verify-visual-direction-artifacts.sh --mode pilot: $pilot_artifacts_ok
  - ./tools/verify-visual-direction-artifacts.sh --mode full: $full_artifacts_ok

## Blocked checklist items (unchecked)

MD

for gid in "${blocked_items[@]}"; do
  reason="not proven yet"
  case "$gid" in
    G0-VISUAL-DIRECTION)
      reason="pilot artifacts only: full matrix incomplete; no RFC acceptance yet"
      ;;
    G1-LINUX-ARM64|G1-DARWIN|G1-WINDOWS|G1-IOS|G1-ANDROID|G1-OBJC|G1-COM|G1-JNI|G1-CALLBACKS|G1-AGGREGATES|G1-RESOURCES|G1-DYNAMIC-LOAD|G1-CONCURRENCY|G1-PACKAGES|G1-RELOAD|G1-SOURCE-FIRST)
      reason="blocked in contracts/upstream-zag.json (non-available/partial prerequisite not upgraded at pinned commit)"
      ;;
    G3-UNICODE|G3-OPENTYPE|G3-EDITING|G3-FONTS|G3-COLOR|G3-SVG|G3-PNG|G3-SHADOWS|G3-LIGHTING|G3-GLASS|G3-MOTION|G3-REDUCED-MOTION|G3-ASSET-PIPELINE)
      reason="not covered by current passed headless gates (contracts currently cover only text/image/primitive raster foundations)"
      ;;
    G4-INPUT|G4-GESTURES|G4-ACCESSIBILITY|G4-CLI|G4-PREVIEW|G4-INSPECTORS|G4-GALLERY)
      reason="downstream/platform and developer-tool implementations missing in this repository or require native host implementations"
      ;;
    G5-WAYLAND|G5-X11|G5-ATSPI|G5-LINUX-CPU|G5-LINUX-GPU|G5-LINUX-POLISH|G5-LINUX-FIDELITY|G5-LINUX-PACKAGE)
      reason="platforms.json marks linux delivery surface capabilities unavailable and no shell/backend implementation is present"
      ;;
    G6-INVENTORY|G6-DESIGN|G6-SHELL|G6-WORKFLOWS|G6-VIEWPORT|G6-DENSE-UI|G6-MATERIALS|G6-ASSETS|G6-AUTOMATION|G6-ACCESSIBILITY|G6-SCREENSHOTS|G6-PERFORMANCE|G6-POLISH)
      reason="PrismStudio migration requires external write access and native shell replacement work in /home/micah/Desktop/Sylorlabs/PrismStudio"
      ;;
    G7-MACOS|G7-WINDOWS|G7-IOS|G7-ANDROID|G7-MOBILE-REFERENCE|G7-COMPONENT-PARITY|G7-TEXT-PARITY|G7-RECOVERY|G7-PERFORMANCE|G7-PACKAGING|G7-ONE-POINT-ZERO)
      reason="requires completed milestones across G1, G5, G6 plus native host/test evidence in platform repos"
      ;;
  esac
  printf -- '- `%s` — %s\n' "$gid" "$reason" >> "$OUT_MD"
done

cat >> "$OUT_MD" <<MD

## Visual direction scope check

- Pilot artifacts expected count: $pilot_expected_count
- Pilot generated: $pilot_artifacts_count
- Pilot expected: $pilot_expected_count
- Full expected matrix mode: $full_expected_count
- Full generated: $full_artifacts_count
- Recommendation section present: $matrix_has_recommendation

## Write-gate blockers

- /home/micah/Desktop/Sylorlabs/zag: $zag_upstream_access
- /home/micah/Desktop/Sylorlabs/PrismStudio: $prismstudio_access

## Agent checklist

This audit produced a canonical blocker checklist at:

- [agent checklist]($AGENT_CHECKLIST_LINK)

## Recommended next concrete actions

1. Update /home/micah/Desktop/Sylorlabs/zag prerequisites (G1.*) at pinned compiler revision and re-run all downstream checks.
2. Implement Linux shell/AT-SPI/caps and a real rendering transport to satisfy G5.
3. Continue PrismStudio migration tasks only after read-write workspace is restored for /home/micah/Desktop/Sylorlabs/PrismStudio.
4. Resume full visual-direction render generation once native material pipeline is implemented; pilot artifacts are placeholders only.
MD

cat > "$OUT_JSON" <<JSON
{
  "generated_at": "$(date -Iseconds)",
  "goal": {
    "total": $goal_total,
    "completed": $goal_completed,
    "blocked": $goal_blocked,
    "blocked_ids": $blocked_ids_json
  },
  "contracts": {
    "upstream_total": $upstream_total,
    "upstream_available": $upstream_available,
    "upstream_partial": $upstream_partial,
    "upstream_missing": $upstream_missing,
    "platform_total": $platform_total,
    "platform_unavailable": $platform_unavailable
  },
  "artifacts": {
    "visual_direction": {
      "pilot_ok": $pilot_artifacts_ok,
      "full_ok": $full_artifacts_ok,
      "matrix_has_recommendation": $matrix_has_recommendation
    }
  },
  "external_write": {
    "zag": "${zag_upstream_access}",
    "prismstudio": "${prismstudio_access}"
  },
  "checks": {
    "headless_ok": $headless_ok,
    "cli_smoke_ok": $cli_smoke_ok
  }
}
JSON

./tools/emit-agent-checklist.sh "$OUT_AGENT_CHECKLIST"

printf 'wrote %s\n' "$OUT_MD"
printf 'wrote %s\n' "$OUT_JSON"
printf 'wrote %s\n' "$OUT_AGENT_CHECKLIST"
