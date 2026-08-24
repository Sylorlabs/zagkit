from pathlib import Path
import subprocess

# The preceding commit contains the reviewed renderer transplant payload inside
# the historical workflow. Read it as data so GitHub's YAML parser never has to
# parse the embedded Zag/Python multiline strings again.
raw = subprocess.check_output(
    ['git', 'show', 'HEAD^:.github/workflows/integrate-v2-surface-pipeline.yml'],
    text=True,
)
lines = raw.splitlines()
start = next(i for i, line in enumerate(lines)
             if line.strip() == "python3 - <<'PY'")
finish = next(i for i in range(start + 1, len(lines))
              if lines[i].strip() == 'PY')
body = []
for line in lines[start + 1:finish]:
    body.append(line[10:] if line.startswith('          ') else line)

# These files contain strict-v2 and repository-hygiene repairs that landed
# after the renderer payload was authored. The renderer transplant must not
# regress them even if the dormant foundation payload touches adjacent areas.
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
             'integrate-v2-surface-pipeline-reviewed.py', 'exec'),
     {'__name__': '__main__'})

for path, content in preserved.items():
    Path(path).write_text(content)

print('Applied reviewed native shadow/display-list SurfaceV2 transplant')
