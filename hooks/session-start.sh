#!/bin/sh
# The only plugin script with logic, because it runs before the CLI is
# known to exist: compares `ai-flow version` with the manifest's
# cli_version ("dev" accepts any binary on PATH), installs the pinned
# release through ai-flow-cli's install.sh when missing or out of range,
# then execs the CLI's own session-start hook.
#
# `ai-flow hook session-start` is implemented once the CLI's `hook`
# command family exists. Until then this script's last line fails, which
# is expected: it is registered with its real, final event bindings
# from day one, and only reaches this line once `ai-flow` is confirmed
# present on PATH above.
set -eu

if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
	PLUGIN_ROOT="$CLAUDE_PLUGIN_ROOT"
	MANIFEST="$PLUGIN_ROOT/.claude-plugin/plugin.json"
elif [ -n "${CURSOR_PLUGIN_ROOT:-}" ]; then
	PLUGIN_ROOT="$CURSOR_PLUGIN_ROOT"
	MANIFEST="$PLUGIN_ROOT/.cursor-plugin/plugin.json"
else
	echo "session-start.sh: neither CLAUDE_PLUGIN_ROOT nor CURSOR_PLUGIN_ROOT is set" >&2
	exit 1
fi

cli_version_wanted="$(sed -n 's/.*"cli_version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$MANIFEST" | head -n1)"

install_needed=0
if ! command -v ai-flow >/dev/null 2>&1; then
	install_needed=1
elif [ "$cli_version_wanted" != "dev" ]; then
	# TODO(phase 17/29): once cli_version moves off "dev" to a real
	# semver range, check `ai-flow version`'s output against it here and
	# set install_needed=1 when it is out of range. Until then every
	# release stays "dev" and any binary on PATH is accepted.
	install_needed=0
fi

if [ "$install_needed" -eq 1 ]; then
	echo "session-start.sh: ai-flow not found on PATH, installing" >&2
	curl -fsSL https://raw.githubusercontent.com/pmi-ai-stack/ai-flow-cli/main/install.sh | sh
fi

exec ai-flow hook session-start --plugin-root "$PLUGIN_ROOT"
