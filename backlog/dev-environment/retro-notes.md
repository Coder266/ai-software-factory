# Retro notes — dev-environment epic

Running list of things to revisit in `/retro` (human feedback captured mid-epic).

- **Story IDs should always be capitalized.** Change the rules so the random
  `<id>` portion of a story id is uppercase too (e.g. `EXP-4VMH95`, not
  `EXP-4vmh95`). Update `.claude/guidelines/story-format.md` — the `<id>` =
  "6 random lowercase-alphanumeric chars" line and its `tr -dc 'a-z0-9'`
  generator — and anywhere else the lowercase id is assumed.
  _Source: human request during EXP-4vmh95 refinement/implementation (2026-06-20)._

- **The orchestrator may create new stories as reminders for the future.** Make this an
  explicit rule. The orchestrator capturing a stub story (status `new`, short description,
  left for `/refine` later) is endorsed — add it to the orchestrator guidelines in
  `CLAUDE.md` (and/or `.claude/guidelines/story-format.md`) so it's sanctioned rather than
  ad hoc.
  _Source: human feedback during EXP-4vmh95 epic (2026-06-20)._

- **Auto-run `/review` once a story's PR is up — don't ask first.** When the implementer
  finishes and a PR is open, the orchestrator should kick off `/review` automatically rather
  than waiting for the human to say "review EXP-x". Update the orchestrator routing rules in
  `CLAUDE.md` accordingly.
  _Source: human feedback during EXP-4vmh95 epic (2026-06-20)._

- **Auto-loop review → implementer-fix without asking; only surface to the human when the PR
  has no open review comments left.** After `/review` posts comments, the orchestrator should
  automatically send the implementer back to address them on the same PR, then re-review as
  needed, repeating until no comments remain. Only return to the human for interaction once
  the PR has no comments left to address. Update the orchestrator routing rules in `CLAUDE.md`.
  _Source: human feedback during EXP-4vmh95 epic (2026-06-20)._

- **Backlog stories are LOCAL-ONLY — never commit/push them to GitHub.** Story `.md` files
  under `backlog/` must not land in any PR or on `main`. Add `backlog/` to `.gitignore`, and
  update `.claude/guidelines/story-format.md` + `CLAUDE.md` to state stories live locally only
  (the implementer's worktree should not commit the story file either). The status field is
  still the source of truth, just kept locally.
  _Source: human feedback during EXP-4vmh95 epic (2026-06-20)._

- **Auto-allow running agents and skills (no permission prompt).** Spawning the implementer
  (and other subagents) and invoking workflow skills (`/refine`, `/review`, `/qa`, `/ship`,
  etc.) are core to the AI-factory loop and should not prompt for permission each time.
  Configure this in `settings.json` (allow the `Agent`/`Task` and `Skill` tool uses) via the
  update-config skill so the orchestrator can drive the loop without interruption.
  _Source: human feedback during EXP-4vmh95 epic (2026-06-20)._

- **QA can actually start the container.** Unlike the review-by-inspection done in this
  sandbox, the QA/`/verify` environment can run Docker and start the devcontainer — so QA can
  exercise the real "rebuild and the login persists / container starts" behavior. Worth noting
  in `reviews.md` QA guidance so QA exercises a real container start rather than only inspecting.
  _Source: human note during EXP-4vmh95 epic (2026-06-20)._

## Workflow-restructure feedback at epic close (2026-06-21)

- **Run `/refine`, `/review`, and `/qa` as isolated agents too** — not in the main
  conversation. Mirror how the implementer already runs as a subagent, so the heavy work
  happens off the main thread.

- **Workflow agents must NOT have access to the main conversation context.** Refine / review /
  QA / implement agents should be isolated — given only the story id + repo + their guideline
  subset, never the orchestrator's conversation. Keeps them focused and context-clean.

- **The orchestrator should be a SKILL, not the main context.** Today the main assistant IS the
  orchestrator (loaded every session via CLAUDE.md). Instead, plain `claude` should be free for
  ad-hoc questions and repo changes *without* being in "factory" mode; orchestration is invoked
  explicitly (e.g. `/factory`). The orchestrator skill's job is just to dispatch the step agents
  and pause for human input at the **review** and **ship** steps — it shouldn't do the work
  itself. Implies moving the "Orchestrator guidelines" out of CLAUDE.md into a skill.

- **Add a dedicated "set story status" capability the agents call** (a small skill/command, or
  whatever is most appropriate) that ONLY changes a story's `status` field (+ the timestamped
  note). Agents call it to advance the lifecycle instead of hand-editing frontmatter, so status
  transitions are consistent and agents don't need broad edit access for them.

- **Link the PR to the story — make it a guideline.** Recording the story's PR (number/URL) on
  the story file (and referencing it in the shipped/done note) was useful; bake it into
  `story-format.md` so every story tracks its PR. Pairs with stories being local-only — the
  link is how you get from a local story to its GitHub PR.
  _Source: human feedback at EXP-4vmh95 epic close (2026-06-21)._
