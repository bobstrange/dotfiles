return {
  "folke/trouble.nvim",
  opts = {
    modes = {
      diagnostics = {
        mode = "diagnostics",
        preview = {
          type = "float",
          relative = "editor",
          border = "rounded",
          title = "Preview",
          title_pos = "center",
          position = { 0, -2 },
          size = { width = 0.3, height = 0.3 },
          zindex = 200,
        },
      },
    },
  },
  keys = {
    { "gR", "<cmd>Trouble lsp_references toggle<cr>",       desc = "LSP References" },
    { "gI", "<cmd>Trouble lsp_implementations toggle<cr>",  desc = "LSP Implementations" },
    { "gD", "<cmd>Trouble lsp_definitions toggle<cr>",      desc = "LSP Definitions" },
    { "gy", "<cmd>Trouble lsp_type_definitions toggle<cr>", desc = "LSP Type Definitions" },
  },
}
