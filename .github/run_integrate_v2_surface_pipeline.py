from pathlib import Path
import ast
import os
import shutil
import subprocess
import tempfile

repo = Path.cwd()
integration_workflow = '.github/workflows/integrate-v2-surface-pipeline.yml'
integration_marker = "python3 - <<'PY'"

# Find the latest revision containing the reviewed embedded renderer payload.
commits = subprocess.check_output(
    ['git', 'log', '--format=%H', '--', integration_workflow],
    text=True,
).splitlines()
source_commit = None
integration_raw = None
for commit in commits:
    candidate = subprocess.check_output(
        ['git', 'show', f'{commit}:{integration_workflow}'],
        text=True,
    )
    if integration_marker in candidate:
        source_commit = commit
        integration_raw = candidate
        break
if source_commit is None or integration_raw is None:
    raise SystemExit('reviewed renderer transplant payload not found in workflow history')

integration_lines = integration_raw.splitlines()
start = next(i for i, line in enumerate(integration_lines)
             if line.strip() == integration_marker)
finish = next(i for i in range(start + 1, len(integration_lines))
              if integration_lines[i].strip() == 'PY')
integration_body = []
for line in integration_lines[start + 1:finish]:
    integration_body.append(line[10:] if line.startswith('          ') else line)
integration_body_text = '\n'.join(integration_body) + '\n'


def extract_python_heredoc(workflow: Path) -> str:
    lines = workflow.read_text().splitlines()
    start_index = next(i for i, line in enumerate(lines)
                       if line.strip() in ("python3 <<'PY'", "python3 - <<'PY'"))
    finish_index = next(i for i in range(start_index + 1, len(lines))
                        if lines[i].strip() == 'PY')
    body = []
    for line in lines[start_index + 1:finish_index]:
        body.append(line[10:] if line.startswith('          ') else line)
    return '\n'.join(body) + '\n'


def literal_value(node: ast.AST, values: dict[str, object]) -> object:
    if isinstance(node, ast.Constant):
        return node.value
    if isinstance(node, ast.Name):
        if node.id not in values:
            raise KeyError(node.id)
        return values[node.id]
    if isinstance(node, ast.BinOp) and isinstance(node.op, ast.Add):
        return literal_value(node.left, values) + literal_value(node.right, values)
    if isinstance(node, ast.List):
        return [literal_value(item, values) for item in node.elts]
    raise TypeError(ast.dump(node))


