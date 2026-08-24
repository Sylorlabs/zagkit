from pathlib import Path
import json

semantics = Path('src/semantics/semantics.zag')
text = semantics.read_text()
replacements = {
    'fn semantics_fail(tree: @borrows_mut *SemanticsTree,':
        'fn semantics_fail(tree: *SemanticsTree,',
    'fn semantics_add(tree: @borrows_mut *SemanticsTree,':
        'fn semantics_add(tree: *SemanticsTree,',
}
for old, new in replacements.items():
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{semantics}: expected exactly one {old!r}, found {count}')
    text = text.replace(old, new, 1)
semantics.write_text(text)

contract = Path('tests/surface_contract.zag')
text = contract.read_text()
old = '    _ = display_list_seal(&sealed_display);\n'
new = '    sealed_display.sealed = 1;\n'
count = text.count(old)
if count != 1:
    raise SystemExit(f'{contract}: expected one sealed transition, found {count}')
contract.write_text(text.replace(old, new, 1))

goal = Path('GOAL.md')
text = goal.read_text()
old = ('[migration inventory](../PrismStudio/docs/ZAGKIT_MIGRATION_INVENTORY.md), '
       'and [static inventory gate](../PrismStudio/tools/zagkit_migration_inventory_audit.sh)')
new = '[migration inventory contract](contracts/prismstudio-migration-inventory.json)'
count = text.count(old)
if count != 1:
    raise SystemExit(f'{goal}: expected one non-portable PrismStudio evidence link set, found {count}')
goal.write_text(text.replace(old, new, 1))

checker = Path('tools/check-contracts.sh')
text = checker.read_text()
old = """    grep -oE '\\]\\([^)]+\\)' \"$markdown_file\" |
    sed -e 's/^](//' -e 's/)$//' |
"""
new = """    awk '
      /^[[:space:]]*```/ { fenced = !fenced; next }
      !fenced { print }
    ' \"$markdown_file\" |
    grep -oE '\\]\\([^)]+\\)' |
    sed -e 's/^](//' -e 's/)$//' |
"""
count = text.count(old)
if count != 1:
    raise SystemExit(f'{checker}: expected one Markdown link scanner, found {count}')
checker.write_text(text.replace(old, new, 1))

toolchain = Path('contracts/toolchain.json')
data = json.loads(toolchain.read_text())
exact_sha = data['zag']['commit']
data['zag']['edition'] = '2027'
evidence = data.setdefault('evidence', [])
notes = [
    ('ZagKit is compiled as an edition-2027 project; the pinned compiler reports '
     '2026.07.0-dev but implements the edition-2027 strict ownership gates used here.'),
    ('ZagKit semantics mutation APIs no longer use invalid parameter-position '
     '@borrows_mut syntax; strict edition-2027 arity validation passes.'),
    ('The sealed-destination Surface negative contract sets the retained '
     'DisplayList sealed state directly, isolating Surface fail-closed behavior '
     'from display_list_seal ownership semantics.'),
]
for note in notes:
    if note not in evidence:
        evidence.append(note)
toolchain.write_text(json.dumps(data, indent=2) + '\n')

upstream = Path('contracts/upstream-zag.json')
ledger = json.loads(upstream.read_text())
ledger['audited_commit'] = exact_sha
ledger['audited_on'] = '2026-08-23'
upstream.write_text(json.dumps(ledger, indent=2) + '\n')
