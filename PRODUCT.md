# mfactory

**What it is.** mfactory is an operating system for long-horizon autonomous product building. It takes an AI coding agent that is strong for hours and makes it dependable for weeks: from ideation with a human sparring partner, through fully autonomous execution, to a deployed, documented, maintained product — controlled live from WhatsApp via OpenClaw.

**Why it exists.** Today's agents (Claude Code, Codex, Cursor CLI) build impressive things in a sitting and degrade over days. The failure is never intelligence; it is state (context rot), discipline (vague prompts instead of enforced rules), and verification (the agent grading its own homework). mfactory closes those three gaps with three thin layers: **artifacts** (durable state in files), **verbs** (callable entry points), and **enforcement** (deterministic gates). Prompts stay small; rules stay mechanical.

## The five capabilities

1. **Sparring partner in ideation** — helps decide *what* to build.
2. **Trade-off surfacing** — asks the questions that matter, decides *how* together with the operator.
3. **Autonomous execution** — builds the product end to end without supervision, e.g. a complete language-learning app from an approved feature file.
4. **Traceable docs** — concise records of what was decided, done, and why; every merge accountable.
5. **Teaching** — on request, explains what was built and why, sourced from the log and decisions.

## Operating principles

- **Ownership lives in a persona, not a process.** One agent identity (the Owner, on OpenClaw) owns each product across weeks. Its memory is the artifact layer, never a long-lived context window.
- **Deterministic beats vague.** Anything that can be a hook, linter, CI gate, or tripwire test must be one. The error message is the prompt.
- **No agent grades its own homework.** Review, QA, and synthetic-user testing run in fresh sessions with no access to the builder's reasoning.
- **Harness-agnostic.** mfactory is markdown + scripts + git conventions. The runner (Claude Code, Codex, Cursor) is a plug.
- **Small core.** The whole of mfactory must remain readable in one evening. Complexity budget is spent on enforcement and verification, never on prompt mass.

## Non-goals

- Not a multi-tenant platform or a product for others (yet). Single operator: Mattia.
- Not a prompt library or persona collection.
- Not a replacement for real user research — synthetic feedback generates hypotheses, humans validate.

## Success criteria for v1

- From an approved `FEATURES.md`, mfactory builds and deploys a real product with human input limited to WhatsApp approvals and steering.
- Every change lands as a small GitHub PR that passed CI gates and isolated adversarial review. Zero direct commits to master.
- A fresh agent session can resume any product cold, from artifacts alone, in one read.
- The operator can answer "what happened and why" for any line of the product from the docs, and can ask mfactory to teach it back.
