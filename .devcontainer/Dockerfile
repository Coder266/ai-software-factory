FROM mcr.microsoft.com/devcontainers/go:1-bookworm

# psql client + the GitHub CLI (`gh`, from GitHub's apt repo — not in the base
# image, and bookworm's own repo lags). Installed in the image, not via a
# devcontainer feature, so it's present on the `make`/raw `docker compose` path.
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

# Register `gh` as git's HTTPS credential helper at the *system* level so it's
# present on every start path (not just devcontainer lifecycle hooks). Inert
# until the one-time `gh auth login`. The pre-created ~/.config/gh dir gives a
# fresh `gh-config` volume `vscode` ownership on first mount.
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
