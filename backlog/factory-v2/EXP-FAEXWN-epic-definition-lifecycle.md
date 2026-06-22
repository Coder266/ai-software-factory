---
id: EXP-FAEXWN
title: Epics get a definition and a status lifecycle
epic: factory-v2
status: done
estimate: 3d
created: 2026-06-21 21:22
branch: story/epic-definition-lifecycle
pr: https://github.com/Coder266/expense-app/pull/4
---

# EXP-FAEXWN — Epics get a definition and a status lifecycle

## Description

Today an "epic" is just a directory of stories — it has no definition, no goal, no status, and
no home for the seed you give `/refine`. That's why it's unclear where `/refine`'s initial
prompt comes from. This story gives every epic a **persisted definition** (`epic.md`) and a
**status lifecycle**, so an epic is a first-class thing you can read, track, and resume.

The seed is still provided **when you call** `/refine` (e.g. `/refine factory-v2 "<seed>"`), but
`/refine` now **persists** it into `backlog/<epic>/epic.md` instead of leaving it only in the
conversation. The epic carries its own status — `draft → in-progress → done → cancelled` — so
the factory always knows where an epic stands without relying on always-on context.

It also formalizes the ad-hoc `retro-notes.md` convention (mid-epic human feedback capture) so
`/retro` reliably finds it.

## Acceptance Criteria

- [ ] Given `.claude/guidelines/story-format.md` (or a new `epic-format.md`), when you read it, then it documents `epic.md`: location `backlog/<epic>/epic.md`, frontmatter (`slug`, `title`, `status`, `created`), and body sections (Goal, Scope / Out of scope, **Acceptance Criteria** — named to match the stories, not "Success criteria" — Seed, and an ordered **Stories** list).
- [ ] Given `epic.md`'s Stories list, when you read it, then each entry is a **markdown link to that story's file** (e.g. `[\`EXP-xxx\` — title](EXP-xxx-slug.md)`), so you can click through from the epic to any story.
- [ ] Given the epic status field, when you read the docs, then the enum `draft | in-progress | done | cancelled` is defined with **who/what sets each** (refine → `draft`; epic run/human → `in-progress`; all stories `done` → `done`; human → `cancelled`).
- [ ] Given `/refine factory-v2 "<seed>"` on an epic with no `epic.md`, when it runs, then it creates `backlog/factory-v2/epic.md` with the seed recorded and `status: draft`.
- [ ] Given `/refine` on an epic that already has an `epic.md`, when it runs, then it updates that file rather than duplicating it.
- [ ] Given `/refine` authoring a **new** epic, when it has drafted `epic.md`, then it **presents `epic.md` to the human for confirmation before writing the individual story files** — the epic definition is agreed first.
- [ ] Given mid-epic human feedback, when the orchestrator captures it, then it lands in a documented location (e.g. `backlog/<epic>/retro-notes.md`), and `/retro` is updated to read it as a signal source.
- [ ] Given `CLAUDE.md`'s "offer `/retro` when every story is done", when you read it, then it is reconciled to trigger off the epic reaching `status: done`.

## Implementation Details

- Add the `epic.md` spec to the format guideline; provide a short template (frontmatter + the
  body sections).
- Update `/refine` (`.claude/commands/refine.md`) so step 2 writes/updates `epic.md` from the
  seed argument and **gets the human's sign-off on it** before writing the individual stories.
- Document the `retro-notes.md` convention where it belongs and point `/retro` step 2 at it.
- `epic.md` is tracked in the repo per **[EXP-4BOJH5](EXP-4BOJH5-track-backlog-in-repo.md)**.

## Out of Scope

- The mechanics that flip an epic to `in-progress` during a batch run — that's wired by
  **[EXP-I4KR50](EXP-I4KR50-epic-batch-run.md)**; here we only define the field and its transitions.
- The `depends_on:` story field (**[EXP-I4KR50](EXP-I4KR50-epic-batch-run.md)**).

## Dependencies

- Depends on **[EXP-4BOJH5](EXP-4BOJH5-track-backlog-in-repo.md)** (so `epic.md` is tracked in the repo).
- Related to **[EXP-I4KR50](EXP-I4KR50-epic-batch-run.md)** (consumes epic status) and **[EXP-0IOKY4](EXP-0IOKY4-orchestrator-as-skill.md)** (`/refine` as an agent).

## Status

`ready` — refined and unblocked _(2026-06-21 21:22)_
`in-progress` — implementing on `story/epic-definition-lifecycle` (PR #4) _(2026-06-22 08:40)_
`under-review` — PR #4 approved _(2026-06-22 09:42)_
`done` — shipped via PR #4 (squash-merged to `main`) _(2026-06-22 09:52)_
