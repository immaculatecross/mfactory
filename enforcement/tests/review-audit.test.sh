#!/bin/bash
# Regression tests for review-audit.sh — the PR #4 lesson encoded (D-017).
# Every false approval the isolated reviewer found on PR #4 is a case here.
set -uo pipefail

AUDIT="$(cd "$(dirname "$0")/.." && pwd)/ci/review-audit.sh"
HEAD="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
OLD="bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
FAIL=0

expect() { # $1 = pass|block, $2 = case name, stdin = comment bodies
  input=$(cat)
  if printf '%s\n' "$input" | "$AUDIT" --stdin "$HEAD" >/dev/null 2>&1; then
    got=pass
  else
    got=block
  fi
  if [ "$got" = "$1" ]; then
    echo "ok: $2"
  else
    echo "FAIL: $2 — expected $1, got $got." >&2
    echo "  Fix: review-audit.sh must $1 this input; see the case in $0." >&2
    FAIL=1
  fi
}

expect pass "genuine approve for head SHA" <<EOF
VERDICT: approve SHA=$HEAD
Tried hardest to break the SHA parsing; could not.
EOF

expect pass "approve with findings below the verdict line" <<EOF
VERDICT: approve SHA=$HEAD
ADVISORY foo.sh:12 — naming could be tighter.
EOF

expect block "request-changes for head SHA" <<EOF
VERDICT: request-changes SHA=$HEAD
BLOCKING bar.sh:3 — test cannot fail.
EOF

expect block "no comments at all" <<EOF
EOF

expect block "split evidence across comments (the PR #4 bug)" <<EOF
This looks great, I would approve it.
The head commit is SHA=$HEAD for reference.
EOF

expect block "negated wording never matches" <<EOF
Do not approve. VERDICT withheld pending fixes for SHA=$HEAD issues.
EOF

expect block "trailing text after the verdict line" <<EOF
VERDICT: approve SHA=$HEAD (only if CI is green)
EOF

expect block "leading text before the verdict line" <<EOF
> VERDICT: approve SHA=$HEAD
EOF

expect block "approve for a stale SHA" <<EOF
VERDICT: approve SHA=$OLD
EOF

expect block "duplicate verdicts for the same head are ambiguous" <<EOF
VERDICT: approve SHA=$HEAD
VERDICT: approve SHA=$HEAD
EOF

expect block "conflicting verdicts for the same head are ambiguous" <<EOF
VERDICT: approve SHA=$HEAD
VERDICT: request-changes SHA=$HEAD
EOF

expect block "format drift (lowercase) is rejected" <<EOF
verdict: approve sha=$HEAD
EOF

expect pass "stale request-changes plus fresh approve for head" <<EOF
VERDICT: request-changes SHA=$OLD
VERDICT: approve SHA=$HEAD
EOF

if "$AUDIT" --stdin "not-a-sha" </dev/null >/dev/null 2>&1; then
  echo "FAIL: malformed head SHA accepted." >&2
  echo "  Fix: review-audit.sh must reject any head that is not 40 hex chars." >&2
  FAIL=1
else
  echo "ok: malformed head SHA rejected"
fi

exit $FAIL
