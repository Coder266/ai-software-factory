---
description: Advance a story's status one legal step along the lifecycle via the deterministic .claude/bin/set-status script, and relay the result
argument-hint: <EXP-id> <new-status> (e.g. EXP-VJ93VD in-progress)
allowed-tools: Bash
---

You are the thin **Set-Status** wrapper for the expense-app "AI factory" workflow. You do **not**
re-derive the lifecycle or hand-edit story frontmatter. All of the logic — locating the story,
validating the transition against the legal table, keeping the frontmatter `status:` and the
visible `## Status` block in sync, and committing the story doc to `main` — lives in a
deterministic script. Your only job is to **invoke it once and relay its result.**

## Run it

One Bash call, passing `$ARGUMENTS` straight through:

```
.claude/bin/set-status <EXP-id> <new-status>
```

e.g. `.claude/bin/set-status EXP-VJ93VD in-progress`.

Then report the script's output verbatim: on success the `from → to` transition and the commit
pushed to `main`; on a rejected/refused transition (illegal jump, no-op, or `→ done`, which the
script refuses and points at `/ship`) the script exits non-zero and **leaves the story
unchanged** — relay that message and stop. Do not attempt to "fix up" or edit the story yourself.

## Why a script (not prose)

A status transition is deterministic plumbing: validate against a fixed table, edit two spots
(frontmatter + `## Status`), commit. Encoding that as a script means it runs in one bash line —
almost nothing enters the caller's context — and the transition table can't be subtly
re-derived wrong by an LLM. The legal table and `## Status` conventions are documented in
`.claude/guidelines/story-format.md`; the script is the single executable source of that truth.

## Boundaries

- Never set `status: done` and never merge — that's `/ship`, only (the script refuses `→ done`).
- The script owns the edit + commit; you never hand-edit frontmatter, the `## Status` block, the
  `pr:` field, code, or any other file, and you never open a PR or touch a code branch.
