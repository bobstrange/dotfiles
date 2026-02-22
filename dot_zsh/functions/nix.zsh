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
