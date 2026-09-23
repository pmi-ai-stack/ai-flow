# Generating real options

Two options that differ only in wording are not two options. Before writing either one down, check that they actually trade something off — scope, risk, effort, or a dependency on something outside this ticket.

## A shape that usually produces two real options

- **Narrow**: the smallest change that satisfies the acceptance criteria, touching the fewest files and repositories.
- **Durable**: the change that also fixes the class of problem the ticket is one instance of, even if it touches more.

These are not "do it right" versus "do it wrong" — both have to actually satisfy the ticket. The narrow option is not a strawman; if it is written as one (vague, obviously worse, three words long), the brainstorm has not actually happened.

## Questions worth asking before choosing

- Does one option leave a repository's own conventions (from its instructions file) more consistent than the other?
- Does one option create a dependency on a change outside this ticket's scope?
- Does a `must` guidance section rule one option out entirely, or just make it more work?
- Would either option need a database migration, a config rollout, or anything with its own timing outside this PR?

## Recording the choice

State which option was chosen and the one or two reasons that decided it — not every consideration weighed. A reviewer reading only that paragraph should be able to tell why the other option lost.
