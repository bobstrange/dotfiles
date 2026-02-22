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
    dprint-check:
      glob: "*.{md,json,yaml,yml,toml}"
      run: dprint check --allow-no-files {staged_files}
EOF
