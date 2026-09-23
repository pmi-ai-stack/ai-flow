# plan.md format

`plan.md` always has these headings, in this order:

1. **Objective** — one paragraph: what changes and why, in terms of the ticket's acceptance criteria.
2. **In-scope repos** — the repositories from `repo.json`, and what each one contributes.
3. **Out-of-scope rationale** — anything the ticket could be read to include that this change deliberately does not touch, and why.
4. **Files to change** — the files or areas the work will touch, repository by repository.
5. **Steps** — the ordered work, one line per step, specific enough that `implement-plan` can follow it without re-deciding what to build.
6. **Test strategy** — what proves the change works: which existing tests, which new ones, which repositories.
7. **Rollback sketch** — one paragraph on how this would be undone if it shipped and turned out wrong. Not the full rollback procedure (that is `rollback-plan.md`, written much later, only for infrastructure and CI/CD changes) — just enough that a reviewer can see the change is reversible.

Add these two only when `ops-targets.json` is non-empty — the ticket touches infrastructure or CI/CD:

8. **Targets and environments** — each target from `ops-targets.json`, the environment it binds to, and its tier.
9. **Expected actions per target** — for each target, the actions (create, update, delete, replace) the change is expected to produce. `dry-run-change` compares the real changeset against this list later and treats any mismatch as a plan gap or a mistake.

## Example fragment

```
## Objective

PROJ-123 asks for webhook delivery retries. Failed deliveries are
currently dropped after one attempt; this adds three attempts with
exponential backoff and logs the final failure.

## In-scope repos

- acme.billing.api — the delivery worker and its tests
```

Every heading is present even when its content is short — an empty "Out-of-scope rationale" still has one line saying there was nothing to exclude.
