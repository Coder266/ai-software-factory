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

- **Estimate discipline is in hours, not days.** The "≈4 days of human effort or less" ceiling
  in `story-format.md` was a slip — the human meant **≈4 hours**. Stories should be sized to a
  few hours of human effort. Fold the corrected unit into `story-format.md`'s "Estimate
  discipline" section (and reword the `estimate:` examples accordingly, e.g. `2d` → `2h`).
  _Source: human, 2026-06-22._

- **QA must exercise the app like a real user, not just `/verify`.** The qa agent should drive
  the running app end-to-end — call HTTP endpoints with `curl`, click through the Vue UI, run
  the CLI — and judge each criterion against observed behavior, not a superficial `/verify` pass
  or static inspection. Applied now to `agents/qa.md` (and `reviews.md` already says it); make it
  a stated expectation of the qa agent at retro. _Source: human, 2026-06-22 (PR #6,
  [`EXP-XEYYQL`](EXP-XEYYQL-step-agents-isolated.md))._

- **Don't hard-pin one test fixture in agent docs.** Agent/guideline wording should say "use or
  create suitable synthetic test data under `testdata/`" rather than naming a single fixture
  file — while keeping the sensitive-data hard rule (never real data, never `*.csv` outside
  `testdata/`). Applied now to `agents/qa.md` + `reviews.md`. _Source: human, 2026-06-22 (PR #6,
  [`EXP-XEYYQL`](EXP-XEYYQL-step-agents-isolated.md))._

- **RESOLVED (2026-06-22) — drop the `/refine` `/review` `/qa` command dispatchers.** The open
  question from PR #6 (kept the command layer in `EXP-XEYYQL`, deferred here) is decided: the thin
  wrappers **do not** earn their keep. `/factory` will dispatch the `refine`/`review`/`qa` agents
  **directly** (like the `implementer`, which never had a command), via one compact dispatch table;
  the wrappers get deleted. Reasons: the dispatch nuance was duplicated across command body + agent
  `description` + `agents/README.md`, and routing `/factory`→`/command` injects dispatcher prose
  into the orchestrator's own context (the human only invokes steps through `/factory`, so the
  wrappers bought no manual-use benefit). `/set-status`, `/ship`, `/retro` stay (real entry points).
  Folded into [`EXP-0IOKY4`](EXP-0IOKY4-orchestrator-as-skill.md). At `/retro`, fold this into the
  agents/commands README + `CLAUDE.md` routing so the durable convention is "`/factory` dispatches
  step agents directly." _Source: human, 2026-06-22._