def apply_reviewed_surface_edits(worktree: Path) -> None:
    tree = ast.parse(integration_body_text)
    values: dict[str, object] = {}
    actions: list[tuple[str, tuple[object, ...]]] = []

    # Collect reviewed literal values and mutation calls without executing the
    # historical orchestration. Harmless formatting drift is handled below.
    for node in tree.body:
        if isinstance(node, ast.Assign) and len(node.targets) == 1 and \
                isinstance(node.targets[0], ast.Name):
            name = node.targets[0].id
            try:
                values[name] = literal_value(node.value, values)
            except (KeyError, TypeError):
                pass
            continue
        if not isinstance(node, ast.Expr) or not isinstance(node.value, ast.Call):
            continue
        call = node.value
        if isinstance(call.func, ast.Name) and call.func.id in ('replace_once', 'replace_between'):
            args = tuple(literal_value(arg, values) for arg in call.args)
            actions.append((call.func.id, args))
            continue
        if isinstance(call.func, ast.Attribute) and call.func.attr == 'write_text':
            owner = call.func.value
            if isinstance(owner, ast.Call) and isinstance(owner.func, ast.Name) and \
                    owner.func.id == 'Path' and len(owner.args) == 1:
                path = literal_value(owner.args[0], values)
                content = literal_value(call.args[0], values)
                if path == 'docs/components/surface-v2.md':
                    actions.append(('write_text', (path, content)))

    def replace_once(path: str, old: str, new: str) -> None:
        file = worktree / path
        text = file.read_text()
        count = text.count(old)
        if count == 1:
            file.write_text(text.replace(old, new, 1))
            return

        if path == 'src/components/surface_v2.zag' and \
                'let before: i32 = budget.display_operations;' in old and \
                'shadow_operations = budget.display_operations - before;' in old:
            emit = text.index('fn surface_v2_emit(')
            block_start = text.index(
                '        let before: i32 = budget.display_operations;', emit)
            end_marker = '        shadow_operations = budget.display_operations - before;\n'
            block_end = text.index(end_marker, block_start) + len(end_marker)
            file.write_text(text[:block_start] + new + text[block_end:])
            return

        if path == 'src/components/surface_v2.zag' and \
                'draw = surface_v2_draw_chrome(spec, effects,' in old and \
                'draw = surface_v2_draw_states(spec,' in old:
            emit = text.index('fn surface_v2_emit(')
            block_start = text.index(
                '    draw = surface_v2_draw_chrome(spec, effects,', emit)
            failure_marker = (
                '    if (draw.error != SurfaceBuildError.none) {\n'
                '        surface_rollback(display, hits, semantics, checkpoint);\n'
            )
            block_end = text.index(failure_marker, block_start)
            file.write_text(text[:block_start] + new + text[block_end:])
            return

        if path == 'tests/surface_v2_contract.zag':
            # The dormant foundation has evolved whitespace around these three
            # assertions. The user-visible messages and semantic anchors are
            # stable, so replace only the reviewed assertion tails/range.
            if 'content panel is opaque modern depth with bounded two-part shadow work' in old:
                message = '"content panel is opaque modern depth with bounded two-part shadow work");'
                message_index = text.index(message)
                block_start = text.rfind(
                    '        built_panel.artifact.shadow_operations ==', 0, message_index)
                if block_start < 0:
                    raise SystemExit('panel shadow assertion anchor not found')
                block_end = message_index + len(message)
                file.write_text(text[:block_start] + new + text[block_end:])
                return

            if 'transient overlay receives one bounded glass treatment and overlay depth' in old:
                message = '"transient overlay receives one bounded glass treatment and overlay depth");'
                message_index = text.index(message)
                block_start = text.rfind(
                    '        built_overlay.artifact.effects.blur_radius ==', 0, message_index)
                if block_start < 0:
                    raise SystemExit('overlay shadow assertion anchor not found')
                block_end = message_index + len(message)
                file.write_text(text[:block_start] + new + text[block_end:])
                return

            if 'focused.artifact.base.focus_ring_visible == 1 &&' in old and \
                    'focused.artifact.base.semantics_role == SemanticRole.button &&' in old:
                first = '        focused.artifact.base.focus_ring_visible == 1 &&\n'
                last = '        focused.artifact.base.semantics_role == SemanticRole.button &&\n'
                block_start = text.index(first)
                block_end = text.index(last, block_start) + len(last)
                file.write_text(text[:block_start] + new + text[block_end:])
                return

        raise SystemExit(
            f'{path}: reviewed replacement did not match current foundation '
            f'(count={count}): {old[:160]!r}')

    def replace_between(path: str, first: str, last: str, replacement: str) -> None:
        file = worktree / path
        text = file.read_text()
        start_index = text.index(first)
        end_index = text.index(last, start_index)
        file.write_text(text[:start_index] + replacement + text[end_index:])

    for action, args in actions:
        if action == 'replace_once':
            replace_once(*args)
        elif action == 'replace_between':
            replace_between(*args)
        elif action == 'write_text':
            path, content = args
            destination = worktree / path
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_text(content)


# Execute the reviewed visual foundation at the historical source revision,
# preserving the public API files that the integration contract explicitly says
# must not be rewritten. Then apply the reviewed SurfaceV2 portion structurally.
worktree = Path(tempfile.mkdtemp(prefix='zagkit-v2-render-source-'))
subprocess.check_call(['git', 'worktree', 'add', '--detach', str(worktree), source_commit])
try:
    historical_preserved = (
        'src/zagkit_v2.zag',
        'src/design/visual_system.zag',
        'src/design/visual_system_v2.zag',
        'src/render/analytic_shadow.zag',
        'src/components/surface.zag',
        'tests/surface_contract.zag',
        'docs/components/surface.md',
    )
    preserved = {
        path: (worktree / path).read_text()
        for path in historical_preserved
    }

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

    dormant_body = extract_python_heredoc(dormant_path)
    old_cwd = Path.cwd()
    os.chdir(worktree)
    try:
        exec(compile(dormant_body, 'zagkit-v2-render-foundation.py', 'exec'),
             {'__name__': '__main__'})
    finally:
        os.chdir(old_cwd)

    for path, content in preserved.items():
        (worktree / path).write_text(content)

    apply_reviewed_surface_edits(worktree)

    # Require the intended retained-native shadow path before harvesting.
    required = {
        'src/render/display_list.zag': 'fill_rounded_shadow',
        'src/render/display_list_codec.zag': 'fill_rounded_shadow',
        'src/render/cpu_raster.zag': 'fill_rounded_shadow',
        'src/components/surface_v2.zag': 'surface_v2_shadow_operation_count() i32 { return 2; }',
    }
    for path, needle in required.items():
        if needle not in (worktree / path).read_text():
            raise SystemExit(f'{path}: reviewed renderer result missing {needle!r}')
    if 'fn surface_v2_shadow_bands' in \
            (worktree / 'src/components/surface_v2.zag').read_text():
        raise SystemExit('SurfaceV2 still contains legacy shadow-band implementation')

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
        *historical_preserved,
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
