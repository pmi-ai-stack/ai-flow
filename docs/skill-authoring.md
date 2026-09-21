# Skill authoring standard

This is the standard every skill in `skills/` is written against, and it is authoritative — there is no separate design document behind it. `internal/skills/lint` (in the `ai-flow-cli` repo) is its executable form — every rule below either carries a lint rule id (enforced by `ai-flow skills lint <dir>`) or is enforced by the embedded `schema/skill-frontmatter.schema.json` directly. A rule that cannot be stated as a lint rule or a one-line review item does not belong here.

Skills carry judgement only, are written once to the [Agent Skills](https://code.claude.com/docs/en/skills) open standard, and behave identically in Claude Code and Cursor.

## Portable skill profile

The intersection of the Agent Skills spec and both hosts' frontmatter.

| Field | Rule | Lint rule id |
| --- | --- | --- |
| `name` | Required; equals the directory name; `a-z0-9-`, 1–64 characters. `develop`/`ship` for the two entry points; verb-object for every other stage skill; `addon-<tool>` for addon skills. Never a host or vendor name. | `name-matches-directory` |
| `description` | Required; third person; ≤ 600 characters; sentence 1 says what it does; sentence 2 is `Use when …` (entry points) or `Loaded by the develop orchestrator at the <stage> stage; not for direct use.` / `Loaded by OPS stage skills for <tool> targets; not for direct use.` | `description-form` |
| `license` | `MIT`. | enforced by `schema/skill-frontmatter.schema.json` |
| `compatibility` | The fixed sentence `Requires the ai-flow CLI on PATH and a git checkout of the in-scope repositories.` | enforced by the schema |
| `disable-model-invocation` | `true` on `develop` and `ship` only; absent everywhere else. | enforced by the schema |
| anything else | Rejected — including `allowed-tools`, which Cursor ignores and which, read as an allowlist, would remove the file editing a stage skill needs. The guard, not the frontmatter, decides what may run. | `frontmatter-unknown-field` |

Frontmatter opens on line 1 of `SKILL.md` — no leading blank line, no content before the `---` fence.

## Body grammar

Positive grammar: prose; fenced `ai-flow …` invocations that exist in the CLI's command catalog (`Catalog()`, phase 3) with its documented argument order — the ticket key is always the first positional argument of a ticket-scoped command; skill names in "load the `<name>` skill"; stage ids and handoff file names drawn from the CLI's `StageTable()`.

| Rule | What it catches | Lint rule id |
| --- | --- | --- |
| Non-portable tokens | Any other `$`, `${`, `` !` ``, `@`, `/name`, absolute path or `../` in the body — one error covers all of them, because the skill must run identically under both hosts and nowhere else. | `non-portable-token` |
| Unknown command | A fenced `ai-flow …` invocation whose noun/verb is not in `Catalog()`. | `unknown-command` |
| Argument order | A fenced invocation whose ticket key is not the first positional argument, or whose flags don't match the catalog. | `arg-order` |
| Unknown stage or file | A stage id or handoff file name not in `StageTable()`. | `unknown-stage-id` |
| Missing reference | A `references/<file>.md` link to a file that doesn't exist. | `missing-reference` |
| Reference too long | A `references/<file>.md` file over 80 lines. | `reference-too-long` |
| Reference drift | A same-named reference file (`tdd.md`, `plan-format.md`, `mutation.md`, `ops-risk.md`, `verify-before-done.md`, …) that isn't byte-identical across every skill that carries it. | `reference-not-identical` |
| Disallowed directory entry | Anything in the skill's directory other than `SKILL.md`, `references/`, `evals/`. | `directory-not-allowed` |
| Body too long | Over 500 lines (hard limit); a warning above 150 lines for stage skills or 250 for entry points. | `body-too-long` |
| Missing evals | `evals/evals.json` absent, or fewer than three scenarios, or missing the happy-path/stop-and-ask/temptation trio. | `missing-evals` |
| Terminology | A word from `docs/terminology.json`'s `avoid` list where the `term` was meant. | `terminology` |
| Addon section missing | An `addon-<tool>` skill missing one of the five fixed sections (Drift, Changeset, Impact, Rollback, Testing) — a capability the addon does not declare still gets a one-line `not_applicable` section, never an absent one. | `addon-section-missing` |

## SKILL.md template

Every stage skill has the same shape:

````markdown
---
name: dry-run-change
description: Runs the read-only dry-run of infrastructure and CI changes for an ai-flow ticket, compares the resulting changeset with the approved plan and fixes unintended diffs at the source. Loaded by the develop orchestrator at the dry-run stage; not for direct use.
license: MIT
compatibility: Requires the ai-flow CLI on PATH and a git checkout of the in-scope repositories.
---

# Dry-run change

## CLI calls

Run `ai-flow <noun> <verb> KEY …` — the ticket key always comes first — and parse stdout as JSON. Exit 4: ask the developer `needs_input.question`, then run `needs_input.resume_with` with the answer. Any other non-zero exit: stop and show `error.message`. Never add flags the steps below do not name.

## Read first

## Workflow

## Judgement

## Stop and ask

## Done when
````

Entry points (`develop`, `ship`) carry `disable-model-invocation: true` and omit the "Loaded by …" sentence in favour of "Use when …". Addon skills use the five fixed sections instead of "Workflow"/"Judgement".

## The authoring standard

- **Conciseness.** Say the rule once. A skill that repeats the CLI's own `--help` text has the wrong content.
- **Degrees of freedom.** State the constraint, not the procedure, wherever the model can safely choose — "run `test run` before claiming a step done" not "run `test run`, wait, read the JSON, check `failed == 0`, then …".
- **Progressive disclosure.** The body is the 80% path; anything conditional, tool-specific or over 40 lines moves to `references/<topic>.md`.
- **Checklists over prose** for anything with a pass/fail shape (`Done when`).
- **Explicit feedback loops and stop-and-ask lists.** Every skill with judgement names what makes it stop and ask a human, not just what makes it proceed.
- **One default.** Where the spec allows a choice, the skill states the default and only the default; alternatives live in configuration, not in a skill deciding among them at runtime.
- **No time-sensitive text.** No "currently", "as of", "the latest version" — those rot. State the fact or point at the command that reveals it (`ai-flow version`).
- **Templates for prose artifacts.** `plan.md`, `impact.md`, `rollback-plan.md`, `review.md` each have a required heading set a reference file states once; the skill fills it in, never invents a different shape.
- **Evals before prose.** A skill's three scenarios (happy path, stop-and-ask, temptation) are written before the skill is considered done, not added afterward to satisfy the lint.

## Evals

`skills/<name>/evals/evals.json` has at least three scenarios: **happy path**, **stop-and-ask** and **temptation** (a shortcut the skill must refuse). Each carries `query`, `fixture` (a recorded handoff directory under `evals/fixtures/<scenario>/`), `baseline` (what happens without the skill) and `expected_behavior[]`. `ai-flow skills evals` runs one fresh headless session per scenario, grades the transcript against `expected_behavior`, and checks `events.jsonl` for the exact CLI calls in the expected order. See the spec's "Evals" section for the harness; this document only states what a skill's `evals.json` must contain.
