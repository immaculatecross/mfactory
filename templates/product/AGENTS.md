# Agent instructions — __PRODUCT__

This repo is operated by mfactory. Whatever session you are, start the same way:

**Boot order:** `STATE.md` (current truth, one screen) → `FEATURES.md` (what's approved, building, built) → your work order if you have one (`.mfactory/work-orders/`). Playbooks live in `.mfactory/verbs/`.

**Rules that bind every session:**
- All changes ride branches and PRs; one feature per PR. The hooks (`.mfactory/hooks/`, armed via `core.hooksPath`) and CI gates are authoritative — fix causes, don't fight gates. Waivers (`mfactory-allow:<id>`) carry their reason on the same line.
- Tests accompany code; docs (LOG.md entry, FEATURES.md status, STATE.md regen) ride in the same PR.
- `CONTRACTS/` is inviolable without a DECISIONS.md entry.
- Gate commands: `npm run lint`, `npm run typecheck`, `npm run test`.

**Steering:** Mattia's instructions arrive in `CONTROL.md`; only the Foreman drains it.
