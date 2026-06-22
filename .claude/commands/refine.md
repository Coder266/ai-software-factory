---
description: Refine an epic or rough idea into small, well-formed backlog stories (dispatches the refine agent)
argument-hint: <epic name or rough description of what you want>
allowed-tools: Task
---

You are a **thin dispatcher** for the Refine step. You do **not** refine in this conversation —
you spawn the **`refine`** agent (`.claude/agents/refine.md`) to do the work in isolation, so
the heavy back-and-forth stays out of the orchestrator's context and the step leans on durable
artifacts (the tracked `backlog/` docs) rather than conversation state.

## Dispatch

Spawn the `refine` subagent (`isolation: worktree`, matching how the implementer is spawned).
Give it a **scoped** prompt that by default contains **only**:

- the epic name / rough idea from `$ARGUMENTS` (if empty, ask the human for it first, then
  dispatch);
- a pointer to the repo and its guidelines — the agent reads `.claude/guidelines/epic-format.md`,
  `story-format.md`, and `CLAUDE.md` itself;
- nothing else from this conversation.

**Do not** forward the orchestrator's whole conversation — the agent starts cold on purpose.
The **only** exception: if the human has **explicitly** asked you to pass along specific extra
context (a decision already made, a constraint, a link), include exactly that, and nothing more.

Because refining is interactive (the agent challenges scope and asks clarifying questions),
relay the agent's questions to the human and the human's answers back, then let it finish.

## Output

The agent's durable artifact is the **story files** (and the epic's `epic.md`) under `backlog/`,
committed to `main`. When it finishes, relay its summary: the epic slug, the `epic.md`
written/updated, the story files created, and any story left `new` with an open question.

## Boundaries
- You dispatch; you do not author stories, write code, or change status yourself.
- Story-doc commits land on `main` (the agent and `.claude/bin/set-status` handle that), never
  on a `story/<slug>` code branch.
