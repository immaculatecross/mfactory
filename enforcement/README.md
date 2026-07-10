# Enforcement

The deterministic layer (ARCHITECTURE.md §Layer 3, D-006). Rules live here as executable checks, never as prompt prose, and every failure message states its own fix — the error message is the prompt.

- `hooks/` — self-contained bundle (pre-commit, commit-msg, tripwire runner + rules). The scaffolder copies it into each product at `.mfactory/hooks/` and arms it via `git config core.hooksPath`. It is also armed on this repo.
- `ci/` — templates the scaffolder installs into each product: `product-gates.yml` (the required merge checks), `pr-rules.sh` (size cap, tests-accompany-src, docs gate), `coverage-ratchet.mjs`.

To add a rule: prefer a tripwire line in `hooks/tripwires.conf` (one line, remediation message required). Any bug class caught twice becomes a tripwire — no exceptions.

Known v1 gaps, on purpose: the coverage ratchet skips until a product emits istanbul coverage (it says so loudly); local secret scanning is regex-only (gitleaks runs in CI with the full ruleset).
