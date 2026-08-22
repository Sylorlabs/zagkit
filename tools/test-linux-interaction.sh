#!/usr/bin/env bash
set -euo pipefail
set -f

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
COMPILER=${ZAG_BIN:-${ZNC:-/home/micah/Desktop/Sylorlabs/zag/zag-poc/znc}}
WINDOW_TITLE='Zagkit — Linux Preview'
EVIDENCE_DIR=${ZAGKIT_INTERACTION_EVIDENCE_DIR:-}
IDLE_MAX_CPU_TICKS=2
POLL_DELAY=0.05
POLL_ATTEMPTS=100

TMP_ROOT=
PREVIEW_PID=
PREVIEW_START_TICKS=
PREVIEW_WAITED=0
BUILD_LOG=
RUNTIME_LOG=
METADATA=
BEFORE_CAPTURE=
HOVER_CAPTURE=
PRESS_CAPTURE=
DISABLED_READY_CAPTURE=
CLICK_CAPTURE=
INSPECTOR_CAPTURE=
SELECT_CAPTURE=
KEYBOARD_CAPTURE=
GENERAL_FOCUS_CAPTURE=
TYPOGRAPHY_CAPTURE=
SMALL_CAPTURE=
RESIZED_CAPTURE=

usage() {
  printf '%s\n' \
    'Usage: tools/test-linux-interaction.sh [--evidence-dir <directory>]' \
    '' \
    'Builds and drives the native Linux X11 preview. ZAG_BIN takes precedence' \
    'over ZNC. The one-second idle allowance is a strict two CPU ticks.'
}

fail() {
  printf 'linux interaction test: FAIL: %s\n' "$1" >&2
  if [ -n "$RUNTIME_LOG" ] && [ -s "$RUNTIME_LOG" ]; then
    printf 'linux interaction test: runtime log tail follows\n' >&2
    tail -n 30 "$RUNTIME_LOG" >&2 || true
  fi
  exit 1
}

proc_stat_tail() {
  local target_pid=$1
  local stat_line stat_tail
  IFS= read -r stat_line < "/proc/$target_pid/stat" || return 1
  stat_tail=${stat_line##*) }
  [ "$stat_tail" != "$stat_line" ] || return 1
  printf '%s\n' "$stat_tail"
}

proc_start_ticks() {
  local stat_tail
  stat_tail=$(proc_stat_tail "$1") || return 1
  set -- $stat_tail
  [ "$#" -ge 20 ] || return 1
  printf '%s\n' "${20}"
}

proc_cpu_ticks() {
  local stat_tail
  stat_tail=$(proc_stat_tail "$1") || return 1
  set -- $stat_tail
  [ "$#" -ge 13 ] || return 1
  printf '%s\n' "$(( ${12} + ${13} ))"
}

proc_state() {
  local stat_tail
  stat_tail=$(proc_stat_tail "$1") || return 1
  set -- $stat_tail
  [ "$#" -ge 1 ] || return 1
  printf '%s\n' "$1"
}

preview_process_matches() {
  local current_start
  [ -n "$PREVIEW_PID" ] && [ -n "$PREVIEW_START_TICKS" ] || return 1
  current_start=$(proc_start_ticks "$PREVIEW_PID" 2>/dev/null) || return 1
  [ "$current_start" = "$PREVIEW_START_TICKS" ]
}

preview_process_running() {
  local current_state
  preview_process_matches || return 1
  current_state=$(proc_state "$PREVIEW_PID" 2>/dev/null) || return 1
  [ "$current_state" != Z ]
}

publish_evidence() {
  local source_path target_name
  [ -n "$EVIDENCE_DIR" ] || return 0
  mkdir -p -- "$EVIDENCE_DIR" || return 1
  for source_path in "$BUILD_LOG" "$RUNTIME_LOG" "$METADATA" \
      "$BEFORE_CAPTURE" "$HOVER_CAPTURE" "$PRESS_CAPTURE" \
      "$DISABLED_READY_CAPTURE" "$CLICK_CAPTURE" \
      "$INSPECTOR_CAPTURE" "$SELECT_CAPTURE" "$KEYBOARD_CAPTURE" "$SMALL_CAPTURE" \
      "$GENERAL_FOCUS_CAPTURE" "$TYPOGRAPHY_CAPTURE" "$RESIZED_CAPTURE"; do
    [ -n "$source_path" ] && [ -f "$source_path" ] || continue
    case "$source_path" in
      "$BUILD_LOG") target_name=linux-interaction-build.log ;;
      "$RUNTIME_LOG") target_name=linux-interaction-runtime.log ;;
      "$METADATA") target_name=linux-interaction-metadata.txt ;;
      "$BEFORE_CAPTURE") target_name=linux-interaction-before.png ;;
      "$HOVER_CAPTURE") target_name=linux-interaction-inspect-hover.png ;;
      "$PRESS_CAPTURE") target_name=linux-interaction-inspect-pressed.png ;;
      "$DISABLED_READY_CAPTURE") target_name=linux-interaction-disabled-ready.png ;;
      "$CLICK_CAPTURE") target_name=linux-interaction-after-click.png ;;
      "$INSPECTOR_CAPTURE") target_name=linux-interaction-token-inspector.png ;;
      "$SELECT_CAPTURE") target_name=linux-interaction-after-select.png ;;
      "$KEYBOARD_CAPTURE") target_name=linux-interaction-keyboard-focus.png ;;
      "$GENERAL_FOCUS_CAPTURE") target_name=linux-interaction-navigation-focus.png ;;
      "$TYPOGRAPHY_CAPTURE") target_name=linux-interaction-typography.png ;;
      "$SMALL_CAPTURE") target_name=linux-interaction-unsupported-size.png ;;
      "$RESIZED_CAPTURE") target_name=linux-interaction-resized.png ;;
      *) continue ;;
    esac
    cp -f -- "$source_path" "$EVIDENCE_DIR/$target_name" || return 1
  done
}

