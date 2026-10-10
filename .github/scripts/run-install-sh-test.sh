#!/bin/sh
# run-install-sh-test.sh PLUGIN_ROOT
#
# Proves hooks/cli-version.sh's run_install_sh passes install.sh's -s
# exactly when AI_FLOW_REQUIRE_SIGNATURE=1, and never otherwise. curl is
# stubbed to write an install.sh that echoes its own arguments, so no
# network is touched and the flags run_install_sh passes are visible.
set -eu
ROOT="$1"
STUB="$(mktemp -d)"
cat > "$STUB/curl" <<'C'
#!/bin/sh
while [ $# -gt 0 ]; do case "$1" in -o) out="$2"; shift 2;; *) shift;; esac; done
printf 'echo "ARGS:$*"\n' > "$out"
C
chmod +x "$STUB/curl"
PATH="$STUB:$PATH"
. "$ROOT/hooks/cli-version.sh"
fail=0
got="$(AI_FLOW_REQUIRE_SIGNATURE='' run_install_sh -v v0.3.0)"; [ "$got" = "ARGS:-v v0.3.0" ] || { echo "default: got '$got'"; fail=1; }
got="$(AI_FLOW_REQUIRE_SIGNATURE=1 run_install_sh -v v0.3.0)"; [ "$got" = "ARGS:-s -v v0.3.0" ] || { echo "required: got '$got'"; fail=1; }
got="$(AI_FLOW_REQUIRE_SIGNATURE=1 run_install_sh)"; [ "$got" = "ARGS:-s" ] || { echo "required, no args: got '$got'"; fail=1; }
rm -rf "$STUB"
[ "$fail" -eq 0 ] && echo PASS || { echo FAIL; exit 1; }
