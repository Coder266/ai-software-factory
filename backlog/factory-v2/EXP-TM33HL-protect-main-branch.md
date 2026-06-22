---
id: EXP-TM33HL
title: Protect the main branch
epic: factory-v2
status: ready
estimate: 2d
created: 2026-06-20 23:54
branch: story/protect-main-branch
---

# EXP-TM33HL — Protect the main branch

## Description

Protect the `main` branch on GitHub so application changes can only land through a reviewed pull
request — not by direct pushes — guarding the factory's "one story = one branch = one PR" rule at
the platform level and keeping `main` always shippable. Force-pushes and branch deletion are
blocked.

The wrinkle: **factory and planning artifacts go straight to `main`**, not through PRs. Story
docs are committed directly by `/refine`, `/set-status`, and `/ship` ([`EXP-4BOJH5`](EXP-4BOJH5-track-backlog-in-repo.md)), and `/retro`
commits its factory changes (`.claude/` guidelines/agents/commands, `CLAUDE.md`) directly too;
`/ship` is the one path that merges code. So protection must allow the **repo owner to bypass**
(admin bypass on), letting those direct commits and `/ship` merges land — while still funneling
normal **application code** through reviewed PRs.

## Acceptance Criteria

- [ ] Given branch protection on `main`, when a non-owner (or a normal push) tries to push code straight to `main`, then it is rejected — code must go through a PR.
- [ ] Given the protection, when anyone attempts a force-push or to delete `main`, then it is blocked.
- [ ] Given the rule, when a PR's required status checks are red, then it cannot be merged.
- [ ] Given the repo owner (running `/refine`, `/set-status`, `/retro`, or `/ship`), when they commit a story doc or a factory change (`.claude/` / `CLAUDE.md`) to `main`, or `/ship` squash-merges a PR, then it **succeeds** (owner/admin bypass) without disabling protection for everyone else.
- [ ] Given `/ship`, when it merges, then it remains the only merge path for code and is not blocked by the protection rule.
- [ ] Given the protection config, when you inspect the repo, then the rule is recorded reproducibly (via `gh api` / a committed ruleset definition), not only clicked in the UI.

## Implementation Details

- Apply protection via `gh api` (classic branch protection or a ruleset); store the
  definition/command in the repo so it's reproducible.
- Settle the bypass model jointly with [`EXP-4BOJH5`](EXP-4BOJH5-track-backlog-in-repo.md): admin/owner bypass **on** so the
  `/refine` / `/set-status` / `/retro` / `/ship` direct commits to `main` and `/ship` merges
  work; required PR + status checks + no force-push/deletion for the normal application-code path.
- Decide on required approving reviews: given the solo workflow and that `/review` posts
  comments (not GitHub approvals), do **not** require an approving review (it would stall
  `/ship`). Document this choice.

## Out of Scope

- Switching `origin` to SSH or changing auth (covered by the shipped `EXP-4vmh95`).
- CI/status-check *content* — this story only requires that whatever checks exist must pass.

## Dependencies

- Depends on **[EXP-4BOJH5](EXP-4BOJH5-track-backlog-in-repo.md)** (story-docs-to-`main` by `/refine` / `/set-status` / `/ship` + the
  owner-bypass reconciliation).

## Status

`ready` — refined and unblocked _(2026-06-21 21:22)_
