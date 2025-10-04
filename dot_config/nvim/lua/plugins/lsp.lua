return {
  -- Mason: Portable package manager for Neovim
  {
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    opts = {},
  },

  -- Mason-lspconfig: Bridges mason.nvim with lspconfig
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      -- List of servers to automatically install
      ensure_installed = {
        "ts_ls",           -- TypeScript/JavaScript
        "html",            -- HTML
        "cssls",           -- CSS
        "vls",             -- Vue.js
        "rust_analyzer",   -- Rust
        "elixirls",        -- Elixir
        "sqls",            -- SQL
        "lua_ls",          -- Lua
      },
      -- Auto-install configured servers
      automatic_installation = true,
    },
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
    },
    config = function()
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

      -- Setup capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      -- Specific server configurations
      local server_configs = {
        ts_ls = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
              },
            },
          },
        },
        html = {
          filetypes = { "html", "eex", "heex" },
        },
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              check = {
                command = "clippy",
              },
              cargo = {
                allFeatures = true,
              },
            },
          },
        },
        elixirls = {
          settings = {
            elixirLS = {
              dialyzerEnabled = true,
              fetchDeps = false,
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              workspace = {
                checkThirdParty = false,
                library = { vim.env.VIMRUNTIME },
              },
              telemetry = { enable = false },
            },
          },
        },
      }

      -- Use mason-lspconfig to setup handlers
      require("mason-lspconfig").setup_handlers({
        -- Default handler for all servers
        function(server_name)
          local config = server_configs[server_name] or {}
          config.capabilities = capabilities
          require("lspconfig")[server_name].setup(config)
        end,
      })

      -- Setup keymaps on LSP attach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local buffer = event.buf
          local opts = { buffer = buffer }

          -- Navigation
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = buffer, desc = "Goto Definition" })
          vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = buffer, desc = "References" })
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = buffer, desc = "Goto Declaration" })
          vim.keymap.set("n", "gI", vim.lsp.buf.implementation, { buffer = buffer, desc = "Goto Implementation" })
          vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, { buffer = buffer, desc = "Goto Type Definition" })

          -- Documentation
          vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = buffer, desc = "Hover" })
          vim.keymap.set("n", "gK", vim.lsp.buf.signature_help, { buffer = buffer, desc = "Signature Help" })
          vim.keymap.set("i", "<c-k>", vim.lsp.buf.signature_help, { buffer = buffer, desc = "Signature Help" })

          -- Actions
          vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = buffer, desc = "Code Action" })
          vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { buffer = buffer, desc = "Rename" })
          vim.keymap.set({ "n", "v" }, "<leader>cf", vim.lsp.buf.format, { buffer = buffer, desc = "Format" })

          -- Diagnostics
          vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { buffer = buffer, desc = "Line Diagnostics" })
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { buffer = buffer, desc = "Prev Diagnostic" })
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { buffer = buffer, desc = "Next Diagnostic" })
          vim.keymap.set("n", "[e", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, { buffer = buffer, desc = "Prev Error" })
          vim.keymap.set("n", "]e", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, { buffer = buffer, desc = "Next Error" })
        end,
      })
    end,
  },
}