# WO-LOOP-DRIVER — The autonomy spine: fresh Foreman per cycle

Feature: F-004 completion — Branch: `feat/loop-driver` — Diff cap: 400 lines

## Objective

Nothing currently re-invokes the Foreman, so "autonomous build" still needs a human to run every cycle. Build the loop driver that dispatches a fresh Foreman session per cycle (D-003), honors an emergency brake (D-014), and stops fail-safe on anything it does not understand.

## Acceptance criteria

1. `bin/mfactory-loop [--dir <repo>] [--max-cycles N]` dispatches one fresh Foreman session per cycle on the repo's build verb and logs each cycle's full output under `.mfactory/loop/`.
2. The Foreman's report ends with a sentinel the driver obeys: `NEXT: continue` re-dispatches, `NEXT: stop <reason>` exits 0. A missing or lookalike sentinel, an agent crash, and the cycle cap all stop the loop with exit 1 and a failure message that states its fix.
3. `.mfactory/STOP` halts before the next dispatch with exit 2; removing the file resumes. Steering stays in CONTROL.md.
4. The agent command is pluggable via `$MFACTORY_AGENT_CMD` (harness-agnostic, D-009); tests drive the real driver end to end with a fake agent, never a real one.
5. `verbs/build.md` ends the cycle with the sentinel instead of looping internally (the internal loop contradicted D-003); driver runtime state is gitignored in mfactory and in scaffolded products.
6. `LOG.md` records the change; `STATE.md` is regenerated (session end).

## Contracts that apply

None (mfactory itself; ARCHITECTURE §Roles and D-003/D-014 govern).

## Files that matter

- `bin/mfactory-loop` (new), `enforcement/tests/mfactory-loop.test.sh` (new)
- `verbs/build.md`, `.github/workflows/ci.yml`, `.gitignore`, `templates/product/gitignore`

## Decisions that apply

- D-003: fresh session per cycle; coordination through artifacts, never session memory.
- D-009: the harness is a plug; the driver must not hardcode one.
- D-014: the emergency stop is a separate mechanism from CONTROL steering.

## Out of scope

- The OpenClaw Owner (F-007) — the driver is what the Owner will call, not the Owner itself.
- Waiting on CI or merging — those live inside the Foreman's cycle, not the driver.

## Repair findings (first review, head 7a9bdec — request-changes)

- BLOCKING: the parser accepted a sentinel before trailing output, conflicting sentinels, and a bare `NEXT: stop` without a reason.
- BLOCKING: second-resolution log names let rapid invocations overwrite a cycle log.
- BLOCKING: missing option values exited through Bash parameter expansion without a `Fix:` instruction.
- BLOCKING: tests discarded driver messages, so removing remediation text or agent stderr logging left the suite green.

## Exit report (after the one permitted repair)

RESULT: done
Branch/PR: `feat/loop-driver` — https://github.com/immaculatecross/mfactory/pull/9
Changed:   New driver with brake, strict final-sentinel protocol, cycle cap, collision-proof per-cycle logs, and a pluggable harness.
Changed:   `verbs/build.md` step 7 emits the sentinel and forbids internal looping; runtime state gitignored in mfactory and product template.
Verified:  `bash -n`; loop-driver suite green, including adversarial sentinel, rapid-invocation, full-log, and remediation assertions; review-audit suite 18/18; tripwires clean.
Risks:     The sentinel is trusted from the Foreman's stdout — a lying report can stop early (fail-safe) but a `NEXT: continue` cannot bypass the cap; real merge safety stays with CI, review, and the audit.
