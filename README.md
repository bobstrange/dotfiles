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
git clone https://github.com/bob1983/dotfiles ~/dotfiles
cd ~/dotfiles

# 1. Initial setup (brew bundle + macOS defaults)
make macos-setup

# 2. Symlink secret files from Dropbox (~/.ssh, ~/.aws, tokens)
make symlinks

# 3. Apply dotfiles
chezmoi apply
```

#### Daily Operations

```bash
# Install/update packages
make macos-install

# Apply macOS system defaults
make macos-defaults
```

### Ubuntu/WSL (Nix)

```bash
# Clone repo
git clone https://github.com/bob1983/dotfiles ~/dotfiles
cd ~/dotfiles

# 1. Install Nix
make nix-install

# 2. Restart shell
exec $SHELL

# 3. Install packages
make nix-bootstrap

# 4. Apply dotfiles
chezmoi apply
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
