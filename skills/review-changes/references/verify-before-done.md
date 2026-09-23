# What "done" requires

"It compiles" is not done. Before marking any item complete:

1. **The tests for that item are green**, run through `test run` — not eyeballed, not assumed from the code looking right.
2. **Every `must` guidance section that applies is satisfied** — not noted as a follow-up, not deferred to review.
3. **The item does what the corresponding line in `plan.md`'s Steps says**, not a nearby, easier thing.

## The simplification pass

The last item, after every other one is done, not skipped when time is short:

- Delete code the change made unreachable.
- Collapse duplication the change introduced (not pre-existing duplication elsewhere — that is a different, larger change).
- Remove debugging output, commented-out code, and TODOs the change added.
- Read the diff once as a reviewer would, not as the person who wrote it.

## What does not count

- A test that asserts the mock returned what the mock was told to return.
- A guidance violation left with a comment saying it will be fixed later.
- Code that "should work" but was never run against the item's own test.
