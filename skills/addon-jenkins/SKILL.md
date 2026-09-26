---
name: addon-jenkins
description: Tool-specific judgement for the jenkins addon, in the five fixed sections every addon skill carries, for a Jenkinsfile, a job DSL file or a job-config XML file. Loaded by OPS stage skills for jenkins targets; not for direct use.
license: MIT
compatibility: Requires the ai-flow CLI on PATH and a git checkout of the in-scope repositories.
---

# Addon: jenkins

Every section below is checked against this addon's own `jenkins-cli` call shapes in source, but no real Jenkins server has confirmed any of their real output yet — read a surprising result as a possible tool-contract gap, not settled fact, until that changes.

## Drift

`ops drift` compares the base rendering, whitespace-normalized, against a real `jenkins-cli get-job` call for the same job — looking backward at what already existed before this ticket. A missing job on the live side fails the call outright rather than reporting drift, since there is nothing yet to compare against; that is a setup problem for the environment, not drift. What differs after normalization is real: a manual edit made through the Jenkins UI, or a stored value this ticket's own file does not account for.

## Changeset

DryRun runs the identical whitespace-normalized comparison against the *branch* file — looking forward at what this ticket would produce. Unlike Drift, a missing live job here is reported as a plain `create`, never a failure: a brand-new job has nothing live yet, and that is expected. An agent-label change, a credential-id change, or a change to what a stage actually runs is dangerous; a display-name, description, or comment-only change is cosmetic. `declarative-linter` findings apply only to a `Jenkinsfile`-shaped target — a job-DSL or job-config-XML target has no declarative syntax for it to check.

## Impact

Every action from this addon carries the `pipeline` kind class, so — like the github-actions addon — the score here comes from `config.ops.protected_kinds` and tier, not from a data/IAM/secret distinction inside one file. Shrink it by keeping an unrelated job change out of this ticket's own file, or by resolving live access to the Jenkins server instead of leaving the target offline.

## Rollback

Text only: the previous job configuration's own content plus a `git revert` of the commit that changed it — no live control-plane call this addon can make on its own. No action from this addon is ever `non_revertible` (the `pipeline` kind class never enters that list), but `rollback-plan.md` should still name what a reverted definition does to a run already triggered by the branch's own version.

## Testing

For a `Jenkinsfile` or a Groovy job-DSL file, a `*.groovy` file importing `com.lesfurets.jenkins.unit` is the unit harness (JenkinsPipelineUnit); the target itself, run through `jenkinsfile-runner`, is the e2e harness and is opt-in only — neither name is wired into the CLI's own harness runner yet. The smallest real test: assert the pipeline's own logic produces the base commit's behavior when stubbed, and the branch commit's changed behavior once the ticket's edit is applied.
