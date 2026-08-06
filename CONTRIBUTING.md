# Contributing to Zagkit

Zagkit accepts narrowly scoped, evidence backed changes that preserve the
architecture and support claims in this repository.

## Before writing code

1. Read [GOVERNANCE.md](GOVERNANCE.md), [DEPENDENCIES.md](DEPENDENCIES.md), and
   the [accepted RFCs](docs/rfcs/README.md).
2. Check [the upstream ledger](contracts/upstream-zag.json). A reusable compiler,
   ABI, concurrency, package, or platform defect belongs in Zag first.
3. Check the visual direction gate. Visual component production cannot begin
   until [the design review](docs/design/visual-direction.md) is accepted.
4. Add or update the smallest contract, test, benchmark, or conformance scene
   that can prove the change.

## Change requirements

- Production implementation is Zag. Do not add a C, C++, Zig, Rust, browser,
  WebView, or foreign toolkit fallback to make a missing Zag feature disappear.
- Do not preserve a workaround merely because it would be conventional in
  another language ecosystem. Improve Zag until the direct design is possible.
- Public OS APIs are permitted only at the platform seams listed in
  [DEPENDENCIES.md](DEPENDENCIES.md).
- A backend or feature may be `supported`, `experimental`, or `unavailable`.
  Supported and experimental states require named executable evidence.
- GPU work on hardware must be explicitly selected, bounded, and recoverable.
  Discovery, compilation, screenshots, or CPU output do not certify GPU use.
- Tests must include cleanup and negative behavior where resources, malformed
  input, callbacks, device loss, or platform boundaries are involved.
- Keep unrelated worktree changes out of the commit.

An upstream fix is complete only when it is committed separately in
`/home/micah/Desktop/Sylorlabs/zag`, carries source and native executable
conformance there, and the affected Zagkit gate passes against that exact Zag
commit. A local Zag working tree, patched compiler binary, or downstream-only
test is not a dependency revision.

## Local gate

```sh
./tools/check-contracts.sh
git diff --check
```

Later milestones add compiler, unit, fuzz, golden, live platform, performance,
accessibility, and packaging gates. A green contract check does not substitute
for any of them.

## RFCs

Use [RFC 0000](docs/rfcs/0000-rfc-process.md) for changes to public API,
architecture, dependency boundaries, backend truth, or release gates. An RFC
records a decision. It is not implementation evidence.
