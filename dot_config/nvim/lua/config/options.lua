-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Example options to override LazyVim defaults:
-- vim.g.mapleader = " "
-- vim.g.maplocalleader = "\\"

-- vim.opt.winbar = "%=%m %f"

-- Set conceallevel to 0 to show all concealed text
vim.opt.conceallevel = 0

-- Skip CJK characters in spell checking (LazyVim enables spell for markdown etc.)
vim.opt.spelllang = { "en", "cjk" }

-- Neovide / GUI settings
if vim.g.neovide then
  vim.o.guifont = "PlemolJP Console NF:h13"
end