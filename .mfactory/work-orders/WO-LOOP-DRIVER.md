# WO-LOOP-DRIVER — The autonomy spine: fresh Foreman per cycle
Feature: F-004 completion — Branch: `feat/loop-driver-v2` — Diff cap: 400 lines
## Objective
Nothing currently re-invokes the Foreman, so "autonomous build" still needs a human to run every cycle. Build the loop driver fresh after PR #9 exhausted its repair limit: one repo-local instance, one fresh Foreman per cycle (D-003), an emergency brake (D-014), and fail-safe handling of anything it does not understand.
## Acceptance criteria
1. `bin/mfactory-loop [--dir <repo>] [--max-cycles N]` atomically permits one driver per repo, dispatches one fresh Foreman per cycle, and preserves each cycle's full stdout/stderr in a unique log. Active and stale locks fail with their own fix; normal and signaled exits release ownership.
2. Only the report's final line is protocol; earlier lines are ordinary output. Final `NEXT: continue` re-dispatches; final `NEXT: stop <reason>` exits 0 only with a non-whitespace reason. Any other final line, agent crash, or cycle cap fails closed with its own fix.
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
## Findings consolidated (PR #9; PR #10 reviews)
- Final-line validation rejects malformed final stops; the contract now explicitly ignores earlier sentinel-shaped prose instead of accumulating a second parser.
- Atomic acquisition is raced; signal handling defers the launch window, tears down TERM-resistant agents, and asserts no child remains.
- The harness proves one complete boot prompt; the brake is tested initially and between cycles; spaced paths and target-qualified recovery work.
- `die` rejects empty remediation centrally; behavioral tests assert path-specific recovery rather than the token `Fix:`.

## Exit report
RESULT: done
Branch/PR: `feat/loop-driver-v2` — https://github.com/immaculatecross/mfactory/pull/10
Changed:   Atomic singleton with deferred-signal launch and bounded TERM→KILL cleanup; final-line-only protocol, unique full logs, target-qualified brake, cycle cap, and safe harness path.
Changed:   `verbs/build.md` step 8 emits the sentinel and forbids internal looping; all runtime state is gitignored in mfactory and product templates.
Verified:  `bash -n`; suite races starts, proves no child survives ignored TERM, checks one complete prompt and between-cycle brake, plus locks, final lines, logs, paths, and remediation; audit 18/18; tripwires clean.
Risks:     SIGKILL can leave a stale lock; PID reuse may label it active but fails closed. Printed recovery requires ownership verification; merge safety stays with CI, review, and audit.
