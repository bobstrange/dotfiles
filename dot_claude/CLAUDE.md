# Global AI Coding Agent Instructions

## Package Management

Package management depends on the OS:

- **macOS**: Use `brew install <package>`
- **Linux**: Use `nix profile install nixpkgs#<package>` or home-manager
- Do NOT use `apt` or other package managers

## Dotfiles Management

Dotfiles are managed with **chezmoi** (https://github.com/bobstrange/dotfiles).

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

## Hosting / Infra Registry

Cross-service hosting state (subdomains under bobstrange.dev, DNS, Cloudflare Access, which routes are auth-protected and which backdoor URLs are closed) is tracked in the **bobstrange/infra** repository (`~/src/bobstrange/infra`, README.md is the ledger).

- Before adding/changing hosting, domains, or auth for any service, check the ledger there
- After such a change, update the ledger in the same piece of work
- Service-internal config (build/deploy settings, in-app auth implementation) stays in each service repo's docs; the infra repo only holds the shared layer and links out
- Before any Vercel work (new service, config change, **or diagnosing slow/production-only performance issues**), also read `infra/docs/vercel-standard-setup.md` — it documents cross-service gotchas (e.g. Function region must match the DB's region, or requests pay a cross-region round trip that no amount of query-level optimization fixes)
