#!/usr/bin/env bash
set -euo pipefail

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

usage() {
  cat <<'USAGE'
Usage: report-goal-progress.sh [--json <path>] [--output <path>]

- --json: write machine-readable progress summary to the given path (default:
  docs/evidence/goal-progress-live.json)
- --output: write a markdown summary to the given path (default:
  docs/evidence/goal-progress-live.md)
USAGE
}

JSON_PATH="docs/evidence/goal-progress-live.json"
OUTPUT_PATH="docs/evidence/goal-progress-live.md"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --json)
      JSON_PATH="$2"
      shift 2
      ;;
    --output)
      OUTPUT_PATH="$2"
      shift 2
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

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 1
fi

goal_total=$(grep -Ec '^- \[[ x]\] `[A-Z0-9][A-Z0-9-]+` ' GOAL.md || true)
goal_completed=$(grep -Ec '^- \[x\] ' GOAL.md || true)
goal_blocked=$((goal_total - goal_completed))
goal_ids=$(grep -E '^- \[ \] `[^`]+` ' GOAL.md | sed -E 's/^- \[ \] `([^`]+)`.*/\1/' || true)

upstream_total=$(jq '.entries | length' contracts/upstream-zag.json)
upstream_available=$(jq '[.entries[] | select(.state=="available")] | length' contracts/upstream-zag.json)
upstream_partial=$(jq '[.entries[] | select(.state=="partial")] | length' contracts/upstream-zag.json)
upstream_missing=$(jq '[.entries[] | select(.state=="missing")] | length' contracts/upstream-zag.json)
upstream_missing_ids=$(jq -r '[.entries[] | select(.state=="missing") | .id] | join(", ")' contracts/upstream-zag.json)

platform_id=$(jq -r '.one_point_zero.required_platforms | join(", ")' contracts/platforms.json)
platform_unavailable=$(jq '[.platforms[].capabilities[] | select(.state=="unavailable")] | length' contracts/platforms.json)
platform_total_capabilities=$(jq '[.platforms[].capabilities[]] | length' contracts/platforms.json)
platform_blockers=$(jq -r '[.platforms[].capabilities[] | select(.state=="unavailable") | "\(.id):\(.reason)"] | join("\n")' contracts/platforms.json)

visual_direction_state=$(jq -r '.visual_direction_gate.state' contracts/upstream-zag.json 2>/dev/null || echo "missing")

roadmap_version=$(jq -r '.zagkit_version' contracts/toolchain.json)
toolchain_commit=$(jq -r '.zag.commit' contracts/toolchain.json)

cat > "$JSON_PATH" <<JSON
{
  "generated_at": "$(date -Iseconds)",
  "zagkit_version": "$roadmap_version",
  "compiler_commit": "$toolchain_commit",
  "goal": {
    "total_items": $goal_total,
    "completed_items": $goal_completed,
    "blocked_items": $goal_blocked
  },
  "upstream": {
    "total_entries": $upstream_total,
    "available": $upstream_available,
    "partial": $upstream_partial,
    "missing": $upstream_missing,
    "missing_ids": $(jq -r '[.entries[] | select(.state=="missing") | .id] | @json' contracts/upstream-zag.json)
  },
  "platforms": {
    "required": "$platform_id",
    "capabilities_total": $platform_total_capabilities,
    "unavailable": $platform_unavailable
  }
}
JSON

cat > "$OUTPUT_PATH" <<MD
# Zagkit live progress snapshot

- Date: $(date -Iseconds)
- Scope: $ROOT
- Zag toolkit version: $roadmap_version
- Compiler commit: $toolchain_commit

## Goal checklist

- Total items: $goal_total
- Completed: $goal_completed
- Blocked: $goal_blocked

### Blocked checklist items (unchecked in GOAL.md)

$(if [ "$goal_blocked" -gt 0 ]; then
  printf '%s\n' "$goal_ids" | grep -v '^$' | sort -u | sed 's/^/- /'
else
  echo "- none"
fi)

## Upstream prereq ledger

- Total: $upstream_total
- Available: $upstream_available
- Partial: $upstream_partial
- Missing: $upstream_missing
- Missing IDs: ${upstream_missing_ids:-none}

## Platform capability summary

- Required families: $platform_id
- Total capability slots: $platform_total_capabilities
- Unavailable capability slots: $platform_unavailable

### Not-ready capability blockers

\`\`\`
$platform_blockers
\`\`\`

MD

printf 'goal status: total=%s completed=%s blocked=%s\n' "$goal_total" "$goal_completed" "$goal_blocked"
printf 'upstream prereq: total=%s available=%s partial=%s missing=%s\n' "$upstream_total" "$upstream_available" "$upstream_partial" "$upstream_missing"
printf 'platforms: required=%s total-capabilities=%s unavailable=%s\n' "$platform_id" "$platform_total_capabilities" "$platform_unavailable"
printf 'wrote %s\n' "$OUTPUT_PATH"
printf 'wrote %s\n' "$JSON_PATH"
