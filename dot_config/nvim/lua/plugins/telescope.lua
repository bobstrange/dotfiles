return {
    'nvim-telescope/telescope.nvim',
    dependencies = {'nvim-lua/plenary.nvim'},
    cmd = "Telescope",
    keys = {{
        "<leader>p",
        "<cmd>Telescope find_files<cr>",
        desc = "Find Files"
    }, {
        "<leader>f",
        "<cmd>Telescope live_grep<cr>",
        desc = "Live Grep"
    }, {
        "<leader>l",
        "<cmd>Telescope buffers<cr>",
        desc = "Buffers"
    }}
}
