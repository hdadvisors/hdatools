#!/bin/bash
# Provisions R for Claude Code on the web sessions on this repo only.
# Runs on every SessionStart; safe to re-run (apt/install.packages are
# idempotent, and the fast-path check below skips work once the container's
# base image already has R + pandoc, e.g. from a cached snapshot).
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "$CLAUDE_PROJECT_DIR"

if ! command -v Rscript >/dev/null 2>&1 || ! command -v pandoc >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y --no-install-recommends \
    r-base \
    pandoc \
    build-essential \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    zlib1g-dev
fi

Rscript "$CLAUDE_PROJECT_DIR/.claude/hooks/install-r-deps.R"
