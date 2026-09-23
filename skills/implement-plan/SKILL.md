---
name: implement-plan
description: Writes the code and tests plan.md names, repository by repository, running test run before any item counts as done, then makes one simplification pass over everything changed. Loaded by the develop orchestrator at the implement stage; not for direct use.
license: MIT
compatibility: Requires the ai-flow CLI on PATH and a git checkout of the in-scope repositories.
---

# Implement plan

## CLI calls

Run each instruction below and parse stdout as JSON. Exit 4: relay `needs_input.question` to the developer verbatim, then run `needs_input.resume_with` with their answer. Any other non-zero exit: stop and show `error.message`. Never add flags the steps below do not name.

## Read first

1. `plan.md`'s Steps and Files to change.
2. `guidance.md` — every `must` section is a requirement for this stage's code and tests, not advice.
3. `references/plan-format.md` for what each item in Steps means; `references/verify-before-done.md` for what "done" requires.

## Workflow

- [ ] Run `ai-flow git prepare KEY`
- [ ] For each repository, work through `plan.md`'s Steps in order — write the code and the tests it names, then run `ai-flow test run KEY --repo REPO` before marking any item in it done
- [ ] Once every repository's items are done, run `ai-flow repo scope KEY`
- [ ] Run `ai-flow stage complete KEY implement`
- [ ] Last: make one simplification pass over everything changed (`ai-flow git diff KEY`) — dead code, duplication, leftover debugging

## Judgement

- `must` guidance is a requirement: a violation is a defect in the change, not a note for review.
- `should` guidance is the default; deviating from it needs a reason recorded in `implementation.log`, not silence.
- The simplification pass removes, it does not add — no new abstraction earns its place from a bug fix or a single caller.

## Stop and ask

- `plan.md`'s Steps conflict with what a repository's instructions file requires.
- A `must` guidance section and an item in Steps cannot both be satisfied without changing `plan.md` itself.

## Done when

Every repository's items are written, `test run` is green for each, `repo scope` has recorded the in-scope files, and the simplification pass is complete. See `references/verify-before-done.md`.
