---
name: run-visual-tests
description: Captures screenshots of the screens an ai-flow ticket's change touches and records a pass or fail verdict for each one against the ticket's acceptance criteria. Loaded by the develop orchestrator at the visual-test stage; not for direct use.
license: MIT
compatibility: Requires the ai-flow CLI on PATH and a git checkout of the in-scope repositories.
---

# Run visual tests

## CLI calls

Run each instruction below and parse stdout as JSON. Exit 4: relay `needs_input.question` to the developer verbatim, then run `needs_input.resume_with` with their answer. Any other non-zero exit: stop and show `error.message`. Never add flags the steps below do not name.

## Read first

1. `ai-flow stage start KEY visual-test` — enters the stage and refreshes `guidance.md` for it.
2. `ai-flow git diff KEY` — which screens the change implies.

## Workflow

- [ ] Run `ai-flow visual run KEY`; add `--screen PATH` (repeatable) for any screen the change implies that the default capture missed
- [ ] Look at each captured screenshot and judge it against the ticket's acceptance criteria
- [ ] Run `ai-flow visual judge KEY --screen PATH --verdict pass --reason "…"` or `--verdict fail --reason "…"`, once per screen
- [ ] For a `fail`, fix the source, then re-run `ai-flow visual run KEY --screen PATH` and re-judge that screen
- [ ] Run `ai-flow stage complete KEY visual-test`

## Judgement

- Whether the default, change-implied screens are the right set — name any missing one explicitly through `--screen`, don't silently accept a narrower set.
- A verdict's reason names what was actually seen in the screenshot; "looks fine" is not a reason.

## Stop and ask

- A screen the ticket clearly requires cannot be captured (the dev server won't start, or the screen doesn't exist on the branch).
- A regression whose fix is unclear, or that would touch a shared component this ticket did not intend to change.

## Done when

`visual-test-results.json` records a verdict for every relevant screen, every `fail` has been fixed and re-judged to `pass` or stopped-and-asked about, and `stage complete KEY visual-test` succeeded.
