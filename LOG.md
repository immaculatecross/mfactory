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
