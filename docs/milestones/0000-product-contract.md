# Milestone 0 audit

- Status: Implemented, pending review and CI
- Date: 2026-08-06
- Runtime capability promoted: none

## Deliverables

| Requirement | Record | Gate |
|---|---|---|
| Separate Apache 2.0 repository | repository root and LICENSE | required file check |
| Governance | GOVERNANCE.md | required file check |
| Semantic versioning and labels | VERSIONING.md, zag.mod | version identity check |
| Support matrix | contracts/platforms.json | platform and capability validation |
| Architecture RFCs | docs/rfcs | accepted RFC check |
| Benchmark scenes | contracts/benchmark-scenes.json | scene and variant validation |
| Component inventory | contracts/components.json | component and visual gate validation |
| Compiler revision | contracts/toolchain.json | exact SHA, version, and edition validation |
| Upstream prerequisites | contracts/upstream-zag.json | required entry and evidence validation |
| Visual direction pause | docs/design/visual-direction.md | blocked gate validation |
| CI contract gate | tools/check-contracts.sh | local and GitHub Actions execution |
| Durable goal checklist | GOAL.md | stable ID, evidence, and exit-condition validation |
| Expanded toolkit contract | RFC 0006 | Flex, Talkback, visual fidelity, and PrismStudio validation |

## Zag audit boundary

The release pin resolves the clean Zag `agent/zagkit-prerequisites` commit
`63e3979d91bfd06f53ee317bd6bf428673814bdf`. It was exported from the exact Git
tree, self-hosted to a byte-identical stage-2/stage-3 fixpoint without external
tools, and passed the resource, aggregate switch value-flow, foreground-cache,
cache-integration, tooling, checksum, stored-zlib, and general DEFLATE gates on
x86-64 and qemu-user ARM64. The neighboring
local Zag checkout still contains extensive unrelated
changes; those changes were not used to claim capabilities or construct this
release identity.

At the pinned commit, Zag documents x86-64 Linux as supported and ARM64 Linux as
experimental through qemu-user execution. Mach-O, PE/COFF, iOS, Android, the
platform ABIs, general foreign callbacks and aggregates, cross-platform resource
object formats, cross-platform dynamic loading, complete concurrency, package
resolution, and stable reload hooks remain missing or partial as recorded in the
upstream ledger.

## Completion meaning

Passing this milestone means the program can start against a coherent and
machine checked contract. It does not mean the headless core, Linux preview,
text engine, accessibility, components, renderer, or tooling exists.
