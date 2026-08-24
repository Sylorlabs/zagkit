from pathlib import Path
import os
import shutil
import subprocess
import tempfile

repo = Path.cwd()
workflow_path = '.github/workflows/integrate-v2-surface-pipeline.yml'
marker = "python3 - <<'PY'"

# Find the latest revision containing the reviewed embedded renderer payload.
commits = subprocess.check_output(
    ['git', 'log', '--format=%H', '--', workflow_path],
    text=True,
).splitlines()
source_commit = None
raw = None
for commit in commits:
    candidate = subprocess.check_output(
        ['git', 'show', f'{commit}:{workflow_path}'],
        text=True,
    )
    if marker in candidate:
        source_commit = commit
        raw = candidate
        break
if source_commit is None or raw is None:
    raise SystemExit('reviewed renderer transplant payload not found in workflow history')

lines = raw.splitlines()
start = next(i for i, line in enumerate(lines) if line.strip() == marker)
finish = next(i for i in range(start + 1, len(lines))
              if lines[i].strip() == 'PY')
body = []
for line in lines[start + 1:finish]:
    body.append(line[10:] if line.startswith('          ') else line)
body_text = '\n'.join(body) + '\n'

# Run the reviewed patch against its own historical repository shape. This
# avoids forcing stale string-replacement assumptions onto today's stricter
# Surface/semantics API. Only the product diff produced by that reviewed patch
# is transplanted back onto the current branch.
worktree = Path(tempfile.mkdtemp(prefix='zagkit-v2-render-source-'))
subprocess.check_call(['git', 'worktree', 'add', '--detach', str(worktree), source_commit])
try:
    # The outer renderer payload explicitly snapshots and restores these files.
    # Its dormant visual-foundation payload predates that preservation contract
    # and contains strict replace-once assertions against legacy Surface. Make
    # those helper-based mutations no-ops so the reviewed renderer/codec/CPU
    # changes can be harvested without rewriting the preserved public API.
    historical_preserved = (
        'src/zagkit_v2.zag',
        'src/design/visual_system.zag',
        'src/design/visual_system_v2.zag',
        'src/render/analytic_shadow.zag',
        'src/components/surface.zag',
        'tests/surface_contract.zag',
        'docs/components/surface.md',
    )
    dormant_path = worktree / '.github/workflows/zagkit-v2-visual-system.yml'
    dormant_text = dormant_path.read_text()
    helper_start = (
        '          def replace_once(path: str, old: str, new: str) -> None:\n'
        '              file = Path(path)\n'
    )
    helper_replacement = (
        '          def replace_once(path: str, old: str, new: str) -> None:\n'
        f'              if path in {historical_preserved!r}:\n'
        '                  return\n'
        '              file = Path(path)\n'
    )
    count = dormant_text.count(helper_start)
    if count != 1:
        raise SystemExit(
            f'dormant visual foundation: expected one replace_once helper, found {count}')
    dormant_path.write_text(dormant_text.replace(
        helper_start, helper_replacement, 1))

    old_cwd = Path.cwd()
    os.chdir(worktree)
    try:
        exec(compile(body_text,
                     f'integrate-v2-surface-pipeline-{source_commit}.py', 'exec'),
             {'__name__': '__main__'})
    finally:
        os.chdir(old_cwd)

    status = subprocess.check_output(
        ['git', '-C', str(worktree), 'diff', '--name-status', '--no-renames'],
        text=True,
    ).splitlines()

    protected_exact = {
        'GOAL.md',
        'contracts/toolchain.json',
        'contracts/upstream-zag.json',
        'src/semantics/semantics.zag',
        'tests/surface_contract.zag',
        'tools/check-contracts.sh',
        'zag.mod',
    }
    protected_prefixes = (
        '.github/',
        'docs/evidence/',
    )

    copied = []
    for row in status:
        if not row.strip():
            continue
        code, path = row.split('\t', 1)
        if path in protected_exact or path.startswith(protected_prefixes):
            continue
        destination = repo / path
        source = worktree / path
        if code.startswith('D'):
            destination.unlink(missing_ok=True)
            copied.append(f'D {path}')
            continue
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, destination)
        copied.append(f'{code} {path}')

    if not copied:
        raise SystemExit('reviewed renderer payload produced no transplantable product diff')
    print(f'Applied reviewed renderer payload from {source_commit}:')
    for item in copied:
        print(f'  {item}')
finally:
    subprocess.call(['git', 'worktree', 'remove', '--force', str(worktree)])
    shutil.rmtree(worktree, ignore_errors=True)
