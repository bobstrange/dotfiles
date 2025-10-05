return { -- LSPの追加設定（LazyVimのデフォルトを拡張）
{
    "neovim/nvim-lspconfig",
    opts = {
        servers = {
            ts_ls = {
                settings = {
                    typescript = {
                        inlayHints = {
                            includeInlayParameterNameHints = "all",
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayVariableTypeHints = true,
                            includeInlayPropertyDeclarationTypeHints = true,
                            includeInlayFunctionLikeReturnTypeHints = true
                        }
                    },
                    javascript = {
                        inlayHints = {
                            includeInlayParameterNameHints = "all",
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayVariableTypeHints = true,
                            includeInlayPropertyDeclarationTypeHints = true,
                            includeInlayFunctionLikeReturnTypeHints = true
                        }
                    }
                }
            },
            html = {},
            cssls = {},
            vue_ls = {},
            rust_analyzer = {
                settings = {
                    ["rust-analyzer"] = {
                        check = {
                            command = "clippy"
                        }
                    }
                }
            },
            elixirls = {},
            sqls = {},
            lua_ls = {
                settings = {
                    Lua = {
                        runtime = {
                            version = "LuaJIT"
                        },
                        diagnostics = {
                            globals = {"vim"}
                        },
                        workspace = {
                            checkThirdParty = false,
                            library = {vim.env.VIMRUNTIME}
                        },
                        telemetry = {
                            enable = false
                        }
                    }
                }
            }
        }
    }
}}
