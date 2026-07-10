#!/bin/bash
# Tests for bin/mfactory-loop — the driver is exercised end to end with a fake
# harness ($MFACTORY_AGENT_CMD), never a real agent.
set -uo pipefail

LOOP="$(cd "$(dirname "$0")/../.." && pwd)/bin/mfactory-loop"
FAIL=0

check() { # $1 = case name, $2 = expected exit code, $3 = actual exit code
  if [ "$3" = "$2" ]; then
    echo "ok: $1"
  else
    echo "FAIL: $1 — expected exit $2, got $3." >&2
    echo "  Fix: mfactory-loop must exit $2 here; see the case in $0." >&2
    FAIL=1
  fi
}

mk_repo() { # a minimal fake product; prints its path
  r=$(mktemp -d)
  mkdir -p "$r/.mfactory/verbs"
  echo stub > "$r/.mfactory/verbs/build.md"
  echo stub > "$r/AGENTS.md"
  printf '%s' "$r"
}

mk_agent() { # $1 = repo, $2 = body of the fake agent (sees $n = call number)
  cat > "$1/agent" <<EOF
#!/bin/bash
d="\$(dirname "\$0")"
n=\$(( \$(cat "\$d/calls" 2>/dev/null || echo 0) + 1 ))
echo "\$n" > "\$d/calls"
$2
EOF
  chmod +x "$1/agent"
}

calls() { cat "$1/calls" 2>/dev/null || echo 0; }

# Continues twice, then stops: three cycles, clean exit, three logs.
R=$(mk_repo); mk_agent "$R" '
echo "cycle report body"
if [ "$n" -lt 3 ]; then echo "NEXT: continue"; else echo "NEXT: stop no ready work"; fi'
MFACTORY_AGENT_CMD="$R/agent" "$LOOP" --dir "$R" >/dev/null 2>&1
check "continue twice then clean stop" 0 $?
check "  … dispatched exactly 3 cycles" 3 "$(calls "$R")"
check "  … wrote one log per cycle" 3 "$(ls "$R/.mfactory/loop" | wc -l | tr -d ' ')"

# The emergency brake halts before any dispatch.
R=$(mk_repo); mk_agent "$R" 'echo "NEXT: continue"'
touch "$R/.mfactory/STOP"
MFACTORY_AGENT_CMD="$R/agent" "$LOOP" --dir "$R" >/dev/null 2>&1
check "STOP brake halts before dispatch" 2 $?
check "  … zero agents dispatched" 0 "$(calls "$R")"

# A report with no sentinel stops the loop fail-safe.
R=$(mk_repo); mk_agent "$R" 'echo "report without any sentinel"'
MFACTORY_AGENT_CMD="$R/agent" "$LOOP" --dir "$R" >/dev/null 2>&1
check "missing sentinel fails safe" 1 $?
check "  … stopped after the first cycle" 1 "$(calls "$R")"

# A sentinel-lookalike must not count.
R=$(mk_repo); mk_agent "$R" 'echo "NEXT: stopgap plan follows"'
MFACTORY_AGENT_CMD="$R/agent" "$LOOP" --dir "$R" >/dev/null 2>&1
check "sentinel lookalike (stopgap) fails safe" 1 $?

# The cycle cap is a leash: perpetual continue stops at the cap.
R=$(mk_repo); mk_agent "$R" 'echo "NEXT: continue"'
MFACTORY_AGENT_CMD="$R/agent" "$LOOP" --dir "$R" --max-cycles 2 >/dev/null 2>&1
check "cycle cap stops a runaway loop" 1 $?
check "  … dispatched exactly the cap" 2 "$(calls "$R")"

# An agent crash stops the loop with the log preserved.
R=$(mk_repo); mk_agent "$R" 'echo "boom"; exit 9'
MFACTORY_AGENT_CMD="$R/agent" "$LOOP" --dir "$R" >/dev/null 2>&1
check "agent crash stops the loop" 1 $?

# A directory without the build verb is refused up front.
R=$(mktemp -d)
"$LOOP" --dir "$R" >/dev/null 2>&1
check "missing build verb is refused" 1 $?

exit $FAIL
