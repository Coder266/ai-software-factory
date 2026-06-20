# Story format & status

Single source of truth for how backlog stories are written and how their status moves.
`/refine` authors stories to this spec; the implementer, `/review`, `/qa`, and `/ship` all
read and update them against it.

## Location & naming
- Path: `backlog/<epic-slug>/EXP-<id>-<story-slug>.md`
- `<id>` = 6 random lowercase-alphanumeric chars
  (`tr -dc 'a-z0-9' < /dev/urandom | head -c6`), mirrored in the `id:` frontmatter field.
- `<epic-slug>` and `<story-slug>` are lowercase, hyphenated.

## Frontmatter
```yaml
id: EXP-<id>
title: <human-readable title>
epic: <epic-slug>
status: <new | ready | in-progress | under-review | done>
estimate: <≈4d or less, e.g. 2d>
created: <YYYY-MM-DD HH:MM>
branch: story/<story-slug>
```
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
- `## QA` — added by `/qa` only on failure (see `reviews.md`).

## Status lifecycle
| status | meaning | set by |
|--------|---------|--------|
| `new` | captured but has a blocking open question | `/refine` |
| `ready` | description + criteria complete, unblocked | `/refine` |
| `in-progress` | implementing **and** code review (multiple comment→fix rounds on the one PR) | implementer (on start) |
| `under-review` | code review settled; handed off to QA | implementer (handoff) |
| `done` | merged / shipped | the human (ship) |

- "The human" means the person running the workflow (the repo owner) — never an agent.
- Code review happens *during* `in-progress`; the story stays there through the fix rounds.
- The implementer flips to `under-review` only when review is settled, to hand off to QA.
- Each stage advances only the value it owns. **Only the human sets `done`,** by merging —
  no agent ever merges or sets `done` on its own.

## Estimate discipline
Every story must be ≈4 days of human effort or less. If you can't justify that, the story is
too big — split it into vertical (independently shippable) slices, not horizontal layers.
