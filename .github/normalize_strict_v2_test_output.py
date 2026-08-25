from pathlib import Path

changed = []
for path in sorted(Path("tests").glob("*.zag")):
    text = path.read_text()
    updated = text
    # Edition-2027 ownership checking correctly requires compiler output bridges
    # to be non-retaining. Until the next pinned Zag revision carries that
    # compiler fix, keep legacy numeric test summaries on the already-proven
    # _zag_println bridge instead of passing owned conversion buffers to
    # _zag_print. This touches reporting only; assertions and product code stay
    # unchanged.
    updated = updated.replace("_zag_print(passed_text);", "_zag_println(passed_text);")
    updated = updated.replace("_zag_print(failed_text);", "_zag_println(failed_text);")
    if updated != text:
        path.write_text(updated)
        changed.append(str(path))

print("strict-v2 test output normalization:")
if changed:
    for path in changed:
        print(f"  {path}")
else:
    print("  no legacy owned _zag_print summaries found")
