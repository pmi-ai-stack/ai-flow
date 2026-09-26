---
name: assess-drift
description: Materializes each changed infrastructure or CI/CD target for an ai-flow ticket, fixes validator findings at the source, and classifies any live drift as expected, unexpected or blocking. Loaded by the develop orchestrator at the render-drift stage; not for direct use.
license: MIT
compatibility: Requires the ai-flow CLI on PATH and a git checkout of the in-scope repositories.
---

# Assess drift

## CLI calls

Run each instruction below and parse stdout as JSON. Exit 4: relay `needs_input.question` to the developer verbatim, then run `needs_input.resume_with` with their answer. Any other non-zero exit: stop and show `error.message`. Never add flags the steps below do not name.

## Read first

1. `ai-flow stage start KEY render-drift` — enters the stage and refreshes `guidance.md` for it.
2. For each addon named in `ops-targets.json`, load the `addon-<name>` skill and read its **Drift** section — the tool's own expected drift (controller-managed fields, defaulted values) and which validator messages are safe to ignore.

## Workflow

- [ ] Run `ai-flow ops drift KEY`
- [ ] Fix every open `validation[]` finding at the source, per the loaded addon skill's own conventions
- [ ] Re-run `ai-flow ops drift KEY` until no target's `validation[]` has an open finding
- [ ] For each target reporting `drift: "present"`, classify every address in `drift_resources[]` as expected (matches the addon skill's own Drift section) or unexpected
- [ ] Run `ai-flow stage complete KEY render-drift`

## Judgement

- A validator finding is fixed in the infrastructure or CI source itself, never by editing the rendering or the tool's own configuration.
- Expected drift needs no action — the addon skill's own examples are the standard to check against, not a guess.
- Unexpected but non-blocking drift is left exactly as recorded: `render-drift-results.json` itself is what carries it forward to `review-changes` and the PR — this skill writes no prose artifact of its own.

## Stop and ask

- Drift the addon skill's own Drift section gives no basis to classify with confidence.
- `drift: "offline"` on a target whose live state genuinely matters for this ticket's own decision.

## Done when

No target's `validation[]` has an open finding, every `drift: "present"` target has been classified, and `stage complete KEY render-drift` succeeded.
