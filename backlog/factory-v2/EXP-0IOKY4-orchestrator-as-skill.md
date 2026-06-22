---
id: EXP-0IOKY4
title: Make the orchestrator a /factory skill, not the main context
epic: factory-v2
status: in-progress
estimate: 4d
created: 2026-06-21 21:22
branch: story/orchestrator-as-skill
---

# EXP-0IOKY4 — Make the orchestrator a /factory skill, not the main context

## Description

Today the main assistant *is* the orchestrator — the "Orchestrator guidelines" load from
`CLAUDE.md` every session, so plain `claude` is always in "factory" mode even when you just want
to ask a question or make a quick repo change. Instead, orchestration should be invoked
**explicitly** via `/factory`, leaving plain `claude` free for ad-hoc work.

The `/factory` skill's job is to **dispatch** the step agents and pause for the human at the
**review** and **ship** steps — it does not do the work itself. This story delivers the
**single-step dispatch** orchestrator; the sequential epic run is built on top in [`EXP-I4KR50`](EXP-I4KR50-epic-batch-run.md).

Because the step agents are isolated ([`EXP-XEYYQL`](EXP-XEYYQL-step-agents-isolated.md)) and status lives in story/epic files,
`/factory` can reconstruct "where each story stands" fresh on every invocation — it never
*depends* on always-on conversation, though the human can still hand it extra context when useful.

## Acceptance Criteria

- [ ] Given the repo, when you look in `.claude/commands/` (or skills), then a `/factory` entry exists containing the orchestrator routing + loop logic.
- [ ] Given `CLAUDE.md`, when you read it, then the "Orchestrator guidelines (read every session)" section is **gone**, replaced by a short pointer to `/factory`; the repo facts, stack, and sensitive-data rules remain.
- [ ] Given a plain `claude` session (no `/factory`), when you start it, then it does **not** behave as the orchestrator (it won't auto-drive the workflow).
- [ ] Given `/factory` with a human request, when you route "refine / implement / review / qa / ship", then it dispatches the matching isolated step agent (per **[EXP-XEYYQL](EXP-XEYYQL-step-agents-isolated.md)**) and uses `/set-status` (per **[EXP-VJ93VD](EXP-VJ93VD-set-status-capability.md)**).
- [ ] Given a fresh `/factory` invocation, when it determines next steps, then it can reconstruct where each story stands from story `status` and `epic.md` alone (it does **not depend on** prior conversation) — while remaining free to pass along extra context the human explicitly provides.
- [ ] Given the review→fix→QA loop for a story, when review or QA produce findings, then `/factory` routes them to the **same implementer agent kept alive** (so fixes reuse the original implementation context) — falling back to a freshly spawned implementer that rebuilds context from the PR diff + story + comments if that live session is gone (e.g. after a long human pause).
- [ ] Given a PR with open automated-review comments, when `/factory` runs, then it auto-loops review→fix and only surfaces to the human when no comments remain — and pauses at ship — matching today's documented routing rules.

## Implementation Details

- Move the "Orchestrator guidelines" + routing rules out of `CLAUDE.md` into the `/factory`
  skill; keep `CLAUDE.md` as repo/stack/sensitive-data facts + a one-line pointer.
- `/factory` dispatches the step agents from [`EXP-XEYYQL`](EXP-XEYYQL-step-agents-isolated.md) and transitions status via
  `/set-status` from [`EXP-VJ93VD`](EXP-VJ93VD-set-status-capability.md).
- **Keep the implementer alive** across a story's review/fix/QA loop — resume it with
  `SendMessage` so each fix carries the original implementation context. If that session is no
  longer available (e.g. a long human-review pause spanned it), spawn a fresh implementer that
  reconstructs context from the PR diff, the story, and the review/QA findings (today's Mode B).
- Scope this story to **single-step dispatch + the review→fix auto-loop**. The sequential epic
  run (topo-sorting a whole epic, the per-story human gate, auto-advance) is [`EXP-I4KR50`](EXP-I4KR50-epic-batch-run.md).

## Out of Scope

- The sequential epic run and `depends_on:` ordering (**[EXP-I4KR50](EXP-I4KR50-epic-batch-run.md)**).
- Defining the step agents themselves (**[EXP-XEYYQL](EXP-XEYYQL-step-agents-isolated.md)**) and `/set-status` (**[EXP-VJ93VD](EXP-VJ93VD-set-status-capability.md)**).

## Dependencies

- Depends on **[EXP-XEYYQL](EXP-XEYYQL-step-agents-isolated.md)** (step agents to dispatch) and **[EXP-VJ93VD](EXP-VJ93VD-set-status-capability.md)** (`/set-status`).
- Precedes **[EXP-I4KR50](EXP-I4KR50-epic-batch-run.md)** (epic run builds on this).

## Status

`ready` — refined and unblocked _(2026-06-21 21:22)_
`in-progress` — implementing _(2026-06-22 21:28)_
