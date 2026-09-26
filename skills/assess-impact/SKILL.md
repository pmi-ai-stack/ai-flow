---
name: assess-impact
description: Scores the risk of an ai-flow ticket's infrastructure or CI/CD change, writes impact.md and shrinks the blast radius at the source when that is genuinely possible before the developer is asked to accept it. Loaded by the develop orchestrator at the impact stage; not for direct use.
license: MIT
compatibility: Requires the ai-flow CLI on PATH and a git checkout of the in-scope repositories.
---

# Assess impact

## CLI calls

Run each instruction below and parse stdout as JSON. Exit 4: relay `needs_input.question` to the developer verbatim, then run `needs_input.resume_with` with their answer. Any other non-zero exit: stop and show `error.message`. Never add flags the steps below do not name.

## Read first

1. `ai-flow stage start KEY impact` — enters the stage and refreshes `guidance.md` for it.
2. `references/ops-risk.md` for what inflates a score and the standard ways to shrink it.

## Workflow

- [ ] Run `ai-flow ops impact KEY`
- [ ] Write `impact.md` with the headings Summary, Why this score (cite `contributions[]`), What could go wrong (cite `blast_radius` and `protected_actions[]`), Mitigations
- [ ] If the blast radius is genuinely avoidable, shrink it at the source (see `references/ops-risk.md`)
- [ ] After any source change, run `ai-flow standards check KEY` and `ai-flow ops dry-run KEY` — the re-run this later edit requires before the stage can complete
- [ ] Run `ai-flow ops impact KEY` again
- [ ] Run `ai-flow stage complete KEY impact`

## Judgement

- Shrink only what is genuinely avoidable — a score that reflects the change's real risk is not itself a defect to hide.
- `impact.md` is what `develop` presents at the gate; write it assuming the developer reads only this file.
- Every mitigation named in "Mitigations" is something actually done to the source, not a promise for later.

## Stop and ask

- No avoidable way exists to reduce a `protected` action or a score at or above `ops.risk_gate`.
- A mitigation would change the ticket's own intent, not just its blast radius.

## Done when

`impact-results.json` reflects the final changeset, `impact.md` carries all four headings, and `stage complete KEY impact` succeeded. Presenting the gate and recording the developer's acceptance is `develop`'s job, not this skill's.
