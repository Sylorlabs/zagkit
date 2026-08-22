# RFC 0003: Text, semantics, and input ownership

- Status: Accepted
- Decision date: 2026-08-06
- Owners: Zagkit maintainers

## Text decision

Zagkit owns Unicode decoding and normalization, bidi, segmentation, line
breaking, OpenType shaping, font fallback, variable and color fonts, emoji,
selection, editing, and rasterization. System fonts and published Unicode and
OpenType data are inputs. FreeType, HarfBuzz, Skia, native text widgets, and
browser text engines are not runtime dependencies.

Malformed input, fonts, tables, clusters, and variation data must fail safely
under fuzzing. Font absence is an observable fallback event, never silent
replacement presented as exact typography.

## Semantics decision

Every component produces a parallel `SemanticsNode` tree. Nodes carry stable
identity, role, name, description, value, state, actions, focus order, live
region behavior, selection, ranges, text navigation, bounds, and relationships.
Actual focus is explicit state, distinct from focus order and focus-ring
visibility. A valid tree exposes at most one enabled, visible, focusable node as
focused; adapters and automation never infer focus from paint.

The semantics tree drives native accessibility adapters, automation, semantic
tests, and the inspector. Accessibility does not scrape pixels or infer meaning
from implementation type names. Visual and semantic trees may differ in shape,
but their relationship is inspectable.

## Input decision

The normalized input model covers pointer, keyboard, touch, pen, wheel,
gamepad, focus, commands, drag and drop, and IME composition. Gesture
recognizers participate in explicit arbitration and cancellation. Velocity,
coalesced events, history, capture, and gesture handoff are retained so motion
does not jump when ownership changes.

Platform text clients remain required seams. AppKit and UIKit adapters expose
their public [accessibility](https://developer.apple.com/documentation/appkit/accessibility-for-appkit)
and [text input](https://developer.apple.com/documentation/appkit/nstextinputclient)
contracts; Windows uses its public
[custom text input](https://learn.microsoft.com/en-us/windows/apps/develop/input/custom-text-input)
and UI Automation contracts; Linux and Android provide equivalent public
adapters. System APIs transport editing and accessibility state but do not own
the document model or semantics tree.

## Verification

Unicode and font parsers receive unit, property, fuzz, and differential tests
against published data. Editing suites cover composition in several script
families, selection, replacement, undo, clipboard, missing fonts, and malformed
input. Semantics suites cover role, name, value, actions, focus, live regions,
selection, ranges, and text navigation in automation and native assistive
technologies.
