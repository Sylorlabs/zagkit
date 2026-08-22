# Versioning and release channels

Zagkit uses Semantic Versioning 2.0.0.

## Version meaning before 1.0

- `0.MINOR.PATCH-experimental.N` may change any API and may have no usable
  platform backend.
- `0.MINOR.PATCH-alpha.N` provides coherent end to end slices for named
  platforms, but important APIs and recovery behavior remain incomplete.
- `0.MINOR.PATCH-beta.N` freezes the intended API for named platforms and has
  native accessibility, text input, packaging, recovery, and performance
  evidence. Defects can still block production use.
- `1.0.0` requires the common gate on all five platform families. There is no
  platform specific early 1.0.

A release channel describes maturity, not capability. The generated capability
record remains authoritative.

## Compatibility

Before 1.0, breaking API changes require a changelog entry and migration note.
After 1.0, public source API compatibility follows SemVer. Serialization,
replay, snapshot, render IR, plugin, and binary compatibility each remain
separately versioned contracts and must not be inferred from the package
version.

The Zag ABI is currently unstable. Every Zagkit release pins an exact Zag
commit and edition in [contracts/toolchain.json](contracts/toolchain.json).
Consumers rebuild Zagkit and its Zag dependencies with that toolchain unless a
release explicitly proves a compatible range.

## Release contents

Every release must include:

- exact Zagkit and Zag revisions;
- backend capability record, including `.auto` selections and fallbacks;
- reference hardware and operating system versions;
- benchmark and quality gate results;
- known unsupported features and untested hardware;
- reproducible build inputs and artifact hashes;
- packaging install, launch, update, and uninstall evidence where applicable.

Until the release automation can produce this evidence, releases remain
experimental and source only.
