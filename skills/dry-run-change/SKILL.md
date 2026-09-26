---
name: dry-run-change
description: Runs the read-only dry-run of infrastructure and CI changes for an ai-flow ticket, compares the resulting changeset with the approved plan and fixes unintended diffs at the source. Loaded by the develop orchestrator at the dry-run stage; not for direct use.
license: MIT
compatibility: Requires the ai-flow CLI on PATH and a git checkout of the in-scope repositories.
---

# Dry-run change

## CLI calls

Run each instruction below and parse stdout as JSON. Exit 4: relay `needs_input.question` to the developer verbatim, then run `needs_input.resume_with` with their answer. Any other non-zero exit: stop and show `error.message`. Never add flags the steps below do not name.

## Read first

1. `ai-flow stage start KEY dry-run` — enters the stage and refreshes `guidance.md` in the handoff directory it names when the resolution changed.
2. `guidance.md`: `must` sections are requirements, `should` is the default unless `plan.md` says why not, `may` is advice. Fix at the source; never edit pack or linter configuration; a convention not listed is a preference, not a violation.
3. `plan.md`, section "Expected actions per target".
4. For each addon in `ops-targets.json`, load the `addon-<name>` skill and read its **Changeset** section.

## Workflow

- [ ] Run `ai-flow ops dry-run KEY`
- [ ] For each entry in `result.targets[]`, open the file its own `plan` field names and compare its `actions[]` with `plan.md`'s expected actions, per target
- [ ] Fix the source for every unintended action; re-run `ai-flow ops dry-run KEY` until the changeset matches intent
- [ ] Run `ai-flow stage complete KEY dry-run`

## Judgement

- An action `plan.md` did not expect is a gap in it (update `plan.md` under "Expected actions per target", say why) or a mistake (fix the source). Never both silently.
- Cosmetic `fields_changed` are noted, not fixed; the addon skill's own Changeset section lists them.
- A target's `tier` (visible in `ops-targets.json`) decides whether `--offline` is ever an option — never the developer's convenience.

## Stop and ask

- Any `delete` or `replace` `plan.md` did not expect.
- `live_credentials_missing` on a `prod`-tier target: never resume with `--offline` yourself — ask the developer to provide credentials, or to split the change so the prod target leaves scope.
- A `protected` action.

## Done when

`stage complete` succeeded and every action is expected by `plan.md` or explained in it.
