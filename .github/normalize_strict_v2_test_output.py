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
    for name in ("passed_text", "failed_text", "passed", "failed"):
        updated = updated.replace(
            f"_zag_print({name});", f"_zag_println({name});")
    if updated != text:
        path.write_text(updated)
        changed.append(str(path))

print("strict-v2 test output normalization:")
if changed:
    for path in changed:
        print(f"  {path}")
else:
    print("  no legacy owned _zag_print summaries found")
