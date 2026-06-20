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
