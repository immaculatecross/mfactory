#!/bin/bash
# PR merge rules, run only on pull_request events.
#   size   total changed lines ≤ 400 (lockfiles excluded)
#   tests  source changes require test changes   (waive: 'tests-waived' label)
#   docs   PR must touch LOG.md/FEATURES.md/CHANGELOG.md (waive: 'docs-none' label)
# Env: BASE_REF (target branch name), LABELS (comma-separated PR labels).
set -uo pipefail

MODE="${1:?usage: pr-rules.sh size|tests|docs}"
BASE="origin/${BASE_REF:?BASE_REF not set}"
MAX_DIFF=400

has_label() { case ",${LABELS:-}," in *",$1,"*) return 0 ;; esac; return 1; }

CHANGED=$(git diff --name-only "$BASE"...HEAD)

case "$MODE" in
  size)
    n=$(git diff --numstat "$BASE"...HEAD -- . \
        ':(exclude)package-lock.json' ':(exclude)yarn.lock' \
        ':(exclude)pnpm-lock.yaml' ':(exclude)bun.lock*' \
        | awk '{ if ($1 != "-") s += $1 + $2 } END { print s + 0 }')
    if [ "$n" -gt "$MAX_DIFF" ]; then
      {
        echo "BLOCKED: PR changes $n lines (cap $MAX_DIFF, lockfiles excluded)."
        echo "  Fix: split this into smaller PRs. Small blocks are what make review"
        echo "  and per-PR agent sessions reliable — this cap is load-bearing."
      } >&2
      exit 1
    fi
    echo "pr size: $n lines — ok."
    ;;
  tests)
    src=$(printf '%s\n' "$CHANGED" | grep -E '\.(ts|tsx|js|jsx|mjs|cjs|py|go|rb)$' \
          | grep -vE '(^|/)(test|tests|__tests__)/|\.(test|spec)\.' || true)
    tst=$(printf '%s\n' "$CHANGED" \
          | grep -E '(^|/)(test|tests|__tests__)/|\.(test|spec)\.' || true)
    if [ -n "$src" ] && [ -z "$tst" ] && ! has_label tests-waived; then
      {
        echo "BLOCKED: source files changed but no test files did."
        echo "  Fix: add or update tests for the changed behavior. Only if the change"
        echo "  is genuinely untestable, add the 'tests-waived' label and say why in the PR."
      } >&2
      exit 1
    fi
    echo "tests-accompany-src: ok."
    ;;
  docs)
    if ! printf '%s\n' "$CHANGED" | grep -qE '(^|/)(LOG\.md|FEATURES\.md|CHANGELOG\.md)$' \
       && ! has_label docs-none; then
      {
        echo "BLOCKED: no doc trail. Every PR appends what happened to LOG.md and,"
        echo "  if features changed state, updates FEATURES.md."
        echo "  Fix: add the LOG.md entry, or add the 'docs-none' label with a reason."
      } >&2
      exit 1
    fi
    echo "docs gate: ok."
    ;;
  *)
    echo "usage: pr-rules.sh size|tests|docs" >&2; exit 2 ;;
esac
