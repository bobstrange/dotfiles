return {
  -- Simple LSP setup without mason
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lspconfig = require("lspconfig")

      -- Setup diagnostics
      vim.diagnostic.config({
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
      })

      -- Common capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      -- Try to setup servers that are available
      local servers = {
        "ts_ls",     -- TypeScript/JavaScript
        "html",      -- HTML
        "cssls",     -- CSS
        "vls",       -- Vue.js
        "rust_analyzer", -- Rust
        "elixirls",  -- Elixir
        "sqls",      -- SQL
        "lua_ls",    -- Lua
      }

      for _, server in ipairs(servers) do
        local ok, _ = pcall(function()
          lspconfig[server].setup({
            capabilities = capabilities,
          })
        end)
        if ok then
          vim.notify("LSP: " .. server .. " configured", vim.log.levels.INFO)
        end
      end

      -- Keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local buffer = event.buf
          local opts = { buffer = buffer }

          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        end,
      })
    end,
  },
}