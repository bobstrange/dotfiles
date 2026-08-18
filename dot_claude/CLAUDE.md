# Global AI Coding Agent Instructions

## Package Management

Package management depends on the OS:

- **macOS**: Use `brew install <package>`
- **Linux**: Use `nix profile install nixpkgs#<package>` or home-manager
- Do NOT use `apt` or other package managers

## Dotfiles Management

Dotfiles are managed with **chezmoi** (<https://github.com/bobstrange/dotfiles>).

**Important:**

- Do NOT edit dotfiles directly (e.g., `~/.zshrc`, `~/.gitconfig`)
- Direct edits will be overwritten by `chezmoi apply`
- To modify dotfiles:
  1. Edit the source in `~/.local/share/chezmoi/` or the dotfiles repo
  2. Run `chezmoi apply` to apply changes

When suggesting dotfile changes, remind the user to update the dotfiles repository.

## Reviewing Pull Request

- Use `gh` command to review Pull Request
- Do NOT checkout the branch locally until it becomes necessary to run the code for fixes

## New Repositories / Shared CI

All bobstrange repos share a CI + git-hook layer: **bobstrange/gh-workflows**
(`~/src/bobstrange/gh-workflows`; lint via reusable workflow, pre-commit hooks via
lefthook remotes).

- When creating a new repo, or adding CI / linters / hooks to any repo, read the
  gh-workflows README first and wire the few-line stubs it prescribes
- Do not hand-roll lint workflows in individual repos

## Repository Visibility

Some repos are public, others private. Anything committed to a public repo — file contents
**and commit messages** — is published wholesale, including full git history once a private
repo is flipped public. Check with `gh repo view bobstrange/<repo> --json visibility` before
writing one repo's name into another repo's files.

## Additional Instructions

Machine-local instructions, imported if present:

@~/.claude/private.md
