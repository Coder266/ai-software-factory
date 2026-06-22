# Story format & status

Single source of truth for how backlog stories are written and how their status moves.
`/refine` authors stories to this spec; the implementer, `/review`, `/qa`, and `/ship` all
read and update them against it.

Stories live inside an **epic** — the epic's own definition (`backlog/<epic>/epic.md`),
frontmatter, sections, and `draft → in-progress → done → cancelled` status lifecycle are
specified in `epic-format.md`.

## Location & naming
- Path: `backlog/<epic-slug>/EXP-<id>-<story-slug>.md`
- `<id>` = 6 random **uppercase**-alphanumeric chars
  (`tr -dc 'A-Z0-9' < /dev/urandom | head -c6`), mirrored in the `id:` frontmatter field —
  so a full id reads `EXP-4VMH95`, all-caps.
- `<epic-slug>` and `<story-slug>` are lowercase, hyphenated.
- **Stories are tracked in the repo.** `backlog/` is committed to `main`, so every story is
  browseable and linkable on GitHub. Story docs are committed to `main` **directly** — by
  `/refine` (authoring/edits), `/set-status` (status changes), and `/ship` (the `done`
  finalization) — and never ride a `story/<slug>` code branch, so they stay out of code PR
  diffs. Story files carry no sensitive data; the bank-data protections (`/data/`, `*.csv`)
  are independent. See `commits-and-prs.md` for the commit flow.

## Frontmatter
```yaml
id: EXP-<id>
title: <human-readable title>
epic: <epic-slug>
status: <new | ready | in-progress | under-review | done>
estimate: <≈4d or less, e.g. 2d>
created: <YYYY-MM-DD HH:MM>
branch: story/<story-slug>
pr: <#number or URL — added only once the PR is merged, at ship; omit until then>
```
The `pr:` field links the (repo-tracked) story to its GitHub PR. Add it **only when the PR is
merged** (set by `/ship`, alongside flipping `status: done` and the timestamped note) — not
while the PR is still open. See `commits-and-prs.md`.
Timestamps are always date **and** time to the minute (`YYYY-MM-DD HH:MM`).

## Body sections
- `## Description` — **mandatory**, human-readable prose; explains *why* it matters (value
  to the user). Understandable by a non-technical reader.
- `## Acceptance Criteria` — **mandatory**, a checklist of specific, observable, testable
  outcomes; `/qa` verifies each line against the running app, so each must be falsifiable
  (prefer Given/When/Then or "- [ ] When X, then Y").
- `## Implementation Details` — optional; approach hints, key files, data shapes.
- `## Out of Scope` — optional but encouraged; keeps the story small.
- `## Dependencies` — optional; other story ids / prerequisites.
- `## Open Questions` — optional; if a question is *blocking*, the story is `new`, not `ready`.
- `## QA` — added by `/qa` only on failure (see `reviews.md`); placed **immediately above**
  the final `## Status` block.
- `## Status` — **mandatory; always the final section.** A visible block that mirrors the
  frontmatter `status:`, so the current status is readable without parsing frontmatter. See
  below.

### Canonical section order
The narrative sections come first (Description → Acceptance Criteria → Implementation Details →
Out of Scope → Dependencies → Open Questions). The story then **always ends** with, in this
order:

1. `## QA` — only if `/qa` has recorded a failure (otherwise absent);
2. `## Status` — the **last** section, every time.

`## QA` therefore sits **immediately above** `## Status` and never pushes it out of last
position.

### The `## Status` block
`## Status` is a visible mirror of the frontmatter `status:` field, kept in sync with it by
`/set-status` (and finalized to `done` by `/ship`). It is the story's final section and reads:

```markdown
## Status

`<status>` — <short note describing the move> _(YYYY-MM-DD HH:MM)_
```

- The backticked word matches the frontmatter `status:` exactly.
- The note is a brief human description of the transition (e.g. `refined and unblocked`,
  `implementing on story/<slug>`, `code review settled, handed to QA`).
- The timestamp is to the minute (`YYYY-MM-DD HH:MM`).

**Status changes are made through `/set-status`, not by hand-editing frontmatter.** It owns the
`status:` field, this block, and the timestamped note together, so the two never drift. The
only exceptions are `/refine` (which authors the initial block when creating a story) and
`/ship` (which sets `done`). See `commits-and-prs.md` for the commit flow.

## Status lifecycle
| status | meaning | reached by (who decides) |
|--------|---------|--------------------------|
| `new` | captured but has a blocking open question | `/refine` (authors the story) |
| `ready` | description + criteria complete, unblocked | `/refine` (authors the story) |
| `in-progress` | implementing **and** code review (multiple comment→fix rounds on the one PR) | implementer, via `/set-status … in-progress` |
| `under-review` | code review settled; handed off to QA | implementer, via `/set-status … under-review` |
| `done` | merged / shipped | the human, via `/ship` (never `/set-status`) |

The legal transitions are exactly:

```
new → ready → in-progress → under-review → in-progress (QA bounce) … → done
```

i.e. `new→ready`, `ready→in-progress`, `in-progress→under-review`, and the QA bounce
`under-review→in-progress`. `→ done` is set **only** by `/ship`, as part of an actual merge.
Any other jump (skipping a stage, illegal backward move) is invalid.

- **Status changes go through `/set-status`,** which validates the transition against the table
  above, keeps the frontmatter `status:` and the visible `## Status` block in sync, adds the
  timestamped note, and commits to `main`. Agents call it rather than hand-editing frontmatter.
  Authoring the initial status is `/refine`'s job; the `done` finalization is `/ship`'s.
- "The human" means the person running the workflow (the repo owner) — never an agent.
- Code review happens *during* `in-progress`; the story stays there through the fix rounds.
- The implementer flips to `under-review` only when review is settled, to hand off to QA.
- Each stage advances only the value it owns. **Only the human sets `done`,** by merging —
  no agent ever merges or sets `done` on its own, and `/set-status` refuses `→ done`.

## Estimate discipline
Every story must be ≈4 days of human effort or less. If you can't justify that, the story is
too big — split it into vertical (independently shippable) slices, not horizontal layers.
