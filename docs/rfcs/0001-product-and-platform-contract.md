# RFC 0001: Product and platform contract

- Status: Accepted
- Decision date: 2026-08-06
- Owners: Zagkit maintainers

## Context

A widget library cannot provide coherent text, gesture, animation,
accessibility, recovery, and tooling guarantees across desktop and mobile.
Proxying platform widgets also fragments behavior and makes renderer truth
uninspectable.

## Decision

Zagkit is a separately versioned first party application platform built in Zag.
It owns the view, layout, semantics, text, input, motion, rendering, component,
and tooling layers. It targets Linux, macOS, Windows, iOS, and Android with one
adaptive design system.

Web, browser rendering, and WebView hosting are outside 1.0. Zagkit is not an
exact imitation of any platform, but adaptive components respect platform input,
navigation, density, menu, typography, and accessibility conventions.

The parity baseline is the capability developers expect from mature declarative
systems: [SwiftUI accessibility](https://developer.apple.com/documentation/swiftui/accessibility-fundamentals),
[Compose state and semantics](https://developer.android.com/develop/ui/compose/architecture),
[Flutter's layered engine and embedders](https://docs.flutter.dev/resources/architectural-overview),
and the [Qt Quick scene graph](https://doc.qt.io/QT-6/qtquick-visualcanvas-scenegraph.html).
These are architecture references, not runtime dependencies.

PrismStudio is the first complex consumer after the Linux preview. A focused
mobile reference app proves the mobile architecture. The component gallery is a
conformance tool, not the only product proof.

## Tooling contract

The first party command surface is `zagkit init`, `zagkit build`, `zagkit run`,
and `zagkit test`. The development environment includes live preview and reload,
a component gallery, semantic inspector, layout reason inspector, frame
timeline, accessibility overlay, theme editor, snapshot runner, and capability
report. These tools consume the same state, semantics, display list, scheduler,
and capability records as applications. Debug tooling cannot become a second
renderer or hidden source of behavior.

## Compatibility

Public API begins unstable under `0.x` SemVer. No platform receives the product
name 1.0 early. The initial stable API freezes only after all five families pass
the shared gate.

## Consequences

This is a larger program than wrapping existing native widgets. It creates one
coherent interaction and inspection model, keeps platform seams replaceable,
and forces missing compiler and runtime primitives to improve Zag for every
consumer.

## Verification

The repository contract gate must find exactly five required platform families,
an active 1.0 block, an exact compiler pin, and no unsupported capability claim.
Runtime verification is defined in RFC 0005.
