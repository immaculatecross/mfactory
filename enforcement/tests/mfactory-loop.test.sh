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
contains() { # $1 = case name, $2 = file, $3 = fixed string
  if grep -qF -- "$3" "$2"; then
    echo "ok: $1"
  else
    echo "FAIL: $1 — '$3' not found in $2." >&2
    echo "  Fix: preserve and assert the required output in this test." >&2
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
echo "\$\$" >> "\$d/dispatches"
$2
EOF
  chmod +x "$1/agent"
}
calls() { cat "$1/calls" 2>/dev/null || echo 0; }
dispatches() {
  if [ -f "$1/dispatches" ]; then wc -l < "$1/dispatches" | tr -d ' '; else echo 0; fi
}
# Continues twice, then stops: three cycles, clean exit, three complete logs.
R=$(mk_repo); mk_agent "$R" '
echo "cycle report body"
echo "cycle diagnostic on stderr" >&2
if [ "$n" -lt 3 ]; then echo "NEXT: continue"; else echo "NEXT: stop no ready work"; fi'
MFACTORY_AGENT_CMD="$R/agent" "$LOOP" --dir "$R" >/dev/null 2>&1
check "continue twice then clean stop" 0 $?
check "  … dispatched exactly 3 cycles" 3 "$(calls "$R")"
check "  … wrote one log per cycle" 3 "$(ls "$R/.mfactory/loop" | wc -l | tr -d ' ')"
for f in "$R"/.mfactory/loop/*cycle1*; do FIRST_LOG="$f"; break; done
contains "  … log preserves agent stdout" "$FIRST_LOG" "cycle report body"
contains "  … log preserves agent stderr" "$FIRST_LOG" "cycle diagnostic on stderr"
contains "  … log preserves the sentinel" "$FIRST_LOG" "NEXT: continue"
# A fixed timestamp across separate invocations must still produce unique logs.
R=$(mk_repo); mk_agent "$R" 'echo "NEXT: stop done"'
mkdir "$R/fake-bin"
cat > "$R/fake-bin/date" <<'EOF'
#!/bin/bash
echo 20260710-200000
EOF
chmod +x "$R/fake-bin/date"
PATH="$R/fake-bin:$PATH" MFACTORY_AGENT_CMD="$R/agent" "$LOOP" --dir "$R" >/dev/null 2>&1
PATH="$R/fake-bin:$PATH" MFACTORY_AGENT_CMD="$R/agent" "$LOOP" --dir "$R" >/dev/null 2>&1
check "rapid invocations keep both cycle logs" 2 "$(ls "$R/.mfactory/loop" | wc -l | tr -d ' ')"
# Two gated processes race lock acquisition; exactly one may dispatch.
R=$(mk_repo); mk_agent "$R" '
touch "$d/started"
while [ ! -e "$d/release" ]; do sleep 0.05; done
echo "NEXT: stop released"'
(while [ ! -e "$R/go" ]; do sleep 0.01; done
 MFACTORY_AGENT_CMD="$R/agent" "$LOOP" --dir "$R") >/dev/null 2>"$R/one-err" &
ONE_PID=$!
(while [ ! -e "$R/go" ]; do sleep 0.01; done
 MFACTORY_AGENT_CMD="$R/agent" "$LOOP" --dir "$R") >/dev/null 2>"$R/two-err" &
TWO_PID=$!
touch "$R/go"
N=0
while [ ! -e "$R/started" ] && [ "$N" -lt 100 ]; do sleep 0.05; N=$((N + 1)); done
sleep 0.1; touch "$R/release"
wait "$ONE_PID"; ONE_STATUS=$?
wait "$TWO_PID"; TWO_STATUS=$?
case "$ONE_STATUS:$TWO_STATUS" in
  0:1) RESULT=pass; LOCK_ERR="$R/two-err" ;;
  1:0) RESULT=pass; LOCK_ERR="$R/one-err" ;;
  *)   RESULT=fail; LOCK_ERR="$R/one-err" ;;
esac
check "simultaneous drivers produce one success and one block" pass "$RESULT"
check "  … only one Foreman was dispatched" 1 "$(dispatches "$R")"
contains "  … active-lock failure states its fix" "$LOCK_ERR" "Fix:"
[ ! -e "$R/.mfactory/loop.lock" ]
check "  … clean exit releases the lock" 0 $?
# A termination signal reaches the agent and releases repository ownership.
R=$(mk_repo); mk_agent "$R" '
trap "" TERM
touch "$d/started"
while :; do sleep 1; done'
MFACTORY_AGENT_CMD="$R/agent" "$LOOP" --dir "$R" >/dev/null 2>"$R/err" &
LOOP_PID=$!
N=0
while [ ! -e "$R/started" ] && [ "$N" -lt 100 ]; do sleep 0.05; N=$((N + 1)); done
kill -TERM "$LOOP_PID"
wait "$LOOP_PID"; check "TERM stops the active driver" 143 $?
[ ! -e "$R/.mfactory/loop.lock" ]; check "  … TERM releases the lock" 0 $?
# A stale lock fails closed and explains the manual recovery.
R=$(mk_repo); mk_agent "$R" 'echo "NEXT: stop must not run"'
mkdir "$R/.mfactory/loop.lock"
echo 99999999 > "$R/.mfactory/loop.lock/pid"
MFACTORY_AGENT_CMD="$R/agent" "$LOOP" --dir "$R" >/dev/null 2>"$R/err"
check "stale lock blocks dispatch" 1 $?
check "  … stale lock dispatches no Foreman" 0 "$(dispatches "$R")"
contains "  … stale-lock failure names the state" "$R/err" "stale mfactory loop lock"
contains "  … stale-lock failure states its fix" "$R/err" "Fix:"
# The emergency brake halts before any dispatch.
R=$(mk_repo); mk_agent "$R" 'echo "NEXT: continue"'
touch "$R/.mfactory/STOP"
MFACTORY_AGENT_CMD="$R/agent" "$LOOP" --dir "$R" >/dev/null 2>"$R/err"
check "STOP brake halts before dispatch" 2 $?
check "  … zero agents dispatched" 0 "$(calls "$R")"
contains "  … STOP failure states its fix" "$R/err" "Fix:"
contains "  … STOP fix names the target repo" "$R/err" "rm -- $R/.mfactory/STOP"
# A report with no sentinel stops the loop fail-safe.
R=$(mk_repo); mk_agent "$R" 'echo "report without any sentinel"'
MFACTORY_AGENT_CMD="$R/agent" "$LOOP" --dir "$R" >/dev/null 2>"$R/err"
check "missing sentinel fails safe" 1 $?
check "  … stopped after the first cycle" 1 "$(calls "$R")"
contains "  … missing-sentinel failure states its fix" "$R/err" "Fix:"
# A sentinel-lookalike must not count.
R=$(mk_repo); mk_agent "$R" 'echo "NEXT: stopgap plan follows"'
MFACTORY_AGENT_CMD="$R/agent" "$LOOP" --dir "$R" >/dev/null 2>"$R/err"
check "sentinel lookalike (stopgap) fails safe" 1 $?
contains "  … lookalike failure states its fix" "$R/err" "Fix:"
# The protocol is exactly one sentinel, on the final line, with a stop reason.
R=$(mk_repo); mk_agent "$R" 'echo "NEXT: stop done"; echo "trailing output"'
MFACTORY_AGENT_CMD="$R/agent" "$LOOP" --dir "$R" >/dev/null 2>"$R/err"
check "output after a sentinel fails safe" 1 $?
contains "  … trailing-output failure states its fix" "$R/err" "Fix:"
R=$(mk_repo); mk_agent "$R" 'echo "NEXT: continue"; echo "NEXT: stop conflict"'
MFACTORY_AGENT_CMD="$R/agent" "$LOOP" --dir "$R" >/dev/null 2>"$R/err"
check "conflicting sentinels fail safe" 1 $?
contains "  … conflicting-sentinel failure states its fix" "$R/err" "Fix:"
R=$(mk_repo); mk_agent "$R" 'echo "NEXT: stop"'
MFACTORY_AGENT_CMD="$R/agent" "$LOOP" --dir "$R" >/dev/null 2>"$R/err"
check "bare stop without a reason fails safe" 1 $?
contains "  … bare-stop failure states its fix" "$R/err" "Fix:"
R=$(mk_repo); mk_agent "$R" 'printf "NEXT: stop valid reason\nNEXT: stop   \n"'
MFACTORY_AGENT_CMD="$R/agent" "$LOOP" --dir "$R" >/dev/null 2>"$R/err"
check "valid then whitespace-only final stop fails safe" 1 $?
R=$(mk_repo); mk_agent "$R" 'printf "NEXT: stop \t\t\n"'
MFACTORY_AGENT_CMD="$R/agent" "$LOOP" --dir "$R" >/dev/null 2>"$R/err"
check "tab-only stop reason fails safe" 1 $?
# The harness contract accepts an executable path containing spaces.
R=$(mk_repo)
mkdir "$R/harness with spaces"
cat > "$R/harness with spaces/agent" <<'EOF'
#!/bin/bash
echo "NEXT: stop spaced path works"
EOF
chmod +x "$R/harness with spaces/agent"
MFACTORY_AGENT_CMD="$R/harness with spaces/agent" "$LOOP" --dir "$R" >/dev/null 2>"$R/err"
check "spaced harness executable path works" 0 $?
# The cycle cap is a leash: perpetual continue stops at the cap.
R=$(mk_repo); mk_agent "$R" 'echo "NEXT: continue"'
MFACTORY_AGENT_CMD="$R/agent" "$LOOP" --dir "$R" --max-cycles 2 >/dev/null 2>"$R/err"
check "cycle cap stops a runaway loop" 1 $?
check "  … dispatched exactly the cap" 2 "$(calls "$R")"
contains "  … cycle-cap failure states its fix" "$R/err" "Fix:"
# An agent crash stops the loop with the log preserved.
R=$(mk_repo); mk_agent "$R" 'echo "boom on stdout"; echo "boom on stderr" >&2; exit 9'
MFACTORY_AGENT_CMD="$R/agent" "$LOOP" --dir "$R" >/dev/null 2>"$R/err"
check "agent crash stops the loop" 1 $?
contains "  … crash failure states its fix" "$R/err" "Fix:"
for f in "$R"/.mfactory/loop/*; do CRASH_LOG="$f"; break; done
contains "  … crash log preserves stdout" "$CRASH_LOG" "boom on stdout"
contains "  … crash log preserves stderr" "$CRASH_LOG" "boom on stderr"
# A directory without the build verb is refused up front.
R=$(mktemp -d)
"$LOOP" --dir "$R" >/dev/null 2>"$R/err"
check "missing build verb is refused" 1 $?
contains "  … missing-verb failure states its fix" "$R/err" "Fix:"
# Missing option values must fail through die(), not Bash parameter expansion.
R=$(mktemp -d)
"$LOOP" --dir >/dev/null 2>"$R/dir-err"
check "missing --dir value is refused" 1 $?
contains "  … missing --dir value states its fix" "$R/dir-err" "Fix:"
"$LOOP" --max-cycles >/dev/null 2>"$R/max-err"
check "missing --max-cycles value is refused" 1 $?
contains "  … missing --max-cycles value states its fix" "$R/max-err" "Fix:"
exit $FAIL
