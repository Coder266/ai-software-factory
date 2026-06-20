FROM mcr.microsoft.com/devcontainers/go:1-bookworm

# psql client + the GitHub CLI (`gh`).
# (git, curl, ripgrep are already present in the base image, but `gh` is NOT —
# install it from GitHub's official apt repo. Doing it here, rather than via a
# devcontainer `features` entry, means `gh` is present no matter how the
# container is started — the `make`/raw `docker compose` path never runs
# devcontainer features or lifecycle hooks.)
RUN apt-get update \
 && apt-get install -y --no-install-recommends postgresql-client \
 && mkdir -p -m 755 /etc/apt/keyrings \
 && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      -o /etc/apt/keyrings/githubcli-archive-keyring.gpg \
 && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends gh \
 && rm -rf /var/lib/apt/lists/*

# Install Node.js LTS via nvm so the vscode user controls the version.
ENV NVM_DIR=/usr/local/nvm
RUN mkdir -p $NVM_DIR \
 && curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
 && . $NVM_DIR/nvm.sh \
 && nvm install --lts \
 && nvm alias default node \
 && nvm use default
ENV PATH="$NVM_DIR/versions/node/$(ls $NVM_DIR/versions/node | tail -1)/bin:${PATH}"

# Install Claude Code (native installer — no Node required) for the non-root
# 'vscode' user that the devcontainer runs as.
USER vscode
RUN curl -fsSL https://claude.ai/install.sh | bash

# Persist ALL Claude auth/config in the single `claude-config` named volume
# (mounted at ~/.claude). The login token lives in ~/.claude/.credentials.json;
# ~/.claude.json is symlinked into the same volume so one volume holds
# everything and a rebuild never logs you out. Creating the dir here also makes
# the fresh volume inherit `vscode` ownership on first mount.
RUN mkdir -p /home/vscode/.claude \
 && ln -sf /home/vscode/.claude/claude.json /home/vscode/.claude.json

# Persist the GitHub CLI login in the `gh-config` named volume (mounted at
# ~/.config/gh). `gh` is installed above from GitHub's apt repo. Pre-creating
# the dir as the `vscode` user makes a fresh volume inherit `vscode` ownership
# on first mount, so `gh` can write its config / hosts.yml without hitting
# root-owned permission errors.
#
# Also wire HTTPS git push/pull to the persisted `gh` token by registering `gh`
# as a git credential helper at the *system* level. Baking this into the image
# means it is present however the container is started — including the
# `make`/raw `docker compose` path, which never runs devcontainer lifecycle
# hooks. `gh auth git-credential` only emits credentials once a login exists in
# the gh-config volume, so this is inert until the one-time `gh auth login`.
USER root
RUN git config --system credential."https://github.com".helper "" \
 && git config --system --add credential."https://github.com".helper "!gh auth git-credential" \
 && git config --system credential."https://gist.github.com".helper "" \
 && git config --system --add credential."https://gist.github.com".helper "!gh auth git-credential"
USER vscode
RUN mkdir -p /home/vscode/.config/gh

# The native installer places the binary in ~/.local/bin; make sure it's on PATH
# for non-login shells (e.g. `docker compose exec app claude`).
ENV PATH="/home/vscode/.local/bin:${PATH}"
