# Architecture

mstack is three thin layers — **artifacts** (durable state), **verbs** (entry points), **enforcement** (deterministic gates) — operated by three roles. Everything else is small prompts.

## Roles

```
OWNER — persistent persona on the OpenClaw box
│  Mattia's single WhatsApp contact per product. Holds the mission and
│  the relationship, never the code context. Fires verbs (cron or on
│  command), relays updates, receives steering into CONTROL.md.
│
├─ FOREMAN — fresh session per cycle
│  Boots from STATE.md + task graph + CONTROL.md. Drains steering,
│  picks the highest-priority unblocked work, writes work orders,
│  dispatches workers, integrates results, regenerates STATE.md,
│  appends to LOG.md, reports to the Owner. Exits.
│
└─ WORKERS — fresh session per PR, three kinds, mutually isolated
   Builder    — implements one feature + its tests from a work order; opens the PR.
   Reviewer   — adversarial; sees only diff + spec + repo; writes a verdict (D-007).
   QA/Synth   — drives the running product in a real browser; no build context.
```

No role ever depends on another role's context window. A crashed session costs one unit of work.

## Layer 1 — Artifacts (per product repo)

| File | Role |
|---|---|
| `PRODUCT.md` | What and why. Written in Define, rarely touched after. |
| `DECISIONS.md` | Append-only ADR log. Trade-offs decided with Mattia land here. |
| `FEATURES.md` | Human-readable roadmap: approved / building / built / verified / unapproved proposals. Maps to the Beads task graph (machine layer). |
| `CONTRACTS/` | Pinned shared surfaces: DB schema, API types, module boundaries. Written in Define, changed only via a decision. |
| `STATE.md` | Distilled current-state brief, regenerated after each merge. First read of every fresh session. |
| `LOG.md` | Append-only journal, one entry per cycle/PR. |
| `CONTROL.md` | Steering queue from WhatsApp; drained by the Foreman between PRs. |
| `feedback/` | Inbox for real user feedback + synthetic-user reports, pre-triage. |
| `.mstack/work-orders/` | One brief per PR: spec, acceptance criteria, relevant contracts, the 3–5 files that matter, applicable decisions. |

## Layer 2 — Verbs

Each verb is a markdown playbook: preconditions, artifacts read/written, exit-report format. The Owner (or Mattia directly) is the only caller.

| Verb | Mode | What it does |
|---|---|---|
| `ideate` | Define | Sparring-partner session → `PRODUCT.md` draft, candidate features. |
| `plan` | Define | Surfaces trade-offs for joint decisions → `DECISIONS.md`, `CONTRACTS/`, approved `FEATURES.md` + task graph with dependencies and acceptance criteria. |
| `build` | Build | The loop: Foreman cycles until no ready work remains or CONTROL says stop. |
| `review` | Build | Isolated adversarial review of one PR → verdict artifact (also runs inside `build`). |
| `qa` | Build/Ship | Browser-drives the running product against acceptance criteria; files findings. |
| `simplify` | Build/Ship | Deletes code, reduces abstraction, no behavior change; tests stay green. |
| `enhance` | Maintain | Generates ≤5 capped, `unapproved` proposals from feedback + repo review (D-011). |
| `maintain` | Maintain | Cron entry: triage feedback, review lint/test health, propose fix PRs. |
| `status` | any | One-screen report from artifacts; no code reading. |
| `teach` | any | Walks Mattia through what was built and why, sourced from LOG + DECISIONS + diffs. |

## Layer 3 — Enforcement (deterministic, never prose)

**Pre-commit (fast, local):** format; strict lint (TS strict, no `any`, no `ts-ignore`/`eslint-disable` without justification comment); file ≤ 500 lines; function complexity cap; no `console.log`/`debugger`; secret scan (gitleaks); conventional commits.

**CI merge gates (authoritative):** full typecheck + test suite; coverage ratchet (never decreases); changed source ⇒ changed tests or explicit waiver; PR size cap (~400 lines, lockfiles excluded); import-boundary lint on `CONTRACTS/` layers; docs gate (PR touches LOG/FEATURES/CHANGELOG or carries a justified `docs-none` label); reviewer verdict = approve; branch protection on main.

**Harness hooks:** PostToolUse runs format+typecheck on each edited file (seconds-scale feedback); Stop hook blocks session exit if STATE/LOG weren't updated or checks are red.

**Tripwires:** any bug class caught twice becomes a permanent static test that fails CI if the pattern reappears (pattern proven at scale in gstack).

Every failure message says how to fix it — the error message is the prompt (D-006).

## Coordination without shared memory (D-003)

1. **Task graph** — dependencies prevent interdependent features being built blind in parallel; "next work" is computed, not remembered.
2. **Contracts** — workers code against pinned shared surfaces, enforced by import-boundary lint.
3. **Work orders** — the Foreman injects cross-feature awareness deliberately into each worker's boot context.
4. **Drift detection** — cross-feature integration tests + the reviewer's explicit "fits ARCHITECTURE/CONTRACTS" checklist item catch what 1–3 miss, before merge.

## Modes and gates (D-008)

**Define** (interactive) → gate: PRODUCT approved, DECISIONS recorded, CONTRACTS pinned, every feature has acceptance criteria.
**Build** (autonomous) → per-PR gate: CI green + reviewer approve; mode gate: no ready work left, QA findings closed.
**Ship** → gate: deployed (or deploy instructions delivered), repo clean, docs audit passes, `teach` available.
**Maintain** (cron) → standing loop: feedback triage, health review, proposal PRs through the same Build gates.

## Feedback pipeline

`feedback/` inbox (app widget, WhatsApp forwards, store reviews) + synthetic-user reports → triage agent classifies **bug / feature / UX-UI / performance / tech-debt**, dedupes, aggregates with evidence counts → proposals for Mattia → approved items become ready work in the graph. Synthetic findings never outrank real users (D-010).

## OpenClaw integration

Outbound: Owner messages at mode transitions, PR opened/merged, gate failures, proposal batches. Inbound: WhatsApp → `CONTROL.md` (drained between PRs, D-014); explicit kill command for emergencies. Cron: `maintain` and `enhance` on schedule. The Owner never edits code.

## This repo

```
mstack/
├── PRODUCT.md  DECISIONS.md  ARCHITECTURE.md  FEATURES.md  LOG.md
├── verbs/          # one playbook per verb (F-004+)
├── enforcement/    # hook configs, CI templates, tripwire library (F-003)
├── templates/      # product-repo scaffold (F-002)
└── gstack-main/    # vendored reference, unversioned — loot, don't import
```
