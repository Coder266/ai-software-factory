---
id: EXP-4BOJH5
title: Track backlog stories in the repo (un-gitignore)
epic: factory-v2
status: done
estimate: 2d
created: 2026-06-21 21:22
branch: story/track-backlog-in-repo
pr: https://github.com/Coder266/expense-app/pull/3
---

# EXP-4BOJH5 — Track backlog stories in the repo (un-gitignore)

## Description

Today `backlog/` is gitignored and story files are "local-only", so you can't link to a story,
reference it from a PR, or read it on GitHub — which makes the stories far less useful than they
should be. This reverses that decision (made at the `dev-environment` retro) and makes the
backlog a **tracked, referenceable part of the repo**.

Story files carry no sensitive data — the sensitive thing is real bank statements, which stay
gitignored independently (`/data/`, `*.csv`). So there's no reason to hide planning docs.

The one constraint: story files must **not** pollute code PR diffs. So they're committed to
`main` on their own — by `/refine` (authoring/edits), `/set-status` (status changes), and
`/ship` (the `done` finalization) — never bundled into a `story/<slug>` code branch. You get
clean code diffs *and* browseable stories.

## Acceptance Criteria

- [ ] Given the updated `.gitignore`, when you run `git check-ignore backlog/factory-v2/EXP-4BOJH5-track-backlog-in-repo.md`, then it reports the file is **not** ignored (no output).
- [ ] Given a committed story file, when you browse the repo on GitHub, then the story `.md` is visible and linkable.
- [ ] Given the sensitive-data rules, when you run `git check-ignore /data/x.csv` and a non-`testdata/` `*.csv`, then they are **still ignored** (the bank-data protections are untouched).
- [ ] Given a `story/<slug>` code branch and its PR, when you inspect the PR diff, then it contains **no** `backlog/` files — story docs are committed to `main` separately, not in the code PR.
- [ ] Given the story-doc writers (`/refine`, `/set-status`, `/ship`), when any of them changes a story file, then the change is committed to `main` directly — so status updates made over a story's life are versioned too, not just the initial authoring.
- [ ] Given `.claude/guidelines/story-format.md` and `CLAUDE.md`, when you read the story-storage rules, then they describe stories as **tracked in the repo and committed to `main`** (not "local-only"), and no stale "local-only / never commit / gitignored" wording remains.
- [ ] Given `commits-and-prs.md`, when you read it, then the story-doc commit flow (which commands commit story files, to where, and that they stay out of code PRs) is documented.

## Implementation Details

- Remove the `backlog/` entry from `.gitignore` (keep `/data/` and the `*.csv` rules exactly as-is).
- Update `story-format.md` — the "Stories are local-only" bullet (lines ~13–14) and the `pr:`
  note (lines ~27–29) — to describe tracked-in-repo + commit-to-`main` storage.
- Update `CLAUDE.md`: the orchestrator bullet that says story files are "local-only … never
  committed or pushed" and the workflow text.
- Document the commit flow in `commits-and-prs.md`: story files are written to `main` by
  `/refine` (new/edited stories), `/set-status` (status changes), and `/ship` (the `done`
  finalization). All such commits go straight to `main` and never ride a `story/<slug>` code
  branch.

## Out of Scope

- Branch protection on `main` and the owner-bypass that lets these doc commits land — that's
  [`EXP-TM33HL`](EXP-TM33HL-protect-main-branch.md) (depends on this story).
- The `epic.md` artifact ([`EXP-FAEXWN`](EXP-FAEXWN-epic-definition-lifecycle.md)) and the `depends_on:` field ([`EXP-I4KR50`](EXP-I4KR50-epic-batch-run.md)) — they just
  inherit "tracked in repo" from here.

## Dependencies

- Pairs with **[EXP-TM33HL](EXP-TM33HL-protect-main-branch.md)** (protect `main` with owner bypass so the `/refine` / `/set-status` /
  `/ship` story-doc commits to `main` succeed). Settle the bypass model jointly.

## Status

`done` — shipped via PR #3 (squash-merged to `main`) _(2026-06-22 08:37)_
`ready` — refined and unblocked _(2026-06-21 21:22)_
