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