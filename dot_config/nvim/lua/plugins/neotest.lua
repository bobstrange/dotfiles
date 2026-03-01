return {
  "nvim-neotest/neotest",
  dependencies = {
    "jfpedroza/neotest-elixir",
    "olimorris/neotest-rspec",
    "marilari88/neotest-vitest",
  },
  opts = function(_, opts)
    opts.adapters = opts.adapters or {}
    vim.list_extend(opts.adapters, {
      require("neotest-elixir"),
      require("neotest-rspec"),
      require("neotest-vitest"),
    })
  end,
}
