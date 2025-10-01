return {
    "mason-org/mason-lspconfig.nvim",
    version = "^1.0.0",
    opts = {
        ensure_installed = { -- for JavaScript
        "ts_ls", "deno", "prettierd", -- for lua
        "lua_ls", "stylua", -- for elixir
        "expert", -- for ShellScript
        "shfmt", -- for Markdown
        "textlint", "marksman", -- for Postgres
        "pgformatter", "postgrestools"}
    },
    dependencies = {{
        "mason-org/mason.nvim",
        version = "^1.0.0",
        opts = {}
    }, "neovim/nvim-lspconfig"}
}
