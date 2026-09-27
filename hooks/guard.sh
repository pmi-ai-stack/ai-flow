#!/bin/sh
# Two lines of logic, unconditionally (spec's own words) — see
# session-start.sh's own comment block for the Windows posture both
# scripts share: on a stock Windows install with neither Git Bash nor
# PowerShell 7 present, the host cannot spawn a POSIX shell at all and
# reports a non-blocking hook error while allowing the tool call
# through, exactly the guard's own already-decided fail-open design
# (spec v7 decision: "the guard is scoped ... and fails open, because
# it prevents accidents while the gates do the enforcing"). Phase 30
# decided not to ship a .cmd/PowerShell twin: see
# .ai/phase-30/plan.md's own Windows section for the evidence and the
# reasoning against maintaining two parallel implementations of
# session-start.sh's own version-comparison logic.
command -v ai-flow >/dev/null 2>&1 || exit 0
exec ai-flow hook guard
