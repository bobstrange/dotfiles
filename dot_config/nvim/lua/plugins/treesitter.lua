return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  branch = "main",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup()

    local parsers = {
      "javascript",
      "json",
      "yaml",
      "toml",
      "typescript",
      "html",
      "css",
      "scss",
      "vue",
      "markdown",
      "markdown_inline",
      "jq",
      "bash",
      "dockerfile",
      "elixir",
      "eex",
      "go",
      "graphql",
      "hcl",
      "terraform",
      "lua",
      "make",
      "mermaid",
      "python",
      "rust",
      "ruby",
      "sql",
      "vim",
    }

    -- 各FileTypeでTreesitterを有効化
    vim.api.nvim_create_autocmd("FileType", {
      pattern = parsers,
      callback = function()
        vim.treesitter.start()

        -- 折りたたみ設定（Treesitterベース）
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo.foldenable = false

        -- インデント設定
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
