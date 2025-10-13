return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  branch = "main",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({})

    -- -- よく使う言語のパーサーを自動インストール
    local parsers = {
      "javascript",
      "markdown",
    }

    -- -- 非同期でパーサーをインストール
    -- require("nvim-treesitter").install(parsers)

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
