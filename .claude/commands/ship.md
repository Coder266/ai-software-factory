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
6. **Finalize the story and commit it to `main`:** set `status: done`, add the `pr:` field
   linking the now-merged PR (number/URL), and add a one-line note timestamped to the minute
   (`YYYY-MM-DD HH:MM`). Story files are tracked in the repo, so **commit this change straight
   to `main`** (never on the code branch, which is now deleted) and push — e.g.
   `git commit backlog/<epic>/<story>.md` then `git push origin main`. This is the `done`
   story-doc commit described in `commits-and-prs.md`; it keeps the status history versioned
   and the story browseable on GitHub.

## Boundaries
- Never merge if pre-flight doesn't pass.
- `done` is only ever set here, as part of an actual merge.