cleanup() {
  local original_status=$?
  local attempt
  trap - INT TERM EXIT
  if [ "$PREVIEW_WAITED" -eq 0 ] && preview_process_matches; then
    kill -TERM "$PREVIEW_PID" 2>/dev/null || true
    for ((attempt = 0; attempt < 20; attempt++)); do
      preview_process_running || break
      sleep "$POLL_DELAY"
    done
    if preview_process_running; then
      kill -KILL "$PREVIEW_PID" 2>/dev/null || true
    fi
    wait "$PREVIEW_PID" 2>/dev/null || true
    PREVIEW_WAITED=1
  fi
  if ! publish_evidence; then
    printf 'linux interaction test: warning: evidence copy failed: %s\n' \
      "$EVIDENCE_DIR" >&2
    if [ "$original_status" -eq 0 ]; then original_status=1; fi
  fi
  if [ -n "$TMP_ROOT" ] && [ -d "$TMP_ROOT" ]; then
    rm -rf -- "$TMP_ROOT"
  fi
  exit "$original_status"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --evidence-dir)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      EVIDENCE_DIR=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'linux interaction test: unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

[ -n "${DISPLAY:-}" ] || fail 'DISPLAY is unavailable'
for required_tool in xdotool import file sha256sum; do
  command -v "$required_tool" >/dev/null 2>&1 ||
    fail "required tool is unavailable: $required_tool"
done
[ -x "$COMPILER" ] || fail "compiler is not executable: $COMPILER"

FONT_LIGHT_FILE=${ZAGKIT_FONT_LIGHT_FILE:-}
FONT_FILE=${ZAGKIT_FONT_FILE:-}
FONT_BOLD_FILE=${ZAGKIT_FONT_BOLD_FILE:-}
if [ -z "$FONT_LIGHT_FILE" ] || [ -z "$FONT_FILE" ] ||
    [ -z "$FONT_BOLD_FILE" ]; then
  command -v fc-match >/dev/null 2>&1 ||
    fail 'font weight paths are unset and fc-match is unavailable'
  FONT_LIGHT_FILE=$(fc-match -f '%{file}\n' 'Fira Sans:style=Light')
  FONT_FILE=$(fc-match -f '%{file}\n' 'Fira Sans:style=Regular')
  FONT_BOLD_FILE=$(fc-match -f '%{file}\n' 'Fira Sans:style=Bold')
fi
[ -f "$FONT_LIGHT_FILE" ] ||
  fail "light font file is unavailable: $FONT_LIGHT_FILE"
[ -f "$FONT_FILE" ] || fail "regular font file is unavailable: $FONT_FILE"
[ -f "$FONT_BOLD_FILE" ] ||
  fail "bold font file is unavailable: $FONT_BOLD_FILE"
cmp -s -- "$FONT_LIGHT_FILE" "$FONT_FILE" &&
  fail 'light and regular font weights resolve to identical bytes'
cmp -s -- "$FONT_FILE" "$FONT_BOLD_FILE" &&
  fail 'regular and bold font weights resolve to identical bytes'
cmp -s -- "$FONT_LIGHT_FILE" "$FONT_BOLD_FILE" &&
  fail 'light and bold font weights resolve to identical bytes'

TMP_ROOT=$(mktemp -d /tmp/zagkit-linux-interaction.XXXXXX)
PREVIEW_BINARY="$TMP_ROOT/linux-preview"
BUILD_LOG="$TMP_ROOT/build.log"
RUNTIME_LOG="$TMP_ROOT/runtime.log"
METADATA="$TMP_ROOT/metadata.txt"
BEFORE_CAPTURE="$TMP_ROOT/before.png"
HOVER_CAPTURE="$TMP_ROOT/inspect-hover.png"
PRESS_CAPTURE="$TMP_ROOT/inspect-pressed.png"
DISABLED_READY_CAPTURE="$TMP_ROOT/disabled-ready.png"
CLICK_CAPTURE="$TMP_ROOT/after-click.png"
INSPECTOR_CAPTURE="$TMP_ROOT/token-inspector.png"
SELECT_CAPTURE="$TMP_ROOT/after-select.png"
KEYBOARD_CAPTURE="$TMP_ROOT/keyboard-focus.png"
GENERAL_FOCUS_CAPTURE="$TMP_ROOT/navigation-focus.png"
TYPOGRAPHY_CAPTURE="$TMP_ROOT/typography.png"
SMALL_CAPTURE="$TMP_ROOT/unsupported-size.png"
RESIZED_CAPTURE="$TMP_ROOT/resized.png"

trap 'exit 130' INT
trap 'exit 143' TERM
trap cleanup EXIT

record_metadata() {
  printf '%s=%s\n' "$1" "$2" >> "$METADATA"
}

list_exact_title_windows() {
  local candidate candidate_title
  while IFS= read -r candidate; do
    case "$candidate" in ''|*[!0-9]*) continue ;; esac
    candidate_title=$(xdotool getwindowname "$candidate" 2>/dev/null || true)
    if [ "$candidate_title" = "$WINDOW_TITLE" ]; then
      printf '%s\n' "$candidate"
    fi
  done < <(xdotool search --name 'Zagkit' 2>/dev/null || true)
}

window_geometry() {
  local target_window=$1
  local geometry_line geometry_key geometry_value
  local geometry_width= geometry_height=
  while IFS= read -r geometry_line; do
    geometry_key=${geometry_line%%=*}
    geometry_value=${geometry_line#*=}
    case "$geometry_key" in
      WIDTH) geometry_width=$geometry_value ;;
      HEIGHT) geometry_height=$geometry_value ;;
    esac
  done < <(xdotool getwindowgeometry --shell "$target_window" 2>/dev/null || true)
  case "$geometry_width" in ''|*[!0-9]*) return 1 ;; esac
  case "$geometry_height" in ''|*[!0-9]*) return 1 ;; esac
  [ "$geometry_width" -gt 0 ] && [ "$geometry_height" -gt 0 ] || return 1
  printf '%s %s\n' "$geometry_width" "$geometry_height"
}

