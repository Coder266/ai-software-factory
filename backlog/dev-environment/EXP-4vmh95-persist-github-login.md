---
id: EXP-4vmh95
title: Persist the GitHub login across devcontainer rebuilds
epic: dev-environment
status: in-progress
estimate: 1d
created: 2026-06-20 23:11
branch: story/persist-github-login
---

## Description

The Claude login already survives a devcontainer rebuild because its credentials live in
the `claude-config` named volume mounted at `~/.claude`. The **GitHub login does not**: the
`gh` CLI stores its token under `~/.config/gh`, which is not persisted, so every container
rebuild or recreate silently logs you out of GitHub. You then have to re-run `gh auth login`
before the AI-factory workflow can open PRs, post review comments, or push branches.

On top of that, the repo's `origin` remote is HTTPS and no git credential helper is
configured, so even while logged into `gh`, `git push`/`git pull` over HTTPS aren't wired to
that token.

This story makes the GitHub login as durable as the Claude login: log in once inside the
container and stay logged in across restarts and rebuilds — for both `gh` commands and
HTTPS git operations — with a one-command way to reset it, mirroring the existing
`make logout`.

## Acceptance Criteria

- [ ] Given a developer logged into `gh` inside the container, when the devcontainer is
  rebuilt (`make rebuild` / "Rebuild Container"), then `gh auth status` still reports
  "Logged in to github.com" without any re-login.
- [ ] Given that persisted login, when the developer runs `gh pr list` (or any authenticated
  `gh` command) after a rebuild, then it succeeds without prompting for authentication.
- [ ] Given the HTTPS `origin` remote, when the developer runs `git push` / `git pull` after
  a rebuild, then it authenticates using the persisted GitHub token without prompting for a
  username/password.
- [ ] Given a fresh `gh-config` volume (first ever start, or after a reset), when the volume
  is mounted, then `~/.config/gh` is owned by the `vscode` user (no root-owned permission
  errors when `gh` writes its config).
- [ ] Given the developer wants to reset the GitHub login, when they run the dedicated make
  target (e.g. `make gh-logout`), then the GitHub config volume is removed and the next
  container start requires a fresh `gh auth login`; the Claude login and database are
  unaffected.
- [ ] Given the existing `make logout` (Claude) and `make clean` (database) targets, when
  the developer runs them, then they continue to behave exactly as before (no GitHub volume
  removed by them, and `make gh-logout` does not touch the Claude or pgdata volumes).

## Implementation Details

- Add a `gh-config` named volume in `.devcontainer/docker-compose.yml`, mounted at
  `/home/vscode/.config/gh` on the `app` service, alongside the existing
  `claude-config` mount. Declare it under the top-level `volumes:` key.
- In `.devcontainer/Dockerfile`, install the GitHub CLI (`gh`) — the base image does not
  bundle it — and pre-create `/home/vscode/.config/gh` as the `vscode` user (mirroring the
  existing `mkdir -p /home/vscode/.claude`) so a fresh volume inherits `vscode` ownership on
  first mount.
- Wire HTTPS git auth to the gh token by registering `gh` as a git credential helper. This
  must survive rebuilds AND work on the `make`/raw `docker compose` path, which never runs
  devcontainer lifecycle hooks (`postCreate`/`postStartCommand`). Configure it at the
  *system* level in the Dockerfile (equivalent to `gh auth setup-git`, but image-baked) so it
  holds however the container is started; it stays inert until the one-time `gh auth login`.
- Add a `make gh-logout` target mirroring `make logout`: `docker compose down` then
  `docker volume rm expense-app_gh-config`. Update the `.PHONY` line and the `logout`
  target's comment if it implies it resets *all* logins.
- Update the comments in `docker-compose.yml` and `Makefile` so the persistence story is
  documented in the same spirit as the existing Claude-login comments.

## Out of Scope

- Switching the `origin` remote to SSH, or any SSH-key-based auth.
- Persisting or sharing the host machine's GitHub login (we use an isolated named volume, not
  a host bind-mount, matching the Claude pattern).
- Changing how the Claude login or the Postgres database are persisted.
- Automating the initial `gh auth login` itself — the developer still logs in once
  interactively; this story only makes that login durable.

## Dependencies

None.
