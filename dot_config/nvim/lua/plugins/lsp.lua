return { -- LSPの追加設定（LazyVimのデフォルトを拡張）
{
    "neovim/nvim-lspconfig",
    opts = function()
        local ts_inlay_hints = {
            includeInlayParameterNameHints = "all",
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
        }

        return {
            servers = {
                ts_ls = {
                    settings = {
                        typescript = { inlayHints = ts_inlay_hints },
                        javascript = { inlayHints = ts_inlay_hints },
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
                elixirls = {
                    cmd_env = {
                        GOOGLE_APPLICATION_CREDENTIALS = vim.fn.expand("~/.config/gcloud/application_default_credentials.json"),
                    },
                    settings = {
                        elixirLS = {
                            dialyzerEnabled = false,
                        }
                    }
                },
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
    end
}}