capture_window() {
  local target_window=$1
  local output_path=$2
  import -window "$target_window" "$output_path" >/dev/null 2>&1 || return 1
  [ -s "$output_path" ] || return 1
  case $(file -b "$output_path") in
    *'PNG image data'*) return 0 ;;
    *) return 1 ;;
  esac
}

capture_hash() {
  local digest ignored
  read -r digest ignored < <(sha256sum -- "$1") || return 1
  case "$digest" in
    *[!0-9a-f]*) return 1 ;;
  esac
  [ "${#digest}" -eq 64 ] || return 1
  printf '%s\n' "$digest"
}

wait_target_bounds() {
  local target_id=$1
  local target_line attempt
  for ((attempt = 0; attempt < POLL_ATTEMPTS; attempt++)); do
    preview_process_running || return 1
    target_line=$(grep -F \
      "zagkit: talkback pixel-fallback target-id=$target_id " \
      "$RUNTIME_LOG" | tail -n 1 || true)
    if [[ $target_line =~ x=([0-9]+)[[:space:]]y=([0-9]+)[[:space:]]width=([0-9]+)[[:space:]]height=([0-9]+)[[:space:]]scale=1/1[[:space:]]enabled=([01]) ]]; then
      printf '%s %s %s %s %s\n' \
        "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" \
        "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}" \
        "${BASH_REMATCH[5]}"
      return 0
    fi
    sleep "$POLL_DELAY"
  done
  return 1
}

mapfile -t PREEXISTING_WINDOWS < <(list_exact_title_windows)
if [ "${#PREEXISTING_WINDOWS[@]}" -ne 0 ]; then
  fail "preexisting exact-title window is present: ${PREEXISTING_WINDOWS[*]}"
fi

printf 'linux interaction test: building native preview with %s\n' "$COMPILER"
if ! "$COMPILER" "$ROOT_DIR/examples/linux_preview.zag" --dynamic \
    --needed libX11.so.6 --no-zagd --analyze-strict --no-foreground-cache \
    -o "$PREVIEW_BINARY" >"$BUILD_LOG" 2>&1; then
  printf 'linux interaction test: compiler log follows\n' >&2
  tail -n 40 "$BUILD_LOG" >&2 || true
  fail 'native preview build failed'
fi
[ -x "$PREVIEW_BINARY" ] || fail 'native preview build produced no executable'

mapfile -t PRELAUNCH_WINDOWS < <(list_exact_title_windows)
if [ "${#PRELAUNCH_WINDOWS[@]}" -ne 0 ]; then
  fail "exact-title window appeared before this launch: ${PRELAUNCH_WINDOWS[*]}"
fi

record_metadata compiler "$COMPILER"
record_metadata display "$DISPLAY"
record_metadata font "$FONT_FILE"
record_metadata font_sha256 "$(capture_hash "$FONT_FILE")"
record_metadata font_light "$FONT_LIGHT_FILE"
record_metadata font_light_sha256 "$(capture_hash "$FONT_LIGHT_FILE")"
record_metadata font_bold "$FONT_BOLD_FILE"
record_metadata font_bold_sha256 "$(capture_hash "$FONT_BOLD_FILE")"
record_metadata window_title "$WINDOW_TITLE"
record_metadata idle_max_cpu_ticks "$IDLE_MAX_CPU_TICKS"

ZAGKIT_INPUT_TRACE=1 ZAGKIT_FONT_LIGHT_FILE="$FONT_LIGHT_FILE" \
  ZAGKIT_FONT_FILE="$FONT_FILE" ZAGKIT_FONT_BOLD_FILE="$FONT_BOLD_FILE" \
  "$PREVIEW_BINARY" >"$RUNTIME_LOG" 2>&1 &
PREVIEW_PID=$!
PREVIEW_START_TICKS=$(proc_start_ticks "$PREVIEW_PID") ||
  fail 'launched preview disappeared before its process identity was recorded'
record_metadata preview_pid "$PREVIEW_PID"
record_metadata preview_start_ticks "$PREVIEW_START_TICKS"

WINDOW_ID=
for ((attempt = 0; attempt < POLL_ATTEMPTS; attempt++)); do
  preview_process_running || fail 'launched preview exited before mapping its window'
  mapfile -t EXACT_WINDOWS < <(list_exact_title_windows)
  if [ "${#EXACT_WINDOWS[@]}" -gt 1 ]; then
    fail "exact-title window association is ambiguous: ${EXACT_WINDOWS[*]}"
  fi
  if [ "${#EXACT_WINDOWS[@]}" -eq 1 ]; then
    WINDOW_ID=${EXACT_WINDOWS[0]}
    break
  fi
  sleep "$POLL_DELAY"
done
[ -n "$WINDOW_ID" ] || fail 'exact-title window did not appear before timeout'

WINDOW_PID_PROPERTY=$(xdotool getwindowpid "$WINDOW_ID" 2>/dev/null || true)
if [ -n "$WINDOW_PID_PROPERTY" ]; then
  case "$WINDOW_PID_PROPERTY" in
    *[!0-9]*) fail "window exposes an invalid PID property: $WINDOW_PID_PROPERTY" ;;
  esac
  [ "$WINDOW_PID_PROPERTY" = "$PREVIEW_PID" ] ||
    fail "window PID $WINDOW_PID_PROPERTY does not match launch PID $PREVIEW_PID"
else
  WINDOW_PID_PROPERTY=unavailable
fi
record_metadata window_id "$WINDOW_ID"
record_metadata window_pid_property "$WINDOW_PID_PROPERTY"
record_metadata window_association prelaunch-empty-plus-unique-exact-title
printf 'linux interaction test: associated pid=%s window=%s (WM_PID=%s)\n' \
  "$PREVIEW_PID" "$WINDOW_ID" "$WINDOW_PID_PROPERTY"

read -r INITIAL_WIDTH INITIAL_HEIGHT < <(window_geometry "$WINDOW_ID") ||
  fail 'initial window geometry is unavailable'
