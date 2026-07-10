#!/bin/bash
# review-audit — verify a PR's review verdict is genuine before merge (D-007, D-017).
#
# The reviewer's PR comment must open with one exact verdict line:
#   VERDICT: approve SHA=<full 40-hex head sha>
#   VERDICT: request-changes SHA=<full 40-hex head sha>
#
# The audit passes only when exactly one verdict line exists for the PR's
# current head SHA and it says approve. The verdict is atomic — word and SHA
# on a single line — so evidence can never be assembled across comments
# (SHA in one, "approve" in another) and negated wording ("do not approve")
# can never match the anchored pattern. This encodes the PR #4 lesson.
#
# Usage:
#   review-audit.sh <owner/repo> <pr-number>   # fetch head SHA + comments via gh
#   review-audit.sh --stdin <head-sha>         # comment bodies on stdin (tests)
set -uo pipefail

die() { printf 'BLOCKED: %s\n' "$1" >&2; shift; for l in "$@"; do printf '  %s\n' "$l" >&2; done; exit 1; }

audit() { # $1 = head sha; stdin = every comment body, one body's lines after another
  sha="$1"
  printf '%s' "$sha" | grep -qE '^[0-9a-f]{40}$' \
    || die "head SHA '$sha' is not a full 40-hex SHA." \
           "Fix: pass the PR head SHA (gh pr view <n> --json headRefOid)."
  verdicts=$(grep -E "^VERDICT: (approve|request-changes) SHA=${sha}$" || true)
  count=$(printf '%s' "$verdicts" | grep -c . || true)
  case "$count" in
    0) die "no verdict line found for head $sha." \
           "Fix: dispatch a fresh review (verbs/review.md). Its comment must open" \
           "with the exact line 'VERDICT: approve|request-changes SHA=<head sha>'." ;;
    1) : ;;
    *) die "$count verdict lines match head $sha — ambiguous." \
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
    audit "${2:?usage: review-audit.sh --stdin <head-sha>}" ;;
  */*)
    REPO="$1"; PR="${2:?usage: review-audit.sh <owner/repo> <pr-number>}"
    SHA=$(gh api "repos/$REPO/pulls/$PR" --jq .head.sha) \
      || die "could not fetch PR $REPO#$PR." "Fix: check the repo/number and gh auth status."
    # --jq '.[].body' prints each body followed by a newline, so lines never
    # merge across comments; the single-line verdict keeps each match atomic.
    gh api "repos/$REPO/issues/$PR/comments" --paginate --jq '.[].body' | audit "$SHA" ;;
  *)
    die "usage: review-audit.sh <owner/repo> <pr-number> | --stdin <head-sha>" \
        "Fix: pass a repo and PR number, or --stdin with the head SHA for tests." ;;
esac
