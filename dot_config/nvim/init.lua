-- bootstrap lazy.nvim, LazyVim and your plugins
vim.cmd("source ~/.vim/base_config.vim")
vim.cmd("source ~/.vim/keybindings.vim")
require("config.lazy")

require("nvim-treesitter.configs").setup({
  highlight = {
    enable = true,
    -- conceal を無効化
    additional_vim_regex_highlighting = false,
  },
  -- conceal を無効化
  incremental_selection = { enable = false },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.conceallevel = 0 -- backtickを表示
    vim.opt_local.concealcursor = ""
  end,
})
