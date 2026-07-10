# WO-AUDIT-FIRST-LINE — Encode PR #6's review findings (D-017, same day)

Feature: F-005 hardening — Branch: `fix/review-audit-first-line` — Diff cap: 400 lines

## Objective

Close the two advisories from PR #6's adversarial review: (1) a verdict line quoted or narrated deeper inside an ordinary comment passed the audit as genuine; (2) a genuine CRLF verdict from the GitHub web UI was blocked with a misleading message.

## Acceptance criteria

1. `review-audit.sh` reads only the first line of each comment; a verdict anywhere else in a body can never match. The demonstrated bypass is a regression test.
2. Carriage returns are stripped before matching; a CRLF verdict passes. Covered by a test.
3. All prior regression cases still pass under the new stdin contract (one comment first-line per input line).
4. The live fetch path re-validates PR #6's real verdict.
5. `LOG.md` records both findings and where they were encoded.

## Contracts that apply

None (mfactory itself; ARCHITECTURE §Layer 3 governs).

## Files that matter

- `enforcement/ci/review-audit.sh`
- `enforcement/tests/review-audit.test.sh`

## Decisions that apply

- D-006: deterministic enforcement over prompt instructions.
- D-017: lessons become enforcement the same day — this PR is the encoding of PR #6's review findings.

## Out of scope

- Changing the verdict-line format or `verbs/review.md` (already mandates first-line placement).
- The reviewer's third advisory (STATE.md regen) — lands with the loop-driver PR that ends this session.

## Exit report

RESULT: done
Branch/PR: `fix/review-audit-first-line` — PR pending
Changed:   Audit matches only each comment's first line; CRs stripped; tests now 16 cases including the demonstrated bypass and CRLF.
Verified:  `bash -n`; `enforcement/tests/review-audit.test.sh` (16/16 ok); live `review-audit.sh immaculatecross/mfactory 6` re-validated the real verdict.
Risks:     none identified beyond the already-required pairing with the `review` commit status.
