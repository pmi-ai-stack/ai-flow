---
name: run-e2e
description: Runs the e2e suite for an ai-flow ticket, decides which case covers the change, and writes any missing case RED against the base commit before confirming it passes on the branch. Loaded by the develop orchestrator at the e2e stage; not for direct use.
license: MIT
compatibility: Requires the ai-flow CLI on PATH and a git checkout of the in-scope repositories.
---

# Run e2e

## CLI calls

Run each instruction below and parse stdout as JSON. Exit 4: relay `needs_input.question` to the developer verbatim, then run `needs_input.resume_with` with their answer. Any other non-zero exit: stop and show `error.message`. Never add flags the steps below do not name.

## Read first

1. `ai-flow stage start KEY e2e` — enters the stage and refreshes `guidance.md` for it.
2. `plan.md`'s Test strategy section — which case, if any, was anticipated.
3. `references/tdd.md` for what RED-on-base means mechanically.

## Workflow

- [ ] Run `ai-flow e2e run KEY` — does an existing case already cover the change?
- [ ] If not, write the missing case against the ticket's acceptance criteria
- [ ] Run `ai-flow git checkout-base KEY`
- [ ] Run `ai-flow e2e run KEY --case NAME` — it must fail; a case that passes on the base commit proves nothing new
- [ ] Run `ai-flow git checkout-branch KEY`
- [ ] Run `ai-flow e2e run KEY --case NAME` — it must pass
- [ ] If a new case was written, run `ai-flow e2e run KEY` again to confirm the full suite is still green
- [ ] Run `ai-flow stage complete KEY e2e`

## Judgement

- A new case is only written when no existing one already covers the change — check before adding one.
- RED-on-base is verified for real, on the base commit, never assumed from reading the code.
- An existing case that starts failing names a real defect in the change, not a target to rewrite until green.

## Stop and ask

- No existing or writable case can express what the ticket's acceptance criteria actually require.
- The suite fails for a reason unrelated to this change (a flaky or already-broken case).

## Done when

`e2e-results.json` shows the new or covering case passing on the branch (and, for a new case, `new_cases` naming it), the full suite is green, and `stage complete KEY e2e` succeeded.
