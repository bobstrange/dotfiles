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
                -- inlay hints (extras does not configure these)
                ts_ls = {
                    settings = {
                        typescript = { inlayHints = ts_inlay_hints },
                        javascript = { inlayHints = ts_inlay_hints },
                    }
                },
                -- custom env and dialyzer setting specific to this machine
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
            }
        }
    end
}}
