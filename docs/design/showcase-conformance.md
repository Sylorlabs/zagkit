# Design-system showcase conformance

The Zagkit showcase is a conformance surface, not a decorative dashboard. A
capture may demonstrate renderer progress while this contract is incomplete,
but it must be labeled experimental and cannot promote the visual system.

## Required proof

### Token provenance

- Every visible color, type style, spacing value, radius, elevation, material,
  and motion value resolves through a named semantic token.
- The inspector reports the token ID, resolved value, environment inputs, and
  fallback used by every rendered node.
- Brand, focus, selection, status, category, warning, error, and data-series
  colors have separate documented meanings. Similar-looking literals are not
  accepted as token proof.
- Component-local exceptions are named, reviewable, and never silently become
  a second token scale.

### Semantic symbols and color

- Icons and status marks use real assets and a documented semantic mapping.
- Color is never the only carrier of category, status, selection, error, or
  focus. Text, shape, icon, semantics, or position carries the same truth.
- Decorative marks are hidden from accessibility. Meaningful marks expose a
  role, name, value, and state.

### Hierarchy and range

- The same canonical card is rendered at base, panel, and raised/overlay
  elevation tiers with visibly distinct fill, edge, depth, and contrast rules.
- Primary navigation, contextual inspection, status, content, and commands use
  distinct component roles. A status rail may not masquerade as a second
  navigation system.
- Typography demonstrates display, title, heading, body, label, caption, and
  code roles with tested line-height, truncation, locale, and large-text rules.

### Interaction states

- Canonical Button, IconButton, navigation item, segmented control, field,
  list row, menu item, and card action show default, hover, keyboard focus,
  pressed, selected, disabled, loading, and error states.
- State differences remain clear in light, dark, high contrast, reduced
  transparency, reduced motion, grayscale, and color-vision simulations.
- Hover is supplementary. Keyboard, touch, pen, gamepad, accessibility action,
  and Zagkit Talkback reach the same action and state truth.

### Data visualization

- Any chart presented as a toolkit component includes named axes, units, tick
  labels, a baseline or domain reference, series identity, hover/focus detail,
  empty/loading/error states, and a semantic table equivalent.
- A decorative grid with dots is not called a chart component and cannot count
  as component coverage.

### Segmented controls and navigation

- A segmented control has one declared selection model, visible selected and
  focused states, arrow-key behavior, disabled behavior, and tab semantics.
- Navigation exposes one canonical active location. Contextual inspectors and
  system status are labeled and styled as their actual roles.
- Every enabled navigation item activates its named destination: the selected
  label, main landmark, visible heading, semantics, actions, and Talkback tree
  must describe the same content. An item whose destination is not implemented
  remains visibly and semantically disabled; changing only its highlight is a
  failing no-op, not navigation evidence.

## Evidence matrix

For each required component and state, record the semantic token trace,
semantics/Talkback snapshot, keyboard path, CPU golden, and native screenshot at
1.0x and 2.0x. The full visual-direction matrix adds all other scales, themes,
locales, directions, contrast, text, motion, and transparency variants.

Screenshot review is necessary but insufficient. Promotion also requires
native input, focus, assistive-technology, deterministic rendering, idle,
frame-time, resize, recovery, and cleanup evidence.
