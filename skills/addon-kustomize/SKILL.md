---
name: addon-kustomize
description: Tool-specific judgement for the kustomize addon, in the five fixed sections every addon skill carries, for a Kustomize overlay. Loaded by OPS stage skills for kustomize targets; not for direct use.
license: MIT
compatibility: Requires the ai-flow CLI on PATH and a git checkout of the in-scope repositories.
---

# Addon: kustomize

## Drift

This addon builds the overlay into one flat object stream before comparing anything, then reuses the raw-manifest addon's own comparison exactly — server-set `metadata` fields and `status` already stripped, so a controller-owned field is never real drift. What survives is real: a manually-applied change, or a value a base, a patch or a component declares that live state disagrees with. `kubeconform` findings are always real; fix the base or the patch that actually owns the field, never the built output.

## Changeset

Because Render already flattens the overlay into one built stream, DryRun never re-derives per-patch structure — it reads exactly like the raw-manifest addon's own changeset: `create` for a new object, `update` naming every changed top-level key, never `delete`/`replace`. A patch that changes a selector, a storage class, or any field a real update would reject in place is dangerous even though it surfaces only as an `update`; an annotation-, label- or replica-count-only patch is cosmetic. A `Secret` patch's own `data`/`stringData` is redacted before this skill ever sees it.

## Impact

The score grows fastest through a patch that reaches a `Secret`, RBAC, storage or namespace-classed object in a `prod`-tier overlay. Shrink it genuinely: move an unrelated patch to its own overlay or target, add a `PodDisruptionBudget` or a rollout cap through a patch rather than describing the safeguard only in `impact.md`, or resolve live access instead of leaving the target offline.

## Rollback

Identical to the raw-manifest addon: a real `kubectl rollout history` read (and a named previous revision) for a `Deployment`/`StatefulSet`/`DaemonSet`, text-only `rollout undo` for everything else. A base or patch change that removes a `Secret`, RBAC, storage or namespace-classed object has no clean revert through `kubectl` alone; name the real restore in `rollback-plan.md`.

## Testing

There is no unit harness for an overlay — only e2e, via a `kuttl-test.yaml` or `chainsaw-test.yaml` file next to it, run against the per-ticket `kind` cluster, identical to the raw-manifest addon. The smallest real test: build and apply the base overlay, assert the expected object is absent or wrong; build and apply the branch overlay, assert it is correct.
