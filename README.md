# ai-flow

A Claude Code / Cursor plugin for a deterministic ticket-to-PR pipeline. Skills carry judgement only; every side effect (tracker, git, git host, infra tools, test/mutation runners) goes through the [`ai-flow` CLI](../ai-flow-cli), a sibling Go binary this plugin's skills call exclusively through `ai-flow <noun> <verb> --json`.

## Install

Either host installs the pinned `ai-flow` CLI release automatically on first use (`hooks/session-start.sh`, resolved against the manifest's `cli_version` range); `ai-flow doctor` reports the plugin roots it found. Nothing below needs a manual CLI install first. The release's checksum is always verified; its cosign signature is verified when `cosign` is on PATH, and `export AI_FLOW_REQUIRE_SIGNATURE=1` makes that check mandatory (the install fails without `cosign`) instead of falling back to the checksum alone.

**Claude Code — plugin**

```
/plugin install ai-flow@ai-flow-marketplace
```

See [Invocation](#invocation) below for how skills are typed after this install.

**Cursor — plugin**

Either import this repository as a team marketplace (share the repository URL with your team's Cursor marketplace settings), or clone it directly:

```sh
git clone https://github.com/pmi-ai-stack/ai-flow ~/.cursor/plugins/local/ai-flow
```

**Skills-directory install (no plugin, either host)**

For a checkout with no plugin wrapper — a monorepo that vendors skills directly, or a host version that does not yet support this plugin format — copy the skills in with the CLI itself, then wire the hooks the same way:

```sh
ai-flow skills install --from ai-flow --into .claude/skills   # serves both Claude Code and Cursor
ai-flow skills install --from ai-flow --into .agents/skills   # Cursor-only form
ai-flow hooks install --host claude-code --scope project      # or --host cursor
```

`--from` is this repository's root (a directory holding a `skills/` subdirectory), not `skills/` itself. Skills installed this way are invoked bare — `/develop KEY`, `/ship KEY` — with no plugin name to prefix, since there is no plugin manifest wrapping them.

## Invocation

A skill's own body never names a prefix or a slash — every skill reads "the ticket key the developer typed" and nothing else (`ai-flow skills lint` enforces this). What the developer actually types depends on how it was installed:

| Install | Invocation |
| --- | --- |
| Claude Code plugin | `/ai-flow:develop KEY` (skills are namespaced under the plugin's own name) |
| Claude Code skills-directory (`.claude/skills`) | `/develop KEY` |
| Cursor plugin | `/develop KEY` in most cases; Cursor's own namespacing behavior for plugin-installed skills has not been verified against a real Cursor session in this development environment — confirm locally before relying on either form |
| Cursor skills-directory (`.agents/skills` or `.claude/skills`) | `/develop KEY` |

`develop` (`disable-model-invocation: true`) drives the whole pipeline from `fetch` to `output`; `ship` takes it from an approved plan through the opened PR. Every stage in between loads its own skill automatically — `develop` names it, the developer never invokes it directly.

## Local development

```sh
# build the CLI this plugin's skills call
cd ../ai-flow-cli && go build -o dist/ai-flow ./cmd/ai-flow && export PATH="$PWD/dist:$PATH"
cd ../ai-flow

ai-flow skills lint .                 # the pre-commit command (see AGENTS.md)
ai-flow skills evals . --out /tmp/evals   # needs ANTHROPIC_API_KEY; skips cleanly without one
```

`cli_version` in both manifests (`.claude-plugin/plugin.json`, `.cursor-plugin/plugin.json`) is `"dev"` on a local build (any binary on PATH is accepted) or a pinned range once released (`">=0.1 <0.2"` as of `0.1.0`, `">=0.2 <0.3"` as of `0.2.0`) — `ai-flow skills lint .` reads the same binary either way, since the lint rules come from `Catalog()`/`StageTable()`, not from the manifest. A binary that reports itself as `dev` (any local `go build`) satisfies every range too, so `session-start.sh` never replaces a developer's own build with a release.

## Release process

A release is a tag `vX.Y.Z` pushed after a commit that bumps `version` in **both** manifests to `X.Y.Z` — the release workflow (`.github/workflows/release.yml`) verifies the tag matches before packaging, rather than writing the bump itself, so a git checkout pinned to the tag is always correct on its own.

`hooks/cli-version.sh`'s `INSTALL_SH_SHA` pins the `ai-flow-cli` `install.sh` that `session-start.sh` and CI download to one commit. Bump it in the same change as any `install.sh` change in `ai-flow-cli`, or bootstrap keeps running the older script.

## What's here

- `skills/` — the stage and entry-point skills (`develop`, `ship`, and the judgement-carrying stages between them).
- `hooks/` — guardrail and session-start hooks, registered per host in `hooks/{claude-code,cursor}.json`; `hooks/cli-version.sh` is the shared `cli_version`-range comparator `session-start.sh` and CI both use.
- `docs/skill-authoring.md` — the authoring standard every skill is written against.

See [`AGENTS.md`](AGENTS.md) and [`docs/skill-authoring.md`](docs/skill-authoring.md) for how this repo is organized and the contract its skills are written against.
