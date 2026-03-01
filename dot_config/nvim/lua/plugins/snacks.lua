return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        files = {
          hidden = true,
        },
      },
    },
  },
  keys = {
    -- find
    { "<leader>l",  function() Snacks.picker.buffers() end,              desc = "Buffers" },
    { "<leader>p",  function() Snacks.picker.files() end,                desc = "Find Files" },
    { "<leader>fg", function() Snacks.picker.git_files() end,            desc = "Find Files (git)" },
    { "<leader>fr", function() Snacks.picker.recent() end,               desc = "Recent Files" },
    -- git
    { "<leader>gc", function() Snacks.picker.git_log() end,              desc = "Git Commits" },
    { "<leader>gs", function() Snacks.picker.git_status() end,           desc = "Git Status" },
    -- search
    { "<leader>sb", function() Snacks.picker.lines() end,                desc = "Buffer Lines" },
    { "<leader>sc", function() Snacks.picker.command_history() end,      desc = "Command History" },
    { "<leader>sd", function() Snacks.picker.diagnostics_buffer() end,   desc = "Document Diagnostics" },
    { "<leader>sD", function() Snacks.picker.diagnostics() end,          desc = "Workspace Diagnostics" },
    { "<leader>sg", function() Snacks.picker.grep() end,                 desc = "Grep" },
    { "<leader>sh", function() Snacks.picker.help() end,                 desc = "Help Pages" },
    { "<leader>sj", function() Snacks.picker.jumps() end,                desc = "Jumplist" },
    { "<leader>sk", function() Snacks.picker.keymaps() end,              desc = "Keymaps" },
    { "<leader>sm", function() Snacks.picker.marks() end,                desc = "Marks" },
    { "<leader>sR", function() Snacks.picker.resume() end,               desc = "Resume" },
    { "<leader>ss", function() Snacks.picker.lsp_symbols() end,          desc = "LSP Symbols" },
    { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
    { "<leader>sw", function() Snacks.picker.grep_word() end,            desc = "Grep Word", mode = { "n", "v" } },
  },
}
