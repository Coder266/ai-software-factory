---
id: EXP-XEYYQL
title: Run refine / review / QA as isolated agents
epic: factory-v2
status: in-progress
estimate: 4d
created: 2026-06-21 21:22
branch: story/step-agents-isolated
---

# EXP-XEYYQL — Run refine / review / QA as isolated agents

## Description

Only the implementer currently runs as a subagent; `/refine`, `/review`, and `/qa` run in the
main conversation, so the heavy work pollutes the orchestrator's context and the steps can lean
on conversation state instead of the durable artifacts. This makes each step a proper isolated
agent — like the implementer. By default each receives **only** the story id, the repo, and its
relevant guideline subset — not the orchestrator's whole conversation — though the orchestrator
may pass along **specific extra context when the human explicitly asks**. The existing command
files become thin dispatchers that spawn the agent.

This keeps each step focused and context-clean, and pushes handoffs through durable artifacts
(PR comments, the story's `## QA` section, `/set-status` transitions) rather than conversation —
which is what lets the orchestrator drive an epic without dragging one giant context around.

## Acceptance Criteria

- [ ] Given `.claude/agents/`, when you list it, then `refine.md`, `review.md`, and `qa.md` exist alongside `implementer.md`, each with `name`/`description`/`tools` frontmatter mirroring the implementer's shape.
- [ ] Given each agent's `tools`, when you read them, then they match its role: refine = Read/Write/Edit/Grep/Glob/Bash; review = read-only Bash + `gh` + Skill, **no** Edit/Write; qa = Read/Grep/Glob/Bash/Edit (story `## QA` only) + Skill.
- [ ] Given `.claude/commands/{refine,review,qa}.md`, when you read them, then each is a thin dispatcher that spawns its agent with the story id + repo + guideline subset by default — **not** the orchestrator's whole conversation — while still able to include specific extra context the human explicitly directs.
- [ ] Given a step run via its command, when it completes, then it produces the same durable artifact as today (refine → story files; review → GitHub PR comments; qa → PASS or a `## QA` section) without inheriting the orchestrator's whole conversation.
- [ ] Given the review and qa agents, when they need isolation from the working tree, then they run in a git worktree (matching the implementer pattern); refine writes story docs to the tracked backlog.
- [ ] Given a status transition during any step, when the agent advances the story, then it uses `/set-status` rather than editing frontmatter directly.

## Implementation Details

- Create the three agent definitions, porting the persona/boundaries from the current command
  files; leave the shared standards in the guidelines (don't restate them).
- Rewrite the three command files as dispatchers (spawn the agent with a scoped prompt). The
  orchestrator-as-skill story ([`EXP-0IOKY4`](EXP-0IOKY4-orchestrator-as-skill.md)) will call these.
- Context isolation is the **default**, not a hard wall: a freshly spawned agent starts cold, so
  the dispatcher passes only the story id + repo + guideline pointers unless the human has asked
  for extra context to be forwarded. Verify by inspecting what the dispatcher passes.
- How review/QA findings get back to the implementer (a kept-alive implementer vs. cold
  reconstruction) is owned by [`EXP-0IOKY4`](EXP-0IOKY4-orchestrator-as-skill.md), not here.

## Out of Scope

- The orchestrator/`/factory` skill that dispatches these (**[EXP-0IOKY4](EXP-0IOKY4-orchestrator-as-skill.md)**).
- Implementer permission changes (**[EXP-8CIOB4](EXP-8CIOB4-implementer-edit-without-asking.md)**).

## Dependencies

- Depends on **[EXP-VJ93VD](EXP-VJ93VD-set-status-capability.md)** (agents call `/set-status`).
- Pairs with **[EXP-0IOKY4](EXP-0IOKY4-orchestrator-as-skill.md)** (orchestrator dispatches these agents and owns the kept-alive
  implementer).

## Status

`ready` — refined and unblocked _(2026-06-21 21:22)_
`in-progress` — implementing _(2026-06-22 13:41)_
`under-review` — code review settled, handed to QA _(2026-06-22 14:19)_
`in-progress` — QA bounce — back to fix _(2026-06-22 17:20)_
