from pathlib import Path
import subprocess

workflow_path = '.github/workflows/integrate-v2-surface-pipeline.yml'
marker = "python3 - <<'PY'"

# Locate the most recent historical revision that still contains the reviewed
# embedded transplant. The live workflow has since been reduced to syntax-safe
# orchestration, so a fixed HEAD^ assumption is intentionally avoided.
commits = subprocess.check_output(
    ['git', 'log', '--format=%H', '--', workflow_path],
    text=True,
).splitlines()
raw = None
source_commit = None
for commit in commits:
    candidate = subprocess.check_output(
        ['git', 'show', f'{commit}:{workflow_path}'],
        text=True,
    )
    if marker in candidate:
        raw = candidate
        source_commit = commit
        break
if raw is None:
    raise SystemExit('reviewed renderer transplant payload not found in workflow history')

lines = raw.splitlines()
start = next(i for i, line in enumerate(lines) if line.strip() == marker)
finish = next(i for i in range(start + 1, len(lines))
              if lines[i].strip() == 'PY')
body = []
for line in lines[start + 1:finish]:
    body.append(line[10:] if line.startswith('          ') else line)

# Preserve strict-v2 and repository-hygiene repairs authored after the renderer
# payload. The transplant may update rendering/components/tests, but it must not
# regress the exact compiler audit or repaired semantics/documentation gates.
preserve_paths = [
    'src/semantics/semantics.zag',
    'tests/surface_contract.zag',
    'GOAL.md',
    'tools/check-contracts.sh',
    'contracts/toolchain.json',
    'contracts/upstream-zag.json',
]
preserve_paths += [str(path) for path in sorted(Path('docs/evidence').glob('*.md'))]
preserved = {path: Path(path).read_text() for path in preserve_paths}

exec(compile('\n'.join(body) + '\n',
             f'integrate-v2-surface-pipeline-{source_commit}.py', 'exec'),
     {'__name__': '__main__'})

for path, content in preserved.items():
    Path(path).write_text(content)

print(f'Applied reviewed native shadow/display-list SurfaceV2 transplant from {source_commit}')
