# WO-PR4-BLOCKED - Record the failed review-hardening follow-up

Feature: operational repair following F-005 - Branch: `docs/pr4-blocked` - Diff cap: 400 lines

## Objective

Record that PR #4 exhausted the build loop's single repair attempt and remains blocked after an isolated reviewer proved its audit script could false-approve split or negated comments. Preserve the evidence without importing any unapproved code from PR #4.

## Acceptance criteria

1. `LOG.md` gains one append-only entry identifying both failed review verdicts, the exact remaining false-approval bug, and PR #4's blocked state.
2. `STATE.md` states concisely that PR #4 is blocked and that its review-hardening changes are not on `master`.
3. The entry records the lesson as encoded in the existing `verbs/build.md` one-repair limit and names the future fix: comment-by-comment exact verdict/SHA validation with positive and negative regression tests.
4. No source, enforcement, verb, decision, or feature-status file changes.
5. The finished work order and an honest exit report ride in the PR.

## Contracts that apply

None.

## Files that matter

- `LOG.md`
- `STATE.md`
- `.mfactory/work-orders/WO-PR4-BLOCKED.md`

## Decisions that apply

- D-006: deterministic enforcement over prompt instructions.
- D-007: reviewer flags and never rewrites.
- D-017: every lesson is encoded the same day.

## Out of scope

- Copying or repairing code from PR #4.
- Changing `FEATURES.md` statuses.
- Reopening the exhausted repair loop.

## Exit report

RESULT: done
Branch/PR: `docs/pr4-blocked` - https://github.com/immaculatecross/mfactory/pull/5
Changed:   Recorded both failed PR #4 verdicts, the exact false-approval bug, and the blocked state in `LOG.md`.
Changed:   Updated `STATE.md` to say PR #4 is blocked and its changes are absent from `master`.
Changed:   Completed this work order without importing or repairing PR #4 code.
Verified:  `git diff --check`; CI shell syntax; `enforcement/hooks/run-tripwires.sh --all`; scaffold smoke test.
Risks:     none identified
