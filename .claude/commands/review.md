---
description: Review a story's PR against its acceptance criteria and post findings as GitHub PR comments (dispatches the review agent)
argument-hint: <EXP-id, PR number, or empty to use the current branch>
allowed-tools: Task
---

You are a **thin dispatcher** for the Review step. You do **not** review in this conversation —
you spawn the **`review`** agent (`.claude/agents/review.md`) to do it in isolation, so the
review's static analysis stays out of the orchestrator's context and the step leans on durable
artifacts (the PR diff, the story's Acceptance Criteria, and the GitHub PR comments it posts).

## Dispatch

Spawn the `review` subagent (`isolation: worktree`, matching how the implementer is spawned —
to keep the review's static analysis isolated from the orchestrator's working tree). The review
itself is **`gh`-driven**: `agents/review.md` step 4 runs `/code-review high --comment <PR#>`,
which gathers the PR diff from GitHub by PR number rather than the local tree, so it does **not**
depend on which branch the worktree is on. (Contrast the qa agent, which *does* check out the PR
branch because it runs the app.) Give it a **scoped** prompt that by default contains **only**:

- the target from `$ARGUMENTS` — an `EXP-` id, a PR number, or empty (use the current branch);
- a pointer to the repo and its guidelines — the agent reads `.claude/guidelines/reviews.md`,
  `story-format.md`, and `CLAUDE.md` itself, and resolves the story and PR from the id/branch;
- nothing else from this conversation.

**Do not** forward the orchestrator's whole conversation — the agent starts cold on purpose and
reconstructs everything from the story doc and the PR. The **only** exception: if the human has
**explicitly** asked you to pass along specific extra context (a particular concern to focus
on, a constraint), include exactly that, and nothing more.

## Output

The agent's durable artifact is its **GitHub PR comments** (it never edits code or the story,
never changes status). When it finishes, relay its summary: the one-line verdict
(`Approved` / `Changes requested` / `Needs discussion`), the blocker-finding count, and the
per-criterion `met / unmet / unclear` list.

## Boundaries
- You dispatch; you do not review, edit code or the story, change status, or merge.
- The agent posts PR comments only; the implementer (not the reviewer) addresses them and moves
  the status via `.claude/bin/set-status`.
