#!/bin/bash
# Install gh CLI extensions
if command -v gh &>/dev/null; then
  gh extension install github/gh-stack || true
fi
