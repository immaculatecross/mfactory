# WO-ARCH-EXPLAINER - Explain mfactory as it exists today

Feature: Owner-requested documentation - Branch: `docs/architecture-explainer` - Diff cap: 400 lines

## Objective

Create a polished standalone HTML document that lets Mattia understand mfactory's intended architecture, the machinery that actually exists on `master`, the manual substitutions being used during the Mora dogfood run, and why the current cycle takes time. The document must distinguish productive gate latency from accidental orchestration friction and cite repository or PR evidence for concrete claims.

## Acceptance criteria

1. Add `docs/architecture-now.html` as one offline, dependency-free HTML file with embedded CSS and no external scripts, fonts, images, gradients, decorative blobs, or marketing-style hero. It opens directly from disk, prints cleanly, and remains legible at 375px and 1440px.
2. Use a restrained operational design with a strong first-viewport title, CSS architecture flow, status legend, role/layer map, PR lifecycle, current-vs-planned matrix, observed Mora timeline, time-cost analysis, improvement priorities, and source-reading map. Repeated role/status items may be compact cards, with radius no greater than 8px and no nested cards.
3. Explain the intended Owner -> Foreman -> isolated Builder/Reviewer/QA roles; artifacts/verbs/enforcement layers; Define/Build/Ship/Maintain modes; and the one-feature/branch/PR lifecycle.
4. State current truth as of 2026-07-10: F-001...F-005 built; scaffolder, hooks, CI, build and review playbooks, required review status, and atomic review-verdict audit exist. F-006...F-014 remain backlog. During Mora, Codex is manually substituting for the missing Owner, task graph, Define, QA, and Ship automation.
5. Include an honest promise-versus-reality table: `STATE.md` and markdown artifacts exist; Beads sync, OpenClaw/WhatsApp Owner, QA, Ship, maintenance, feedback pipeline, harness hooks, and complete import-boundary/complexity enforcement are not yet operational. Do not present planned architecture as shipped.
6. Explain observed time with evidence: branch protection serializes CI and review; fresh sessions reread artifacts; Mora's first builder crashed on model capacity and a replacement recovered its dirty worktree; the first reviewer caught misleading coverage and forced the single repair path; CI then reran and the new SHA required a fresh review. Separate useful verification time from avoidable manual polling/dispatch and recovery latency.
7. Include the improvement queue learned from Mora L-001...L-006: Define bootstrap, F-000 coupling, reviewer credential separation, factory version/sync, worker timeout/heartbeat/restart, and coverage-scope/build-idempotence gates.
8. Correct `STATE.md` so it no longer says PR #4 review-hardening is absent: record that fresh PR #6 landed the atomic verdict audit and tests. Append `LOG.md` with the explainer, its verification, the STATE drift found, and where that lesson was encoded (STATE correction plus the document's current-vs-planned section).
9. Validate with `tidy -errors -quiet docs/architecture-now.html`, `xmllint --html --noout docs/architecture-now.html`, `git diff --check`, tripwires, and manual responsive/print inspection. Keep the total non-lockfile diff below 400 lines.

## Contracts that apply

None.

## Files that matter

- `ARCHITECTURE.md`, `PRODUCT.md`, `FEATURES.md`, `STATE.md`, `LOG.md`
- `verbs/build.md`, `verbs/review.md`
- `enforcement/ci/`, `enforcement/hooks/`
- Mora's `learnings.md` at `/Users/mattiamauro/Desktop/Murder she wrote/mora/learnings.md`
- `docs/architecture-now.html`

## Decisions that apply

- D-002: ownership lives in a persona.
- D-003: fresh session per PR.
- D-006: deterministic enforcement over prose.
- D-007: reviewer flags and never rewrites.
- D-008: four modes and eight gates.
- D-017: lessons must be encoded, not merely narrated.

## Out of scope

- Changing architecture, feature statuses, enforcement behavior, or product code.
- Claiming the OpenClaw Owner, task graph, QA, Ship, or maintenance loops already exist.
- Adding a documentation framework, build dependency, or hosted site.
- Editing the Mora repository.

## Review repair context

The isolated review on pinned SHA `8a13a4e45ce16bc5011d39a81a17a9b76496b508` returned four BLOCKING findings. This is the single permitted repair.

1. Add F-014 to the planned/backlog boundary and state that the current Mora run is an early manual rehearsal, not completion of the v1 exit test.
2. Correct the time-cause claim: `verbs/build.md` serializes review after green CI; branch protection requires both gates but does not create their order.
3. Replace the unsupported model-capacity cause with the durable-evidence wording `unexpected termination`; the replacement worker's dirty-worktree recovery remains supported.
4. Encode the STATE drift lesson in `verbs/build.md`: after merge, the Foreman must verify the merged `STATE.md` against master truth and make artifact repair the next work unit when stale. Update the LOG entry to point to that playbook line, not to prose as enforcement.

`origin/master` advanced through PR #7 and the Foreman's rebase produced a `LOG.md` conflict. Resolve it by preserving both append-only entries in chronological order. Do not drop or rewrite the PR #7 history. Re-run the full validator and rendering set, update the exit report, and ensure the final branch is based on current `origin/master`.

## Exit report

The builder appends the required result here.

RESULT: done
Branch/PR: docs/architecture-explainer / https://github.com/immaculatecross/mfactory/pull/8
Changed:   Added the standalone, evidence-linked architecture explainer with responsive and print CSS.
Changed:   Repaired the F-014, gate-order, and unexpected-termination claims from isolated review.
Changed:   Corrected stale PR #6 truth in STATE and encoded its post-merge check in the build playbook and LOG.
Verified:  tidy, xmllint, diff-check, tripwires, shell syntax, 18 audit tests; Chrome at true 375px/1440px and six-page print PDF.
Risks:     Evidence links require a network when followed; the document itself remains fully offline.
