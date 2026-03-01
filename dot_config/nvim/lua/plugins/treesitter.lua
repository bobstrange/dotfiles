return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    -- LazyVim already includes: bash, c, diff, html, javascript, json, jsonc,
    -- lua, markdown, markdown_inline, python, query, toml, tsx, typescript,
    -- vim, vimdoc, xml, yaml
    -- lang extras include: elixir, eex (lang.elixir), ruby (lang.ruby),
    --   vue (lang.vue), go (lang.go), rust (lang.rust)
    -- Add parsers not in LazyVim defaults or extras:
    ensure_installed = {
      "scss",
      "jq",
      "dockerfile",
      "graphql",
      "hcl",
      "terraform",
      "make",
      "mermaid",
      "sql",
    },
  },
}
