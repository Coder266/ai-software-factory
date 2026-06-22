# Agents

Subagent definitions ("personas"). One Markdown file per agent: YAML frontmatter
(`name`, `description`, `tools`, optional `model`) + system prompt.

Each factory step runs as its own isolated subagent, spawned (best in a git worktree) by a
thin dispatcher command of the same name in `.claude/commands/`. The dispatcher passes only the
story id / target + repo + guideline pointers by default — not the orchestrator's whole
conversation — so each step starts cold and hands off through durable artifacts (story docs, PR
comments, the `## QA` section, `/set-status` transitions).

| agent | step | dispatched by | durable artifact | `tools` |
|-------|------|---------------|------------------|---------|
| `refine.md` | Refine | `/refine` | story files + `epic.md` under `backlog/` | Read, Write, Edit, Grep, Glob, Bash |
| `implementer.md` | Implement | orchestrator / `/factory` | code branch + PR | Read, Write, Edit, Grep, Glob, Bash |
| `review.md` | Review | `/review` | GitHub PR comments | Read, Grep, Glob, Bash, Skill (read-only — no Edit/Write) |
| `qa.md` | QA | `/qa` | PASS, or a `## QA` section in the story | Read, Grep, Glob, Bash, Edit (story `## QA` only), Skill |
