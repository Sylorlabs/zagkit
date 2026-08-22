# Experimental native token inspector

The Linux showcase's `Inspect tokens` control is a real retained interaction,
not a screenshot annotation. Activating stable `NodeKey` `20302:0` rebuilds the
composition with canonical overlay Surface `20800:0`; activating it again
closes the overlay. The Button publishes selected state and the visible label
`Close inspector` while open.

The overlay currently inspects retained main Surface `20300:0`. Ten visible
Text nodes, `20801:0` through `20810:0`, publish the same content to semantics
and Zagkit Talkback:

- inspector title and selected `NodeKey`;
- canonical component and hierarchy tier;
- material and fill token IDs;
- visible type token IDs;
- Flex spacing token ID;
- radius and elevation token IDs;
- current theme, scale, and density inputs;
- the material's exact deterministic CPU fallback reason.

The overlay uses the canonical `SurfaceTier.overlay` path. Its display,
semantic, and hit bounds come from `linux_preview_token_inspector_bounds`; the
control is disabled with no action or focus order when the minimum 320 by 340
logical-pixel panel cannot fit. The Linux interaction runner opens it by ID,
captures it, requires the frame hash to change, and closes it by the same ID.

## Honest boundary

This slice proves a stateful control, visible provenance, overlay hierarchy,
stable IDs, and compact fail-closed behavior. It does not yet support choosing
an arbitrary rendered node. It also does not yet expose resolved numeric token
values, the complete interaction-state trace, or one serialized Flex trace
shared by all inspectors. Those remain required by
[showcase conformance](../design/showcase-conformance.md) and keep the inspector
and gallery milestones open.
