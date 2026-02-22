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

nix-search() {
  nix search nixpkgs "$@" 2>&1 \
    | grep -v "^evaluation warning:" \
    | awk '/^\* / { skip = /\.(tests|haskellPackages|vimPlugins|vscode-extensions)\./ } !skip'
}
