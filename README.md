# ai-flow

A Claude Code / Cursor plugin for a deterministic ticket-to-PR pipeline. Skills carry judgement only; every side effect (tracker, git, git host, infra tools, test/mutation runners) goes through the [`ai-flow` CLI](../ai-flow-cli), a sibling Go binary this plugin's skills call exclusively through `ai-flow <noun> <verb> --json`.

## Install

**Claude Code**

```
/plugin install ai-flow@ai-flow-marketplace
```

**Cursor**

Import this repository as a team marketplace, or clone it to `~/.cursor/plugins/local/ai-flow`.

Either host installs the pinned `ai-flow` CLI release automatically on first use (`hooks/session-start.sh`); `ai-flow doctor` reports the plugin roots it found.

## What's here

- `skills/` — the stage and entry-point skills (`/develop`, `/ship`, and the judgement-carrying stages between them).
- `hooks/` — guardrail and session-start hooks, registered per host in `hooks/{claude-code,cursor}.json`.
- `docs/skill-authoring.md` — the authoring standard every skill is written against.

See [`AGENTS.md`](AGENTS.md) and [`docs/skill-authoring.md`](docs/skill-authoring.md) for how this repo is organized and the contract its skills are written against.
