# WO-LOOP-DRIVER — The autonomy spine: fresh Foreman per cycle
Feature: F-004 completion — Branch: `feat/loop-driver-v2` — Diff cap: 400 lines

## Objective
Nothing currently re-invokes the Foreman, so "autonomous build" still needs a human to run every cycle. Build the loop driver fresh after PR #9 exhausted its repair limit: one repo-local instance, one fresh Foreman per cycle (D-003), an emergency brake (D-014), and fail-safe handling of anything it does not understand.

## Acceptance criteria
1. `bin/mfactory-loop [--dir <repo>] [--max-cycles N]` atomically permits one driver per repo, dispatches one fresh Foreman per cycle, and preserves each cycle's full stdout/stderr in a unique log. Active and stale locks fail with their own fix; normal and signaled exits release ownership.
2. Exactly one sentinel must be the report's final line: `NEXT: continue` re-dispatches; `NEXT: stop <reason>` exits 0 only with a non-whitespace reason. Missing, bare, whitespace-only, conflicting, non-final, or lookalike sentinels, agent crashes, and the cycle cap fail closed with a fix.
3. `.mfactory/STOP` halts before dispatch with exit 2 and names the target-qualified removal command. Steering stays in CONTROL.md.
4. `$MFACTORY_AGENT_CMD` is a quoting-safe executable/wrapper path (harness-agnostic, D-009), including paths with spaces; tests drive the real driver with fake agents.
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

## Prior blocked attempt consolidated (PR #9)
- Sentinel parsing accepted trailing/conflicting/bare/whitespace-only stops; scenario tests missed the protocol invariant.
- Logs collided, and concurrent invocations could dispatch two Foremen against the same ready work.
- Missing option values lacked fixes; spaced harness paths failed; the `--dir` brake fix named the caller's repo.
- Tests ignored driver messages and stderr, so mutations removing remediation or full logging stayed green.

## Exit report
RESULT: done
Branch/PR: `feat/loop-driver-v2` — PR pending
Changed:   Singleton driver with stale-lock diagnosis, strict final sentinel, unique full logs, target-qualified brake, cycle cap, and quoting-safe harness path.
Changed:   `verbs/build.md` step 8 emits the sentinel and forbids internal looping; all runtime state is gitignored in mfactory and product templates.
Verified:  `bash -n`; invariant suite covers true concurrency, stale/released locks, sentinel attacks, collisions, full logs, spaced paths, and remediation; audit 18/18; tripwires clean.
Risks:     SIGKILL can leave a stale lock requiring the printed manual recovery; real merge safety remains with CI, isolated review, and the verdict audit.
