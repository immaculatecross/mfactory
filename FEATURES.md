# Features — mfactory v1

Single source of truth for what gets built. Statuses: `backlog` → `building` → `built` → `verified`. Proposals enter as `unapproved` (max 5 open) and become `backlog` only on Mattia's approval. Ordering reflects dependencies: each feature assumes the ones above it.

| ID | Status | Feature | Acceptance criteria |
|---|---|---|---|
| F-001 | built | Founding docs | PRODUCT, DECISIONS, ARCHITECTURE, FEATURES, LOG exist, are concise, and a fresh session can boot from them alone. |
| F-002 | built | Product scaffolder | One command creates a new product repo with all Layer-1 artifacts, git, a fresh GitHub repo under the factory account (`gh repo create`), branch protection. |
| F-003 | built | Enforcement pack | Pre-commit config, CI workflow templates (all gates from ARCHITECTURE §Layer 3), harness hooks, tripwire library; every failure message states its own fix. |
| F-004 | built | Build loop (`build` verb) | Foreman playbook + work-order template + builder playbook; runs one full cycle unattended: pick ready work → branch → build → PR. |
| F-005 | built | Adversarial review (`review` verb) | Isolated reviewer produces verdict artifact; wired as required GitHub check; flags, never rewrites. |
| F-006 | backlog | Task graph integration | Beads installed and synced with FEATURES.md; Foreman computes "next work" from the graph; decisions.jsonl mirror of DECISIONS.md. |
| F-007 | backlog | OpenClaw Owner | Owner persona on the box: outbound updates, CONTROL.md steering queue, verb dispatch, emergency kill. |
| F-008 | backlog | Define verbs (`ideate`, `plan`) | Interactive playbooks producing PRODUCT/DECISIONS/CONTRACTS/approved FEATURES with acceptance criteria. |
| F-009 | backlog | QA verb | Browser-driven product testing against acceptance criteria (gstack browse daemon or equivalent); findings filed to the graph. |
| F-010 | backlog | Ship verb | Deploy (or deliver deploy instructions), repo-clean check, docs audit gate. |
| F-011 | backlog | `simplify`, `status`, `teach` verbs | Simplify passes under green tests; status reports from artifacts only; teach walks Mattia through LOG + DECISIONS + diffs. |
| F-012 | backlog | Feedback pipeline + `enhance` | feedback/ triage into bug/feature/UX-UI/performance/tech-debt with evidence counts; capped unapproved proposals; synthetic-user cold-walk report. |
| F-013 | backlog | Maintenance mode | Cron-triggered `maintain` on the box: triage, health review, fix PRs through standard gates. |
| F-014 | backlog | Dogfood build #1 | mfactory builds and deploys a complete language-learning app with human input limited to WhatsApp approvals. This is the v1 exit test. |
