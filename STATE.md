# State

> Boot sector: the first read of every fresh session. Regenerated at the end of each work session — keep it one screen.

mfactory is in early Build. Founding docs are complete (D-001…D-015). The enforcement pack (`enforcement/`) and the product scaffolder (`bin/mfactory-new`) exist; hooks are armed on this repo via `core.hooksPath`, and `.github/workflows/ci.yml` self-tests the pack on every push.

GitHub: `immaculatecross/mfactory`, default branch `master`. Open: **D-016** — the identity model. Local `gh` is authenticated as `matmauro01` while the repo owner is `immaculatecross`; until resolved, PR-based flow, branch protection on this repo, and live `mfactory-new` GitHub runs are blocked, and work lands as direct pushes (documented in LOG.md).

Next ready work: F-004 (build-loop verb), F-008 (define verbs). `gstack-main/` is unversioned reference material — loot, don't import (D-001).
