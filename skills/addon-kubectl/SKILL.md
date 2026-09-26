---
name: addon-kubectl
description: Tool-specific judgement for the kubectl addon, in the five fixed sections every addon skill carries, for a directory of raw Kubernetes manifests. Loaded by OPS stage skills for kubectl targets; not for direct use.
license: MIT
compatibility: Requires the ai-flow CLI on PATH and a git checkout of the in-scope repositories.
---

# Addon: kubectl

## Drift

`ops drift` compares the base rendering's declared objects against live state, with server-set `metadata` fields and the whole `status` subtree already stripped before the comparison — a `resourceVersion`, a generation counter, an injected label a controller or an admission webhook owns are never real drift, they never reach this comparison at all. What survives that stripping and still differs is real: a manually-`kubectl apply`'d change, a value this ticket's own manifest declares but live state disagrees with. `kubeconform` findings are always real; fix the manifest, never the rendering.

## Changeset

DryRun reports `create` for an object with no live counterpart and `update` naming every changed top-level key for one that exists; this addon never reports `delete`/`replace` (a plain `apply` cannot honestly claim one). A change to a selector, a storage class, or any other field a real update would reject in place is dangerous even though it only ever surfaces as an `update` here — flag it by field name, not by action kind. An annotation-, label- or replica-count-only `update` is cosmetic. A `Secret`'s own `data`/`stringData` keys are marked sensitive and redacted at render time, before any changeset exists.

## Impact

The score grows fastest through a change to a `Secret`, an RBAC object, a `PersistentVolume(Claim)`, or a `Namespace`/`CustomResourceDefinition` in a `prod`-tier target. Shrink it genuinely: split an unrelated object into its own target, add a `PodDisruptionBudget` or a rollout `maxUnavailable` cap so a workload change is safer in the cluster itself, or resolve live access instead of leaving a target offline.

## Rollback

For a `Deployment`, `StatefulSet` or `DaemonSet`, `ops rollback` makes one real, read-only `kubectl rollout history` call and reports the previous revision by number — the one addon whose rollback text is backed by a live read, not a guess. Every other kind's own rollback is a text-only `kubectl rollout undo`-shaped instruction, never executed. A `delete`/`replace`-equivalent update to a `Secret`, RBAC, storage or namespace-classed object has no clean revert through `kubectl` alone; `rollback-plan.md`'s own mitigation must name a real restore.

## Testing

There is no unit harness for raw manifests — only e2e, via a `kuttl-test.yaml` or `chainsaw-test.yaml` file next to the target, run against the per-ticket `kind` cluster. This section is still required content, not `not_applicable`: the addon has no unit harness, but it does have an e2e one. The smallest real test: apply the base rendering, assert the expected object is absent or wrong; apply the branch rendering, assert it is correct.
