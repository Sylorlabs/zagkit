# Platform support

Zagkit currently supports no runtime platform. The repository is an
experimental product contract and all shell, renderer, accessibility, text
input, GPU, and packaging capabilities are `unavailable`.

The machine readable authority is
[contracts/platforms.json](contracts/platforms.json). Future release artifacts
will contain a generated instance of the same capability model with one of
three states:

- `supported`: the feature passed its complete native gate on a named target.
- `experimental`: executable evidence exists, but the support gate is
  incomplete and the missing condition is named.
- `unavailable`: the backend did not activate or has no qualifying evidence;
  the reason is mandatory.

`.auto` is a selection request, not a capability. A runtime using `.auto` must
record the backend actually activated. Device loss and fallback append
observable events and update the capability record.

## Intended beta policy

When a backend first enters beta, its matrix freezes exact OS versions and
reference devices:

| Family | Intended policy | Current Zagkit state |
|---|---|---|
| Linux | current Ubuntu LTS and current Fedora releases on x86-64 and ARM64 | unavailable |
| macOS | current and previous two stable major releases | unavailable |
| Windows | current and previous two supported stable releases | unavailable |
| iOS | current and previous two stable major releases | unavailable |
| Android | current and previous two stable API generations | unavailable |

Version names are deliberately not frozen before beta. Recording a date based
guess here would look precise while providing no tested support. Every beta and
stable release instead records the exact versions used by its native evidence.

Web, browser rendering, and WebView hosting are outside the 1.0 scope.

## Promotion gate

A capability cannot move out of `unavailable` based on a code path,
cross-compile, screenshot, emulator, or API discovery. Promotion requires the
target device, exact OS and compiler revisions, executable test, selected
backend, assistive technology where relevant, cleanup, and recovery result.

The whole product remains pre-1.0 until all five required platform families
pass [the release gates](docs/quality/release-gates.md).
