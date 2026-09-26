# rollback-plan.md format, and what makes a mitigation real

`rollback-plan.md` always has these headings, in this order — every heading is present even when its content is short:

1. **Trigger criteria** — the observable signal that says "revert now": an alert, a failed health check, a specific error rate. Not "if something looks wrong."
2. **Steps** — the ordered revert procedure: `git revert` per repository (from `rollback-results.json`'s own `repositories[]`), then each target's own tool-level rollback text (from `targets[]`), in the order they must happen.
3. **Non-revertible** — one entry per address in `rollback-results.json`'s own `non_revertible[]`, each with a real mitigation (see below). This is the one heading `ai-flow stage complete KEY rollback` checks by name: every address must appear here as text, or the stage refuses.
4. **Watch list** — `rollback-results.json`'s own deterministic watch list, completed with the actual metric, alert or dashboard that would show the change misbehaving.
5. **Owner** — who acts on the trigger criteria.

## What a real mitigation looks like

A mitigation says what a person does about a non-revertible action, not just that it exists. Restating the address ("acme.data:aws_db_instance.primary — non-revertible") satisfies nothing but the literal check; it names no action.

- **Data-bearing deletion** — a snapshot or backup taken immediately before, with the restore procedure named; or, when no backup is possible, an explicit acknowledgement of what is permanently lost and why the change proceeds anyway.
- **IAM or CRD removal** — the exact recreate command or manifest, and who is authorized to run it.
- **Secret rotation** — how the previous secret is recovered if consumers break, and how long the old value stays valid in a rotation-with-overlap scheme.
- **A one-way schema or version upgrade** — what downgrading actually requires (a restore point, a compatibility shim) or an explicit statement that there is no way back, and what that means for the trigger criteria above.

## Text, never executed

Every rollback command in `rollback-results.json` — `helm rollback`, `kubectl rollout undo`, a reverse Terraform plan, a previous job config — is derived as text for a person to read and run by hand. Nothing here has an allowlist row; `ai-flow` never runs it. This is why the plan explains context (what state must be true first, what could go wrong mid-revert), not just the bare command.
