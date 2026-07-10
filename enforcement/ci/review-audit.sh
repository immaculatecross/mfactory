#!/bin/bash
# review-audit — verify a PR's review verdict is genuine before merge (D-007, D-017).
#
# The reviewer's PR comment must OPEN with one exact verdict line:
#   VERDICT: approve SHA=<full 40-hex head sha>
#   VERDICT: request-changes SHA=<full 40-hex head sha>
#
# The audit reads only the FIRST line of each comment and passes only when
# exactly one of them is a verdict line for the PR's current head SHA saying
# approve. The verdict is atomic — word and SHA on a single line — so evidence
# can never be assembled across comments (SHA in one, "approve" in another),
# negated wording ("do not approve") can never match, and a verdict quoted or
# narrated deeper inside a comment is never even read. Encodes the PR #4
# lesson and both PR #6/#7 review findings.
#
# Comment bodies travel base64-encoded, one comment per line, so comment
# boundaries survive transport and the first-line extraction happens HERE,
# inside the tested unit — not in a jq filter the tests can't see (PR #7
# blocking finding). A line that fails to decode contributes nothing: the
# audit fails closed.
#
# Usage:
#   review-audit.sh <owner/repo> <pr-number>   # fetch head SHA + comments via gh
#   review-audit.sh --stdin <head-sha>         # base64 comment bodies on stdin,
#                                              # one per line (tests)
set -uo pipefail

die() { printf 'BLOCKED: %s\n' "$1" >&2; shift; for l in "$@"; do printf '  %s\n' "$l" >&2; done; exit 1; }

# macOS base64 historically decodes with -D, GNU with -d; detect once.
if printf 'aGk=' | base64 -d >/dev/null 2>&1; then B64D=-d; else B64D=-D; fi

extract_first_lines() { # stdin: one base64-encoded comment body per line
  while IFS= read -r enc; do
    [ -n "$enc" ] || continue
    line=$(printf '%s\n' "$enc" | base64 $B64D 2>/dev/null | head -n1 | tr -d '\r')
    printf '%s\n' "$line"
  done
}

audit() { # $1 = head sha; stdin = each comment's first line, one per line
  sha="$1"
  printf '%s' "$sha" | grep -qE '^[0-9a-f]{40}$' \
    || die "head SHA '$sha' is not a full 40-hex SHA." \
           "Fix: pass the PR head SHA (gh pr view <n> --json headRefOid)."
  verdicts=$(grep -E "^VERDICT: (approve|request-changes) SHA=${sha}$" || true)
  count=$(printf '%s' "$verdicts" | grep -c . || true)
  case "$count" in
    0) die "no comment opens with a verdict line for head $sha." \
           "Fix: dispatch a fresh review (verbs/review.md). Its comment's FIRST" \
           "line must be exactly 'VERDICT: approve|request-changes SHA=<head sha>'." ;;
    1) : ;;
    *) die "$count comments open with a verdict for head $sha — ambiguous." \
           "Fix: dispatch one fresh review for this head; each verdict must follow" \
           "its own review, never be re-posted or duplicated." ;;
  esac
  case "$verdicts" in
    "VERDICT: approve SHA=$sha")
      echo "review audit: genuine approve for $sha." ;;
    *)
      die "the reviewer requested changes on head $sha." \
          "Fix: treat the review's BLOCKING findings as a repair work order;" \
          "new commits void this verdict and need a fresh review." ;;
  esac
}

case "${1:-}" in
  --stdin)
    extract_first_lines | audit "${2:?usage: review-audit.sh --stdin <head-sha>}" ;;
  */*)
    REPO="$1"; PR="${2:?usage: review-audit.sh <owner/repo> <pr-number>}"
    SHA=$(gh api "repos/$REPO/pulls/$PR" --jq .head.sha) \
      || die "could not fetch PR $REPO#$PR." "Fix: check the repo/number and gh auth status."
    COMMENTS=$(gh api "repos/$REPO/issues/$PR/comments" --paginate --jq '.[].body | @base64') \
      || die "could not fetch the comments of $REPO#$PR." \
             "Fix: check gh auth status and network — this is a fetch failure," \
             "not a verdict problem; rerun once the comments API is reachable."
    printf '%s\n' "$COMMENTS" | extract_first_lines | audit "$SHA" ;;
  *)
    die "usage: review-audit.sh <owner/repo> <pr-number> | --stdin <head-sha>" \
        "Fix: pass a repo and PR number, or --stdin with the head SHA for tests." ;;
esac
