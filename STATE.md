# State

> Boot sector: the first read of every fresh session. Regenerated at the end of each work session — keep it one screen.

mfactory is in early Build. Founding docs are complete (D-001…D-015). The enforcement pack (`enforcement/`) and the product scaffolder (`bin/mfactory-new`) exist; hooks are armed on this repo via `core.hooksPath`, and `.github/workflows/ci.yml` self-tests the pack on every push.

GitHub: `immaculatecross/mfactory` (public), default branch `master`, **branch protection armed** (required checks `self-check` + `review`, admins included) — all changes go through PRs now. Identity (D-016): immaculatecross is the factory account (`gh` auth + `~/.mfactory/owner`); matmauro01 is the human's. The factory's token deliberately lacks `delete_repo`.

F-002 is built and live-tested (`mfactory-smoke` created with labels + protection; awaiting Mattia's manual deletion). F-004 is built: Foreman/builder playbooks in `verbs/`, work-order contract in `templates/`, all shipped into products by the scaffolder; one full local cycle ran with a genuinely fresh builder session and survived independent verification (PR leg pends the first real product). F-005 is built: `verbs/review.md`, verdict = PR comment + `review` commit status, required on mfactory and in scaffolded products; merge bar everywhere is CI-green **and** review-approve. D-017 armed: lessons must be encoded as tripwire/test/playbook line same-day. Next ready work: F-008 (define verbs), F-006 (task graph). `gstack-main/` is unversioned reference material — loot, don't import (D-001).
