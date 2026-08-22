#!/usr/bin/env bash
set -euo pipefail

SCRIPT_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
DEFAULT_PRISM_ROOT="$SCRIPT_ROOT/../PrismStudio"
ARG_ROOT="${1:-}"
if [ -n "${ARG_ROOT}" ]; then
  PRISM_ROOT="$ARG_ROOT"
elif [ -d "$DEFAULT_PRISM_ROOT" ]; then
  PRISM_ROOT="$DEFAULT_PRISM_ROOT"
elif [ -d "/home/micah/Desktop/Sylorlabs/PrismStudio" ]; then
  PRISM_ROOT="/home/micah/Desktop/Sylorlabs/PrismStudio"
else
  PRISM_ROOT=""
fi

if [ -z "$PRISM_ROOT" ]; then
  echo "E: PrismStudio root not found. Set with first argument or place it at ../PrismStudio relative to this repo." >&2
  exit 1
fi
OUTPUT_MD="${2:-docs/evidence/prismstudio-migration-inventory-$(date +%Y-%m-%d).md}"
OUTPUT_JSON="${3:-contracts/prismstudio-migration-inventory.json}"

if [ ! -d "$PRISM_ROOT" ]; then
  echo "E: PrismStudio root missing: $PRISM_ROOT" >&2
  exit 1
fi

if [ ! -x "$(command -v python3 || true)" ]; then
  echo "E: python3 is required for this generator" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT_MD")" "$(dirname "$OUTPUT_JSON")"

python3 - "$PRISM_ROOT" "$OUTPUT_MD" "$OUTPUT_JSON" <<'PY'
from __future__ import annotations

import json
import re
import sys
from collections import OrderedDict
from pathlib import Path

prism_root = Path(sys.argv[1])
out_md = Path(sys.argv[2])
out_json = Path(sys.argv[3])

inventory_md = prism_root / "docs" / "INVENTORY.md"
manifest_md = prism_root / "probe" / "MANIFEST.md"
mcp_zag = prism_root / "src" / "mcp.zag"
workspace_zag = prism_root / "src" / "workspace.zag"
commands_zag = prism_root / "src" / "commands.zag"
agents_md = prism_root / "AGENTS.md"

required_paths = (
    inventory_md,
    manifest_md,
    mcp_zag,
    workspace_zag,
    commands_zag,
    agents_md,
)
for path in required_paths:
    if not path.exists():
        raise SystemExit(f"E: required source missing: {path}")


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def parse_inventory(path: Path):
    text = read_text(path)
    modules = []
    in_section = False
    for line in text.splitlines():
        if line.startswith("## Source modules"):
            in_section = True
            continue
        if not in_section:
            continue
        if line.startswith("## "):
            break
        if not line.startswith("|"):
            continue
        if line.startswith("| Module |") or line.startswith("|---"):
            continue
        m = re.match(r"^\|\s*`([^`]+)`\s*\|\s*(.*?)\s*\|$", line)
        if m:
            modules.append({"name": m.group(1).strip(), "role": m.group(2).strip()})
    return modules


def parse_manifest(path: Path):
    text = read_text(path)
    sections = []
    current_heading = None
    declared = None
    bullets = []

    for raw in text.splitlines():
        line = raw.strip()
        if raw.startswith("## "):
            if current_heading is not None:
                sections.append(
                    {
                        "heading": current_heading,
                        "declared": declared,
                        "probes": bullets,
                    }
                )
            heading_match = re.match(r"^##\s+(.+?)\s*$", raw)
            if heading_match:
                heading_body = heading_match.group(1).strip()

                declared = None
                m_declared = re.search(r"\((\d+)\)\s*$", heading_body)
                if m_declared is None:
                    m_declared = re.search(r"\s+[—-]\s+(\d+)\s*$", heading_body)
                if m_declared:
                    declared = int(m_declared.group(1))

                current_heading = re.sub(r"\s*\(\d+\)\s*$", "", heading_body)
                current_heading = re.sub(r"\s+[—-]\s+\d+\s*$", "", current_heading)
                current_heading = current_heading.strip()
                bullets = []
                continue

            # Non-manifest heading while parsing; stop at next top-level heading.
            current_heading = None
            declared = None
            bullets = []
            continue

        if current_heading is None or not line.startswith("- "):
            continue

        m = re.match(r"^- `([^`]+)`\s*$", line)
        if m:
            bullets.append(m.group(1))
        else:
            m = re.match(r"^- (.+)$", line)
            if m:
                bullets.append(m.group(1).strip())

    if current_heading is not None:
        sections.append(
            {
                "heading": current_heading,
                "declared": declared,
                "probes": bullets,
            }
        )

    return [
        section for section in sections if section["probes"] or section["declared"] is not None
    ]


