# Fixing at the source

A check finding names a symptom. "At the source, in the spirit of the guidance" means fixing the reason the tool flagged it, not the narrowest edit that makes the tool stop flagging it.

## Narrow versus real

- Narrow: silencing a lint rule inline, renaming a variable to dodge a naming check without changing what it names, adding a one-off allow entry for a single occurrence of a pattern the guidance actually rules out everywhere.
- Real: changing the code so the reason the rule exists no longer applies — the naming actually follows the convention, the pattern the guidance forbids is genuinely gone, not just hidden from this one tool run.

A `should` finding gets the same treatment as a `must` — it is the default the guidance names, not a suggestion to weigh against convenience.

## Recognising a genuine conflict

Three classes are real conflicts, not excuses:

- **Framework requirement** — the framework itself mandates the shape the guidance forbids, with no supported alternative.
- **Generated code** — the finding is in a file this ticket did not write and regenerating it is out of scope.
- **Vendored code** — the finding is in third-party code brought in unmodified.

Anything else — "it would take longer," "the existing code already does this elsewhere" — is not a conflict; it is a reason to fix the finding, possibly more than the one this check flagged.

## Never touch pack or linter configuration

Loosening a rule, adding a new exclusion, or editing a tool's own configuration file is never this skill's job — that is a standards-pack change with its own review, not a shortcut inside one ticket. The only sanctioned exception path is a waiver, scoped to one check, one repository, and an expiry date.

## Proposing a waiver

For a genuine conflict: `ai-flow standards waive KEY --check ID --repo REPO --reason "…" --expires YYYY-MM-DD`. The reason names which of the three conflict classes applies and why. A `secrets`-kind check cannot be waived at all — the CLI refuses it regardless of the reason given.
