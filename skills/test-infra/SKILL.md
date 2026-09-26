---
name: test-infra
description: Runs and, when missing, writes the smallest infrastructure or CI/CD test for an ai-flow ticket's changed targets, RED against the base rendering and GREEN against the branch's. Loaded by the develop orchestrator at the infra-test stage; not for direct use.
license: MIT
compatibility: Requires the ai-flow CLI on PATH and a git checkout of the in-scope repositories.
---

# Test infra

## CLI calls

Run each instruction below and parse stdout as JSON. Exit 4: relay `needs_input.question` to the developer verbatim, then run `needs_input.resume_with` with their answer. Any other non-zero exit: stop and show `error.message`. Never add flags the steps below do not name.

## Read first

1. `ai-flow stage start KEY infra-test` — enters the stage and refreshes `guidance.md` for it.
2. `references/tdd.md` for what RED-first means here.

## Workflow

- [ ] Run `ai-flow ops test detect KEY` to see every harness a target's own addon detected, and which will actually run
- [ ] Run `ai-flow ops render KEY --ref base` and read the base rendering it writes
- [ ] Write the smallest test, at the addon's own convention (named by the harness's `tool`/`kind`), that fails against the base rendering
- [ ] Run `ai-flow ops test run KEY --harness NAME --ref base` — it must fail
- [ ] Run `ai-flow ops test run KEY --harness NAME` — against the branch, it must pass
- [ ] Run `ai-flow ops test run KEY` to run every eligible harness
- [ ] Run `ai-flow stage complete KEY infra-test`

## Judgement

- The test asserts the ticket's own acceptance criteria against real rendered content, never a tautology that would pass regardless of the change.
- Add a harness only where an addon convention already exists for it (kuttl/chainsaw manifests, a `.tftest.hcl` file, …) — inventing a new harness framework is a bigger decision than this ticket.
- A `--ref base` run is diagnostic only: it is never what `stage complete`'s own gate reads.

## Stop and ask

- No harness convention exists for the addon or tool involved, and hand-writing one from scratch is a bigger decision than this ticket.
- A harness fails for a reason unrelated to this change.

## Done when

Every persisted `infra-test-results.json` entry shows `failed: 0`, and `stage complete KEY infra-test` succeeded.