record_metadata initial_geometry "${INITIAL_WIDTH}x${INITIAL_HEIGHT}"
xdotool mousemove --window "$WINDOW_ID" 1 1 ||
  fail 'initial pointer normalization failed'
capture_window "$WINDOW_ID" "$BEFORE_CAPTURE" || fail 'initial screenshot failed'
BEFORE_FILE=$(file -b "$BEFORE_CAPTURE")
case "$BEFORE_FILE" in
  *"$INITIAL_WIDTH x $INITIAL_HEIGHT"*) ;;
  *) fail "initial screenshot dimensions disagree with geometry: $BEFORE_FILE" ;;
esac
BEFORE_HASH=$(capture_hash "$BEFORE_CAPTURE") || fail 'initial screenshot hash failed'
record_metadata before_sha256 "$BEFORE_HASH"

# The Inspect control must toggle a real retained overlay. Resolve the Button
# by stable ID, open the canonical overlay Surface, capture it, then close it
# before exercising the remaining interaction state machine.
INSPECT_ID=20302
read -r INSPECT_X INSPECT_Y INSPECT_WIDTH INSPECT_HEIGHT INSPECT_ENABLED \
  < <(wait_target_bounds "$INSPECT_ID") ||
  fail "stable target bounds unavailable for ID $INSPECT_ID"
[ "$INSPECT_ENABLED" -eq 1 ] ||
  fail "token inspector target ID $INSPECT_ID is not actionable"
INSPECT_CLICK_X=$((INSPECT_X + INSPECT_WIDTH / 2))
INSPECT_CLICK_Y=$((INSPECT_Y + INSPECT_HEIGHT / 2))
record_metadata inspector_target_id "$INSPECT_ID"
record_metadata inspector_target_bounds \
  "${INSPECT_X},${INSPECT_Y},${INSPECT_WIDTH},${INSPECT_HEIGHT}"
record_metadata inspector_target_origin talkback-id-to-recorded-pixel-fallback
xdotool mousemove --window "$WINDOW_ID" \
  "$INSPECT_CLICK_X" "$INSPECT_CLICK_Y" ||
  fail 'token inspector hover injection failed'
INSPECT_HOVER_PATTERN="hovered-id=$INSPECT_ID pressed-id=-1 focused-id=-1 general-focus-visible=0"
INSPECT_HOVER_SEEN=0
for ((attempt = 0; attempt < POLL_ATTEMPTS; attempt++)); do
  preview_process_running || fail 'preview exited while waiting for Inspect hover'
  if grep -Fq "$INSPECT_HOVER_PATTERN" "$RUNTIME_LOG"; then
    INSPECT_HOVER_SEEN=1
    break
  fi
  sleep "$POLL_DELAY"
done
[ "$INSPECT_HOVER_SEEN" -eq 1 ] ||
  fail 'Inspect did not publish retained hover state'
capture_window "$WINDOW_ID" "$HOVER_CAPTURE" ||
  fail 'Inspect hover screenshot failed'
HOVER_HASH=$(capture_hash "$HOVER_CAPTURE") ||
  fail 'Inspect hover screenshot hash failed'
[ "$HOVER_HASH" != "$BEFORE_HASH" ] ||
  fail 'Inspect hover did not change presented pixels'
record_metadata inspector_hover_trace "$INSPECT_HOVER_PATTERN"
record_metadata inspector_hover_sha256 "$HOVER_HASH"

xdotool mousedown --window "$WINDOW_ID" 1 ||
  fail 'token inspector press injection failed'
INSPECT_PRESS_PATTERN="hovered-id=$INSPECT_ID pressed-id=$INSPECT_ID focused-id=$INSPECT_ID general-focus-visible=0"
INSPECT_PRESS_SEEN=0
for ((attempt = 0; attempt < POLL_ATTEMPTS; attempt++)); do
  preview_process_running || fail 'preview exited while waiting for Inspect press'
  if grep -Fq "$INSPECT_PRESS_PATTERN" "$RUNTIME_LOG"; then
    INSPECT_PRESS_SEEN=1
    break
  fi
  sleep "$POLL_DELAY"
done
[ "$INSPECT_PRESS_SEEN" -eq 1 ] ||
  fail 'Inspect did not publish retained pressed and pointer-focus state'
capture_window "$WINDOW_ID" "$PRESS_CAPTURE" ||
  fail 'Inspect pressed screenshot failed'
PRESS_HASH=$(capture_hash "$PRESS_CAPTURE") ||
  fail 'Inspect pressed screenshot hash failed'
[ "$PRESS_HASH" != "$HOVER_HASH" ] ||
  fail 'Inspect pressed state did not change presented pixels'
record_metadata inspector_pressed_trace "$INSPECT_PRESS_PATTERN"
record_metadata inspector_pressed_sha256 "$PRESS_HASH"

xdotool mouseup --window "$WINDOW_ID" 1 ||
  fail 'token inspector release injection failed'
INSPECT_OPEN_PATTERN='zagkit: token inspector open=1'
INSPECT_FRAME_PATTERN='token-inspector-open=1 hovered-id=20302 pressed-id=-1 focused-id=20302 general-focus-visible=0 evidence-hash='
INSPECT_OPEN_SEEN=0
for ((attempt = 0; attempt < POLL_ATTEMPTS; attempt++)); do
  preview_process_running || fail 'preview exited while opening token inspector'
  if grep -Fq "$INSPECT_OPEN_PATTERN" "$RUNTIME_LOG" &&
      grep -Fq "$INSPECT_FRAME_PATTERN" "$RUNTIME_LOG"; then
    INSPECT_OPEN_SEEN=1
    break
  fi
  sleep "$POLL_DELAY"
done
[ "$INSPECT_OPEN_SEEN" -eq 1 ] ||
  fail 'token inspector did not publish retained open state'
capture_window "$WINDOW_ID" "$INSPECTOR_CAPTURE" ||
  fail 'token inspector screenshot failed'
