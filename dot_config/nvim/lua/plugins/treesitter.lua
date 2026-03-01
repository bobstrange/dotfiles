return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    -- LazyVim already includes: bash, c, diff, html, javascript, json, jsonc,
    -- lua, markdown, markdown_inline, python, query, toml, tsx, typescript,
    -- vim, vimdoc, xml, yaml
    -- Add parsers not in LazyVim defaults:
    ensure_installed = {
      "scss",
      "vue",
      "jq",
      "dockerfile",
      "elixir",
      "eex",
      "graphql",
      "hcl",
      "terraform",
      "make",
      "mermaid",
      "ruby",
      "sql",
    },
  },
}
