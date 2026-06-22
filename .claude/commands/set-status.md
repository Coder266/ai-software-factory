---
description: Advance a story's status one legal step along the lifecycle, keeping frontmatter and the visible ## Status block in sync, and commit it to main
argument-hint: <EXP-id> <new-status> (e.g. EXP-VJ93VD in-progress)
allowed-tools: Read, Edit, Grep, Glob, Bash
---

You are running the **Set-Status** step for the expense-app "AI factory" workflow. Your one and
only job is to advance a single story's `status` along the legal lifecycle, safely and
uniformly, so the other agents never hand-edit story frontmatter. You touch nothing else.

## Guidelines to follow
- `.claude/guidelines/story-format.md` — the `status` lifecycle (the legal-transition table
  below mirrors it), the `## Status` body-block convention, and the canonical section order
  (`## QA` immediately above the final `## Status`).
- `.claude/guidelines/commits-and-prs.md` — the story-doc commit flow (status changes are
  committed **directly to `main`**, never on a code branch).

## Legal transitions
Only these `from → to` moves are allowed:

| from | to | meaning |
|------|----|---------|
| `new` | `ready` | refined / unblocked |
| `ready` | `in-progress` | implementer starts |
| `in-progress` | `under-review` | code review settled, hand off to QA |
| `under-review` | `in-progress` | QA bounce — back to fix |

- **`→ done` is always refused** — `done` is only ever set by `/ship`, as part of an actual
  merge. If asked for `done`, refuse and point to `/ship`.
- Any move not in the table (e.g. `new → under-review`, skipping a stage, going backwards
  illegally, or a no-op to the same status) is **rejected with a clear message**, and the file
  is left **unchanged**.

## What you own (and only this)
- The frontmatter `status:` field.
- The visible `## Status` body block (the story's **final** section): the status word + a short
  note + a timestamp.
- The timestamped (`YYYY-MM-DD HH:MM`) transition note inside that block.

Never touch code, the `pr:` field, or any other frontmatter, and never open a PR or push a code
branch.

## Steps
1. Read `CLAUDE.md`, `story-format.md`, and `commits-and-prs.md`.
2. **Parse `$ARGUMENTS`** into an `EXP-` id and a target status. Locate the story under
   `backlog/**` by its id. If the id or target is missing/unparseable, report and stop.
3. **Read the current `status:`** from the story's frontmatter.
4. **Validate the transition** against the table above:
   - target `done` → refuse, pointing to `/ship`;
   - current → target not in the table → reject with a message naming the current status and
     the legal next step(s).
   In either rejection case, **change nothing** and stop.
5. **Compute the timestamp** to the minute: `date '+%Y-%m-%d %H:%M'`.
6. **Update the story file** (only these edits):
   - set the frontmatter `status:` to the target value;
   - rewrite the `## Status` block — `` `<target>` `` + a short human note describing the move
     + ` _(YYYY-MM-DD HH:MM)_`. (See `story-format.md` for the exact block shape.)
   - ensure `## Status` is the story's **final** section; if a `## QA` section exists, it must
     sit **immediately above** `## Status` (move `## Status` below it if needed — never reorder
     other sections).
7. **Commit directly to `main`** (story docs are tracked there; the owner bypass lets it land).
   Do **not** create or switch to a code branch and do **not** open a PR. Stage only the one
   story file, commit with a message like `EXP-<id>: set status <target>`, and push:
   `git commit backlog/<epic>/<story>.md -m "..."` then `git push origin main`. End the commit
   message with the single attribution line per `commits-and-prs.md`.

End your turn with a one-line summary: the story id, the `from → to` transition (or the
rejection/refusal reason), and the commit pushed to `main`.

## Boundaries
- Never set `status: done` and never merge — that's `/ship`, only.
- Never edit code, the `pr:` field, or other frontmatter; never open a PR or touch a code
  branch.
- On any illegal/refused transition, leave the file exactly as it was.
