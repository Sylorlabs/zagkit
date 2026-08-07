#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
GOAL_FILE="$ROOT_DIR/GOAL.md"
OUTPUT_PATH="${1:-}"

if [ ! -f "$GOAL_FILE" ]; then
  echo "missing GOAL.md at $GOAL_FILE" >&2
  exit 1
fi

if [ ! -x "$(command -v jq || true)" ]; then
  echo "jq is required" >&2
  exit 1
fi

usage() {
  cat <<'USAGE'
Usage: emit-agent-checklist.sh [output.md]

If output.md is provided, the checklist is written there.
Otherwise it is printed to stdout.
USAGE
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

python3 - "$ROOT_DIR" "$GOAL_FILE" "$OUTPUT_PATH" <<'PY'
import json
import re
import sys
from pathlib import Path
from datetime import datetime

root_dir = Path(sys.argv[1])
goal_path = Path(sys.argv[2])
output_path = sys.argv[3] if len(sys.argv) > 3 else ""
contracts_dir = root_dir / "contracts"

goal_text = goal_path.read_text(encoding="utf-8").splitlines()
upstream = json.loads((contracts_dir / "upstream-zag.json").read_text(encoding="utf-8"))
platforms = json.loads((contracts_dir / "platforms.json").read_text(encoding="utf-8"))

upstream_by_id = {entry["id"]: entry for entry in upstream.get("entries", [])}
platform_capabilities = {
    f"{plat['id']}::{cap['id']}": cap for plat in platforms.get("platforms", []) for cap in plat.get("capabilities", [])
}

goal_to_upstream = {
    "G1-LINUX-ARM64": "target-linux-arm64",
    "G1-DARWIN": "target-darwin-macho",
    "G1-WINDOWS": "target-windows-pe-coff",
    "G1-IOS": "target-ios-arm64",
    "G1-ANDROID": "target-android-arm64",
    "G1-OBJC": "abi-objective-c",
    "G1-COM": "abi-com",
    "G1-JNI": "abi-jni",
    "G1-CALLBACKS": "abi-callbacks",
    "G1-AGGREGATES": "abi-aggregates",
    "G1-RESOURCES": "resource-embedding",
    "G1-DYNAMIC-LOAD": "dynamic-platform-loading",
    "G1-CONCURRENCY": "main-loop-and-workers",
    "G1-PACKAGES": "package-resolution",
    "G1-RELOAD": "incremental-and-reload-hooks",
}

goal_to_platform_blocker = {
    "G5-WAYLAND": ("linux", "platform_shell"),
    "G5-X11": ("linux", "platform_shell"),
    "G5-ATSPI": ("linux", "accessibility"),
    "G5-LINUX-CPU": ("linux", "cpu_renderer"),
    "G5-LINUX-GPU": ("linux", "gpu_transport"),
    "G5-LINUX-POLISH": ("linux", "packaging"),
    "G5-LINUX-FIDELITY": ("linux", "cpu_renderer"),
    "G5-LINUX-PACKAGE": ("linux", "packaging"),
    "G4-ACCESSIBILITY": ("linux", "accessibility"),
}

goal_to_fallback_reason = {
    "G0-VISUAL-DIRECTION": "blocked until full visual-matrix + RFC 0007 acceptance and recommendation packet exist",
    "G3-UNICODE": "foundation contracts are in place; Unicode normalization, scripts, and locale logic are not yet implemented end to end",
    "G3-OPENTYPE": "headless contracts do not yet include full shaping, fallback, and OpenType asset coverage",
    "G3-EDITING": "text editing, selection, caret, and IME-aware model are not yet implemented",
    "G3-FONTS": "font fallback policy, precision typography, and legibility matrix are not yet implemented",
    "G3-COLOR": "wide-gamut conversion and color-management contracts are not yet implemented",
    "G3-SVG": "secure SVG decode/render contract is not yet implemented",
    "G3-PNG": "full PNG color-profile, malformed, and safety contracts are not yet implemented",
    "G3-SHADOWS": "material shadow primitives and shadow test suite are not yet implemented",
    "G3-LIGHTING": "lighting and depth contracts are not yet implemented",
    "G3-GLASS": "glass material contracts are not yet implemented",
    "G3-MOTION": "advanced motion contract beyond replay is not yet implemented",
    "G3-REDUCED-MOTION": "reduced-motion replacement matrix and assertions are not yet implemented",
    "G3-ASSET-PIPELINE": "asset lifecycle, missing asset behavior, and cleanup contracts are not yet implemented",
    "G4-INPUT": "input routing across pointer/keyboard/touch/pen/gamepad host seams is not yet implemented",
    "G4-GESTURES": "gesture arbitration and handoff contracts are not yet implemented",
    "G4-CLI": "CLI host workflow is currently headless-only and lacks promoted-target clean-workflow verification",
    "G4-PREVIEW": "live preview and reload contracts are not yet implemented",
    "G4-INSPECTORS": "inspector surfaces are not yet implemented",
    "G4-GALLERY": "component gallery conformance surface is not yet implemented",
    "G6-INVENTORY": "PrismStudio migration work requires replacement of visible shell and inventory mapping",
    "G6-DESIGN": "PrismStudio visual direction must be selected and accepted before migration",
    "G6-SHELL": "PrismStudio shell replacement is not implemented in this repository",
    "G6-WORKFLOWS": "PrismStudio workflows have not yet been migrated to Zagkit-native equivalents",
    "G6-VIEWPORT": "PrismStudio viewport chrome and interactions remain unmigrated",
    "G6-DENSE-UI": "PrismStudio dense UI surfaces remain unmigrated",
    "G6-MATERIALS": "Materials and visual tokens for PrismStudio have not been migrated",
    "G6-ASSETS": "PrismStudio production asset migration remains incomplete",
    "G6-AUTOMATION": "PrismStudio actions must expose stable IDs through a native UI migration",
    "G6-ACCESSIBILITY": "PrismStudio accessibility polish is blocked on full migration",
    "G6-SCREENSHOTS": "PrismStudio native screenshot comparison cannot run before full UI migration",
    "G6-PERFORMANCE": "PrismStudio performance gates depend on migrated native UI and runtime"
    ,
    "G6-POLISH": "PrismStudio polish requires full migration and defect closure",
    "G7-MACOS": "depends on completed upstream targets, linux parity, and migration evidence",
    "G7-WINDOWS": "depends on completed upstream targets, linux parity, and migration evidence",
    "G7-IOS": "depends on completed upstream targets, linux parity, and migration evidence",
    "G7-ANDROID": "depends on completed upstream targets, linux parity, and migration evidence",
    "G7-MOBILE-REFERENCE": "depends on native mobile runtime, text/IME, and component migration",
    "G7-COMPONENT-PARITY": "depends on component suite migration across all five targets",
    "G7-TEXT-PARITY": "depends on Unicode, font, IME, and text rendering completion",
    "G7-RECOVERY": "depends on recovery/lifecycle evidence across all five platforms",
    "G7-PERFORMANCE": "depends on 120Hz/idle/stall/recovery evidence on reference hardware",
    "G7-PACKAGING": "depends on install/update/uninstall coverage on all supported platforms",
    "G7-ONE-POINT-ZERO": "depends on every remaining milestone and unexpired waivers",
}


def format_upstream_reason(goal_id: str) -> str:
    upstream_id = goal_to_upstream.get(goal_id)
    if not upstream_id:
        return ""
    entry = upstream_by_id.get(upstream_id)
    if not entry:
        return f"missing ledger entry for {upstream_id}"
    return f"upstream prerequisite `{upstream_id}` is `{entry.get('state')}`: {entry.get('evidence', '').strip()}"


def format_platform_reason(goal_id: str) -> str:
    platform_ref = goal_to_platform_blocker.get(goal_id)
    if not platform_ref:
        return ""
    platform, cap = platform_ref
    key = f"{platform}::{cap}"
    cap_entry = platform_capabilities.get(key)
    if not cap_entry:
        return f"missing platform capability evidence for {platform}/{cap}"
    reason = cap_entry.get("reason", "unavailable")
    return f"`{platform}` capability `{cap}` unavailable: {reason}"


blocked = {}
section = ""
for line in goal_text:
    if line.startswith("## "):
        section = line[3:].strip()
        continue
    if line.startswith("## Checklist maintenance"):
        section = ""
        continue
    match = re.match(r"^- \[ \] `([^`]+)`", line)
    if section and match:
        blocked.setdefault(section, []).append(match.group(1))

lines = []
lines.append("# Zagkit execution checklist (agent-facing)")
lines.append("")
lines.append(f"- Generated: {datetime.now().astimezone().isoformat(timespec='seconds')}")
lines.append("- Source of truth: GOAL.md")
lines.append("- Evidence inputs: GOAL.md, contracts/upstream-zag.json, contracts/platforms.json")
lines.append("")
lines.append("## Blocked items, in checklist order")
lines.append("")
for section, ids in blocked.items():
    if not ids:
        continue
    lines.append(f"### {section}")
    for item_id in ids:
        reason = goal_to_fallback_reason.get(item_id, "")
        upstream_reason = format_upstream_reason(item_id)
        platform_reason = format_platform_reason(item_id)
        if upstream_reason:
            reason = upstream_reason
        elif platform_reason:
            reason = platform_reason
        elif not reason:
            reason = "requires downstream implementation and native evidence"
        lines.append(f"- [ ] `{item_id}`: {reason}")
    lines.append("")

lines.append("## Immediate next actions")
lines.append("")
lines.append("- Advance upstream prerequisites in `/home/micah/Desktop/Sylorlabs/zag` until no required G1 entries are `missing`/`partial`.")
lines.append("- Complete RFC 0007 full-direction acceptance after full visual matrix evidence is generated.")
lines.append("- Implement Linux shell/AT-SPI and capability-backed backends only after capability blockers are reduced.")
lines.append("- Resume PrismStudio migration once repository write access is available and inventory-driven UI replacement is planned.")

content = "\n".join(lines) + "\n"

if output_path:
    output = Path(output_path)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(content, encoding="utf-8")
    print(f"wrote {output}")
else:
    print(content)
PY