INSPECTOR_HASH=$(capture_hash "$INSPECTOR_CAPTURE") ||
  fail 'token inspector screenshot hash failed'
[ "$INSPECTOR_HASH" != "$BEFORE_HASH" ] ||
  fail 'token inspector state did not change presented pixels'
[ "$INSPECTOR_HASH" != "$PRESS_HASH" ] ||
  fail 'released inspector overlay is indistinguishable from pressed state'
record_metadata inspector_sha256 "$INSPECTOR_HASH"
xdotool click --window "$WINDOW_ID" 1 ||
  fail 'token inspector close injection failed'
INSPECT_CLOSE_PATTERN='zagkit: token inspector open=0'
INSPECT_CLOSE_SEEN=0
for ((attempt = 0; attempt < POLL_ATTEMPTS; attempt++)); do
  preview_process_running || fail 'preview exited while closing token inspector'
  if grep -Fq "$INSPECT_CLOSE_PATTERN" "$RUNTIME_LOG"; then
    INSPECT_CLOSE_SEEN=1
    break
  fi
  sleep "$POLL_DELAY"
done
[ "$INSPECT_CLOSE_SEEN" -eq 1 ] ||
  fail 'token inspector did not publish retained closed state'

# Initial selection is Overview (index 0). Components is intentionally disabled
# until its real gallery route is composed. Resolve its retained bounds by
# stable ID, then record the explicit scale-aware pixel fallback used by
# xdotool. The test owns no second coordinate table.
COMPONENTS_ID=20201
read -r TARGET_X TARGET_Y TARGET_WIDTH TARGET_HEIGHT TARGET_ENABLED \
  < <(wait_target_bounds "$COMPONENTS_ID") ||
  fail "stable target bounds unavailable for ID $COMPONENTS_ID"
[ "$TARGET_ENABLED" -eq 0 ] ||
  fail "Components target ID $COMPONENTS_ID unexpectedly became actionable"
CLICK_X=$((TARGET_X + TARGET_WIDTH / 2))
CLICK_Y=$((TARGET_Y + TARGET_HEIGHT / 2))
[ "$CLICK_X" -gt 0 ] && [ "$CLICK_Y" -gt 0 ] ||
  fail 'resolved disabled-navigation target has invalid geometry'
record_metadata disabled_target_id "$COMPONENTS_ID"
record_metadata disabled_target_bounds \
  "${TARGET_X},${TARGET_Y},${TARGET_WIDTH},${TARGET_HEIGHT}"
record_metadata disabled_target_origin talkback-id-to-recorded-pixel-fallback
record_metadata click_relative "${CLICK_X},${CLICK_Y}"
xdotool mousemove --window "$WINDOW_ID" "$CLICK_X" "$CLICK_Y" ||
  fail 'disabled-navigation pointer move failed'
capture_window "$WINDOW_ID" "$DISABLED_READY_CAPTURE" ||
  fail 'disabled-navigation settled screenshot failed'
DISABLED_READY_HASH=$(capture_hash "$DISABLED_READY_CAPTURE") ||
  fail 'disabled-navigation settled screenshot hash failed'
record_metadata disabled_ready_sha256 "$DISABLED_READY_HASH"
xdotool click --window "$WINDOW_ID" 1 ||
  fail 'left-navigation click injection failed'

TRACE_PATTERN="zagkit: pointer down x=$CLICK_X y=$CLICK_Y button=1"
UNAVAILABLE_PATTERN='zagkit: navigation unavailable route=Components'
TRACE_SEEN=0
for ((attempt = 0; attempt < POLL_ATTEMPTS; attempt++)); do
  preview_process_running || fail 'preview exited while waiting for input trace'
  if grep -Fq "$TRACE_PATTERN" "$RUNTIME_LOG" &&
      grep -Fq "$UNAVAILABLE_PATTERN" "$RUNTIME_LOG"; then
    TRACE_SEEN=1
    break
  fi
  sleep "$POLL_DELAY"
done
[ "$TRACE_SEEN" -eq 1 ] ||
  fail "missing pointer or unavailable-route trace: $TRACE_PATTERN"
record_metadata pointer_trace "$TRACE_PATTERN"
record_metadata navigation_unavailable Components

capture_window "$WINDOW_ID" "$CLICK_CAPTURE" ||
  fail 'disabled-navigation screenshot failed'
CLICK_HASH=$(capture_hash "$CLICK_CAPTURE") ||
  fail 'disabled-navigation screenshot hash failed'
[ "$CLICK_HASH" = "$DISABLED_READY_HASH" ] ||
  fail 'disabled navigation changed visible content or selection'
record_metadata after_click_sha256 "$CLICK_HASH"

# Activate Motion through the same stable-ID fallback and prove that the
# retained SegmentedControl changes the presented composition.
MOTION_ID=20402
read -r MOTION_X MOTION_Y MOTION_WIDTH MOTION_HEIGHT MOTION_ENABLED \
  < <(wait_target_bounds "$MOTION_ID") ||
  fail "stable target bounds unavailable for ID $MOTION_ID"
[ "$MOTION_ENABLED" -eq 1 ] ||
  fail "Motion segment target ID $MOTION_ID is not actionable"
MOTION_CLICK_X=$((MOTION_X + MOTION_WIDTH / 2))
MOTION_CLICK_Y=$((MOTION_Y + MOTION_HEIGHT / 2))
record_metadata selected_target_id "$MOTION_ID"
record_metadata selected_target_bounds \
  "${MOTION_X},${MOTION_Y},${MOTION_WIDTH},${MOTION_HEIGHT}"
record_metadata selected_target_origin talkback-id-to-recorded-pixel-fallback
xdotool mousemove --window "$WINDOW_ID" \
  "$MOTION_CLICK_X" "$MOTION_CLICK_Y" click 1 ||
  fail 'Motion segment click injection failed'

