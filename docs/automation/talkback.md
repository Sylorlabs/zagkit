# Zagkit Talkback protocol

Zagkit Talkback is Zagkit's native automation and inspection control plane. It
is distinct from Android TalkBack, which remains a required assistive-technology
test target. The protocol is experimental and has no native transport yet.

## Target truth

Normal automation uses the exact `NodeKey` published by the retained semantics
tree. A request may pin the semantics revision; a mismatch returns
`stale-semantics` instead of risking an action on a replacement node. Missing,
hidden, disabled, and semantically unsupported targets fail explicitly.

Pixel coordinates are a separate target kind, disabled by default. A backend
must advertise the fallback before dispatch. Pixel requests record physical
coordinates and a positive rational display scale. Zagkit converts them to its
26.6 fixed-point logical viewport for bounds checks. Every accepted or rejected
pixel attempt remains labelled `pixel`; it can never be reported as an ID
action.

## Requests and evidence

The machine-readable field, command, status, and capability vocabulary lives in
[the protocol contract](../../contracts/talkback-protocol.json). Request IDs
must be positive. Timeouts must be between 1 and 300000 milliseconds. Every
dispatch receives one monotonic event sequence and records the command, target
kind, target ID, semantic revision, status, coordinates, and scale.

The in-process slice resolves semantic discovery and queries and validates
click, type, focus, and scroll before emitting them into the ordered event
stream. For this slice, key/drag/gesture/wait/assert/snapshot/replay are
also accepted as event-emitted command types when their capabilities are
advertised; they are validated for target presence and timeout policy before
recording. Protocol minor version 2 query responses distinguish read-only results
from emitted actions and expose the resolved node index, role, action mask,
fixed-point bounds, collection counts and coordinates, tree level and expansion
state, owned-text lengths, state flags, and a deterministic evidence hash over
the complete semantic node. This makes geometry and semantic-state changes
observable even before the native transport gains structured text payloads.
Capability reports and timeline counts are available. Pixel fallback is fail-closed
unless advertised, and screenshots remain unavailable in this slice.
Advertising a command in the protocol vocabulary does not claim its runtime
capability.

## Planned agent contract

The complete control plane will add app and window discovery, structured query
results, text payloads, keyboard input, scrolling parameters, paths and
velocity for drag and gesture, waits and assertions, screenshots, frame
timelines, capability records, snapshots, and deterministic replay. Failed
actions will retain candidates, geometry, semantics, backend truth, and timeout
evidence in one inspectable bundle. These remain unchecked in the master goal
until their executable exit suites pass.
