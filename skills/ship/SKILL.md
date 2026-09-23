---
name: ship
description: Composes the commit message and PR body for an approved ai-flow ticket, runs the ship checks and fixes what they report, then commits and opens the PR(s) once the developer confirms. Use when the developer says to ship a ticket that has reached output.
license: MIT
compatibility: Requires the ai-flow CLI on PATH and a git checkout of the in-scope repositories.
disable-model-invocation: true
---

# Ship

## CLI calls

Run each instruction below in the order given and parse stdout as JSON. Exit 4: relay `needs_input.question` to the developer verbatim, then run `needs_input.resume_with` with their answer. Any other non-zero exit: stop and show `error.message`. Never add flags the steps below do not name, and never run `git push` or `pr create` before `stage approve KEY ship` has recorded the approval — both refuse without it.

## Read first

1. `ai-flow status KEY` — `output` must already be `pass`; `stage approve KEY ship` refuses otherwise.
2. `plan.md`, `test-results.json`, `mutation-results.json` (when present) and `review.md` — the source for the commit message and the PR body.

## Workflow

- [ ] Run `ai-flow stage start KEY ship`
- [ ] Write `commit-message.md`: a Conventional-Commit subject naming the ticket key, a body summarizing `plan.md`'s Objective and the files changed. See `references/commit-and-pr.md`
- [ ] Write `pr-body.md` with a `## Summary` and a `## Test plan` heading, drawing on `plan.md`, `test-results.json`, `mutation-results.json` and `review.md`
- [ ] Run `ai-flow standards check KEY --stage ship`; fix at the source anything it reports; repeat until no `must` finding is open
- [ ] Ask the developer to say "ship it"
- [ ] Once they do, run `ai-flow stage approve KEY ship`
- [ ] Run `ai-flow git commit KEY`, then `ai-flow pr create KEY`
- [ ] Run `ai-flow ticket update KEY --status in_review --marker ship --comment "PR links, mutation score and check summary"`
- [ ] Run `ai-flow stage complete KEY ship`

## Judgement

- Fix `must` and `should` findings from `standards check --stage ship` at the source — never by editing `commit-message.md`/`pr-body.md` around a finding the source itself causes.
- The developer approves a commit message, a PR body and a clean check run, not a promise: show all three before asking them to confirm.

## Stop and ask

- Any `must` finding `standards check --stage ship` still reports after a fix attempt.
- The developer has not said "ship it" in words — never infer consent from silence or from an earlier "looks good".

## Done when

`stage complete KEY ship` succeeded and the developer has the PR link(s).
