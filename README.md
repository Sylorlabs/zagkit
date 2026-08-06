# Zagkit

Zagkit is a first party application platform and UI toolkit built in Zag. It is
being designed for one adaptive product codebase across Linux, macOS, Windows,
iOS, and Android, with precise text, fluid interaction, built in semantics, and
inspectable runtime truth.

The durable, CI-checked execution plan is the [master goal checklist](GOAL.md).
It includes the Flex placement system, Zagkit Talkback native automation,
modern materials and asset fidelity, and a complete PrismStudio UI replacement.

This repository is at **0.1.0-experimental.0**. It currently contains the
accepted product contract and executable Milestone 0 checks. It does not yet
contain a usable renderer, window shell, component library, or supported
platform backend. Nothing in this repository is a Zagkit 1.0 release.

## What Zagkit owns

Zagkit will own the declarative view model, state tracking, reconciliation,
layout, semantics, input, animation, text, display lists, CPU rendering,
components, and developer tools. Public operating system APIs are narrow seams
for lifecycle, surfaces, input methods, accessibility, GPU submission, and
packaging. They do not define Zagkit's architecture.

The deterministic CPU renderer will be the visual oracle. Metal, D3D12, and
public Linux and Android GPU APIs will carry a Zag owned render IR. Backend
selection, fallback, and device loss will always be observable through a
capability record.

Zagkit is not a wrapper around native widgets and will not ship Skia, Flutter,
Qt, FreeType, HarfBuzz, a browser, or a WebView as its UI engine. System fonts
and published Unicode and OpenType data are allowed inputs. The exact boundary
is normative in [DEPENDENCIES.md](DEPENDENCIES.md).

## Status

| Area | Current state | Proof |
|---|---|---|
| Product and architecture contract | accepted | [RFC index](docs/rfcs/README.md) |
| Compiler dependency | pinned, prerequisites incomplete | [toolchain lock](contracts/toolchain.json) |
| Platform shells | unavailable | [support matrix](SUPPORT.md) |
| Headless core | not implemented | [roadmap](ROADMAP.md) |
| Components and visual language | inventory only, visual review pending | [component inventory](contracts/components.json) |
| Flex and Zagkit Talkback | contract accepted, not implemented | [RFC 0006](docs/rfcs/0006-flex-talkback-visual-fidelity-and-prismstudio.md) |
| Benchmarks | scene specifications only, no results | [benchmark contract](benchmarks/README.md) |

Run the repository contract gate with:

```sh
./tools/check-contracts.sh
```

The gate validates the release identity, exact Zag revision, required platform
families, backend truth states, upstream prerequisite ledger, component
inventory, benchmark scene coverage, and the 1.0 block.

## Build order

1. Advance reusable compiler, ABI, concurrency, package, and platform features
   in [Zag](https://github.com/Sylorlabs/zag), each with native executable proof.
2. Build Zagkit's deterministic headless core.
3. Ship a polished Linux reference, then completely rebuild PrismStudio's UI on Zagkit.
4. Reach desktop parity on macOS and Windows.
5. Reach mobile parity on iOS and Android.
6. Call the shared product 1.0 only after all five families pass the same gate.

See [ROADMAP.md](ROADMAP.md) for milestone exit conditions and
[CONTRIBUTING.md](CONTRIBUTING.md) before proposing implementation work.

## License

Apache License 2.0. See [LICENSE](LICENSE).
