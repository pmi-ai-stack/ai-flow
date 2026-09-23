#!/bin/sh
# Shared cli_version range helpers, sourced by session-start.sh and by
# CI's install-pinned-cli composite action, so the comparison logic
# exists in exactly one place — a plugin install and a CI job must never
# disagree about what "in range" means. Not a hook itself; nothing here
# reads a hook payload. Functions only: source this file, don't run it.
set -eu

# read_cli_version MANIFEST: prints the manifest's metadata.cli_version
# field — the one place this extraction lives, so a plugin install and
# a CI job read the same value the same way.
read_cli_version() {
	sed -n 's/.*"cli_version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$1" | head -n1
}

# version_num V: strips a leading "v" so "v0.1.0" and "0.1.0" compare
# equal — release tags carry it, `ai-flow version`'s own output and the
# manifest's cli_version clauses never do.
version_num() {
	echo "${1#v}"
}

# version_cmp A B: prints -1, 0 or 1 comparing two dotted, 1-to-3
# component numeric versions (a missing component counts as 0, so
# "0.2" > "0.1.9"). Not general semver — pre-release/build suffixes are
# never produced by this project's own release tags — just enough to
# compare what cli_version and `ai-flow version` actually contain.
version_cmp() {
	awk -v a="$(version_num "$1")" -v b="$(version_num "$2")" '
		function parts(v,    arr) {
			split(v, arr, ".")
			return (arr[1] + 0) * 1000000 + (arr[2] + 0) * 1000 + (arr[3] + 0)
		}
		BEGIN {
			na = parts(a); nb = parts(b)
			if (na > nb) { print 1 } else if (na < nb) { print -1 } else { print 0 }
		}'
}

# range_satisfied VERSION RANGE: RANGE is this project's own cli_version
# shape — one or more space-separated "<op><version>" clauses
# (">=0.1 <0.2"), every clause required to hold. Anything this function
# does not recognize (including "dev", and any future range syntax this
# script has not been taught) is treated as satisfied rather than
# blocking a session or a CI run — the same fail-open principle the
# CLI's guard table already applies to an unrecognized hook payload
# shape.
range_satisfied() {
	version="$1"
	range="$2"
	# shellcheck disable=SC2086 # word-splitting the range into its clauses is intentional
	for clause in $range; do
		case "$clause" in
		">="*) op=">=" ver="${clause#>=}" ;;
		"<="*) op="<=" ver="${clause#<=}" ;;
		">"*) op=">" ver="${clause#>}" ;;
		"<"*) op="<" ver="${clause#<}" ;;
		"="*) op="=" ver="${clause#=}" ;;
		*)
			echo "cli-version.sh: unrecognized cli_version clause '${clause}', treating as satisfied" >&2
			return 0
			;;
		esac
		cmp="$(version_cmp "$version" "$ver")"
		case "${op}:${cmp}" in
		">=:0" | ">=:1") ;;
		"<=:0" | "<=:-1") ;;
		">:1") ;;
		"<:-1") ;;
		"=:0") ;;
		*) return 1 ;;
		esac
	done
	return 0
}

# resolve_pinned_tag RANGE: prints the highest published ai-flow-cli
# release tag satisfying RANGE, or nothing when none can be determined
# (offline, rate-limited, or no matching release yet) — the caller
# decides what to do about an empty result. Looks at only the newest 100
# releases (GitHub's default page order is newest-first); not paginated
# further, since a range with no match in the 100 most recent releases
# is far outside this project's current, single-digit release count.
resolve_pinned_tag() {
	range="$1"
	best=""
	tags="$(curl -fsSL "https://api.github.com/repos/pmi-ai-stack/ai-flow-cli/releases?per_page=100" 2>/dev/null | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' || true)"
	for tag in $tags; do
		case "$tag" in
		v[0-9]*.[0-9]*.[0-9]*) ;;
		*) continue ;;
		esac
		if range_satisfied "$tag" "$range" && { [ -z "$best" ] || [ "$(version_cmp "$tag" "$best")" = "1" ]; }; then
			best="$tag"
		fi
	done
	echo "$best"
}
