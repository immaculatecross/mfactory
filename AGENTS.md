# Agent instructions — mfactory

You are working on mfactory itself: the system that builds products, not a product. Small core, deterministic enforcement, honest docs — read PRODUCT.md §Operating principles if in doubt.

**Boot order:** `STATE.md` → `FEATURES.md` → `DECISIONS.md` (settled calls — don't re-litigate) → `ARCHITECTURE.md` for the map. `LOG.md` has the history; `verbs/` has the playbooks; `enforcement/` is the deterministic layer; `templates/` is what products are born with.

**Rules:** lessons become enforcement (D-017) — encode every lesson as a tripwire, test, or playbook line the same day; a prose-only lesson is considered lost. Branch protection is armed — every change is a PR through CI. Hooks are armed locally (`core.hooksPath enforcement/hooks`): Conventional Commits, 500-line file cap, tripwires. Every change updates LOG.md (and FEATURES.md if statuses moved, STATE.md at session end) in the same PR. Every failure message you write must state its own fix. `gstack-main/` is unversioned reference — loot ideas, never import files.
