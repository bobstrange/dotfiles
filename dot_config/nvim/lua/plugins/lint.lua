return {
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "cspell" } },
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}

      -- Add cspell to markdown (alongside existing markdownlint-cli2)
      local md = opts.linters_by_ft["markdown"] or {}
      if not vim.tbl_contains(md, "cspell") then
        table.insert(md, "cspell")
      end
      opts.linters_by_ft["markdown"] = md
    end,
  },
}
