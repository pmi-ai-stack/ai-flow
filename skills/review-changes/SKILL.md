---
name: review-changes
description: Reviews an ai-flow ticket's full changed set for severity of findings, cross-repository contract consistency and compliance with each must guidance section, and re-examines every mutation equivalent claim before writing review.md. Loaded by the develop orchestrator at the review stage; not for direct use.
license: MIT
compatibility: Requires the ai-flow CLI on PATH and a git checkout of the in-scope repositories.
---

# Review changes

## CLI calls

Run each instruction below and parse stdout as JSON. Exit 4: relay `needs_input.question` to the developer verbatim, then run `needs_input.resume_with` with their answer. Any other non-zero exit: stop and show `error.message`. Never add flags the steps below do not name.

## Read first

1. `ai-flow stage start KEY review` — enters the stage and refreshes `guidance.md` for it.
2. `ai-flow git diff KEY` — everything changed, across every in-scope repository.
3. `guidance.md`'s `must` sections; `checks-results.json`; `mutation-results.json`; `visual-test-results.json` and `e2e-results.json`, when present.
4. `references/review-rubric.md` for `review.md`'s required headings and the review checks; `references/mutation.md` for judging an equivalent claim; `references/verify-before-done.md` for what "done" already required at each earlier stage.

## Workflow

- [ ] Check cross-repo contract consistency in what `git diff` showed (see `references/review-rubric.md`)
- [ ] Re-examine every equivalent claim in `mutation-results.json` (see `references/mutation.md`)
- [ ] Check each `must` guidance section for compliance, citing its id
- [ ] Write `review.md` with the headings `references/review-rubric.md` names
- [ ] Fix anything within this ticket's own scope directly
- [ ] Run `ai-flow stage complete KEY review`

## Judgement

- Severity by real impact — would shipping this as written produce wrong behavior or a security defect — not by tone.
- An open `should` finding from an earlier stage is justified in `review.md`, not silently dropped.
- An equivalent-mutant claim gets a genuinely skeptical second look, not a rubber stamp because an earlier stage already accepted it.
- `must` compliance is cited by section id, never paraphrased into "looks fine."

## Stop and ask

- A cross-repo contract mismatch: one repository's change to a shared contract isn't reflected in its consumer.
- A `must` guidance section this change appears to violate, with no waiver and no fix within this ticket's own scope.

## Done when

`review.md` exists with every heading `references/review-rubric.md` names, every reopened or newly found `must` is fixed, and `stage complete KEY review` succeeded.
