# Governance

## Project ownership

Zagkit is a first party Sylor Labs project. Maintainers are responsible for the
public API, repository releases, accepted RFCs, support claims, security
response, and the relationship with Zag and first party consumers.

The project uses reviewable pull requests for normative and implementation
changes. Direct emergency fixes must receive follow up review and evidence.

## Decision classes

| Change | Required record |
|---|---|
| Typo, test repair, internal refactor | pull request and relevant gates |
| Public API or behavior | RFC, compatibility note, tests |
| New runtime dependency or OS seam | RFC and dependency boundary review |
| Platform status promotion | native evidence bundle and capability record |
| Performance waiver over 5 percent | explicit reviewed waiver with expiry |
| Stable release or 1.0 gate change | maintainer approval and release audit |

Accepted RFCs are normative until superseded. Code that conflicts with an
accepted RFC is a defect unless a newer RFC explicitly changes the decision.

## Support claims

Only evidence can promote a capability. Marketing copy, a code path, a compile,
a screenshot, emulation, or a provider report is not native runtime proof.
Capability changes must identify the device, operating system, compiler
revision, backend selected, executable gate, and cleanup result.

No individual platform is named Zagkit 1.0. The product reaches 1.0 only when
Linux, macOS, Windows, iOS, and Android all satisfy the common release contract.

## Upstream ownership

Reusable language, compiler, ABI, package, concurrency, platform, or runtime
work is implemented and tested in Zag. Zagkit may carry a temporary failing
conformance test that demonstrates the need, but it may not hide the defect
behind a foreign language shim or permanent local workaround. The upstream fix
lands as its own reviewable Zag commit with native conformance; the downstream
change then pins that exact commit and proves the consumer path.

## Conduct and security

Contributors must be direct, respectful, and evidence led. Security reports
follow [SECURITY.md](SECURITY.md); do not publish exploit details before a fix
and coordinated disclosure are ready.
