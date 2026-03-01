-- nvim --headless -c "lua print(vim.fn.stdpath('data'))" -c "quit"
-- /home/bob/.local/share/nvim

local treesitter_path = vim.fs.joinpath(vim.fn.stdpath("data"), "/treesitter")
vim.uv.fs_mkdir(treesitter_path, tonumber("755", 8))

return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  branch = "main",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({
      install_dir = treesitter_path,
    })

    -- -- よく使う言語のパーサーを自動インストール
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
        -- Treesitterを開始
        vim.treesitter.start()

        -- 折りたたみ設定（Treesitterベース）
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo.foldenable = false -- デフォルトで折りたたみを無効

        -- インデント設定（実験的機能）
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
