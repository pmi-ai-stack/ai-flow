---
name: addon-helm
description: Tool-specific judgement for the helm addon, in the five fixed sections every addon skill carries, for a Helm chart. Loaded by OPS stage skills for helm targets; not for direct use.
license: MIT
compatibility: Requires the ai-flow CLI on PATH and a git checkout of the in-scope repositories.
---

# Addon: helm

## Drift

`ops drift` compares `helm get manifest` for the installed release against the base chart's own template output, with no server-set-field stripping of its own (unlike the raw-manifest addon, this comparison is release-vs-template text, not object-vs-live-object). Expected drift is a value Helm itself injects at install/upgrade time and never templates (a release revision annotation, a `helm.sh/`-prefixed label the chart's own templates don't set) — anything a values file or a template controls that still differs live is real drift. A `helm lint` or `kubeconform` finding is always real; fix the chart, never the rendered output.

## Changeset

DryRun prefers `helm diff upgrade`; when that call fails for any reason (the extension is missing, or a real difference is reported) it falls back, unconditionally, to templating plus the same object-level comparison the raw-manifest addon uses — so a target's own changeset can come from either path and should be read the same way regardless. A chart value that forces an object to be destroyed and recreated (a selector, a storage class, an immutable field a template exposes as configurable) is dangerous; a values-only change to replica count, an annotation, or a label is cosmetic. A `Secret` template's own rendered `data`/`stringData` is redacted before this skill ever sees it.

## Impact

The score grows fastest through a change that reaches a `Secret`, RBAC or storage template, or through any change to a `prod`-tier release. Shrink it genuinely: split an unrelated value change into its own ticket or target, pin the change behind a values flag so only the intended objects change, or add a `PodDisruptionBudget` or a rollout cap in the template itself rather than describing the safeguard only in `impact.md`.

## Rollback

`ops rollback` calls `helm history` once per release (not once per object — a release's history is one timeline, unlike an object-by-object addon) and names the instruction `helm rollback <release> <revision>` as text, never executed. A one-way schema migration a chart's own hook performs, or a change to a `Secret`, RBAC or storage template, has no clean revert through `helm rollback` alone; `rollback-plan.md`'s own mitigation must name the real, tool-specific restore.

## Testing

`helm unittest` (a `tests/*_test.yaml` file under the chart) is the unit harness; `ct lint` plus `ct install` on the per-ticket `kind` cluster is the e2e harness — neither name is dispatched by the CLI's own harness runner today, so a test written this way is verified by hand until that wiring lands. The smallest real test: template the base chart, assert the object this ticket changes is absent or wrong; template the branch chart, assert it is correct.
