---
id: EXP-I4KR50
title: Sequential, dependency-ordered epic run
epic: factory-v2
status: ready
estimate: 3d
created: 2026-06-21 21:22
branch: story/epic-batch-run
---

# EXP-I4KR50 — Sequential, dependency-ordered epic run

## Description

The factory should drive a whole epic without you hand-kicking each story — but **one story at a
time**, with you reviewing (and shipping) each story's PR before the next one begins. This adds an
**epic-run mode** to `/factory`: given an epic, it orders the `ready` stories by dependency and
processes them sequentially. For each story it spawns a fresh implementer and runs
implement → review → fix → QA to `under-review`, then **pauses for you to review and `/ship` that
story's PR**. Once you've shipped it, the orchestrator automatically advances to the next
dependency-ready story, spawning new agents for it.

So there is **no "walk away and collect a stack of PRs"**: only one story is ever in flight, and
you remain the per-story review/ship gate. The win is narrower but real — the orchestrator keeps
the epic *moving* (dependency-ordered, spawning the agents for each story) instead of you
launching every story by hand.

v1 is **sequential**, which also sidesteps parallel agents colliding on shared files and lets a
dependent story build on its predecessor's *already-shipped* base. To order stories mechanically,
this adds a `depends_on:` story frontmatter field.

## Acceptance Criteria

- [ ] Given `story-format.md`, when you read it, then the optional `depends_on:` frontmatter field (a list of `EXP-` ids) is documented.
- [ ] Given `/factory <epic-slug>`, when it runs, then it topologically orders the epic's `ready` stories by `depends_on` and processes them **one at a time** in that order.
- [ ] Given a story's turn, when it runs, then it goes implement → automated review → fix-loop → QA to `status: under-review`, then **pauses for the human to review and `/ship` that story's PR** before the next story starts.
- [ ] Given a story the human has just shipped, when `/ship` completes, then the orchestrator **automatically advances** to the next dependency-ready story (spawning fresh agents for it) without the human re-invoking `/factory`.
- [ ] Given the start of an epic run, when `/factory <epic>` kicks off, then the epic's `status` flips to `in-progress` (per **[EXP-FAEXWN](EXP-FAEXWN-epic-definition-lifecycle.md)**); when the last story is shipped, the epic goes `done`.
- [ ] Given a story that cannot proceed (a real blocker, or an unmet/unshipped dependency), when the run reaches it, then `/factory` **halts and reports** it rather than silently skipping.
- [ ] Given a dependency cycle in `depends_on`, when `/factory` orders the epic, then it reports the cycle instead of looping forever.
- [ ] Given the per-story flow, when the run proceeds, then the human pauses **once per story** (to review/ship its PR); the automated `/review`→fix loop runs unattended *within* each story, and only one story is in flight at a time.

## Implementation Details

- Add `depends_on:` to the story-format spec; default empty/absent = no deps.
- Extend the `/factory` skill (from **[EXP-0IOKY4](EXP-0IOKY4-orchestrator-as-skill.md)**) with an epic-run loop: gather `ready` stories,
  topo-sort, then for each one drive its single-step pipeline to `under-review`, surface its PR
  for the human, and — after the human ships — advance to the next.
- Reuse the single-step dispatch + review→fix loop + the kept-alive implementer from
  **[EXP-0IOKY4](EXP-0IOKY4-orchestrator-as-skill.md)**; this story adds the ordering, the per-story human gate, the auto-advance, and
  the epic-status transitions.

## Out of Scope

- **Parallel** execution / fan-out of independent stories — intentionally deferred; sequential
  only for now.
- Auto-shipping — `/ship` stays human-gated, once per story.

## Dependencies

- Depends on **[EXP-0IOKY4](EXP-0IOKY4-orchestrator-as-skill.md)** (single-step `/factory` + kept-alive implementer) and **[EXP-FAEXWN](EXP-FAEXWN-epic-definition-lifecycle.md)**
  (epic status to flip).

## Status

`ready` — refined and unblocked _(2026-06-21 21:22)_
