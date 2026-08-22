# Milestone 1 upstream prerequisite execution tracker

- Goal: keep this checklist as the canonical next-step gate before claiming `1. Advance Zag` progress in `GOAL.md`.
- Completion policy: each unchecked item must have a linked upstream commit, native conformance command, and proof artifact.

| Upstream ledger ID | Target area | Scope | Current state | Immediate next action | Proof required |
| --- | --- | --- | --- | --- | --- |
| `target-linux-arm64` | Linux ARM64 object target | [2, 7] | `partial` | Continue with deterministic ARM64 executable + bootstrap + cleanup proof at current pinned commit or newer pinned commit. | native ABI + self-host + cleanup evidence |
| `target-darwin-macho` | Mach-O targets | [5, 6, 7] | `missing` | Upstream Mach-O backend + executable conformance on declared macOS versions. | x86_64/ARM64 native execution evidence |
| `target-windows-pe-coff` | PE/COFF objects | [5, 7] | `missing` | Upstream PE/COFF backend + ABI/unwind/resource/lifecycle conformance. | Windows native executor evidence |
| `target-ios-arm64` | iOS executable format | [6, 7] | `missing` | Implement iOS output + signing path and native lifecycle conformance. | physical-device smoke + lifecycle evidence |
| `target-android-arm64` | Android executable format | [6, 7] | `missing` | Implement Android output + JNI lifecycle conformance path. | physical-device execution evidence |
| `abi-objective-c` | Objective-C ABI seams | [5, 6, 7] | `missing` | Add Objective-C message/callback/aggregate tests and conformance implementation. | message/callback/ownership suites |
| `abi-com` | COM ABI seams | [5, 7] | `missing` | Add COM interface/lifetime/threading/HRESULT aggregate cases and conformance. | Windows COM ABI evidence |
| `abi-jni` | JNI ABI seams | [6, 7] | `missing` | Add Java↔Zag call, exceptions, references, callbacks, cleanup. | Android/JNI conformance evidence |
| `abi-callbacks` | Foreign callbacks | [3, 5, 6, 7] | `partial` | Extend beyond one scalar callback to captures, aggregates, unwind, reentrancy. | callback suites per target |
| `abi-aggregates` | Aggregate ABI | [3, 5, 6, 7] | `missing` | Add structs/unions/floats/vectors/returns across targets. | ABI aggregate conformance |
| `resource-embedding` | Compiler owned resources | [3, 5, 6, 7] | `partial` | Extend to all object formats and malformed-target/cross-target deterministic suites. | binary-empty-malformed-reproducibility evidence |
| `dynamic-platform-loading` | Dynamic loading | [3, 5, 6, 7] | `partial` | Expand symbol lookup/version failure/unload/aggregate paths. | per-target dynamic loading suites |
| `main-loop-and-workers` | Scheduler + workers | [2, 3, 5, 6, 7] | `partial` | Implement wakeup, cancel, affinity, shutdown and race tests. | concurrency suites |
| `package-resolution` | Package semantics | [2, 3, 5, 6, 7] | `partial` | Add registry/conflict/offline/reproducible checksums flow and lockfile contract. | deterministic resolution evidence |
| `incremental-and-reload-hooks` | Incremental reload | [2, 3, 5, 6, 7] | `partial` | Add stable reload/recovery hooks, state-preserving rebuild, rollback. | reload crash-recovery suites |
| `G1-SOURCE-FIRST` | Source-first enforcement | [all] | `unchecked` | For each downstream workaround, add an upstream fix in `/home/micah/Desktop/Sylorlabs/zag`. | upstream regression IDs linked in downstream checklist |

## Action rule

1. Do not mark an item complete until every exit condition is linked to a native executable conformance command and artifact path.
2. Every downstream workaround in `/home/micah/Desktop/Sylorlabs/PrismStudio` must be paired with a `G1-SOURCE-FIRST` upstream fix in `/home/micah/Desktop/Sylorlabs/zag`.
3. Keep this file synchronized with `contracts/upstream-zag.json` and `GOAL.md`.
