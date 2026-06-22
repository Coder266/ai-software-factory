# Commits & PRs

- **Branches:** one story = one branch = one PR. Use the story's `branch:` field —
  `story/<slug>` — branched off the default branch.
- **Commit messages:** clear and scoped to the story. Attribution is a **single short line**
  at the end — `Generated with Claude Opus 4.8`. Do **not** add an email or a
  `Co-Authored-By:` trailer.
- **PRs:** open with `gh pr create`. The title references the story; the body restates the
  Acceptance Criteria as a checklist and links the story file, and ends with the same single
  line — `Generated with Claude Opus 4.8`.
- **Merging:** only `/ship` (human-invoked) merges, with `--squash --delete-branch`. No agent
  merges on its own.

## Story-doc commits (kept out of code PRs)

Story files under `backlog/` are tracked in the repo, but they are **committed to `main`
directly** — never on a `story/<slug>` code branch — so code PR diffs stay clean and contain
no `backlog/` files. The story-doc writers each commit straight to `main`:

- **`/refine`** — commits new and edited story files (authoring, criteria, scope changes).
- **`/set-status`** — commits status-field changes, so a story's status history is versioned
  over its whole life, not just at authoring time.
- **`/ship`** — commits the `done` finalization (flipping `status: done`, adding the `pr:`
  link and the timestamped note) after the human merges the code PR.

The implementer never commits the story file onto its code branch. When it changes a story's
status (e.g. `ready → in-progress`, or `→ under-review`), that status edit is committed to
`main` (via `/set-status`), separate from the code branch's commits and PR.
