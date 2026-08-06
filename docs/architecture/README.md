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

The first experimental compiled slice now fixes the initial Zag shapes for
`NodeKey`, `State<T>`, `Binding<T>`, `Action`, `Environment`, `ViewContext`,
`ViewSpec`, and `RenderNode`. State reads record their reader and revision;
invalidation reports the exact read and revision edge; keyed reconciliation
preserves retained identity through reorder and fails visibly on duplicate
keys. Ownership, threading, serialization, typed environment values,
cancellation, and deterministic replay are still open contracts rather than
stable API.
