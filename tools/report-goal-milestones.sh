#!/usr/bin/env bash
set -euo pipefail

GOAL_FILE="${1:-GOAL.md}"

usage() {
  cat <<'USAGE'
Usage: report-goal-milestones.sh [goal-file]

Print milestone-level progress from GOAL.md-style checklists.
USAGE
}

if [ "$#" -gt 1 ]; then
  usage
  exit 1
fi

[ -f "$GOAL_FILE" ] || { echo "missing goal file: $GOAL_FILE" >&2; exit 1; }

awk -v goal_file="$GOAL_FILE" '
function emit_blockers(id_list) {
  if (id_list == "") {
    return
  }
  split(id_list, items, "\n")
  for (i = 1; i <= length(items); i++) {
    if (items[i] != "") {
      printf "  - %s\n", items[i]
    }
  }
}

function flush_section() {
  if (section == "") return
  printf "%s | total=%d completed=%d blocked=%d\n", section, total, completed, blocked
  emit_blockers(blocked_ids)
  section = ""
  total = 0
  completed = 0
  blocked = 0
  blocked_ids = ""
}

BEGIN {
  section = ""
  total = 0
  completed = 0
  blocked = 0
  blocked_ids = ""
}

/^## / {
  flush_section()
  section = substr($0, 4)
  next
}

/^## Checklist maintenance/ {
  flush_section()
  section = ""
  next
}

/^- \[[ x]\] `/ {
  if (section == "") next

  match($0, /^- \[.\] `([^`]+)`/, m)
  id = m[1]

  if ($0 ~ /^- \[x\] /) {
    completed++
  } else {
    blocked++
    blocked_ids = blocked_ids id "\n"
  }
  total++
}

END { flush_section() }
' "$GOAL_FILE"
