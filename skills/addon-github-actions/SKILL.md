---
name: addon-github-actions
description: Tool-specific judgement for the github-actions addon, in the five fixed sections every addon skill carries, for a GitHub Actions definition file. Loaded by OPS stage skills for github-actions targets; not for direct use.
license: MIT
compatibility: Requires the ai-flow CLI on PATH and a git checkout of the in-scope repositories.
---

# Addon: github-actions

## Drift

Not applicable — this addon has no live counterpart to compare against. A `.github/workflows/*.yml` file has no running configuration outside its own history the way a Terraform module or a Kubernetes object does, so `ops drift` reports every target here as `not_applicable` rather than running a real comparison.

## Changeset

DryRun runs the job graph and reports one `update` per target naming the job ids the branch's own file defines — there is no comparison of each job's own individual steps, only a per-job one. A job addition or removal, or a change to a job's `needs` field or its trigger conditions, is the shape most likely to change what actually runs; a comment, a display-name, or a `timeout-minutes` tweak is cosmetic. `actionlint` findings are always real; fix the file, never the copy `ai-flow` rendered.

## Impact

The score for this addon is driven entirely by `config.ops.protected_kinds` and tier, since every action here carries the same `pipeline` kind class regardless of what the job actually does — there is no data/IAM/secret distinction within one file the way there is for an infrastructure addon. Shrink it by keeping an unrelated job change out of this ticket's own file, or by resolving the `act -n` job-graph check instead of skipping it.

## Rollback

Text only: the previous file's own content plus a `git revert` of the commit that changed it — there is no live control-plane call this addon can make the way `kubectl rollout history` can. No action from this addon is ever `non_revertible` (the `pipeline` kind class never enters that list), but a `rollback-plan.md` entry should still say what re-running the reverted definition does to anything already triggered by the branch's own version before the revert lands.

## Testing

`act -j <job> -n` (a job-graph-only check, no real execution) is the unit-shaped harness; `act -j <job>` (a real run) is the e2e harness and is opt-in only — neither is wired into the CLI's own harness runner yet, so either is verified by hand until that lands. The smallest real check: run `act -n` against the base file and the branch file and confirm the job list actually differs the way the ticket intends.
