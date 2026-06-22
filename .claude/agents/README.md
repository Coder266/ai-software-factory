# Agents

Subagent definitions ("personas"). One Markdown file per agent: YAML frontmatter
(`name`, `description`, `tools`, optional `model`) + system prompt.

Each factory step runs as its own isolated subagent, spawned by a thin dispatcher command of the
same name in `.claude/commands/`. The dispatcher passes only the story id / target + repo +
guideline pointers by default — not the orchestrator's whole conversation — so each step starts
cold and hands off through durable artifacts (story docs, PR comments, the `## QA` section,
`/set-status` transitions).

The agents that touch a **code working tree** (implement, review, qa) run in a git worktree for
isolation; **qa** must additionally check out the PR's `story/<slug>` branch into that worktree
before running the app (it consumes an existing remote branch rather than creating one).
**refine** runs on `main` (no worktree): it authors no code, only `backlog/` docs that must be
committed to `main`.

| agent | step | dispatched by | durable artifact | `tools` |
|-------|------|---------------|------------------|---------|
| `refine.md` | Refine | `/refine` | story files + `epic.md` under `backlog/` | Read, Write, Edit, Grep, Glob, Bash |
| `implementer.md` | Implement | orchestrator / `/factory` | code branch + PR | Read, Write, Edit, Grep, Glob, Bash |
| `review.md` | Review | `/review` | GitHub PR comments | Read, Grep, Glob, Bash, Skill (read-only — no Edit/Write) |
| `qa.md` | QA | `/qa` | PASS, or a `## QA` section in the story | Read, Grep, Glob, Bash, Edit (story `## QA` only), Skill |
