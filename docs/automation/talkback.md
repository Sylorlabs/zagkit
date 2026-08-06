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

The first in-process slice resolves semantic discovery and queries and validates
click, type, focus, and scroll before emitting them into the ordered event
stream. Responses distinguish read-only results from emitted actions and name
the resolved semantic-node index. Capability reports and timeline counts are
available. Key, drag, gesture, wait, assertion payloads, screenshots, snapshots,
replay, native action consumption, and native transport remain unavailable and
fail closed. Advertising a command in the protocol vocabulary does not claim
its runtime capability.

## Planned agent contract

The complete control plane will add app and window discovery, structured query
results, text payloads, keyboard input, scrolling parameters, paths and
velocity for drag and gesture, waits and assertions, screenshots, frame
timelines, capability records, snapshots, and deterministic replay. Failed
actions will retain candidates, geometry, semantics, backend truth, and timeout
evidence in one inspectable bundle. These remain unchecked in the master goal
until their executable exit suites pass.
