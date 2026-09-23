---
name: plan-solution
description: Reads an ai-flow ticket, asks clarifying questions where the request is ambiguous, weighs at least two solution options, and writes plan.md for the developer to approve. Loaded by the develop orchestrator at the plan stage; not for direct use.
license: MIT
compatibility: Requires the ai-flow CLI on PATH and a git checkout of the in-scope repositories.
---

# Plan solution

## CLI calls

Run each instruction below and parse stdout as JSON. Exit 4: relay `needs_input.question` to the developer verbatim, then run `needs_input.resume_with` with their answer. Any other non-zero exit: stop and show `error.message`. Never add flags the steps below do not name.

## Read first

1. `ai-flow stage start KEY plan` — enters the stage and resolves `guidance.md` for it.
2. `ticket.json`'s summary and description (where acceptance criteria live), its recent comments, and `images.md`/`attachments/` for anything attached.
3. `repo.json` — the repositories in scope and each one's instructions file.
4. `guidance.md` — `must` sections are requirements for `plan.md` itself (an architecture rule, a required ADR); `should` is the default unless `plan.md` says why not.
5. `references/plan-format.md` for the required headings; `references/brainstorm.md` for generating real options.

## Workflow

- [ ] Read the ticket and every attachment; if the request is ambiguous or the acceptance criteria conflict, ask the developer before drafting anything
- [ ] Draft at least two genuinely different options (see `references/brainstorm.md`), not one option and a strawman
- [ ] Choose one and record why, in `plan.md` itself
- [ ] Write `plan.md` with the required headings from `references/plan-format.md`
- [ ] Run `ai-flow stage complete KEY plan`

## Judgement

- A clarifying question is for something the ticket cannot answer, not for a decision `plan.md` should just record.
- The choice between options is `plan.md`'s own content — write the reasoning there, not only in conversation.
- Add the OPS headings `references/plan-format.md` names only when it says they apply.

## Stop and ask

- The ticket's acceptance criteria are ambiguous or contradict an attachment.
- No option satisfies a `must` guidance section without a real drawback worth recording.

## Done when

`stage complete KEY plan` succeeded and `plan.md` names at least two options and the reasoning for the one chosen. Presenting the gate for approval is `develop`'s job, not this skill's.