SELECTION_PATTERN="zagkit: segment selection target-id=$MOTION_ID selected-index=2"
SELECTED_FRAME_PATTERN='zagkit: frame selected-segment=2 roving-segment=2 has-focus=1 focus-visible=0 hovered-segment=2 token-inspector-open=0 hovered-id=-1 pressed-id=-1 focused-id=-1 general-focus-visible=0 evidence-hash='
SELECTION_SEEN=0
for ((attempt = 0; attempt < POLL_ATTEMPTS; attempt++)); do
  preview_process_running || fail 'preview exited while waiting for segment selection'
  if grep -Fq "$SELECTION_PATTERN" "$RUNTIME_LOG" &&
      grep -Fq "$SELECTED_FRAME_PATTERN" "$RUNTIME_LOG"; then
    SELECTION_SEEN=1
    break
  fi
  sleep "$POLL_DELAY"
done
[ "$SELECTION_SEEN" -eq 1 ] ||
  fail "missing stable segment selection trace: $SELECTION_PATTERN"
record_metadata selected_trace "$SELECTION_PATTERN"
record_metadata selected_frame_trace "$SELECTED_FRAME_PATTERN"
capture_window "$WINDOW_ID" "$SELECT_CAPTURE" ||
  fail 'selected-segment screenshot failed'
SELECT_HASH=$(capture_hash "$SELECT_CAPTURE") ||
  fail 'selected-segment screenshot hash failed'
[ "$SELECT_HASH" != "$CLICK_HASH" ] ||
  fail 'selected segment did not change the presented composition'
record_metadata after_select_sha256 "$SELECT_HASH"

# Continue from the real pointer-focused segment. Keyboard navigation must
# skip unavailable Render, wrap to State, and make keyboard modality visible.
STATE_ID=20400
xdotool key --window "$WINDOW_ID" Right ||
  fail 'keyboard segment navigation injection failed'
KEY_SELECTION_PATTERN="zagkit: segment selection target-id=$STATE_ID selected-index=0"
KEY_FRAME_PATTERN='zagkit: frame selected-segment=0 roving-segment=0 has-focus=1 focus-visible=1 hovered-segment=2 token-inspector-open=0 hovered-id=-1 pressed-id=-1 focused-id=-1 general-focus-visible=0 evidence-hash='
KEYBOARD_SEEN=0
for ((attempt = 0; attempt < POLL_ATTEMPTS; attempt++)); do
  preview_process_running || fail 'preview exited while waiting for keyboard focus state'
  if grep -Fq "$KEY_SELECTION_PATTERN" "$RUNTIME_LOG" &&
      grep -Fq "$KEY_FRAME_PATTERN" "$RUNTIME_LOG"; then
    KEYBOARD_SEEN=1
    break
  fi
  sleep "$POLL_DELAY"
done
[ "$KEYBOARD_SEEN" -eq 1 ] ||
  fail "missing real keyboard focus trace: $KEY_FRAME_PATTERN"
capture_window "$WINDOW_ID" "$KEYBOARD_CAPTURE" ||
  fail 'keyboard-focus screenshot failed'
KEYBOARD_HASH=$(capture_hash "$KEYBOARD_CAPTURE") ||
  fail 'keyboard-focus screenshot hash failed'
[ "$KEYBOARD_HASH" != "$SELECT_HASH" ] ||
  fail 'keyboard focus and selection did not change presented pixels'
record_metadata keyboard_target_id "$STATE_ID"
record_metadata keyboard_trace "$KEY_SELECTION_PATTERN"
record_metadata keyboard_frame_trace "$KEY_FRAME_PATTERN"
record_metadata keyboard_focus_sha256 "$KEYBOARD_HASH"

# Tab leaves the segmented control through its one roving stop, wraps to the
# first enabled navigation item, then advances to Typography. The visible ring
# and semantic focus must move together before keyboard activation.
OVERVIEW_ID=20200
TYPOGRAPHY_ID=20203
xdotool key --window "$WINDOW_ID" Tab ||
  fail 'Tab from segmented control to primary navigation failed'
OVERVIEW_FOCUS_PATTERN='has-focus=0 focus-visible=0 hovered-segment=2 token-inspector-open=0 hovered-id=-1 pressed-id=-1 focused-id=20200 general-focus-visible=1 evidence-hash='
OVERVIEW_FOCUS_SEEN=0
for ((attempt = 0; attempt < POLL_ATTEMPTS; attempt++)); do
  preview_process_running || fail 'preview exited while moving focus to Overview'
  if grep -Fq "$OVERVIEW_FOCUS_PATTERN" "$RUNTIME_LOG"; then
    OVERVIEW_FOCUS_SEEN=1
    break
  fi
  sleep "$POLL_DELAY"
done
[ "$OVERVIEW_FOCUS_SEEN" -eq 1 ] ||
  fail 'Tab did not move actual focus from the segment to Overview'

xdotool key --window "$WINDOW_ID" Tab ||
  fail 'Tab from Overview to Typography failed'
TYPOGRAPHY_FOCUS_PATTERN='has-focus=0 focus-visible=0 hovered-segment=2 token-inspector-open=0 hovered-id=-1 pressed-id=-1 focused-id=20203 general-focus-visible=1 evidence-hash='
TYPOGRAPHY_FOCUS_SEEN=0
for ((attempt = 0; attempt < POLL_ATTEMPTS; attempt++)); do
  preview_process_running || fail 'preview exited while moving focus to Typography'
  if grep -Fq "$TYPOGRAPHY_FOCUS_PATTERN" "$RUNTIME_LOG"; then
    TYPOGRAPHY_FOCUS_SEEN=1
    break
  fi
  sleep "$POLL_DELAY"
done
[ "$TYPOGRAPHY_FOCUS_SEEN" -eq 1 ] ||
  fail 'Tab did not move actual focus to Typography'
capture_window "$WINDOW_ID" "$GENERAL_FOCUS_CAPTURE" ||
  fail 'navigation-focus screenshot failed'
GENERAL_FOCUS_HASH=$(capture_hash "$GENERAL_FOCUS_CAPTURE") ||
  fail 'navigation-focus screenshot hash failed'
