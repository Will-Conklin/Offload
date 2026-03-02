#!/bin/bash
# Purpose: Install project tooling for Claude Code on the web sessions.
# Installs: gh CLI, markdownlint-cli, yamllint, and backend Python dev deps.

set -euo pipefail

# Only run in remote (Claude Code on the web) environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

echo "==> Installing gh CLI..."
apt-get install -y -q gh

echo "==> Configuring gh CLI..."
if [ -n "${GITHUB_TOKEN:-}" ]; then
    gh auth login --with-token <<< "$GITHUB_TOKEN"
else
    echo "    GITHUB_TOKEN not set — skipping gh auth (set it in project secrets to enable PR creation)"
fi

echo "==> Installing markdownlint-cli..."
npm install -g markdownlint-cli --silent

echo "==> Installing backend Python dev dependencies..."
pip3 install -q -e "${CLAUDE_PROJECT_DIR}/backend/api[dev]"

echo "==> Installing yamllint..."
pip3 install -q yamllint

echo "==> Session start complete."
