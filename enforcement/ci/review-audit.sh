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
# negated wording ("do not approve") can never match, and a verdict line
# quoted deeper inside an ordinary comment is never even read. This encodes
# the PR #4 lesson and the PR #6 review finding.
#
# Usage:
#   review-audit.sh <owner/repo> <pr-number>   # fetch head SHA + comments via gh
#   review-audit.sh --stdin <head-sha>         # first line of each comment on
#                                              # stdin, one per line (tests)
set -uo pipefail

die() { printf 'BLOCKED: %s\n' "$1" >&2; shift; for l in "$@"; do printf '  %s\n' "$l" >&2; done; exit 1; }

audit() { # $1 = head sha; stdin = each comment's first line, one per line
  sha="$1"
  printf '%s' "$sha" | grep -qE '^[0-9a-f]{40}$' \
    || die "head SHA '$sha' is not a full 40-hex SHA." \
           "Fix: pass the PR head SHA (gh pr view <n> --json headRefOid)."
  # tr strips CRs so a genuine verdict typed in the GitHub web UI (CRLF) passes.
  verdicts=$(tr -d '\r' | grep -E "^VERDICT: (approve|request-changes) SHA=${sha}$" || true)
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
    audit "${2:?usage: review-audit.sh --stdin <head-sha>}" ;;
  */*)
    REPO="$1"; PR="${2:?usage: review-audit.sh <owner/repo> <pr-number>}"
    SHA=$(gh api "repos/$REPO/pulls/$PR" --jq .head.sha) \
      || die "could not fetch PR $REPO#$PR." "Fix: check the repo/number and gh auth status."
    # Only each comment's first line is emitted — a verdict anywhere else in a
    # body (quoted, fenced, narrated) is structurally invisible to the audit.
    gh api "repos/$REPO/issues/$PR/comments" --paginate --jq '.[].body | split("\n")[0]' \
      | audit "$SHA" ;;
  *)
    die "usage: review-audit.sh <owner/repo> <pr-number> | --stdin <head-sha>" \
        "Fix: pass a repo and PR number, or --stdin with the head SHA for tests." ;;
esac
