---
id: EXP-8CIOB4
title: Let the implementer edit files without asking every time
epic: factory-v2
status: ready
estimate: 1d
created: 2026-06-20 23:30
branch: story/implementer-edit-without-asking
---

# EXP-8CIOB4 — Let the implementer edit files without asking every time

## Description

The implementer agent currently pauses for confirmation on every file edit, which stalls the
factory loop — especially the walk-away epic run, where there's no human present to approve.
Give the implementer permission to edit files without a per-change prompt, scoped the same way
the orchestrator already is, so the loop runs unattended without handing the agent broader
power than it needs.

## Acceptance Criteria

- [ ] Given the implementer agent working in its branch/worktree, when it creates or edits a file in the repo, then it does **not** prompt for per-edit approval.
- [ ] Given that permission, when you inspect its scope, then it covers the edits + the `git`/build commands the implementer needs — and is **not** broader than the orchestrator's existing scope (no blanket arbitrary-shell escalation beyond what's already granted).
- [ ] Given the review and qa agents, when they run, then this change does **not** grant *them* edit-without-ask (review has no Edit; qa may still only touch the `## QA` section).
- [ ] Given the configuration, when you inspect the repo, then the permission is set in `settings.json` (committed), so it's reproducible across machines/rebuilds.
- [ ] Given the sensitive-data rules, when the implementer runs, then they still hold — no real bank statements or non-`testdata/` `*.csv` get committed.

## Implementation Details

- Grant the permission via `settings.json` permissions (use the update-config skill), mirroring
  the orchestrator's existing allowances rather than inventing a new, wider scope.
- Keep it targeted at the implementer's file edits; do not loosen review/qa.

## Out of Scope

- Auto-approving merges or `/ship` (always human-gated).
- Loosening permissions for the review/qa agents.

## Dependencies

- Relates to **[EXP-XEYYQL](EXP-XEYYQL-step-agents-isolated.md)** (agent isolation), but can land independently.

## Status

`ready` — refined and unblocked _(2026-06-21 21:22)_
