#!/bin/sh
# The only plugin script with logic, because it runs before the CLI is
# known to exist: compares `ai-flow version`'s own reported version
# against the manifest's cli_version range ("dev" accepts any binary on
# PATH), installs a release satisfying that range through
# ai-flow-cli's install.sh when missing or out of range, then execs the
# CLI's own session-start hook. The range-comparison functions live in
# the sibling hooks/cli-version.sh, shared with CI's own use of the same
# comparison (see ../.github/workflows/ci.yml).
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

# shellcheck source=./cli-version.sh
. "$PLUGIN_ROOT/hooks/cli-version.sh"

cli_version_wanted="$(read_cli_version "$MANIFEST")"

install_needed=0
if ! command -v ai-flow >/dev/null 2>&1; then
	install_needed=1
elif [ "$cli_version_wanted" != "dev" ]; then
	installed_version="$(ai-flow version --json 2>/dev/null | sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"
	if [ -z "$installed_version" ] || ! range_satisfied "$installed_version" "$cli_version_wanted"; then
		install_needed=1
	fi
fi

if [ "$install_needed" -eq 1 ]; then
	install_rc=0
	if [ "$cli_version_wanted" = "dev" ]; then
		echo "session-start.sh: ai-flow not found on PATH, installing latest" >&2
		run_install_sh || install_rc=$?
	else
		pinned_tag="$(resolve_pinned_tag "$cli_version_wanted")"
		if [ -n "$pinned_tag" ]; then
			echo "session-start.sh: installing ai-flow ${pinned_tag} (cli_version ${cli_version_wanted})" >&2
			run_install_sh -v "$pinned_tag" || install_rc=$?
		else
			echo "session-start.sh: could not resolve a released ai-flow-cli version matching cli_version '${cli_version_wanted}'; installing latest instead" >&2
			run_install_sh || install_rc=$?
		fi
	fi
	if [ "$install_rc" -ne 0 ]; then
		# An out-of-range binary still on PATH beats none: keep the
		# session usable and say why. With nothing on PATH there is no
		# CLI to exec, so fail here, at the cause.
		if command -v ai-flow >/dev/null 2>&1; then
			echo "session-start.sh: installing ai-flow failed; continuing with $(command -v ai-flow), which does not satisfy cli_version '${cli_version_wanted}'" >&2
		else
			echo "session-start.sh: installing ai-flow failed and no ai-flow is on PATH; see the install.sh output above" >&2
			exit 1
		fi
	fi
fi

exec ai-flow hook session-start --plugin-root "$PLUGIN_ROOT"
