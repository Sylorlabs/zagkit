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

The release pin resolves the clean Zag `zag-v2-machine-control` commit
`67cad46feb6a6d912b8d599d7ed3ade7e81175c5`. The neighboring local Zag checkout
contains extensive unrelated changes on another branch. Those changes were not
used to claim capabilities or construct a release identity.

At the pinned commit, Zag documents x86-64 Linux as supported and ARM64 Linux as
experimental through qemu-user execution. Mach-O, PE/COFF, iOS, Android, the
platform ABIs, general foreign callbacks and aggregates, resource embedding,
cross-platform dynamic loading, complete concurrency, package resolution, and
stable reload hooks remain missing or partial as recorded in the upstream
ledger.

## Completion meaning

Passing this milestone means the program can start against a coherent and
machine checked contract. It does not mean the headless core, Linux preview,
text engine, accessibility, components, renderer, or tooling exists.
