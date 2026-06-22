---
id: EXP-VJ93VD
title: Dedicated "/set-status" capability for agents
epic: factory-v2
status: under-review
estimate: 2d
created: 2026-06-21 21:22
branch: story/set-status-capability
---

# EXP-VJ93VD — Dedicated "/set-status" capability for agents

## Description

Status transitions are currently done by hand-editing a story's frontmatter, which means every
agent needs broad edit access and can get the lifecycle subtly wrong (illegal jumps, missing the
timestamped note, accidentally setting `done`). This adds one small, dedicated capability —
`/set-status` — whose only job is to advance a story's `status` consistently. Agents call it
instead of editing the file, so transitions are uniform and safe.

## Acceptance Criteria

- [ ] Given a story at `ready`, when you run `/set-status EXP-x in-progress`, then the story's `status:` becomes `in-progress` **and** a timestamped (`YYYY-MM-DD HH:MM`) note recording the transition is added.
- [ ] Given an illegal transition (e.g. `new → under-review`, or skipping a stage), when you run `/set-status`, then it is **rejected** with a clear message and the file is unchanged.
- [ ] Given any request to set `done`, when you run `/set-status EXP-x done`, then it is **refused** with a message pointing to `/ship` (only `/ship` sets `done`, via an actual merge).
- [ ] Given a `/set-status` run, when it succeeds, then it updates **both** the frontmatter `status:` field **and** a visible `## Status` block kept as the **final section** of the story body (status word + timestamp), keeping them in sync — so the current status is readable without parsing frontmatter.
- [ ] Given a story with a `## QA` section, when it is present, then `## QA` sits **immediately above** the final `## Status` block (QA never pushes Status out of last position).
- [ ] Given a successful `/set-status`, when it finishes, then it commits the updated story file **directly to `main`** per the story-storage flow (**[EXP-4BOJH5](EXP-4BOJH5-track-backlog-in-repo.md)**) — not to a code branch or a PR.
- [ ] Given a `/set-status` run, when it succeeds, then it modifies **only** the `status` field, the visible `## Status` block, and the transition note — never code, never the `pr:` field, never other frontmatter.
- [ ] Given the legal lifecycle, when you run each valid transition (`new→ready`, `ready→in-progress`, `in-progress→under-review`, `under-review→in-progress` for a QA bounce), then each is accepted.
- [ ] Given the implementer, `/refine`, and `/qa` agents, when they advance a story, then their docs instruct them to call `/set-status` rather than hand-edit frontmatter.

## Implementation Details

- Add `.claude/commands/set-status.md` (consistent with the other workflow commands).
- Encode the legal-transition table from `story-format.md`'s lifecycle; reject anything not in
  it. Treat `→ done` as always-refused here.
- The command owns the `status` field, the visible `## Status` body block, and the timestamped
  note only. The `pr:` link and the `done` finalization remain `/ship`'s job.
- After updating the file, `/set-status` commits the change **directly to `main`** (story docs
  are tracked there per **[EXP-4BOJH5](EXP-4BOJH5-track-backlog-in-repo.md)**; the owner bypass in **[EXP-TM33HL](EXP-TM33HL-protect-main-branch.md)** lets it land) — it
  never opens a PR or touches a code branch.
- Document the `## Status` body-section convention in `story-format.md` (a bottom block mirroring
  the frontmatter `status:`), so every story shows its status without reading frontmatter.
- `## Status` is always the **final** section of a story. Update `reviews.md` / `/qa` so a
  `## QA` section is **inserted immediately above `## Status`** (not appended at end-of-file), and
  note the canonical section order in `story-format.md`.
- Update the implementer agent and the `refine`/`qa` docs to call `/set-status` for the
  transitions they own.

## Out of Scope

- Setting the `pr:` field or `done` (both stay in `/ship`).
- Epic status transitions (those are [`EXP-FAEXWN`](EXP-FAEXWN-epic-definition-lifecycle.md) / the orchestrator).

## Dependencies

- Pairs with **[EXP-XEYYQL](EXP-XEYYQL-step-agents-isolated.md)** (the step agents call `/set-status`) and **[EXP-0IOKY4](EXP-0IOKY4-orchestrator-as-skill.md)** (the
  orchestrator relies on it).

## Status

`under-review` — code review settled (PR #5 approved, 0 blockers), handed to QA _(2026-06-22 10:09)_
