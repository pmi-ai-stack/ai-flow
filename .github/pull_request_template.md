## What and why

<!-- One logical change. Link the phase record: .ai/phase-N/plan.md in the workspace. -->

## Checklist

The spec's Working agreement (`spec-v7/ai-flow-implementation-spec.md` §Working agreement), as review items.

- [ ] `ai-flow skills lint .` reports 0 findings
- [ ] `ai-flow hook selftest --host claude-code` and `--host cursor` pass
- [ ] A skill change carries the skill, its references and its three evals (happy path, stop-and-ask, temptation)
- [ ] Skills are written against real `--json` output, not an assumed shape
- [ ] An addon skill has its Go package of the same name in `ai-flow-cli`
- [ ] If this needs new CLI behaviour: the required CLI version is named and `cli_version` in both manifests is bumped
- [ ] Hook scripts pass shellcheck
- [ ] Commits are one logical change each
