# dotfiles

## Requirements

- Dropbox has been installed.
- Dropbox folder should be `~/Dropbox/`.

## Tools

- **[chezmoi](https://www.chezmoi.io/)**: Dotfile management
- **[Homebrew](https://brew.sh/) + Brewfile**: Package management (macOS)
- **[Nix Flakes](https://nixos.wiki/wiki/Flakes) + [home-manager](https://github.com/nix-community/home-manager)**: Package management (Ubuntu/WSL)

## Usage

### macOS (Homebrew)

```bash
# Clone repo
git clone https://github.com/bobstrange/dotfiles ~/.local/share/chezmoi
cd ~/.local/share/chezmoi

# 1. Initial setup (brew bundle + macOS defaults + mise runtimes)
make setup-macos

# 2. Symlink secret files from Dropbox (~/.ssh, ~/.aws, tokens)
make symlinks

# 3. Apply dotfiles
chezmoi apply
```

#### Daily Operations

```bash
# Apply Brewfile changes
make macos-apply

# Apply macOS system defaults
make macos-defaults
```

### Ubuntu/WSL (Nix)

```bash
# Clone repo
git clone https://github.com/bobstrange/dotfiles ~/.local/share/chezmoi
cd ~/.local/share/chezmoi

# 1. Install Nix
make setup-nix

# 2. Restart shell
exec $SHELL

# 3. Set up Linux environment (nix-apply + lefthook + xremap + mise)
make setup-linux
```

#### Daily Operations

```bash
# After editing nix/*.nix files
make nix-apply

# Update all packages to latest
make nix-update

# Search for packages
nix search nixpkgs <package-name>

# Rollback to previous generation
home-manager rollback
```

## Help

```bash
make help
```
