# AGENTS.md — ai-flow

This repo is the **plugin** (skills, hooks) for Claude Code and Cursor. The CLI — the sole deterministic actor, which owns every side effect — is a sibling repository, `ai-flow-cli`.

- **Skill rules:** `docs/skill-authoring.md` — the authoring standard, with a lint rule id for every rule it states. `docs/terminology.json` is the fixed vocabulary it enforces. This is the authority for what a skill, a hook or a manifest field must look like; there is no separate design document to consult.
- **Hook contract:** `hooks/{claude-code.json,cursor.json,guard.sh,session-start.sh}` — the guardrail and session-start bindings for each host. Read these files directly before changing hook behavior.

## Pre-commit command

```
ai-flow skills lint .
```

(Once `internal/skills/lint` in the CLI repo and real skill content here both exist — `skills/` is currently empty.)

## What this repo owns

Skills carry judgement only and behave identically under both hosts. A skill never talks to Jira/GitHub/git/terraform/kubectl/helm directly, never hand-writes machine-readable state, and never decides which standards apply — it only calls `ai-flow <noun> <verb> --json` and reads the JSON envelope from stdout.

The two hook scripts (`hooks/guard.sh`, `hooks/session-start.sh`) are the only place this repo runs anything itself, and both are two-or-so lines that immediately hand off to `ai-flow hook …`.

## Repository status

Built so far: both plugin manifests (`.claude-plugin/`, `.cursor-plugin/`), the hook registration files and scripts (with their final event bindings — the `ai-flow hook …` commands they call don't exist in the CLI yet), `docs/terminology.json`, `docs/skill-authoring.md`. `skills/` is empty — no skills have been written yet. `cli_version` stays `"dev"` until the first tagged release.
