# WO-REVIEW-AUDIT — Close the review false-approval gap (the PR #4 fix)

Feature: F-005 hardening — Branch: `feat/review-audit` — Diff cap: 400 lines

## Objective

Build the deterministic verdict audit that PR #4 failed to deliver, fresh, importing nothing from that blocked branch. A `review` commit status must be backed by a genuine, unambiguous verdict artifact for the exact head SHA before the Foreman may merge.

## Acceptance criteria

1. `enforcement/ci/review-audit.sh` exists; given a repo+PR (or stdin comments + head SHA for tests) it passes only when exactly one exact verdict line `VERDICT: approve SHA=<full head sha>` matches the current head.
2. Split evidence across comments, negated wording, stale SHAs, duplicate or conflicting verdicts, format drift, and malformed SHAs are all rejected — each with a failure message that states its own fix.
3. Positive and negative regression tests live in `enforcement/tests/` and run in CI on every push.
4. `verbs/review.md` mandates the exact verdict-line format; `verbs/build.md` adds the audit to the merge bar as a committed command (D-017); `bin/mfactory-new` ships the script into products.
5. `LOG.md` records the change and why the single-line-atomic design satisfies the "validate comments individually" intent.

## Contracts that apply

None (mfactory itself; ARCHITECTURE §Layer 3 governs).

## Files that matter

- `enforcement/ci/review-audit.sh` (new)
- `enforcement/tests/review-audit.test.sh` (new)
- `verbs/review.md`, `verbs/build.md`, `bin/mfactory-new`, `.github/workflows/ci.yml`

## Decisions that apply

- D-006: deterministic enforcement over prompt instructions.
- D-007: the reviewer flags, never rewrites; approval must be meaningful.
- D-017: the PR #4 lesson is encoded as script + tests the same day.

## Out of scope

- Importing or repairing any code from blocked PR #4.
- Changing branch-protection contexts (the `review` status stays the required check; the audit is the Foreman's pre-merge command).

## Exit report

RESULT: done
Branch/PR: `feat/review-audit` — PR pending
Changed:   New `review-audit.sh` with atomic verdict-line validation; 14 regression tests; verbs and scaffolder wired; CI runs the test suite.
Verified:  `bash -n` on all scripts; `enforcement/tests/review-audit.test.sh` (14/14 ok); `enforcement/hooks/run-tripwires.sh --all` clean.
Risks:     A verdict line quoted verbatim inside a code fence in an ordinary comment would match; only the factory account comments on these PRs today, and the required `review` status must still exist alongside.
