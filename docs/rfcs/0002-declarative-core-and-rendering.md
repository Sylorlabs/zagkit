# RFC 0002: Declarative core and rendering architecture

- Status: Accepted
- Decision date: 2026-08-06
- Owners: Zagkit maintainers

## State and authoring contract

State flows down and actions flow up. The initial public concepts are:

- `State<T>` owns observable value and revision identity;
- `Binding<T>` provides a scoped read and action based write path;
- `NodeKey` supplies stable identity across reconciliation;
- `Action` is an application intent, not an arbitrary mutation callback;
- `Environment` carries typed inherited values;
- `ViewContext` records state reads, environment reads, actions, and child
  identity during view evaluation.

The exact Zag syntax remains implementation work. These semantic names cannot
be repurposed without a superseding RFC.

Each state or environment read is tracked. When work is invalidated, the
inspector can name the read identity, old revision, new revision, affected node,
and whether view, measure, layout, paint, or semantics work followed.

`RenderNode` is the retained escape hatch for specialized layout and painting.
`Canvas` is the immediate drawing escape hatch. Neither bypasses resource
ownership, semantics, damage, capability, or replay contracts.

## Layout contract

The core types are `Constraints`, `Size`, and `Rect`. Layout supports intrinsic
measurement, stack, flex, grid, overlay, scroll, virtual list, table, tree, safe
areas, breakpoints, direction, text scale, and platform density.

Constraints are finite or explicitly unbounded by axis. Measurement and layout
must be deterministic for the same inputs. Cycles, non-finite geometry,
overflow, unstable intrinsic measurement, and duplicate keys fail with
inspectable reasons.

## Rendering contract

Rendering produces an immutable `DisplayList` of paths, paints, images, glyph
runs, clips, transforms, layers, and effects. Resources are content addressed
and carry explicit lifetime. Damage and cache reuse cannot change output.

The CPU renderer is deterministic and is the visual oracle. GPU transports
consume a versioned Zag owned render IR and are compared to the oracle within
documented operation and device tolerances. Metal, D3D12, Vulkan or other
public Linux and Android submission APIs are transports, not the architecture.

## Scheduling and motion

The scheduler is refresh rate aware, does no continuous layout or paint while
idle, and records why every frame exists. Springs, keyframes, layout transitions,
and shared transitions are interruptible and deterministic under a supplied
clock. Reduced motion changes behavior through explicit substitution, not a
global duration multiplier.

## Verification

Property tests cover constraints and identity. Deterministic replay covers state,
input, time, and backend events. CPU goldens cover the full variant matrix. GPU
comparison, interruption, reversal, resize, idle, and resource cleanup gates
are mandatory before promotion.
