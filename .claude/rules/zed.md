---
paths:
  - "dot_config/zed/**"
---

# Zed (add-back workflow)

`dot_config/zed/` is the one place where editing the `$HOME` target directly is correct. Zed
rewrites `~/.config/zed/settings.json` itself whenever a setting is changed from the UI (font size,
theme picker, vim mode), so the loop is reversed:

1. Change settings in Zed / `~/.config/zed/settings.json` as usual
2. `chezmoi add ~/.config/zed/settings.json`
3. `chezmoi diff` and commit

Keep these as plain JSON — promoting one to `.tmpl` breaks `chezmoi add`, so only do that once a
setting genuinely differs per machine. Zed writes `settings.json` with mode `0600`, so the source is
`private_settings.json`; leave the `private_` prefix or the mode churns on every `chezmoi diff`.
Zed also reformats the file as JSONC (trailing commas) and normalizes values (e.g.
`"relative_line_numbers": true` → `"enabled"`) — that is Zed, not a stray edit. `.config/zed/` is in
`.prettierignore` so this formatting does not ping-pong with prettier.

Extensions are declarative via `auto_install_extensions` in `settings.json`; there is no `run_once_`
install script. The installed extension binaries live in `~/Library/Application Support/Zed/extensions/`
on macOS (`~/.local/share/zed/extensions/` on Linux), which — along with the DB, logs, and agent
history — is state, not config, and stays unmanaged.

**Gotcha:** installing an extension or picking a theme from the UI does _not_ add it to
`auto_install_extensions`. A theme in particular leaves only its _name_ in `theme.dark`, so a fresh
machine sets a name it cannot resolve. Register the extension by hand in the same change.
