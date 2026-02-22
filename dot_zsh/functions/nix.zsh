CHEZMOI_DIR="${HOME}/.local/share/chezmoi"
NIX_PACKAGES_FILE="nix/packages.nix"

nix-add() {
  "${EDITOR:-vim}" "${CHEZMOI_DIR}/${NIX_PACKAGES_FILE}"
  echo "Running nix-apply..."
  make -C "${CHEZMOI_DIR}" nix-apply
}

nix-apply() {
  make -C "${CHEZMOI_DIR}" nix-apply
}

nix-update() {
  make -C "${CHEZMOI_DIR}" nix-update
}

# Search nixpkgs with filtered output.
# By default, results are filtered by prefix match on the package attribute name
# (last segment of the attribute path, e.g. "bun" in "legacyPackages.x86_64-linux.bun").
# This avoids noise from description-only matches like "ubuntu", "bundled", etc.
#   nix-search <query>      -- prefix match on package name (default)
#   nix-search -a <query>   -- search all fields including description
nix-search() {
  local match_all=false
  if [[ "$1" == "-a" ]]; then
    match_all=true
    shift
  fi

  local query="$*"

  if $match_all; then
    # Strip ANSI escape codes that nix search emits even in a pipe
    nix search nixpkgs "$@" 2>&1 \
      | sed 's/\x1b\[[0-9;]*m//g' \
      | grep -v "^evaluation warning:" \
      | awk '/^\* / { skip = /\.(tests|haskellPackages|vimPlugins|vscode-extensions)\./ } !skip'
  else
    # Strip ANSI escape codes that nix search emits even in a pipe
    nix search nixpkgs "$query" 2>&1 \
      | sed 's/\x1b\[[0-9;]*m//g' \
      | grep -v "^evaluation warning:" \
      | awk -v q="$query" '
        BEGIN { q = tolower(q) }
        /^\* / {
          attr = $2
          n = split(attr, parts, ".")
          pkg = tolower(parts[n])
          skip = (index(pkg, q) != 1) || /\.(tests|haskellPackages|vimPlugins|vscode-extensions)\./
        }
        !skip
      '
  fi
}