[ "$GENERAL_FOCUS_HASH" != "$KEYBOARD_HASH" ] ||
  fail 'navigation focus ring did not change presented pixels'
record_metadata overview_focus_trace "$OVERVIEW_FOCUS_PATTERN"
record_metadata typography_focus_trace "$TYPOGRAPHY_FOCUS_PATTERN"
record_metadata navigation_focus_sha256 "$GENERAL_FOCUS_HASH"

# Typography is a real retained route, not a static label. Resolve it through
# the same Talkback ID geometry, then activate the real keyboard-focused
# destination. Prove that the hosted specimen replaces the chart, capture all
# three actual font weights, then return to Overview before resize behavior.
read -r TYPOGRAPHY_X TYPOGRAPHY_Y TYPOGRAPHY_WIDTH TYPOGRAPHY_HEIGHT \
  TYPOGRAPHY_ENABLED < <(wait_target_bounds "$TYPOGRAPHY_ID") ||
  fail "stable target bounds unavailable for ID $TYPOGRAPHY_ID"
[ "$TYPOGRAPHY_ENABLED" -eq 1 ] ||
  fail "Typography target ID $TYPOGRAPHY_ID is not actionable"
record_metadata typography_target_id "$TYPOGRAPHY_ID"
record_metadata typography_target_bounds \
  "${TYPOGRAPHY_X},${TYPOGRAPHY_Y},${TYPOGRAPHY_WIDTH},${TYPOGRAPHY_HEIGHT}"
record_metadata typography_target_origin talkback-id-plus-keyboard-focus
xdotool key --window "$WINDOW_ID" Return ||
  fail 'Typography route keyboard activation failed'
TYPOGRAPHY_SELECTION_PATTERN="zagkit: keyboard navigation selection target-id=$TYPOGRAPHY_ID selected-navigation=3"
TYPOGRAPHY_FRAME_PATTERN='zagkit: route selected-navigation=3 typography-composed=1 typography-rows=13'
TYPOGRAPHY_SEEN=0
for ((attempt = 0; attempt < POLL_ATTEMPTS; attempt++)); do
  preview_process_running || fail 'preview exited while opening Typography route'
  if grep -Fq "$TYPOGRAPHY_SELECTION_PATTERN" "$RUNTIME_LOG" &&
      grep -Fq "$TYPOGRAPHY_FRAME_PATTERN" "$RUNTIME_LOG"; then
    TYPOGRAPHY_SEEN=1
    break
  fi
  sleep "$POLL_DELAY"
done
[ "$TYPOGRAPHY_SEEN" -eq 1 ] ||
  fail 'Typography route did not publish its retained specimen state'
capture_window "$WINDOW_ID" "$TYPOGRAPHY_CAPTURE" ||
  fail 'Typography route screenshot failed'
TYPOGRAPHY_HASH=$(capture_hash "$TYPOGRAPHY_CAPTURE") ||
  fail 'Typography route screenshot hash failed'
[ "$TYPOGRAPHY_HASH" != "$GENERAL_FOCUS_HASH" ] ||
  fail 'Typography route did not change presented pixels'
record_metadata typography_trace "$TYPOGRAPHY_SELECTION_PATTERN"
record_metadata typography_frame_trace "$TYPOGRAPHY_FRAME_PATTERN"
record_metadata typography_sha256 "$TYPOGRAPHY_HASH"

read -r OVERVIEW_X OVERVIEW_Y OVERVIEW_WIDTH OVERVIEW_HEIGHT OVERVIEW_ENABLED \
  < <(wait_target_bounds "$OVERVIEW_ID") ||
  fail "stable target bounds unavailable for ID $OVERVIEW_ID"
[ "$OVERVIEW_ENABLED" -eq 1 ] ||
  fail "Overview target ID $OVERVIEW_ID is not actionable"
OVERVIEW_CLICK_X=$((OVERVIEW_X + OVERVIEW_WIDTH / 2))
OVERVIEW_CLICK_Y=$((OVERVIEW_Y + OVERVIEW_HEIGHT / 2))
xdotool mousemove --window "$WINDOW_ID" \
  "$OVERVIEW_CLICK_X" "$OVERVIEW_CLICK_Y" click 1 ||
  fail 'Overview route return injection failed'
OVERVIEW_SELECTION_PATTERN="zagkit: navigation selection target-id=$OVERVIEW_ID selected-navigation=0"
OVERVIEW_FRAME_PATTERN='zagkit: route selected-navigation=0 typography-composed=0 typography-rows=0'
OVERVIEW_SEEN=0
for ((attempt = 0; attempt < POLL_ATTEMPTS; attempt++)); do
  preview_process_running || fail 'preview exited while returning to Overview'
  if grep -Fq "$OVERVIEW_SELECTION_PATTERN" "$RUNTIME_LOG" &&
      grep -Fq "$OVERVIEW_FRAME_PATTERN" "$RUNTIME_LOG"; then
    OVERVIEW_SEEN=1
    break
  fi
  sleep "$POLL_DELAY"
done
[ "$OVERVIEW_SEEN" -eq 1 ] ||
  fail 'Overview route did not restore the canonical chart composition'
record_metadata overview_return_trace "$OVERVIEW_SELECTION_PATTERN"

# Resize below the 480x360 desktop composition minimum. The shell must remain
# alive and present the explicit semantic resize state, never a cropped chart.
xdotool windowsize "$WINDOW_ID" 320 240 ||
  fail '320x240 unsupported-size request failed'
SMALL_MATCHED=0
UNSUPPORTED_PATTERN='zagkit: unsupported-size target-id=20750 minimum=480x360'
for ((attempt = 0; attempt < POLL_ATTEMPTS; attempt++)); do
  preview_process_running || fail 'preview exited during unsupported-size resize'
  if read -r SMALL_WIDTH SMALL_HEIGHT < <(window_geometry "$WINDOW_ID") &&
      [ "$SMALL_WIDTH" -eq 320 ] && [ "$SMALL_HEIGHT" -eq 240 ] &&
      grep -Fq "$UNSUPPORTED_PATTERN" "$RUNTIME_LOG"; then
    SMALL_MATCHED=1
    break
  fi
  sleep "$POLL_DELAY"
