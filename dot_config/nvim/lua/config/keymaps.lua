-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Set leader
vim.keymap.set("n", "<leader>p", "<cmd>lua require('fzf-lua').files()<CR>", {
    noremap = true,
    silent = true,
    desc = "FZF Files"
})
vim.keymap.set("n", "<leader>l", "<cmd>lua require('fzf-lua').buffers()<CR>", {
    noremap = true,
    silent = true,
    desc = "FZF Buffers"
})
