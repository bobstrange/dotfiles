return { -- LSPの追加設定（LazyVimのデフォルトを拡張）
{
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
        local ts_inlay_hints = {
            includeInlayParameterNameHints = "all",
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
        }

        opts.servers = opts.servers or {}

        -- inlay hints (extras does not configure these)
        opts.servers.ts_ls = vim.tbl_deep_extend("force", opts.servers.ts_ls or {}, {
            settings = {
                typescript = { inlayHints = ts_inlay_hints },
                javascript = { inlayHints = ts_inlay_hints },
            },
        })

        -- custom env and dialyzer setting specific to this machine
        opts.servers.elixirls = vim.tbl_deep_extend("force", opts.servers.elixirls or {}, {
            cmd_env = {
                GOOGLE_APPLICATION_CREDENTIALS = vim.fn.expand("~/.config/gcloud/application_default_credentials.json"),
            },
            settings = {
                elixirLS = {
                    dialyzerEnabled = false,
                },
            },
        })

    end,
}}
