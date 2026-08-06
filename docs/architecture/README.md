# Architecture map

Zagkit separates product semantics from rendering transport and platform shell:

```text
Application views, state, actions, environment
                    |
          reconciliation and layout
             /                 \
     SemanticsNode tree      DisplayList
       /          \          /         \
accessibility  automation  CPU oracle  GPU transport
       \          /          \         /
      public platform input, lifecycle, and surface seams
```

The semantics and display trees are parallel outputs of the same retained view
state. Accessibility is not reconstructed from pixels. GPU transports do not
receive view nodes. Platform shells do not own component state.

Normative decisions:

- [product and platform](../rfcs/0001-product-and-platform-contract.md)
- [declarative core and rendering](../rfcs/0002-declarative-core-and-rendering.md)
- [text, semantics, and input](../rfcs/0003-text-semantics-and-input.md)
- [platform seams and backend truth](../rfcs/0004-platform-seams-and-backend-truth.md)
- [quality and release](../rfcs/0005-quality-and-release-contract.md)

The public API names in RFC 0002 are semantic reservations, not compiled API.
The first implementation RFC will fix Zag syntax, ownership, threading, error,
and serialization details after the required upstream primitives are proven.
