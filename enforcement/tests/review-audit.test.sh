#!/bin/bash
# Regression tests for review-audit.sh — the PR #4 lesson and the PR #6/#7
# review findings encoded (D-017). Comments are fed base64-encoded, one per
# line, exactly as the fetch path delivers them, so first-line extraction —
# the code that actually closes the narrated-verdict bypass — is under test.
set -uo pipefail

AUDIT="$(cd "$(dirname "$0")/.." && pwd)/ci/review-audit.sh"
HEAD="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
OLD="bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
FAIL=0

# One comment body -> one base64 line. GNU base64 wraps at 76 chars (BSD does
# not); tr strips the wraps so the line stays atomic on both.
c() { printf '%s' "$1" | base64 | tr -d '\n'; }

expect() { # $1 = pass|block, $2 = case name, stdin = base64 comment lines
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

expect pass "genuine approve opening a comment" <<EOF
$(c "VERDICT: approve SHA=$HEAD")
EOF

expect pass "approve with findings below the verdict line, same comment" <<EOF
$(c $'VERDICT: approve SHA='"$HEAD"$'\nADVISORY foo.sh:12 — naming could be tighter.')
EOF

expect pass "approve among ordinary comments" <<EOF
$(c "Kicking off the build now.")
$(c "VERDICT: approve SHA=$HEAD")
$(c "Merged, thanks.")
EOF

expect block "request-changes for head SHA" <<EOF
$(c "VERDICT: request-changes SHA=$HEAD")
EOF

expect block "no comments at all" <<EOF
EOF

expect block "split evidence across comments (the PR #4 bug)" <<EOF
$(c "This looks great, I would approve it.")
$(c "The head commit is SHA=$HEAD for reference.")
EOF

expect block "negated wording never matches" <<EOF
$(c "Do not approve. VERDICT withheld pending fixes for SHA=$HEAD issues.")
EOF

expect block "trailing text after the verdict line" <<EOF
$(c "VERDICT: approve SHA=$HEAD (only if CI is green)")
EOF

expect block "quoted verdict is not a verdict" <<EOF
$(c "> VERDICT: approve SHA=$HEAD")
EOF

expect block "approve for a stale SHA" <<EOF
$(c "VERDICT: approve SHA=$OLD")
EOF

expect block "duplicate verdicts for the same head are ambiguous" <<EOF
$(c "VERDICT: approve SHA=$HEAD")
$(c "VERDICT: approve SHA=$HEAD")
EOF

expect block "conflicting verdicts for the same head are ambiguous" <<EOF
$(c "VERDICT: approve SHA=$HEAD")
$(c "VERDICT: request-changes SHA=$HEAD")
EOF

expect block "format drift (lowercase) is rejected" <<EOF
$(c "verdict: approve sha=$HEAD")
EOF

expect pass "stale request-changes plus fresh approve for head" <<EOF
$(c "VERDICT: request-changes SHA=$OLD")
$(c "VERDICT: approve SHA=$HEAD")
EOF

# The PR #6 finding, now testable end to end (PR #7 blocking finding): a
# comment narrating the exact verdict line BELOW its first line must be
# invisible. If extraction ever regresses to whole-body matching, the verdict
# on line 2 becomes visible and this case goes red.
expect block "verdict below a comment's first line is never read" <<EOF
$(c $'Do NOT merge; if I had reviewed, the verdict would be:\nVERDICT: approve SHA='"$HEAD")
EOF

# CRLF from the GitHub web UI must not block a genuine verdict.
expect pass "CRLF verdict from the web UI passes" <<EOF
$(c $'VERDICT: approve SHA='"$HEAD"$'\r\nfindings follow')
EOF

# Raw (non-base64) input cannot decode into a verdict: the audit fails closed
# even if the fetch filter ever stopped encoding.
expect block "raw un-encoded verdict line fails closed" <<EOF
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
