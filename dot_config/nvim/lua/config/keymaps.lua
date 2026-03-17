-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Map Ctrl-C to ESC
vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("v", "<C-c>", "<Esc>", { desc = "Exit visual mode" })
vim.keymap.set("s", "<C-c>", "<Esc>", { desc = "Exit select mode" })
vim.keymap.set("x", "<C-c>", "<Esc>", { desc = "Exit visual block mode" })
vim.keymap.set("c", "<C-c>", "<C-c>", { desc = "Keep default in command mode" })
vim.keymap.set("o", "<C-c>", "<Esc>", { desc = "Exit operator-pending mode" })

-- Neovide: clipboard copy/paste with Alt-c/Alt-v
if vim.g.neovide then
  vim.keymap.set("v", "<A-c>", '"+y', { desc = "Copy to system clipboard" })
  vim.keymap.set({ "n", "v" }, "<A-v>", '"+p', { desc = "Paste from system clipboard" })
  vim.keymap.set("i", "<A-v>", function()
    vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
  end, { desc = "Paste from system clipboard" })
  vim.keymap.set("c", "<A-v>", "<C-r>+", { desc = "Paste from system clipboard" })
end