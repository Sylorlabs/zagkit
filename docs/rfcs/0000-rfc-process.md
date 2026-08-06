# RFC 0000: RFC process

- Status: Accepted
- Decision date: 2026-08-06
- Owners: Zagkit maintainers

## Purpose

An RFC records a reviewable decision that changes Zagkit's public API,
architecture, runtime dependency boundary, support truth model, or release
gate. It prevents consequential decisions from being hidden in implementation.

## Lifecycle

1. A proposal begins as `Proposed` with context, decision, alternatives,
   consequences, compatibility, safety, and verification sections.
2. Maintainers can request evidence or a prototype before accepting it.
3. `Accepted` makes the decision normative. It does not imply implementation.
4. `Implemented` requires links to the executable gates named by the RFC.
5. A later RFC may mark it `Superseded`; rejected proposals remain in history.

Status changes use dated pull requests. Material scope changes return an RFC to
`Proposed` rather than silently rewriting an accepted decision.

## Required review

Dependency and platform seam RFCs require security and ownership review.
Visual system RFCs require accessibility review. Platform promotion and release
gate RFCs require native evidence on the affected targets.

## Evidence rule

Prose, code presence, compilation, screenshots, cross execution, and emulation
can support review but do not prove native capability. An implementation claim
names the executable command, exact revision, target device, result artifact,
cleanup behavior, and any unavailable boundary.
