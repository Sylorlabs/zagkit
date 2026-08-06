# RFC 0006: Flex, Talkback, visual fidelity, and PrismStudio

- Status: Accepted
- Decision date: 2026-08-06
- Owners: Zagkit maintainers

## Decision

Zagkit includes a first-party placement system named **Flex**, a first-party
native automation and inspection system named **Zagkit Talkback**, and a modern
adaptive visual-material system. The complete PrismStudio interface will be
rebuilt on these public Zagkit contracts and is required product proof.

These are core architecture and release requirements. They are not examples,
optional packages, post-1.0 polish, or PrismStudio-only helpers.

## Flex

Flex is the public placement and spacing contract for stacks, wrapping rows and
columns, grids, overlays, scroll content, safe areas, and adaptive composition.
It owns typed length and spacing tokens, gap, padding, alignment, distribution,
baseline alignment, wrapping, minimum and maximum constraints, priorities,
intrinsic sizes, breakpoints, and layout transitions.

All values are density-independent and resolve through explicit platform scale,
text scale, direction, safe-area, and environment inputs. RTL changes logical
start and end, not physical truth. Stable layout inspection reports the node,
resolved inputs, state read, rule, and ancestor that caused every measurement or
placement. Product screens must compose public Flex rules and semantic tokens;
unexplained per-screen offsets are conformance failures.

## Zagkit Talkback

Zagkit Talkback is the Playwright-equivalent control plane for native Zagkit
applications. It uses the same retained node and semantics truth as rendering
and accessibility. Developer-assigned IDs are preferred; deterministic
generated IDs are available for framework-owned nodes. IDs are scoped by app,
window, and retained node identity and have defined behavior across
virtualization, navigation, reload, replacement, and stale references.

The versioned protocol supports discovery, semantic and property queries,
click, type, key, focus, scroll, drag, gesture, wait, assertion, screenshot,
timeline, capability report, snapshot, and deterministic replay. Normal agent
automation targets IDs. Pixel coordinates are an explicit, scale-aware fallback
for canvases or unavailable semantics; every fallback is recorded and never
reported as an ID action. Failed actions return structured candidates, geometry,
semantics, capability truth, and timeout evidence.

The product name is always qualified as **Zagkit Talkback** in contexts where it
could be confused with **Android TalkBack**, the assistive technology. Zagkit
Talkback does not replace AT-SPI, VoiceOver, Narrator, or Android TalkBack tests.

## Visual and asset fidelity

Zagkit's renderer owns scalable curves, anti-aliasing, subpixel-aware placement,
color management, font rasterization, SVG, PNG, gradients, masks, filters,
lighting, soft shadows, and adaptive materials. SVG and PNG decoders are
bounded, fuzzed, color-managed, and never delegated to a foreign UI engine.

The visual language may use liquid-glass materials: backdrop sampling, blur,
tint, refraction or distortion, edge highlights, specular response, depth, and
motion must form one coherent material model. Text and controls remain legible
over changing content. Reduced transparency, high contrast, reduced motion, and
CPU fallback have designed equivalents. Effects must remain crisp across every
declared scale and may not collapse into hard, pixelated approximations.

The target is competitive capability and finish, including SwiftUI-class
fluidity and current Apple-class material coherence, without copying Apple's
private implementation or making Zagkit an imitation of a platform skin.

## PrismStudio proof

Milestone 4 is a complete visible UI replacement, not a partial migration.
Zagkit must own the supported Linux shell, placement, styling, assets,
components, semantics, focus, input, and automation. Existing CAD workflows,
keyboard control, direct manipulation, tables, trees, menus, dialogs, viewport,
performance evidence, and GPU safety boundaries remain functional while the
experience is redesigned to the selected Zagkit direction.

Every actionable node receives a stable Talkback ID. Canonical tasks run by ID,
with pixel fallback permitted only for declared canvas interactions and always
reported. Native screenshots at matched state, viewport, scale, theme, and
effect settings are compared to approved direction images and CPU goldens.
Screenshots are necessary visual proof but do not replace interaction,
semantics, accessibility, recovery, or performance evidence.

Linux is the first polish reference. Its preview cannot be called polished
while known severity-one or severity-two defects remain in visual fidelity,
spacing, text, input, accessibility, recovery, automation, or packaging.

## Visual selection gate

Before visual component or PrismStudio production, maintainers compare exactly
three materially different directions using the same representative CAD and
component states. Review covers light, dark, high contrast, large text, RTL,
reduced motion, and reduced transparency. One direction is accepted by RFC;
implementation then follows that target rather than inventing style per screen.

## Evidence

The durable itemized exit conditions live in [the master goal checklist](../../GOAL.md).
Removing or weakening those items requires an RFC amendment. Capability records
remain fail-closed until executable evidence exists.
