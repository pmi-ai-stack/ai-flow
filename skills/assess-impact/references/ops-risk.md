# Reading a risk score, and shrinking a blast radius

`ai-flow ops impact`'s score is `min(100, contribution per action summed, plus a penalty per drifted or offline target)`. Each action's own contribution is `action weight × kind-class weight × tier multiplier` — a `delete` on a `data` or `iam` resource in `prod` contributes far more than an `update` on a `workload` in `nonprod`. A `noop` action never contributes anything and never gates.

## The two flags on every action

- **`protected`** — `true` when the action is a `delete` or `replace` on a `data`, `iam`, `secret` or `crd_or_namespace`-class resource, or when it is any non-`noop` action on a `prod`-tier target whose kind is in `config.ops.protected_kinds`. This is one of the two gate triggers (the other is `score ≥ ops.risk_gate`) and the only one `stage skip KEY impact` is refused for. There is no way to shrink `protected` by editing `impact.md`'s own wording — only by changing what the change actually does.
- **`sensitive`** — `true` when the kind class is `secret`, or a changed field is marked sensitive by the tool. Its only effect is redaction (`fields_changed` values become `<redacted:sha256-prefix>`); it never affects the score.

## What inflates a score

- More actions, especially `delete`/`replace` on `data`, `iam`, `secret` or `crd_or_namespace` resources.
- A `prod`-tier target, which multiplies every contribution on it.
- Pre-existing drift on a target this change touches, or a target scored `offline` (no live access) — both add a flat penalty independent of the actions themselves.

## The standard ways to shrink it, genuinely

- **Split the target.** A change that touches an unrelated resource alongside the one this ticket needs can drop the unrelated one from scope entirely.
- **Add a safeguard the tool itself enforces**, so the action's own risk is smaller, not just its description: a `prevent_destroy` lifecycle rule, a `PodDisruptionBudget`, a rollout `maxUnavailable` cap.
- **Resolve live access instead of leaving a target offline** — the `offline_penalty` exists because an unverified changeset is a real, not cosmetic, risk; providing credentials removes the penalty honestly, where narrating around it would not.
- **Fix real drift** (at the `render-drift` stage, before this one) rather than letting a drifted target's own penalty stand.

None of these are available after the fact by editing `impact.md`'s prose — every one of them changes the changeset itself, which is why shrinking a blast radius always means re-running `ai-flow ops dry-run KEY` before scoring again.

## What is not shrinkable

A `protected` action stays protected regardless of score. A score that reflects the change's real risk — because the change genuinely is that risky — is not a defect; the gate exists so a human decides, not so the score reaches zero.
