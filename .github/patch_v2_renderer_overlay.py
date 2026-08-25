from pathlib import Path

helper = Path('.github/run_integrate_v2_surface_pipeline.py')
text = helper.read_text()
anchor = '''    apply_reviewed_surface_edits(worktree)\n\n    # Require the intended retained-native shadow path before harvesting.\n'''
overlay = '''    apply_reviewed_surface_edits(worktree)\n\n    # The reviewed native-render branch contains the complete three-file IR\n    # delta. Its parent blobs are byte-identical to the active branch's render\n    # blobs, so overlaying these exact files is a clean delta and avoids the\n    # older dormant workflow's incomplete codec extraction.\n    renderer_commit = '005e423357e28529cf745dc34a6f51e3987a6c3a'\n    renderer_paths = (\n        'src/render/display_list.zag',\n        'src/render/display_list_codec.zag',\n        'src/render/cpu_raster.zag',\n    )\n    try:\n        subprocess.check_call(\n            ['git', 'cat-file', '-e', f'{renderer_commit}^{{commit}}'],\n            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)\n    except subprocess.CalledProcessError:\n        subprocess.check_call(['git', 'fetch', 'origin', renderer_commit])\n    for path in renderer_paths:\n        content = subprocess.check_output(\n            ['git', 'show', f'{renderer_commit}:{path}'], text=True)\n        (worktree / path).write_text(content)\n\n    # Require the intended retained-native shadow path before harvesting.\n'''
if text.count(anchor) != 1:
    raise SystemExit(f'expected one renderer overlay anchor, found {text.count(anchor)}')
helper.write_text(text.replace(anchor, overlay, 1))
