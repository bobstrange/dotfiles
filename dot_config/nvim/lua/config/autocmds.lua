-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Treesitter-based folding (disabled by default)
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    if vim.treesitter.get_parser(0, vim.bo.filetype, { error = false }) then
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.wo.foldenable = false
    end
  end,
})
