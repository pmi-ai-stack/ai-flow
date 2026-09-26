# review.md format and the review rubric

`review.md` always has these headings, in this order — every heading is present even when its content is short:

1. **Findings** — every finding, severity-ranked (`must`, `should`, nice-to-have), each citing the guidance id or check id it responds to. A `must` finding here is one this ticket's own review surfaced, not a restatement of `checks-results.json`. For a ticket with targets, this heading also carries: the final changeset against `plan.md`'s own "Expected actions per target" (a mismatch is a finding, same as any other); each `render-drift-results.json` drift entry, acknowledged by name even when it needed no fix; and any open OPS `should` finding, justified rather than dropped.
2. **Cross-repo consistency** — for a change touching more than one repository: whether a contract change (an API shape, a schema, a shared message format) is reflected identically in every consumer. For a single-repository ticket, one line saying there is nothing to check.
3. **Mutation review** — which `mutation-results.json` equivalent claims were re-examined and the verdict on each (see `references/mutation.md`).
4. **Guidance compliance** — each `must` guidance section's id, whether this change satisfies it, and the reason when it does not. For a ticket with targets, confirm every `rollback-results.json` `non_revertible` address has a real mitigation in `rollback-plan.md` — `plan_check` already required one to exist at the `rollback` stage; this is a second, human-judgement look at whether it is actually credible, not a repeat of that mechanical check.

## Cross-repo contract consistency

Read the change to the contract itself (the API, the schema, the message shape) in the repository that owns it, then read every other in-scope repository's own use of that contract. A mismatch — a field renamed on one side and not the other, a new required field the consumer doesn't send — is a real defect, not a note for later.

## The equivalent-mutant challenge

See `references/mutation.md`'s "What review-changes re-examines" for the standard each claim is checked against. Record the verdict on each claim under `review.md`'s Mutation review heading.

## Severity by impact, not tone

A `must` finding here is one where shipping the change as written would produce wrong behavior, a security defect, or a guidance violation with no waiver. A `should` finding is a real improvement that does not block. Anything smaller is nice-to-have — real, but not worth a citation-heavy paragraph.
