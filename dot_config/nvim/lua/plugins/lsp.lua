return {{
    "neovim/nvim-lspconfig",
    dependencies = {"williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim"},
    config = function()
        local lspconfig = require("lspconfig")
        local mason = require("mason")
        local mason_lspconfig = require("mason-lspconfig")

        -- Mason のセットアップ
        mason.setup()
        mason_lspconfig.setup({
            ensure_installed = {"lua_ls", -- Lua
            "tsserver", -- TypeScript
            "pyright", -- Python
            "rust_analyzer", -- Rust
            "gopls" -- Go
            }
        })

        -- 共通の `on_attach` 関数
        local on_attach = function(client, bufnr)
            local opts = {
                noremap = true,
                silent = true,
                buffer = bufnr
            }
            local keymap = vim.api.nvim_buf_set_keymap

            keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
            keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
            keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
            keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
            keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
            keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
        end

        -- LSP 設定を一括適用
        mason_lspconfig.setup_handlers({function(server_name)
            lspconfig[server_name].setup({
                on_attach = on_attach
            })
        end})
    end
}}

