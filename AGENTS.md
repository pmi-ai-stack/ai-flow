# AGENTS.md — ai-flow

This repo is the **plugin** (skills, hooks) for Claude Code and Cursor. The CLI — the sole deterministic actor, which owns every side effect — is a sibling repository, `ai-flow-cli`.

- **Skill rules:** `docs/skill-authoring.md` — the authoring standard, with a lint rule id for every rule it states. `docs/terminology.json` is the fixed vocabulary it enforces. This is the authority for what a skill, a hook or a manifest field must look like; there is no separate design document to consult.
- **Hook contract:** `hooks/{claude-code.json,cursor.json,guard.sh,session-start.sh}` — the guardrail and session-start bindings for each host. Read these files directly before changing hook behavior.

## Pre-commit command

```
ai-flow skills lint .
```

(Live as of phase 10 — `internal/skills/lint` exists in the CLI repo and `skills/hello/` gives it real, non-empty content to check.)

## What this repo owns

Skills carry judgement only and behave identically under both hosts. A skill never talks to Jira/GitHub/git/terraform/kubectl/helm directly, never hand-writes machine-readable state, and never decides which standards apply — it only calls `ai-flow <noun> <verb> --json` and reads the JSON envelope from stdout.

The two hook scripts (`hooks/guard.sh`, `hooks/session-start.sh`) are the only place this repo runs anything itself, and both are two-or-so lines that immediately hand off to `ai-flow hook …`.

## Repository status

Built so far: both plugin manifests (`.claude-plugin/`, `.cursor-plugin/`), the hook registration files and scripts (with their final event bindings, live since phase 9), `docs/terminology.json`, `docs/skill-authoring.md`.

Phase 10 adds `skills/hello/` — the first non-empty entry under `skills/`, proving the `skills lint`/`skills install` loop against real content rather than only the CLI repo's own `testdata/`. It is deliberately **not** one of the fourteen stage/entry skills or six addon skills the spec names (those are phases 15, 16 and 21-27); it is a placeholder that carries no real judgement, and its own `SKILL.md` says so in its first sentence. Its description's second sentence still has to take one of skill-authoring.md's two fixed forms (there is no third, "this is a placeholder" form in the standard), so it references the real `mutation` stage id — honest about the *form* the rule checks, not about *occupancy* (no real work happens here; `run-mutation`, phase 16's real content, is that stage's actual future skill). Whoever writes phase 15/16's real skills should remove or repurpose `hello` rather than treat its stage reference as a precedent — see `.ai/phase-10/implementation-log.md` step 7 for the full reasoning.

`skills/` is otherwise still empty; the Plugin required CI job now runs `ai-flow skills lint .` for real, building the CLI from a sibling `ai-flow-cli` checkout since `cli_version` is still `"dev"`. `cli_version` stays `"dev"` until the first tagged release (phase 17).

Phase 11 adds `skills/hello/evals/fixtures/{happy_path,stop_and_ask,temptation}/status.json` — the three recorded handoff directories `hello`'s own `evals/evals.json` already named (`fixture: "fixtures/…"`) since phase 10, but that phase never created (its own lint shape check never reads the path). Each is a minimal, schema-conformant `status.json` with `"key": "PROJ-1"`. While building these, `evals.json`'s three queries were found to name no ticket key at all ("load the hello skill", …) — fixed by appending "for PROJ-1" to each, since the CLI's new `skills evals` harness (`internal/skills/evals.ExtractKey` in `ai-flow-cli`) reads the ticket key from the query's own free text, not from a separate field; `ai-flow skills lint .` still passes with zero findings after the edit (lint does not inspect query content). A new `.github/workflows/ci.yml` job, `plugin-evals`, runs `ai-flow skills evals .` — built from the same sibling `ai-flow-cli` checkout `plugin-required` already uses — gated to pull requests from non-fork branches only (`ANTHROPIC_API_KEY` is a repository secret no fork PR ever has access to; the CLI's own `skipped: true` behaviour on a missing key makes this `if:` belt-and-braces, not load-bearing) and uploads `results.json` as a build artifact. See `../ai-flow-cli/AGENTS.md`'s own phase 11 paragraph for the harness itself (`internal/skills/evals`), which lives entirely in the CLI repository — this repository's only phase 11 content is `hello`'s completed fixtures and the new CI job.
