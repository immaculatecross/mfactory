#!/usr/bin/env node
// Coverage ratchet: total line coverage may never drop below the committed baseline.
// Baseline: .mfactory/coverage-baseline.json   e.g. { "lines": 82.4 }
// Source:   coverage/coverage-summary.json (istanbul json-summary; vitest/jest emit it)
import { readFileSync, existsSync } from "node:fs";

const SUMMARY = "coverage/coverage-summary.json";
const BASELINE = ".mfactory/coverage-baseline.json";

if (!existsSync(SUMMARY)) {
  console.error(`coverage ratchet: ${SUMMARY} not found — SKIPPED (known v1 gap).`);
  console.error(`  Close it: make "npm run test" emit istanbul coverage`);
  console.error(`  (vitest: --coverage --coverage.reporter=json-summary).`);
  process.exit(0);
}

const pct = JSON.parse(readFileSync(SUMMARY, "utf8")).total.lines.pct;

if (!existsSync(BASELINE)) {
  console.error(`BLOCKED: coverage exists (${pct}% lines) but no baseline is committed.`);
  console.error(`  Fix: commit ${BASELINE} containing {"lines": ${pct}} to arm the ratchet.`);
  process.exit(1);
}

const base = JSON.parse(readFileSync(BASELINE, "utf8")).lines;

if (pct + 0.05 < base) {
  console.error(`BLOCKED: line coverage ${pct}% fell below the baseline ${base}%.`);
  console.error(`  Fix: add tests for the code this change introduces or touches.`);
  console.error(`  The baseline only moves up — never edit it downward to pass.`);
  process.exit(1);
}

if (pct > base + 0.5) {
  console.error(`coverage ratchet: ${pct}% beats baseline ${base}%. Raise ${BASELINE} to lock in the gain.`);
}
console.error(`coverage ratchet: ${pct}% (baseline ${base}%) — ok.`);
