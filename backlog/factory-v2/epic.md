---
slug: factory-v2
title: Full review & cleanup of the AI factory
status: in-progress
created: 2026-06-21 21:22
---

# factory-v2 — Full review & cleanup of the AI factory

## Goal

Make the AI-factory workflow itself trustworthy and pleasant to run, after the first epic
(`dev-environment`) exposed how rough it was. Plain `claude` should be free for ad-hoc work;
the factory should be invoked explicitly, run its steps as isolated agents, track its own
planning artifacts in the repo, and drive a whole epic **story-by-story** — pausing for the
human to review (and ship) each story's PR before moving on to the next.

## Scope

In scope — the **factory machinery only** (no expense-app product code):

- Make backlog stories tracked/referenceable in the repo instead of gitignored.
- Give epics a real definition (`epic.md`) and a status lifecycle, seeded from `/refine`.
- A dedicated `/set-status` capability so agents stop hand-editing frontmatter.
- Run refine/review/qa as isolated agents (like the implementer), context-clean.
- Turn the always-on orchestrator into an explicit `/factory` skill.
- A sequential, dependency-ordered epic run that advances story-by-story, pausing for your
  review at each story's PR.
- Protect `main`; let the implementer edit without per-change prompts.
- Terminology/naming cleanup so named steps map 1:1 to real commands.

### Out of scope

- Any expense-app feature/product work.
- **Parallel** epic execution — v1 is sequential; fan-out is deferred.
- Auto-merge / auto-ship — `/ship` stays human-gated.

## Acceptance Criteria

- Plain `claude` is no longer in "factory mode"; `/factory` is the explicit entry point.
- Story files are browseable/linkable on GitHub, without polluting code PR diffs.
- Every epic has an `epic.md` with a tracked status; `/refine`'s seed has a home.
- The human can run `/factory <epic>` (e.g. `/factory factory-v2`) and it drives the epic one
  story at a time, pausing for review/ship at each story's PR before starting the next.
- Agents advance status via `/set-status`; refine/review/qa run isolated from the main thread.
- `main` is protected (with owner bypass for story-docs + `/ship`).

## Seed

> "We did a first story and the factory was obviously a mess. The stories being gitignored
> means I can't reference them. The epic needs a definition, and the refine agent needs an
> initial prompt from me — it's not clear where that comes from. I want a full review and
> cleanup of the factory, plus any other changes the refine agent thinks worth doing. And I
> want to tell the factory to implement an epic and come back to the PRs ready to review."
>
> — human, 2026-06-21

## Stories

9 stories, all `ready`. Suggested order:

1. [`EXP-4BOJH5` — Track backlog stories in the repo (un-gitignore)](EXP-4BOJH5-track-backlog-in-repo.md)
2. [`EXP-FAEXWN` — Epics get a definition + status lifecycle](EXP-FAEXWN-epic-definition-lifecycle.md)
3. [`EXP-VJ93VD` — `/set-status` capability](EXP-VJ93VD-set-status-capability.md)
4. [`EXP-XEYYQL` — refine/review/qa as isolated agents](EXP-XEYYQL-step-agents-isolated.md)
5. [`EXP-0IOKY4` — Orchestrator → `/factory` skill (single-step)](EXP-0IOKY4-orchestrator-as-skill.md)
6. [`EXP-I4KR50` — Sequential, dependency-ordered epic run](EXP-I4KR50-epic-batch-run.md)
7. [`EXP-TM33HL` — Protect the main branch](EXP-TM33HL-protect-main-branch.md)
8. [`EXP-8CIOB4` — Implementer edits without asking](EXP-8CIOB4-implementer-edit-without-asking.md)
9. [`EXP-HK08SK` — Terminology & naming cleanup](EXP-HK08SK-terminology-cleanup.md)
