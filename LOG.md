# Log

Append-only. One entry per session/cycle: what happened, what changed, what's next.

---

## 2026-07-10 — Define phase: founding design session

Mattia + Claude designed mfactory end to end in a live sparring session. Researched OpenAI harness engineering (deterministic enforcement > prompts; the error message is the prompt), Anthropic long-running-agent harnesses (file-persisted state, fresh sessions), Beads (git-backed task graphs as agent memory), and synthetic-user research (generator, not validator). Audited gstack internals; verdict: loot the browse daemon pattern, eval-tested prompts, tripwire habit, and decision log — build the autonomy layer ourselves.

Fourteen durable decisions recorded in DECISIONS.md (D-001…D-014), architecture fixed as three layers (artifacts / verbs / enforcement) operated by Owner / Foreman / Workers with fresh sessions per PR. v1 backlog written to FEATURES.md (F-001…F-014). F-001 (founding docs) completed this session.

Next: F-002 scaffolder and F-003 enforcement pack — the deterministic foundation everything else stands on.

---

## 2026-07-10 — Repo live: immaculatecross/mfactory

Mattia created the GitHub repo (default branch `master`) and pushed the founding commit. Project renamed mstack → mfactory across all docs (D-015). Open question: GitHub identity model — `gh` on the Mac is authenticated as matmauro01 while the repo lives under immaculatecross; autonomous repo creation (F-002) and PR gating (F-005) need the factory account authenticated wherever the loop runs.

---

## 2026-07-10 — F-003 built, F-002 building: enforcement pack + scaffolder

`enforcement/` now holds the deterministic layer: a self-contained hooks bundle (pre-commit: 500-line cap, conflict markers, tripwires with per-line `mfactory-allow:` waivers; commit-msg: Conventional Commits) and CI gate templates (lint/typecheck/test with mandatory scripts, gitleaks, coverage ratchet, PR size cap, tests-accompany-src, docs gate). `bin/mfactory-new` scaffolds a product repo with artifacts, armed hooks, gates workflow, waiver labels, and branch protection; `--local` skips GitHub.

Verified end to end in `--local` mode: console.log, oversize file, bad commit message, fake API key, and private key all blocked with remediation messages; waivered lines and clean conventional commits pass. Testing caught one real bug — the private-key regex starts with `-` and grep parsed it as an option, failing silently behind `|| true`; fixed with `grep -e`, regression-tested. Lesson recorded: a gate that can fail silently is worse than no gate.

Hooks are now armed on mfactory itself (`core.hooksPath`), and `.github/workflows/ci.yml` re-runs syntax checks, tripwires, and the scaffold smoke test on every push. F-002 stays `building`: the GitHub-side path (repo creation, protection) is untestable until D-016 (factory account) is decided. This entry lands as a direct push to master — pre-enforcement, deliberate, and impossible once protection is armed.

---

## 2026-07-10 — D-016 decided; F-002 built; protection armed; direct pushes end here

Mattia decided D-016: immaculatecross is the factory identity, and authenticated `gh` accordingly; `~/.mfactory/owner` is set. The enforcement-pack CI run passed on GitHub's runners (8s). F-002 was then tested live end to end: `mfactory-new mfactory-smoke --public` created the repo, pushed, created both waiver labels, and armed branch protection (required checks tripwires/secrets/code/pr-rules, admins included) — all verified via the API, so F-002 moves to `built`. Deleting the smoke repo was refused for lack of `delete_repo` scope; per D-016 that scope stays withheld on purpose, and the cleanup is Mattia's one manual click.

Branch protection is now armed on mfactory itself (required check `self-check`, admins included). This entry is the first change to land through a gated PR; direct pushes to master are no longer possible for anyone, including the factory.

---

## 2026-07-10 — F-004 built: the build loop ran with a real fresh builder

The loop's three artifacts exist: `verbs/build.md` (Foreman: boot from files, drain CONTROL, pick ready work, write the work order, dispatch a fresh builder, judge by report *and* facts, one repair attempt max), `verbs/builder.md` (worker: one feature, tests with code, contracts inviolable, honest exit report, `split` over squeezing the cap), and `templates/work-order.md` (the entire briefing a builder ever gets). Products now also get `AGENTS.md`/`CLAUDE.md`, the verbs, and the work-order template via the scaffolder, so every product repo is self-contained. mfactory itself gained AGENTS/CLAUDE (boot order, rules) and a CI dedupe (push runs only on master).

Live test: scaffolded a demo product, wrote WO-000 (make the gate scripts real) as Foreman, dispatched a genuinely fresh builder session. Result, independently verified rather than trusted: two conventional commits, 207-line diff (cap 400), zero waivers, docs and exit report riding the same branch, gates green when re-run cold, lint proven to exit 1 on a tracked syntax error, and the builder proactively flagged a scope gap (FEATURES mentioned a coverage ratchet its work order never ordered) instead of improvising — the exact behavior the playbook demands. The PR leg was untested (no remote in local mode); F-004 moves to `verified` at the first real product build.

Meta-lesson recorded: verification produced two false failures before the true verdict — an untracked file outside lint's declared scope, then a shell pipeline masking an exit code. Verification commands are code too; trust committed, tested scripts over ad-hoc shell.
