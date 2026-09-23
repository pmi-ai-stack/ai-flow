---
name: apply-checks
description: Runs every applicable standards check for an ai-flow ticket and fixes the must and should findings it reports at the source, proposing a waiver only for a genuine conflict and never editing pack or linter configuration. Loaded by the develop orchestrator at the checks stage; not for direct use.
license: MIT
compatibility: Requires the ai-flow CLI on PATH and a git checkout of the in-scope repositories.
---

# Apply checks

## CLI calls

Run each instruction below and parse stdout as JSON. Exit 4: relay `needs_input.question` to the developer verbatim, then run `needs_input.resume_with` with their answer. Any other non-zero exit: stop and show `error.message`. Never add flags the steps below do not name.

## Read first

1. `ai-flow stage start KEY checks` — enters the stage and refreshes `guidance.md` for it.
2. `guidance.md`'s `must` and `should` sections — what every finding below is checked against.
3. `references/fix-at-source.md` for what "at the source" means and how to recognise a genuine conflict.

## Workflow

- [ ] Run `ai-flow standards check KEY --fix`
- [ ] Fix every open `must` and `should` finding at the source, per `references/fix-at-source.md`
- [ ] Re-run `ai-flow standards check KEY --fix` until no `must` finding remains open
- [ ] For a genuine conflict, propose `ai-flow standards waive KEY --check ID --repo REPO --reason "…" --expires YYYY-MM-DD`; relay the confirmation it asks for, then replay `needs_input.resume_with`
- [ ] Run `ai-flow stage complete KEY checks`

## Judgement

- Fix in the spirit of the guidance, not the narrowest edit that silences the tool.
- Never touch pack or linter configuration — a waiver is the only sanctioned way around a genuine conflict.
- A genuine conflict (a framework requirement, generated code, or vendored code) earns a waiver; an inconvenience does not.

## Stop and ask

- A `must` finding whose only real fix is a genuine conflict, and the developer has not yet confirmed the waiver.
- A `secrets` finding that cannot be fixed at the source — it cannot be waived either, so it needs the developer's own decision.

## Done when

`checks-results.json` shows no open `must` finding, every `should` finding is fixed or carries a recorded reason for staying open, and `stage complete KEY checks` succeeded.
