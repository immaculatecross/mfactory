# Decisions

Append-only record of durable decisions. Format: ID, date, status, decision, why, consequences. Reversals get a new entry that supersedes the old one — never edit history. (A machine-readable `decisions.jsonl` mirror is planned; see F-006.)

---

## D-001 · 2026-07-10 · Accepted — Build our own thin core; loot gstack for parts

gstack (Garry Tan's Claude Code software factory, vendored in `gstack-main/` for reference) covers interactive workflows well but has no autonomous loop, no state machine, heavy prompt mass (25–35K-token skills), and a baked-in personal voice. **Why:** all of mfactory's novel value is on the autonomy axis gstack doesn't have; adopting it wholesale imports 54 skills of someone else's opinions. **Consequences:** we borrow its eval-tested prompts (review, QA, investigate, security audit), its browse daemon pattern, its tripwire-test habit, and its event-sourced decision log — and build everything else ourselves.

## D-002 · 2026-07-10 · Accepted — Ownership lives in a persona, not a process

One persistent Owner identity per product (the OpenClaw agent Mattia talks to on WhatsApp) owns the mission and the relationship. All actual work runs in disposable sessions. **Why:** a long session's memory becomes a lossy, unauditable self-summary once context fills; explicit file state is the same mechanism made durable, auditable, and crash-safe. **Consequences:** the Owner holds no code context; everything it "knows" is in artifacts.

## D-003 · 2026-07-10 · Accepted — Fresh session per PR, no milestone-scoped sessions

Every work unit (one feature → one branch → one PR) runs in a fresh worker session booted from a work order. The Foreman that dispatches work is itself a fresh session per cycle. **Why:** immunity to context rot, per-PR blast radius, full auditability; a curated boot brief beats hour-30 of a silted-up session. **Consequences:** cross-feature coordination must come from the four mechanisms in ARCHITECTURE.md §Coordination (task graph, contracts, work orders, drift detection) — never from session memory.

## D-004 · 2026-07-10 · Accepted — Real GitHub PRs, never local-only branches

**Why:** GitHub Actions run the authoritative gates, branch protection makes discipline mechanical, PR history is the audit trail, and Mattia can review from his phone next to the WhatsApp thread. **Consequences:** every product repo needs CI workflows and branch protection configured at scaffold time (F-003).

## D-005 · 2026-07-10 · Accepted — Task graph as machine layer, FEATURES.md as human view

Adopt Beads (git-backed graph issue tracker, github.com/steveyegge/beads) for task state: IDs, priorities, dependencies, audit trail, computed "ready work." `FEATURES.md` remains the human-readable roadmap Mattia edits and approves. **Why:** markdown plans are write-only memory for agents; dependencies are what make blind per-PR workers safe. **Consequences:** a sync convention between FEATURES.md and the graph is needed (F-006); if Beads proves heavy we clone its ideas rather than abandon the layer.

## D-006 · 2026-07-10 · Accepted — Deterministic enforcement over prompt instructions

Rules live in pre-commit hooks, CI gates, harness hooks, and tripwire tests — not in system-prompt prose. Failure messages are remediation-focused because the error message is the prompt (per OpenAI's harness-engineering findings). **Why:** the strongest public evidence on agent-first codebases; mechanical rules don't decay with context. **Consequences:** the enforcement pack (F-003) is a core deliverable, not tooling garnish; every bug class caught twice becomes a tripwire test.

## D-007 · 2026-07-10 · Accepted — The reviewer flags; it never rewrites

Adversarial review runs in an isolated fresh session (diff + spec + repo only, no builder reasoning), produces a verdict artifact with blocking/non-blocking findings, and is a required merge check. One reviewer plus mechanical gates — no stacked review chains. **Why:** rewriting in review churns diffs and destroys accountability; multi-reviewer chains have steeply diminishing returns. **Consequences:** elegance improvements go through the dedicated `simplify` pass under green tests.

## D-008 · 2026-07-10 · Accepted — Four modes, eight gates

Mattia's original eight phases survive as named *gates*, but the machinery is four modes: **Define** (ideate → discuss → plan), **Build** (the PR loop), **Ship** (deploy + docs audit), **Maintain** (cron-triggered). **Why:** final testing, correction, and docs-checking are properties of the loop (iterated, enforced per-PR), not one-shot phases. **Consequences:** each gate is a checklist a script can evaluate; mode transitions notify the Owner.

## D-009 · 2026-07-10 · Accepted — Verb API as the OpenClaw ↔ mfactory contract

mfactory exposes named entry points — `ideate`, `plan`, `build`, `review`, `qa`, `simplify`, `enhance`, `maintain`, `status`, `teach` — each a markdown playbook declaring preconditions, artifacts read/written, and exit-report format. **Why:** verbs are portable skills in any harness (agnosticism requirement) and make OpenClaw integration trivial (cron calls `maintain`; Mattia texts "mfactory status"). **Consequences:** anything not reachable through a verb doesn't exist; new capabilities land as new verbs.

## D-010 · 2026-07-10 · Accepted — Synthetic user is a generator, not a validator

The post-ship synthetic user cold-walks the product in a fresh session with zero build context and files categorized proposals (bug / feature / UX-UI / performance / tech-debt). **Why:** documented tendency of AI personas to validate ideas real users would reject; they excel at friction-finding, not desire-prediction. **Consequences:** real user feedback always outranks synthetic findings in triage; synthetic output can never self-approve into buildable work.

## D-011 · 2026-07-10 · Accepted — Auto-ideation on a leash

The `enhance` verb (cron or on demand) may propose features, but proposals land in an `unapproved` state, capped at 5 open, and nothing unapproved is buildable. **Why:** uncapped ideation becomes backlog spam — an agent optimizing for looking busy. **Consequences:** Mattia approves from WhatsApp; stale proposals expire.

## D-012 · 2026-07-10 · Accepted — One STATE.md, no memory infrastructure in v1

A single distilled current-state brief, regenerated after each merge, is the boot sector for every fresh session. **Why:** Beads covers task memory; a compressed wiki layer is speculative complexity. **Consequences:** revisit only when STATE.md demonstrably creaks.

## D-013 · 2026-07-10 · Accepted — Develop on the Mac, run production on the OpenClaw box

mfactory itself is built and iterated locally; product build loops run on Mattia's always-on OpenClaw server, where the Owner lives. **Why:** fire-and-forget from WhatsApp requires surviving a closed laptop lid. **Consequences:** everything must run headless; no Mac-only dependencies in the loop.

## D-014 · 2026-07-10 · Accepted — Steering interrupts between PRs, not mid-edit

Mattia's WhatsApp messages append to a `CONTROL.md` queue; the Foreman drains it between work units. **Why:** the PR boundary is the natural checkpoint — state is consistent, gates have run, redirection is cheap. **Consequences:** a true emergency stop (kill the loop) is a separate Owner command, not a queue entry.

## D-015 · 2026-07-10 · Accepted — Project name is mfactory; repo is immaculatecross/mfactory, default branch master

Renamed from mstack. **Why:** "stack" says pile of tools (gstack's model); "factory" says production line that runs without you, which is the thesis. **Consequences:** all artifacts renamed this day; the GitHub identity model (operator account vs. factory account) is an open question tracked in LOG.md.
