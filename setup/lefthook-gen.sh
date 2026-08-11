#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

cat > lefthook.yml << EOF
extends:
  - $HOME/.config/lefthook/lefthook.yml

pre-commit:
  parallel: true
  commands:
    trailing-whitespace:
      run: git diff --cached --check
    prettier-check:
      glob: "*.{md,json,yaml,yml}"
      run: npx --yes --prefer-offline prettier@3.9.6 --check {staged_files}
EOF
