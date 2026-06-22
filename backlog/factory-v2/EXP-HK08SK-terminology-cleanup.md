---
id: EXP-HK08SK
title: Terminology & naming cleanup across the factory
epic: factory-v2
status: ready
estimate: 2d
created: 2026-06-21 21:22
branch: story/terminology-cleanup
---

# EXP-HK08SK — Terminology & naming cleanup across the factory

## Description

The factory's own docs are inconsistent in ways that confuse both humans and agents. The
`.claude/commands/*.md` files are referred to as both "commands" and "skills", `.claude/skills/`
exists but holds only an empty README, and `CLAUDE.md`'s workflow names a `/verify` step when the
actual command is `/qa`. This story makes the factory describe itself consistently so the named
steps map 1:1 to real commands.

## Acceptance Criteria

- [ ] Given the factory docs (`CLAUDE.md`, `.claude/guidelines/*`, the `README.md` files), when you read them, then the workflow files are referred to by **one** consistent term throughout (no mixing "command"/"skill" for the same thing).
- [ ] Given `.claude/skills/` (currently just a README), when this story is done, then it is either populated with real content or removed, and no doc points at a non-existent skills location.
- [ ] Given `CLAUDE.md`'s workflow (the "definition of done" steps), when you read step 4 (QA), then it references `/qa` — not `/verify` — and every named step (Refine / Implement / Review / QA / Ship) maps to an actual command of the same name.
- [ ] Given the `README.md` files under `.claude/commands/`, `.claude/agents/`, and `.claude/guidelines/`, when you read them, then they accurately describe what's actually in each directory.
- [ ] Given the cleanup, when you grep the repo for the old/ambiguous terms, then no stale references remain (e.g. a `/verify`-as-a-workflow-step mention where `/qa` is meant).

## Implementation Details

- Pick the canonical term — recommend **"commands"** for the `.claude/commands/*.md` slash
  entries, since that's where the files live and how they're invoked — and apply it everywhere.
- Resolve `.claude/skills/`: remove it if unused, or give it real purpose; update any doc that
  references it.
- Fix the `/verify` vs `/qa` drift in `CLAUDE.md` (the `/qa` command may *use* `/verify`
  internally — that's fine; the workflow *step* is QA/`/qa`).

## Out of Scope

- Behavioral changes to any command — this is a docs/naming pass only.
- Renames driven by the restructure stories (best run **after** [`EXP-0IOKY4`](EXP-0IOKY4-orchestrator-as-skill.md) / [`EXP-XEYYQL`](EXP-XEYYQL-step-agents-isolated.md)
  land so naming isn't churned twice).

## Dependencies

- Soft: best sequenced after **[EXP-0IOKY4](EXP-0IOKY4-orchestrator-as-skill.md)** and **[EXP-XEYYQL](EXP-XEYYQL-step-agents-isolated.md)** (so the new `/factory` + step
  agents are named once, here), but not a hard blocker.

## Status

`ready` — refined and unblocked _(2026-06-21 21:22)_
