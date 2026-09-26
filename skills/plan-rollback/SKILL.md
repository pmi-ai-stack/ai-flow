---
name: plan-rollback
description: Derives the rollback path for an ai-flow ticket's infrastructure or CI/CD change and writes rollback-plan.md with a real mitigation for every non-revertible address. Loaded by the develop orchestrator at the rollback stage; not for direct use.
license: MIT
compatibility: Requires the ai-flow CLI on PATH and a git checkout of the in-scope repositories.
---

# Plan rollback

## CLI calls

Run each instruction below and parse stdout as JSON. Exit 4: relay `needs_input.question` to the developer verbatim, then run `needs_input.resume_with` with their answer. Any other non-zero exit: stop and show `error.message`. Never add flags the steps below do not name.

## Read first

1. `ai-flow stage start KEY rollback` — enters the stage and refreshes `guidance.md` for it.
2. `references/ops-rollback.md` for `rollback-plan.md`'s required headings and what makes a mitigation real.

## Workflow

- [ ] Run `ai-flow ops rollback KEY`
- [ ] Write `rollback-plan.md` with the headings Trigger criteria, Steps, Non-revertible, Watch list, Owner
- [ ] Under "Non-revertible", write one real mitigation per `non_revertible` address reported
- [ ] If a mitigation needs an infrastructure-source guard, add it, then run `ai-flow standards check KEY` and `ai-flow ops dry-run KEY` — the re-run this edit requires before the stage can complete
- [ ] If the source changed, run `ai-flow ops rollback KEY` again
- [ ] Run `ai-flow stage complete KEY rollback`

## Judgement

- `rollback-results.json`'s tool-level rollback text is produced, never executed — `rollback-plan.md` explains it to a person, it does not run anything.
- A mitigation names what a person actually does when the trigger fires, not just the address the check matches against.
- The watch list is completed with real metrics, alerts and dashboards this change makes observable, not placeholders.

## Stop and ask

- A `non_revertible` address with no honest mitigation beyond "restore from backup" when no backup exists.
- A watch-list item this ticket's own change gives no way to actually observe.

## Done when

Every `non_revertible` address has a real mitigation under "## Non-revertible", and `stage complete KEY rollback` succeeded.
