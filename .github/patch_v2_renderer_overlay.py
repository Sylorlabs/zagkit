from pathlib import Path

# Renderer transplant compatibility for the current strict-v2 compiler pin.
helper = Path('.github/run_integrate_v2_surface_pipeline.py')
text = helper.read_text()
anchor = '''    apply_reviewed_surface_edits(worktree)\n\n    # Require the intended retained-native shadow path before harvesting.\n'''
overlay = '''    apply_reviewed_surface_edits(worktree)\n\n    # The reviewed native-render branch contains the complete IR delta plus its\n    # dedicated contract. Its parent render blobs are byte-identical to the\n    # active branch, so overlaying these exact files is a clean transplant and\n    # avoids the older dormant workflow's incomplete codec/test extraction.\n    renderer_commit = '005e423357e28529cf745dc34a6f51e3987a6c3a'\n    renderer_paths = (\n        'src/render/display_list.zag',\n        'src/render/display_list_codec.zag',\n        'src/render/cpu_raster.zag',\n        'tests/visual_system_v2_contract.zag',\n    )\n    try:\n        subprocess.check_call(\n            ['git', 'cat-file', '-e', f'{renderer_commit}^{{commit}}'],\n            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)\n    except subprocess.CalledProcessError:\n        subprocess.check_call(['git', 'fetch', 'origin', renderer_commit])\n    for path in renderer_paths:\n        content = subprocess.check_output(\n            ['git', 'show', f'{renderer_commit}:{path}'], text=True)\n        destination = worktree / path\n        destination.parent.mkdir(parents=True, exist_ok=True)\n        destination.write_text(content)\n\n    # Bring the staged regression forward to strict edition-2027 semantics.\n    # The assertions stay identical; only discarded mutating return values are\n    # named so a stack address is not misclassified as a non-local store.\n    contract = worktree / 'tests/visual_system_v2_contract.zag'\n    contract_text = contract.read_text()\n    strict_replacements = {\n        '_ = display_list_push(&list, shadow);':\n            'let shadow_push_error: DisplayError = display_list_push(&list, shadow);',\n        '_ = display_list_push(&list, fill);':\n            'let fill_push_error: DisplayError = display_list_push(&list, fill);',\n        '_ = display_list_seal(&list);':\n            'let seal_error: DisplayError = display_list_seal(&list);',\n    }\n    for old, new in strict_replacements.items():\n        if contract_text.count(old) != 1:\n            raise SystemExit(f'visual contract expected one {old!r}')\n        contract_text = contract_text.replace(old, new, 1)\n    contract.write_text(contract_text)\n\n    # Require the intended retained-native shadow path before harvesting.\n'''
if text.count(anchor) != 1:
    raise SystemExit(f'expected one renderer overlay anchor, found {text.count(anchor)}')
text = text.replace(anchor, overlay, 1)

old_codec_gate = "        'src/render/display_list_codec.zag': 'fill_rounded_shadow',\n"
new_codec_gate = "        'src/render/display_list_codec.zag': 'kind_code > 13',\n"
if text.count(old_codec_gate) != 1:
    raise SystemExit(f'expected one codec gate, found {text.count(old_codec_gate)}')
text = text.replace(old_codec_gate, new_codec_gate, 1)

old_status = '''    status = subprocess.check_output(\n        ['git', '-C', str(worktree), 'diff', '--name-status', '--no-renames'],\n        text=True,\n    ).splitlines()\n'''
new_status = '''    status = subprocess.check_output(\n        ['git', '-C', str(worktree), 'status', '--porcelain', '--untracked-files=all'],\n        text=True,\n    ).splitlines()\n'''
if text.count(old_status) != 1:
    raise SystemExit(f'expected one harvest status command, found {text.count(old_status)}')
text = text.replace(old_status, new_status, 1)

old_parse = '''        code, path = row.split('\\t', 1)\n        if path in protected_exact or path.startswith(protected_prefixes):\n            continue\n        destination = repo / path\n        source = worktree / path\n        if code.startswith('D'):\n            destination.unlink(missing_ok=True)\n            copied.append(f'D {path}')\n            continue\n        destination.parent.mkdir(parents=True, exist_ok=True)\n        shutil.copy2(source, destination)\n        copied.append(f'{code} {path}')\n'''
new_parse = '''        code = row[:2]\n        path = row[3:]\n        if path in protected_exact or path.startswith(protected_prefixes):\n            continue\n        destination = repo / path\n        source = worktree / path\n        if 'D' in code:\n            destination.unlink(missing_ok=True)\n            copied.append(f'D {path}')\n            continue\n        destination.parent.mkdir(parents=True, exist_ok=True)\n        shutil.copy2(source, destination)\n        copied.append(f'{code.strip() or code} {path}')\n'''
if text.count(old_parse) != 1:
    raise SystemExit(f'expected one harvest row parser, found {text.count(old_parse)}')
text = text.replace(old_parse, new_parse, 1)

helper.write_text(text)
