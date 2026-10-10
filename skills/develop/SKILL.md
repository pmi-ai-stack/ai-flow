---
name: develop
description: Drives an ai-flow ticket through every stage from fetch to output, running each CLI-only stage itself and loading the skill each judgement stage names. Use when the developer wants to advance a ticket, resume a session left mid-stage, or check what a ticket needs next.
license: MIT
compatibility: Requires the ai-flow CLI on PATH and a git checkout of the in-scope repositories.
disable-model-invocation: true
---

# Develop

## CLI calls

Run `ai-flow status KEY` to find what happens next, and parse stdout as JSON. When the result names a CLI-only stage's own instruction rather than a skill, run exactly that instruction — for example `ai-flow ticket fetch KEY`, `ai-flow repo locate KEY` or `ai-flow summary render KEY` — then check status again. Exit 4: relay `needs_input.question` to the developer verbatim, then run `needs_input.resume_with` with their answer. Any other non-zero exit: stop and show `error.message`. Never add flags the steps below do not name.

## Read first

1. The ticket key is what the developer typed when they invoked this skill; if it is missing or not shaped like a key, ask before running anything.
2. `ai-flow status KEY`'s own result — `next_stage`, `next_skill`, `next_command` and `next_state`.

## Workflow

- [ ] Run `ai-flow status KEY`
- [ ] `next_state` is `awaiting_approval` — present the gate in full; once the developer approves it, run `ai-flow stage approve KEY plan` (or whichever stage `status` named), which the host asks them to confirm; if the guard refuses it, ask the developer to run it in their own terminal and wait — never `stage start`, which would discard the gate as a revision
- [ ] `next_state` is `pending` or `running` and `next_skill` is set — load the skill it names
- [ ] `next_state` is `pending` and `next_command` is set with no skill — run that instruction directly
- [ ] `next_state` is `fail` — show the failure and stop
- [ ] Repeat from the top until `status` names neither a skill nor an instruction

## Judgement

- Present every gate in full before it is approved; never approve one on the developer's own behalf.
- Relay `needs_input.question` verbatim — a paraphrase can silently drop one of its `options`.
- When the developer says to redo a named stage, run stage reset for that stage — for example `ai-flow stage reset KEY plan` — with the ticket key, then resume the loop from `status`. This is the only time a passed or approved stage's state is touched outside its own skill.

## Stop and ask

- `needs_input` is present in a result.
- `next_state` is `awaiting_approval` — a gate is open.
- `next_state` is `fail` — a stage failed; wait for the developer to fix the cause and say to redo it, or to stop.

## Done when

`output.md` exists and the developer has been told the ticket is ready for `ship`.
