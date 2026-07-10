# State

> Boot sector: the first read of every fresh session. Regenerated at the end of each work session — keep it one screen.

mfactory is in early Build. Founding docs are complete (D-001…D-015). The enforcement pack (`enforcement/`) and the product scaffolder (`bin/mfactory-new`) exist; hooks are armed on this repo via `core.hooksPath`, and `.github/workflows/ci.yml` self-tests the pack on every push.

GitHub: `immaculatecross/mfactory` (public), default branch `master`, **branch protection armed** (required check `self-check`, admins included) — all changes go through PRs now. Identity (D-016): immaculatecross is the factory account (`gh` auth + `~/.mfactory/owner`); matmauro01 is the human's. The factory's token deliberately lacks `delete_repo`.

F-002 is built and live-tested (`mfactory-smoke` created with labels + protection; awaiting Mattia's manual deletion). Next ready work: F-004 (build-loop verb), F-008 (define verbs). `gstack-main/` is unversioned reference material — loot, don't import (D-001).
