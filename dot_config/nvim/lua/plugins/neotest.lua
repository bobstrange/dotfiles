return {
  "nvim-neotest/neotest",
  dependencies = {
    "jfpedroza/neotest-elixir",
    "olimorris/neotest-rspec",
  },
  opts = function(_, opts)
    opts.adapters = opts.adapters or {}
    vim.list_extend(opts.adapters, {
      require("neotest-elixir"),
      require("neotest-rspec"),
    })
  end,
}
