---
paths:
  - "dot_config/private_Code/**"
---

# VS Code (add-back workflow)

`dot_config/private_Code/` is, like `dot_config/zed/`, a place where editing the `$HOME`
target directly is correct. VS Code rewrites `~/.config/Code/User/settings.json` itself
whenever a setting is changed from the settings editor, so the loop is reversed:

1. Change settings in VS Code / `~/.config/Code/User/settings.json` as usual
2. `chezmoi add ~/.config/Code/User/settings.json`
3. `chezmoi diff` and commit

The file is JSONC — comments and trailing commas — so `dot_config/private_Code/` is in
`.prettierignore`; without it prettier rewrites the file into invalid JSON on every commit.
Keep it as plain JSONC: promoting it to `.tmpl` breaks `chezmoi add`, so only do that once a
setting genuinely differs per machine.

`~/.config/Code` is mode 700, so the source is `private_Code`. Leave the `private_` prefix or
the mode churns on every `chezmoi diff`.

## Settings is the only resource this repo owns

Everything else belongs to Settings Sync:

| Resource                                                                                  | Owner         |
| ----------------------------------------------------------------------------------------- | ------------- |
| Settings                                                                                  | this repo     |
| Keyboard Shortcuts, Snippets, Tasks, MCP Servers, UI State, Extensions, Profiles, Prompts | Settings Sync |

**Do not `chezmoi add` `keybindings.json`, `snippets/`, or `tasks.json`.** Two owners means
the cloud overwrites the file and `chezmoi apply` writes it back, forever. Keybindings are
deliberately left to Sync because `settingsSync.keybindingsPerPlatform` already keeps macOS
and Linux bindings apart; reproducing that here would need per-OS templates.

Extensions are not declared anywhere — not in `Brewfile`, not in `nix/packages.nix`. See the
VS Code section of `CLAUDE.md` for why.

**Gotcha:** turning Settings sync off is per-machine and cannot be declared. It lives in
`globalStorage/state.vscdb` (SQLite) as `sync.enable.settings`, and there is no equivalent
setting id — `settingsSync.ignoredSettings`, `settingsSync.ignoredExtensions` and
`settingsSync.keybindingsPerPlatform` are the only sync keys that live in `settings.json`. So
a new machine needs the GUI once: `Backup and Sync Settings...` (the command is no longer
called `Settings Sync: Turn On`), then uncheck **Settings**. Until that is done, applying this
repo's `settings.json` will fight the cloud copy.

## Linux only, for now

macOS keeps its settings in Settings Sync, because its path differs
(`~/Library/Application Support/Code/User/`) and would need a second source tree plus OS
gating in `.chezmoiignore`. The two therefore diverge. Do not assume a setting seen here is
active on macOS.
