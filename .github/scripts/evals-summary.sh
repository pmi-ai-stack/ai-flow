#!/bin/sh
# evals-summary.sh ENVELOPE RESULTS_JSON TITLE
#
# Writes one unmistakable verdict for a `skills evals` run to
# $GITHUB_STEP_SUMMARY (stdout when unset): SKIPPED, PASSED or FAILED,
# never a green tick for a run in which nothing ran. "Skipped" covers
# both a missing ANTHROPIC_API_KEY (result.skipped) and a run whose
# every scenario was skipped — the summary's pass rate is a vacuous
# 100% then, which is exactly the false comfort this script exists to
# prevent (improvement plan item 4.1).
set -eu

envelope="$1"
results="$2"
title="$3"
out="${GITHUB_STEP_SUMMARY:-/dev/stdout}"

say() { printf '%s\n' "$*" >> "$out"; }

skill_table() {
  [ -s "$results" ] || return 0
  say ""
  say "| Skill | Pass rate | Ran | Skipped |"
  say "| --- | --- | --- | --- |"
  jq -r '.skills[] | "| \(.skill) | \((.pass_rate * 100) | floor)% | \([.scenarios[] | select(.skipped | not)] | length) | \([.scenarios[] | select(.skipped)] | length) |"' "$results" >> "$out"
}

if [ ! -s "$envelope" ]; then
  say "### ❌ $title — FAILED: no envelope (the command did not run)"
  exit 0
fi

if [ "$(jq -r '.ok' "$envelope")" != "true" ]; then
  say "### ❌ $title — FAILED ($(jq -r '.error.code' "$envelope"))"
  say ""
  say "$(jq -r '.error.message' "$envelope")"
  jq -r '.error.details // [] | .[] | "- \(.)"' "$envelope" >> "$out"
  skill_table
  exit 0
fi

if [ "$(jq -r '.result.skipped' "$envelope")" = "true" ]; then
  say "### ⚠️ $title — SKIPPED: $(jq -r '.result.skip_reason' "$envelope")"
  say ""
  say "No scenario ran. This run says nothing about whether the skills work."
  exit 0
fi

ran="$(jq '[.result.skills[].scenarios[] | select(.skipped | not)] | length' "$envelope")"
skipped="$(jq '[.result.skills[].scenarios[] | select(.skipped)] | length' "$envelope")"
if [ "$ran" -eq 0 ]; then
  reasons="$(jq -r '[.result.skills[].scenarios[].skip_reason // empty] | unique | join("; ")' "$envelope")"
  say "### ⚠️ $title — SKIPPED: every scenario was skipped ($reasons)"
  say ""
  say "No scenario ran. This run says nothing about whether the skills work."
  exit 0
fi

rate="$(jq -r '(.result.pass_rate * 100) | floor' "$envelope")"
say "### ✅ $title — PASSED: ${rate}% over $ran scenario(s), $skipped skipped"
skill_table
