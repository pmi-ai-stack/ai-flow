# Equivalent mutants and the below-threshold decision

## What makes a mutant genuinely equivalent

A surviving mutant is equivalent only when **no test, however written, could ever kill it** — the mutation changes code that has no observable effect on any behavior the system exposes. Examples: a mutated branch that is provably unreachable; an off-by-one in a bound already enforced one layer up; a logging-only statement's argument.

A survivor is **not** equivalent just because:

- the existing tests happen not to cover it (that is a real gap — write a test),
- killing it would take real effort (effort is not equivalence),
- the mutated line "probably doesn't matter" without a specific reason it cannot matter.

## The reason a reviewer must be able to check

`mutation summarize KEY --equivalent ID --reason "…"` requires a reason a second person, without running anything, could verify from the code alone: which behavior the mutation touches and why nothing observable changes. "Not worth testing" is not a reason; "this branch is unreachable because X already guarantees Y" is.

## Accepting a score below threshold

`--accept --reason "…"` is a last resort, not a schedule pressure valve. A credible reason names what specifically stands between the current score and the threshold — a class of code that is hard to test for a stated structural reason (not "generally hard") — and, when the round limit hasn't been reached, why `add-tests` was tried or ruled out first, not skipped.

## What `review-changes` re-examines

Every accepted equivalent claim is read again during review, cold, against the same standard above — not re-approved on trust. A claim that doesn't survive a second look is a real gap: write the test, don't re-argue the label.
