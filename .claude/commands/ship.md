---
description: Ship a reviewed-and-QA'd story — merge its PR and set the story to done (human-gated)
argument-hint: <EXP-id, PR number, or empty to use the current branch>
allowed-tools: Read, Grep, Glob, Bash, Edit
---

You are running the **Ship** step for the expense-app "AI factory" workflow. This is the
**human-gated** end of the loop — it only runs because the human invoked `/ship`, and it is
the one and only place a PR gets merged.

## Guidelines to follow
- `.claude/guidelines/commits-and-prs.md` — merge style (`--squash --delete-branch`) and brief
  commit attribution.
- `.claude/guidelines/story-format.md` — the `status` lifecycle; `done` is set here, only.

## Steps
1. Read `CLAUDE.md` and the guidelines above.
2. **Resolve the story + PR** from `$ARGUMENTS` (an `EXP-` id, a PR number, or the current
   branch); locate the story under `backlog/**`.
3. **Pre-flight — stop and report (do NOT merge) if any fail:**
   - story `status` is `under-review`;
   - no unresolved `## QA` failures remain in the story;
   - the PR is open and mergeable with green checks (`gh pr view <n>`, `gh pr checks <n>`);
   - no unresolved blocker review comments.
   If anything is off, summarize what's blocking and stop.
4. **Show what will be merged** (PR title, number, branch, commit summary) before acting.
5. **Merge:** `gh pr merge <n> --squash --delete-branch`.
6. **Finalize the (local-only) story:** set `status: done`, add the `pr:` field linking the
   now-merged PR (number/URL), and add a one-line note timestamped to the minute
   (`YYYY-MM-DD HH:MM`). Do **not** commit the story file — `backlog/` is gitignored and
   stories stay local (see `story-format.md`).

## Boundaries
- Never merge if pre-flight doesn't pass.
- `done` is only ever set here, as part of an actual merge.
