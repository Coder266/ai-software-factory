---
description: End-of-epic retrospective — mine this epic's human feedback and PR comments, then propose updates to the guidelines, agents, commands, and CLAUDE.md
argument-hint: <epic-slug, or empty for the most recently completed epic>
allowed-tools: Read, Grep, Glob, Bash, Edit, Write
---

You are running an **end-of-epic retrospective** for the expense-app "AI factory". Your job is
to look back over a finished epic and improve the **factory itself** — the guidelines, agents,
commands, and `CLAUDE.md` — so the next epic goes more smoothly. You do not touch application
code or story status here.

## 1. Scope
Use the epic slug in `$ARGUMENTS`, or infer the most recently completed epic from `backlog/**`
(the one whose stories are all `done`). Confirm with the human if ambiguous.

## 2. Gather signal
Pull from every place the human's intent showed up during this epic:
- **The epic's stories** under `backlog/<epic>/` — `## QA` history, how many comment→fix
  rounds each took, anything that bounced repeatedly.
- **PR comments the human left** on the epic's PRs (`gh pr view <n> --comments`,
  `gh api repos/{owner}/{repo}/pulls/<n>/comments`). Note repeated or strongly-worded asks.
- **Human feedback in the session transcripts** (read-only): scan
  `~/.claude/projects/-workspace/*.jsonl` for corrections, rejected tool calls, and
  "actually / instead / don't / I'd prefer" guidance. (Transcripts are only a *source* — never
  write anything to the home folder.)

## 3. Find patterns, not one-offs
Focus on things the human had to correct **more than once**, friction in the loop, and defaults
an agent/command got wrong. A single off-hand remark is not a pattern.

## 4. Propose concrete changes
For each pattern, propose a specific edit — with rationale and the **exact diff** — to one of:
- `.claude/guidelines/*.md` — the shared standards (usually the right home for a learning).
- `.claude/agents/*.md` — implementer persona / boundaries.
- `.claude/commands/*.md` — `refine` / `review` / `qa` / `ship` behavior.
- `CLAUDE.md` — workflow or orchestrator guidelines.

Every proposal must trace back to real feedback or a PR comment — **do not invent preferences.**
All changes stay **in the repo**; never write to home-folder agent memory.

## 5. Apply (human-gated)
Present the proposals as a short numbered list and let the human pick which to apply. Apply only
the approved ones; skip the rest. Then summarize what changed.