done
[ "$SMALL_MATCHED" -eq 1 ] ||
  fail 'native shell did not publish its explicit unsupported-size state'
capture_window "$WINDOW_ID" "$SMALL_CAPTURE" ||
  fail 'unsupported-size screenshot failed'
SMALL_FILE=$(file -b "$SMALL_CAPTURE")
case "$SMALL_FILE" in
  *'320 x 240'*) ;;
  *) fail "unsupported-size screenshot dimensions disagree: $SMALL_FILE" ;;
esac
SMALL_HASH=$(capture_hash "$SMALL_CAPTURE") ||
  fail 'unsupported-size screenshot hash failed'
record_metadata unsupported_target_id 20750
record_metadata unsupported_geometry 320x240
record_metadata unsupported_sha256 "$SMALL_HASH"

xdotool windowsize "$WINDOW_ID" 800 600 || fail '800x600 resize request failed'
RESIZE_MATCHED=0
for ((attempt = 0; attempt < POLL_ATTEMPTS; attempt++)); do
  preview_process_running || fail 'preview exited while waiting for resize'
  if read -r RESIZED_WIDTH RESIZED_HEIGHT < <(window_geometry "$WINDOW_ID") &&
      [ "$RESIZED_WIDTH" -eq 800 ] && [ "$RESIZED_HEIGHT" -eq 600 ]; then
    RESIZE_MATCHED=1
    break
  fi
  sleep "$POLL_DELAY"
done
[ "$RESIZE_MATCHED" -eq 1 ] || fail 'window geometry did not reach 800x600'
record_metadata resized_geometry 800x600

RESIZED_DIMENSIONS_MATCHED=0
for ((attempt = 0; attempt < POLL_ATTEMPTS; attempt++)); do
  preview_process_running || fail 'preview exited while waiting for resized screenshot'
  if capture_window "$WINDOW_ID" "$RESIZED_CAPTURE"; then
    RESIZED_FILE=$(file -b "$RESIZED_CAPTURE")
    case "$RESIZED_FILE" in
      *'800 x 600'*) RESIZED_DIMENSIONS_MATCHED=1; break ;;
    esac
  fi
  sleep "$POLL_DELAY"
done
[ "$RESIZED_DIMENSIONS_MATCHED" -eq 1 ] ||
  fail 'resized native screenshot is not 800x600'
RESIZED_HASH=$(capture_hash "$RESIZED_CAPTURE") || fail 'resized screenshot hash failed'
record_metadata resized_sha256 "$RESIZED_HASH"

# Wait for four consecutive 50 ms samples without a CPU-tick change before
# measuring the formal one-second idle window. The measured window remains
# fail-closed and cannot be skipped by a slow final resize render.
SETTLE_STREAK=0
SETTLE_TICKS=$(proc_cpu_ticks "$PREVIEW_PID") || fail 'cannot read preview CPU ticks'
for ((attempt = 0; attempt < 40; attempt++)); do
  preview_process_running || fail 'preview exited before idle measurement'
  sleep "$POLL_DELAY"
  CURRENT_TICKS=$(proc_cpu_ticks "$PREVIEW_PID") || fail 'cannot sample preview CPU ticks'
  if [ "$CURRENT_TICKS" -eq "$SETTLE_TICKS" ]; then
    SETTLE_STREAK=$((SETTLE_STREAK + 1))
    if [ "$SETTLE_STREAK" -ge 4 ]; then break; fi
  else
    SETTLE_STREAK=0
    SETTLE_TICKS=$CURRENT_TICKS
  fi
done
[ "$SETTLE_STREAK" -ge 4 ] || fail 'preview did not become idle after resize'

IDLE_TICKS_BEFORE=$(proc_cpu_ticks "$PREVIEW_PID") || fail 'cannot begin idle CPU measurement'
for ((attempt = 0; attempt < 20; attempt++)); do
  preview_process_running || fail 'preview exited during idle CPU measurement'
  sleep "$POLL_DELAY"
done
IDLE_TICKS_AFTER=$(proc_cpu_ticks "$PREVIEW_PID") || fail 'cannot finish idle CPU measurement'
IDLE_TICK_DELTA=$((IDLE_TICKS_AFTER - IDLE_TICKS_BEFORE))
[ "$IDLE_TICK_DELTA" -ge 0 ] || fail 'preview CPU tick counter regressed'
[ "$IDLE_TICK_DELTA" -le "$IDLE_MAX_CPU_TICKS" ] ||
  fail "idle CPU used $IDLE_TICK_DELTA ticks; maximum is $IDLE_MAX_CPU_TICKS"
record_metadata idle_cpu_ticks "$IDLE_TICK_DELTA"
record_metadata idle_samples 20x0.05s

xdotool windowclose "$WINDOW_ID" || fail 'native close request failed'
for ((attempt = 0; attempt < POLL_ATTEMPTS; attempt++)); do
  preview_process_running || break
  sleep "$POLL_DELAY"
done
preview_process_running && fail 'preview did not exit after native close request'

set +e
wait "$PREVIEW_PID"
PREVIEW_EXIT=$?
set -e
PREVIEW_WAITED=1
[ "$PREVIEW_EXIT" -eq 0 ] || fail "preview exited with status $PREVIEW_EXIT"
record_metadata preview_exit "$PREVIEW_EXIT"

printf 'linux interaction test: PASS (pid=%s window=%s disabled_id=%s selected_id=%s idle_ticks=%s)\n' \
  "$PREVIEW_PID" "$WINDOW_ID" "$COMPONENTS_ID" "$MOTION_ID" \
  "$IDLE_TICK_DELTA"
if [ -n "$EVIDENCE_DIR" ]; then
  printf 'linux interaction test: evidence -> %s\n' "$EVIDENCE_DIR"
fi
