# Epic format & status

Single source of truth for how an **epic** is defined and how its status moves. An epic is a
first-class thing — not just a directory of stories. It has a persisted definition (`epic.md`)
and a status lifecycle, so the factory can read, track, and resume it without relying on
always-on conversation context.

`/refine` authors and updates `epic.md` to this spec; the orchestrator, `/factory`, and
`/retro` read it.

## Location & naming
- Path: `backlog/<epic-slug>/epic.md` — one per epic directory, alongside its story files.
- `<epic-slug>` is lowercase, hyphenated (the same slug used in each story's `epic:` field).
- **Epics are tracked in the repo.** Like story files, `epic.md` is committed to `main`
  directly (by `/refine`) so it is browseable and linkable on GitHub, and it never rides a
  `story/<slug>` code branch. See `commits-and-prs.md` and `story-format.md`.

## Frontmatter
```yaml
slug: <epic-slug>
title: <human-readable title>
status: <draft | in-progress | done | cancelled>
created: <YYYY-MM-DD HH:MM>
```
Timestamps are date **and** time to the minute (`YYYY-MM-DD HH:MM`).

## Body sections
Start the body with a visible `# <slug> — <title>` heading (mirrors the frontmatter, for easy
copy-paste), then:

- `## Goal` — **mandatory**, prose; the outcome the epic delivers and why it matters.
- `## Scope` — **mandatory**; what's in. Include an `### Out of scope` subsection for what's
  explicitly deferred or excluded.
- `## Acceptance Criteria` — **mandatory**; epic-level observable outcomes. Named
  **"Acceptance Criteria"** to match the stories (not "Success criteria"), so the vocabulary is
  consistent across epic and story docs.
- `## Seed` — **mandatory**; the verbatim seed you gave `/refine` (e.g. a blockquote with an
  attribution line). This records *where the epic came from* so it isn't lost to the
  conversation.
- `## Stories` — **mandatory**; an **ordered** list of the epic's stories. Each entry is a
  **markdown link to that story's file**, so you can click through from the epic to any story:

  ```markdown
  1. [`EXP-xxxxxx` — Story title](EXP-xxxxxx-story-slug.md)
  2. [`EXP-yyyyyy` — Another story](EXP-yyyyyy-another-slug.md)
  ```

  Suggested implementation order lives here (dependencies first).

## Status lifecycle
| status | meaning | set by |
|--------|---------|--------|
| `draft` | epic defined / being refined into stories | `/refine` (on creating `epic.md`) |
| `in-progress` | at least one story is being worked; the epic is actively running | the epic run (`/factory`) or the human |
| `done` | every story in the epic has reached `done` | the run/orchestrator when all stories are `done` |
| `cancelled` | the epic is abandoned and won't ship | the human |

- "The human" means the person running the workflow (the repo owner) — never an agent.
- `/refine` sets `draft` when it first writes `epic.md`; editing an existing epic does not
  reset its status.
- The mechanics that flip an epic to `in-progress` during a batch run are wired by the epic
  run command (`/factory`); this guideline only defines the field and its transitions.
- When the epic reaches `done` (all stories `done`), the orchestrator **offers `/retro`** to
  fold the epic's learnings back into the factory.

## `retro-notes.md` — mid-epic feedback capture
Alongside `epic.md`, an epic may carry `backlog/<epic-slug>/retro-notes.md`: a running list of
**mid-epic human feedback** the orchestrator captures while the epic is in flight (corrections,
"actually do it this way", preferences worth making durable). It is the documented home for
"change now and save for retro" notes, tracked in the repo like the other backlog docs.

`/retro` reads `retro-notes.md` as a first-class signal source (see `retro.md` step 2),
turning those notes into durable rules in the guidelines, agents, and commands.

## Epic template
```markdown
---
slug: <epic-slug>
title: <human-readable title>
status: draft
created: <YYYY-MM-DD HH:MM>
---

# <epic-slug> — <human-readable title>

## Goal

<What this epic delivers and why it matters.>

## Scope

<What's in scope.>

### Out of scope

<What's explicitly deferred or excluded.>

## Acceptance Criteria

<Epic-level observable outcomes.>

## Seed

> <The verbatim seed given to /refine.>
>
> — human, <YYYY-MM-DD>

## Stories

<Ordered, linked list — added/updated as stories are refined.>

1. [`EXP-xxxxxx` — Story title](EXP-xxxxxx-story-slug.md)
```
