return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  branch = "main",
  build = ":TSUpdate",
  config = function()
    -- 基本セットアップ（オプション）
    require("nvim-treesitter").setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })

    -- よく使う言語のパーサーを自動インストール
    local parsers = {
      "lua", "vim", "vimdoc", "query",
      "javascript", "typescript", "tsx",
      "json", "yaml", "toml",
      "html", "css", "markdown", "markdown_inline",
      "bash", "python", "rust", "go",
      "c", "cpp", "java",
      "dockerfile", "regex",
    }

    -- 非同期でパーサーをインストール
    require("nvim-treesitter").install(parsers)

    -- 各FileTypeでTreesitterを有効化
    vim.api.nvim_create_autocmd("FileType", {
      pattern = parsers,
      callback = function()
        -- Treesitterを開始
        vim.treesitter.start()

        -- 折りたたみ設定（Treesitterベース）
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo.foldenable = false  -- デフォルトで折りたたみを無効

        -- インデント設定（実験的機能）
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
