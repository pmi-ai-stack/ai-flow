# Writing a test RED first

"RED first" means: the test exists and fails, for the right reason, before the code that satisfies it exists or is exercised. It applies the same way whether the gap is a mutation survivor or a missing e2e case.

## For a mutation survivor

1. Read the survivor's `file`/`line` and the mutation itself (what the tool changed) from the round report.
2. Write or extend a test that exercises that exact behavior — one that would fail if the mutation were the real code.
3. Run it against the mutated behavior first, if the tool exposes that; otherwise reason from the mutation's own diff whether the new test would catch it.
4. Run `test run` — it must be green against the actual code before the next mutation round.

## For an e2e case

1. Write the case against the ticket's acceptance criteria, not against what currently happens to work.
2. Check it out on the base commit and run it — it must fail. A case that passes on base tests nothing new.
3. Check the branch back out and run it again — it must pass.

## The one rule that never bends

**Never edit an existing test to make it pass.** If an existing test now fails, either:

- the change broke real behavior the test correctly protects — fix the change, not the test, or
- the test asserted the wrong thing even before this change — that is a separate, deliberate decision to record, not a side effect of getting a mutation score or an e2e run to go green.

A test edited to match new behavior it was written to catch is not verification; it is the shortcut this rule exists to name and refuse.

## What "green for the wrong reason" looks like

- A test that asserts a mock returned what the mock was told to return.
- A test broadened until it can no longer fail (removed assertions, widened tolerances) rather than fixed.
- A case marked `--case` skip-narrowed so the failing one never runs.
