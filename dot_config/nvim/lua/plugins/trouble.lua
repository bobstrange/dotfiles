return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "Trouble",
  opts = function()
    return {
      auto_close = false,
      auto_open = false,
      auto_jump = false,
      auto_refresh = true,
      focus = false,
      restore = true,
      follow = true,
      indent_guides = true,
      multiline = true,
      pinned = false,
      warn_no_results = true,
      open_no_results = false,
      win = {},
      preview = {
        type = "main",
        scratch = true,
      },
      throttle = {
        refresh = 20,
        preview = { ms = 100, debounce = true },
        follow = 100,
      },
      keys = {
        ["?"] = "help",
        r = "refresh",
        R = "toggle_refresh",
        q = "close",
        o = "jump_close",
        ["<esc>"] = "cancel",
        ["<cr>"] = "jump",
        ["<2-leftmouse>"] = "jump",
        ["<c-s>"] = "jump_split",
        ["<c-v>"] = "jump_vsplit",
        ["<c-t>"] = "jump_tab",
        j = "next",
        k = "prev",
        dd = "delete",
        d = { action = "delete", mode = "v" },
        i = "inspect",
        p = "preview",
        P = "toggle_preview",
        zo = "fold_open",
        zO = "fold_open_recursive",
        zc = "fold_close",
        zC = "fold_close_recursive",
        za = "fold_toggle",
        zA = "fold_toggle_recursive",
        zm = "fold_more",
        zM = "fold_close_all",
        zr = "fold_reduce",
        zR = "fold_open_all",
        zx = "fold_update",
        zX = "fold_update_all",
        zn = "fold_disable",
        zN = "fold_enable",
        zi = "fold_toggle_enable",
        gb = {
          action = function(view)
            view:filter({ buf = 0 }, { toggle = true })
          end,
          desc = "Toggle Current Buffer Filter",
        },
        s = {
          action = function(view)
            local f = view:get_filter("severity")
            local severity = vim.diagnostic.severity.HINT
            if f and f.filter.severity then
              severity = f.filter.severity
            end
            if severity == vim.diagnostic.severity.HINT then
              severity = vim.diagnostic.severity.ERROR
            else
              severity = severity + 1
            end
            view:filter({ severity = severity }, {
              id = "severity",
              template = "{hl:Title}Filter:{hl} {severity}",
              del = severity == vim.diagnostic.severity.HINT,
            })
          end,
          desc = "Toggle Severity Filter",
        },
      },
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
    }
  end,
  keys = {
    -- Diagnostics
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
    { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
    { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
    { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
    { "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
    { "<leader>cl", "<cmd>Trouble lsp toggle<cr>", desc = "LSP (Trouble)" },

    -- LSP
    { "gR", "<cmd>Trouble lsp_references toggle<cr>", desc = "LSP References" },
    { "gI", "<cmd>Trouble lsp_implementations toggle<cr>", desc = "LSP Implementations" },
    { "gD", "<cmd>Trouble lsp_definitions toggle<cr>", desc = "LSP Definitions" },
    { "gy", "<cmd>Trouble lsp_type_definitions toggle<cr>", desc = "LSP Type Definitions" },

    -- Navigation
    {
      "[q",
      function()
        if require("trouble").is_open() then
          require("trouble").prev({ skip_groups = true, jump = true })
        else
          local ok, err = pcall(vim.cmd.cprev)
          if not ok then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      end,
      desc = "Previous Trouble/Quickfix Item",
    },
    {
      "]q",
      function()
        if require("trouble").is_open() then
          require("trouble").next({ skip_groups = true, jump = true })
        else
          local ok, err = pcall(vim.cmd.cnext)
          if not ok then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      end,
      desc = "Next Trouble/Quickfix Item",
    },
  },
}