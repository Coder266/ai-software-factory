FROM mcr.microsoft.com/devcontainers/go:1-bookworm

# psql client + Node.js LTS (for Vue/Vite frontend tooling).
# (git, curl, ripgrep are already present in the base image.)
RUN apt-get update \
 && apt-get install -y --no-install-recommends postgresql-client \
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

# The native installer places the binary in ~/.local/bin; make sure it's on PATH
# for non-login shells (e.g. `docker compose exec app claude`).
ENV PATH="/home/vscode/.local/bin:${PATH}"
