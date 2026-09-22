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
