---
name: addon-terraform
description: Tool-specific judgement for the terraform addon, in the five fixed sections every addon skill carries, for Terraform root modules. Loaded by OPS stage skills for terraform targets; not for direct use.
license: MIT
compatibility: Requires the ai-flow CLI on PATH and a git checkout of the in-scope repositories.
---

# Addon: terraform

## Drift

`ops drift` runs `tflint` against the branch rendering and compares the base rendering with the live environment. Expected drift is a computed attribute that legitimately differs after creation — a cloud-assigned identifier, an ARN, a timestamp, or a default tag the environment itself adds outside this ticket's own files. Anything else — a change made outside version control, or a drift on an attribute this ticket's own configuration declares — is real and belongs in `review.md`, acknowledged, not silently accepted. A `tflint` finding is always real; fix it at the source, never by editing the rendering.

## Changeset

Every `create`/`update`/`delete` combination `terraform plan` reports becomes one changeset action; `create,delete`/`delete,create` becomes a `replace`. An address forced to `replace` by an immutable attribute (an identifier, a field only a `provider` accepts at creation, an engine or storage-class setting) is dangerous — it destroys and recreates, unlike an in-place `update`. A `provider` version bump alone, a tag- or label-only `update`, or a description/comment change is cosmetic. A value already marked `sensitive` by the `provider`'s own schema is redacted before this skill ever sees it — never re-derive it from context.

## Impact

The score grows fastest through a `delete`/`replace` on a data-, IAM- or secret-classed address (an `aws_db_*`/`aws_s3_bucket*`/`aws_secretsmanager_*`-shaped type, among others) in a `prod`-tier target, and through pre-existing drift or an offline target's own flat penalty. Shrink it genuinely: split an unrelated address out of the target, add a `prevent_destroy` lifecycle rule so the safeguard lives in the target itself, or resolve live access instead of leaving a target offline.

## Rollback

`ops rollback` produces text only for this addon — a `git revert` plus a re-render/re-drift instruction, never a second real apply this addon runs itself. A `delete` or `replace` on a data, IAM, secret or namespace-classed address has no clean revert path through Terraform alone: `rollback-plan.md`'s own mitigation for that address must name a real, tool-specific restore (a snapshot, a backup, manual reconstruction), not just "revert the commit."

## Testing

A `*.tftest.hcl` file next to the module is a unit harness (`terraform test`); a Go file importing `github.com/gruntwork-io/terratest` under the target's own directory is an e2e harness against a sandbox `workspace`. The smallest real test: a `run` block that exercises this ticket's change fails (or is absent) against the base rendering and passes against the branch's.
