# Retro notes — factory-v2 epic

Mid-epic human feedback to fold into the **factory itself** at `/retro` (per the convention
[`EXP-FAEXWN`](EXP-FAEXWN-epic-definition-lifecycle.md) formalizes). These were also applied to
this epic's artifacts now ("change now and save for retro"); the retro turns them into durable
rules in the guidelines/agents/commands.

- **Always link story mentions.** Whenever a story is referenced — in another story, in
  `epic.md`, in chat — render it as a markdown link to the story file. Fold into the refine
  agent + `story-format.md` so cross-references are links by default.
  _Source: human, 2026-06-21._

- **Stories/epics carry a visible id+name heading.** Put `# EXP-xxxx — Title` at the top of each
  story body (and `# <slug> — <title>` in `epic.md`), in addition to the frontmatter, for easy
  copy-paste. Fold into `story-format.md` / the `epic.md` spec.
  _Source: human, 2026-06-21._

- **`/retro` commits factory changes directly to `main`.** When the retro agent changes
  `.claude/` guidelines/agents/commands or `CLAUDE.md`, it commits those straight to `main` — it
  does **not** open a PR. This relies on the owner bypass from
  [`EXP-TM33HL`](EXP-TM33HL-protect-main-branch.md) (factory/planning artifacts go direct to
  `main`; only application code goes through reviewed PRs). Update the `/retro` command to commit
  its approved changes, and list `/retro` among the bypass actors in
  [`EXP-TM33HL`](EXP-TM33HL-protect-main-branch.md).
  _Source: human, 2026-06-21._

- **The refiner must be critical of the human's ideas.** `/refine` should actively challenge
  proposals and **voice disagreement**, not just capture what it's told. The persona already says
  "challenge before you capture" — make explicit, vocal pushback a stated expectation.
  _Source: human, 2026-06-21._
