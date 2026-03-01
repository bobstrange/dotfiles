return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        -- web
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        vue = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        html = { "prettier" },
        -- ruby
        ruby = { "rubocop" },
        -- terraform/HCL
        terraform = { "terraform_fmt" },
        hcl = { "terraform_fmt" },
        tf = { "terraform_fmt" },
        -- SQL
        sql = { "pg_format" },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "prettier",
        "stylua",
        "rubocop",
      },
    },
  },
}
