# expense-app

Personal expense tracker that imports bank statements and summarizes spending.
Also a testbed for an "AI factory" workflow: stories are refined, implemented,
reviewed, QA'd, and shipped through a repeatable loop.

## Stack
- **Backend:** Go (stdlib HTTP for now)
- **Database:** Postgres 17
- **Frontend:** Vue 3 + Vite, lives in `frontend/`. No component framework — plain Vue with scoped CSS. Run with `npm run dev` (port 5173 in dev).
- **Dev environment:** Devcontainer (`.devcontainer/`) — Go + Postgres via docker compose

## Running locally
The project is meant to run **inside the devcontainer**:
- App listens on `:8080` (`/healthz` returns `ok`).
- Postgres is reachable at host `db:5432`; connection string is in `DATABASE_URL`.
- `go run .` starts the server.

## Sensitive data — important
- **Real bank statements never get committed.** They live in `/data/` (gitignored).
- All `*.csv` files are gitignored by default; only synthetic fixtures under
  `testdata/` are allowed into git.
- Prefer the synthetic `testdata/sample_statement.csv` during development. Use real
  statements only when running locally yourself.

## AI factory workflow (definition of done)
Each story flows through:
1. **Refine** — `/refine` turns the story into clear acceptance criteria (`backlog/`).
2. **Implement** — the implementer agent works one story per branch (`story/<slug>`) and opens a PR.
3. **Review** — `/review` reviews the PR against the acceptance criteria and posts GitHub comments; the implementer addresses them on the same PR.
4. **QA** — `/verify` the running behavior against the acceptance criteria; on failure it appends a `## QA` section for the implementer to fix.
5. **Ship** — the human merges the PR and sets the story `done`.

## Guidelines (single source of truth)
Shared standards live in `.claude/guidelines/` so there's one place to change a rule. Each
command and agent reads the subset relevant to it instead of restating it:

- `story-format.md` — story file location, frontmatter, sections, and the `status` lifecycle
  (`new → ready → in-progress → under-review → done`).
- `code.md` — backend/frontend conventions, tests, running locally, sensitive data.
- `commits-and-prs.md` — branch, commit, and PR conventions (incl. brief attribution).
- `reviews.md` — code-review and QA standards.

Durable preferences and learnings are recorded **in this repo** (a guideline file or this
file), never in home-folder agent memory.

## Orchestrator guidelines (read every session)
You (the main assistant) are the **orchestrator** and the human's single point of contact.
The commands and the implementer agent are your tools — the human talks to you and you drive
them. This file and the guideline files load from the repo at session start, so this is all
the context you need to pick the workflow back up. There is nothing to "reload" by hand.

Routing the human's requests:
- a new epic / rough idea, or "refine …" → run `/refine` (interactive).
- "implement EXP-x" → spawn the **implementer** subagent with `isolation: worktree`, passing
  the story id. Do **not** implement stories yourself in the main thread.
- a PR is up (implementer finished), or "review EXP-x" → **auto-run** `/review` without
  waiting to be asked.
- "qa EXP-x" → run `/qa`.
- "ship EXP-x" → run `/ship` (human-gated; it refuses unless the story is `under-review`,
  QA is clean, and PR checks are green).

Rules:
- After `/review` posts comments, **auto-loop**: send the implementer back to address them on
  the same PR, then re-review, repeating until no open review comments remain. Only return to
  the human when the PR has no comments left — and at the ship step. Don't ask between rounds.
- You may capture **stub reminder stories** (`status: new`, short description, left for
  `/refine`) when the human flags future work mid-stream.
- Never merge a PR or set a story to `done` yourself — only `/ship`, invoked by the human.
- The backlog story files (their `status` field) are the **source of truth** for where each
  story stands. Story files are **local-only** — gitignored under `backlog/`, never committed
  or pushed (agents must not commit them).
- Follow the sensitive-data rules above and the guideline files in `.claude/guidelines/`.
- When every story in an epic has reached `done`, **offer to run `/retro`** so what you
  learned during the epic gets folded back into the guidelines, agents, and commands.

## Conventions
- One story = one branch = one PR.
- Branch names: `story/<short-slug>`.
- Keep changes scoped to the story; defer unrelated cleanups to their own story.
