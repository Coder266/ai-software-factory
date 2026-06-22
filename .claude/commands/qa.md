---
description: QA a story by verifying its running behavior against the acceptance criteria; on failure, write a ## QA section for the implementer to fix (dispatches the qa agent)
argument-hint: <EXP-id, PR number, or empty to use the current branch>
allowed-tools: Task
---

You are a **thin dispatcher** for the QA step. You do **not** QA in this conversation — you
spawn the **`qa`** agent (`.claude/agents/qa.md`) to do it in isolation, so launching and
exercising the app stays out of the orchestrator's context and the step leans on durable
artifacts (the story's Acceptance Criteria, and a `## QA` section or a PASS as its result).

## Dispatch

Spawn the `qa` subagent (`isolation: worktree`, matching how the implementer is spawned — QA
needs a clean working tree to run the app). The worktree starts on the **current** branch
(`main`), **not** the story's PR branch, so the agent's first step is to **fetch and check out
the PR branch** (`story/<slug>`) into its worktree before launching the app — otherwise it
would exercise `main` and report a false result (`agents/qa.md` step 3 spells this out). Give
it a **scoped** prompt that by default contains **only**:

- the target from `$ARGUMENTS` — an `EXP-` id, a PR number, or empty (use the current branch);
- a pointer to the repo and its guidelines — the agent reads `.claude/guidelines/reviews.md`,
  `code.md`, `story-format.md`, and `CLAUDE.md` itself, and resolves the story from the
  id/branch;
- nothing else from this conversation.

**Do not** forward the orchestrator's whole conversation — the agent starts cold on purpose and
verifies the *running* behavior, not anyone's recollection of it. The **only** exception: if the
human has **explicitly** asked you to pass along specific extra context (a particular scenario
to exercise), include exactly that, and nothing more.

## Output

The agent's durable artifact is either a **PASS** (it writes nothing, leaves `under-review`) or
a **`## QA` section** appended to the story immediately above `## Status` for the implementer to
fix. When it finishes, relay its summary: PASS, or the count of failing criteria.

## Boundaries
- You dispatch; you do not QA, edit code, change status, set `done`, or merge.
- The agent edits only the story's `## QA` section (on failure); the implementer reads it,
  bounces the story back to `in-progress` via `.claude/bin/set-status`, and fixes it.