def parse_mcp_tools(path: Path):
    text = read_text(path)
    tools = []
    seen = set()
    pattern = re.compile(r'mcp_append_tool\(&out,\s*(true|false),\s*"([^"]+)"')
    for line in text.splitlines():
        m = pattern.search(line)
        if m:
            key = (m.group(2), m.group(1) == "true")
            if key in seen:
                continue
            tools.append({"name": key[0], "mutation": key[1]})
            seen.add(key)
    return tools


def parse_command_ids(path: Path):
    text = read_text(path)
    pattern = re.compile(
        r"fn\s+(cmd_[A-Za-z0-9_]+)\s*\(\)\s*i32\s*\{\s*return\s*(-?\d+)\s*;\s*\}"
    )
    items = []
    seen = set()
    for m in pattern.finditer(text):
        name = m.group(1)
        value = int(m.group(2))
        key = (name, value)
        if key in seen:
            continue
        items.append({"name": name, "id": value})
        seen.add(key)
    return sorted(items, key=lambda item: (item["id"], item["name"]))


def parse_workspace_sections(path: Path):
    text = read_text(path)
    sections = []
    seen = set()
    pattern = re.compile(r"Section\s+([0-9]+(?:\.[0-9]+)?)\s*[:\)]?\s*(.*)")
    for line in text.splitlines():
        m = pattern.search(line)
        if not m:
            continue
        label = m.group(2).strip(" -—:\u2014").strip()
        if label and not re.search(r"[A-Za-z]", label):
            continue
        section_key = f"section-{m.group(1)}"
        if section_key in seen:
            continue
        seen.add(section_key)
        sections.append({
            "id": m.group(1),
            "name": label,
        })
    return sections


def parse_agents_rules(path: Path):
    lines = read_text(path).splitlines()
    in_rules = False
    rules = []
    for line in lines:
        if line.startswith("## Hard Rules"):
            in_rules = True
            continue
        if not in_rules:
            continue
        if re.match(r"^## ", line):
            break
        m = re.match(r"^###\s+\d+\.\s+(.*)", line)
        if m:
            rules.append({"title": m.group(1).strip()})
    return rules


inventory_modules = parse_inventory(inventory_md)
manifest_sections = parse_manifest(manifest_md)
mcp_tools = parse_mcp_tools(mcp_zag)
workspace_sections = parse_workspace_sections(workspace_zag)
command_ids = parse_command_ids(commands_zag)
hard_rules = parse_agents_rules(agents_md)

manifest_probe_total = sum(len(section["probes"]) for section in manifest_sections)
declared_total = sum(section["declared"] for section in manifest_sections if section["declared"] is not None)

manifest_coverage = []
for section in manifest_sections:
    declared = section["declared"]
    parsed = len(section["probes"])
    status = "complete"
    if declared is None:
        status = "partial"
    elif parsed < declared:
        status = "partial"
    manifest_coverage.append({
        "heading": section["heading"],
        "declared": declared,
        "parsed": parsed,
        "status": status,
        "probes": section["probes"],
    })

summary = {
    "source": {
        "prismstudio_root": str(prism_root),
        "inventory_module_count": len(inventory_modules),
        "manifest_sections": len(manifest_sections),
        "manifest_section_declared_total": declared_total,
        "manifest_probe_total": manifest_probe_total,
        "mcp_tool_count": len(mcp_tools),
        "command_id_count": len(command_ids),
        "workspace_sections": len(workspace_sections),
        "hard_rules_count": len(hard_rules),
    },
    "migration_scope": {
        "source_modules": inventory_modules,
        "probe_manifest_sections": manifest_sections,
        "manifest_count_check": manifest_coverage,
        "mcp_protocol_tools": mcp_tools,
        "command_ids": command_ids,
        "workspace_sections": workspace_sections,
        "hard_rules": hard_rules,
    },
    "open_questions": [
        "No native UI transport exists in this repo for full PrismStudio parity; this inventory proves extraction scope only.",
        "No one-shot pixel-to-talking migration suite exists for every command/state pair yet.",
        "G6 migration shell replacement and full automation coverage are still unimplemented in Zagkit.",
    ],
}

