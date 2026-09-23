---
name: run-mutation
description: Runs mutation testing for an ai-flow ticket, judges which survivors are genuinely equivalent and which need a test, writes any missing tests RED first, and records the add-tests or accept decision when the score stays below threshold. Loaded by the develop orchestrator at the mutation stage; not for direct use.
license: MIT
compatibility: Requires the ai-flow CLI on PATH and a git checkout of the in-scope repositories.
---

# Run mutation

## CLI calls

Run each instruction below and parse stdout as JSON. Exit 4: relay `needs_input.question` to the developer verbatim, then run `needs_input.resume_with` with their answer. Any other non-zero exit: stop and show `error.message`. Never add flags the steps below do not name.

## Read first

1. `ai-flow stage start KEY mutation` — enters the stage and refreshes `guidance.md` for it.
2. `test-results.json` — must already be green; a red suite is fixed before mutation testing runs at all.
3. `references/tdd.md` for what RED-first means here; `references/mutation.md` for judging a survivor and the below-threshold decision.

## Workflow

- [ ] Run `ai-flow mutation scope KEY` to see each repository's detected tool and changed-code scope
- [ ] Run `ai-flow mutation run KEY`
- [ ] Read each repository's round report; for a mutant that is genuinely equivalent, run `ai-flow mutation summarize KEY --equivalent ID --reason "…"` — once per survivor, in any order
- [ ] For a real gap, write a test RED first (see `references/tdd.md`), never editing an existing test, then run `ai-flow test run KEY --repo REPO`
- [ ] If any tests were added, run `ai-flow mutation run KEY` again
- [ ] Run `ai-flow mutation summarize KEY` — on exit 4, relay `needs_input.question`; for "add tests," continue the loop above; for "accept," run `needs_input.resume_with` once the reason is written and checkable (see `references/mutation.md`)
- [ ] Run `ai-flow stage complete KEY mutation`

## Judgement

- An equivalent claim needs a real, checkable reason (see `references/mutation.md`) — never "not worth testing" or "hard to cover."
- A new test is RED first against the branch's own code; an existing test that now fails names a real defect to fix, not a target to edit until it passes.
- An accepted score names what specifically stands between the current score and the threshold, not a deadline.

## Stop and ask

- Genuinely unsure whether a survivor is equivalent or a real gap, and the code alone doesn't settle it.
- Only `accept` remains (the round limit is reached) and no honest reason exists yet.

## Done when

`mutation-results.json` shows every repository at or above its threshold, or accepted with a written reason, `test-results.json` stayed green throughout, and `stage complete KEY mutation` succeeded.