out_json.write_text(json.dumps(summary, indent=2), encoding="utf-8")

lines = [
    "# PrismStudio migration evidence inventory",
    "",
    f"Generated: 2026-08-07 (workflow artifact)",
    f"Source: `{prism_root}`",
    "",
    "## Source inventory",
    "",
    f"- Source modules discovered: {len(inventory_modules)}",
    f"- Manifest sections discovered: {len(manifest_sections)}",
    f"- Probe files discovered by manifest: {manifest_probe_total}",
    f"- Probe files declared by manifest heading: {declared_total}",
    f"- MCP protocol tools discovered: {len(mcp_tools)}",
    f"- Command identifiers discovered: {len(command_ids)}",
    f"- Workspace sections discovered from source comments: {len(workspace_sections)}",
    f"- Hard-rule sets in AGENTS: {len(hard_rules)}",
    "",
    "## Source module snapshot",
    "",
    "| Module | Role |",
    "| --- | --- |",
]

for module in inventory_modules:
    lines.append(f"| {module['name']} | {module['role'].replace('|', '\\|')} |")

lines += [
    "",
    "## Probe manifest coverage",
    "",
]

for section in manifest_coverage:
    declared = section["declared"]
    parsed = section["parsed"]
    marker = "✅" if section["status"] == "complete" else "⚠️"
    if declared is None:
        summary_text = f"parsed {parsed}"
    else:
        summary_text = f"declared {declared}, parsed {parsed}"
    lines.append(f"- {marker} **{section['heading']}**: {summary_text}")
    if section["status"] == "partial":
        lines.append("  - parser gap or declaration mismatch; audit manifest header-by-header")
    if section["probes"]:
        sample = ", ".join(f"`{name}`" for name in section["probes"][:12])
        if len(section["probes"]) > 12:
            sample += "…"
        lines.append(f"  - sample: {sample}")

lines += [
    "",
    "## Workspace section map",
    "",
]
for section in workspace_sections:
    lines.append(f"- {section['id']}: {section['name'] or 'unlabeled section'}")

lines += [
    "",
    "## PrismStudio command surface",
    "",
]
for entry in command_ids:
    lines.append(f"- `{entry['name']}` = `{entry['id']}`")

lines += [
    "",
    "## MCP tools",
    "",
]
for tool in mcp_tools:
    suffix = "mutation" if tool["mutation"] else "query"
    lines.append(f"- `{tool['name']}` ({suffix})")

lines += [
    "",
    "## Hard rules carried into migration planning",
    "",
]
for rule in hard_rules:
    lines.append(f"- {rule['title']}")

lines += [
    "",
    "## Open ownership questions (must close before G6-** tasks)",
    "",
    "- Confirm that every visible or keyboard-operable control in the target PrismStudio migration matrix has a mapped Zagkit replacement before shell replacement.",
    "- Confirm each protocol transport behavior above is represented by the same automation contract in Zagkit Talkback (not via pixel fallback).",
    "- Confirm each critical visual asset state (lighting/shadows/glass, scale variants, transparency and reduced-motion variants) has a matching native fixture policy before finalizing visual direction selection.",
]

out_md.write_text("\n".join(lines) + "\n", encoding="utf-8")

print(f"wrote migration map markdown: {out_md}")
print(f"wrote migration map json: {out_json}")
print(f"discovered manifest sections: {len(manifest_sections)}")
print(f"discovered manifest probes: {manifest_probe_total}")
print(f"discovered workspace sections: {len(workspace_sections)}")
print(f"discovered command ids: {len(command_ids)}")
print(f"discovered hard rules: {len(hard_rules)}")
PY

echo "wrote migration map markdown: $OUTPUT_MD"
echo "wrote migration map json: $OUTPUT_JSON"
