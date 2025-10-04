return {
  -- GitHub Dark theme
  {
    "projekt0n/github-nvim-theme",
    lazy = false, -- make sure we load this during startup
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("github-theme").setup({
        options = {
          transparent = false,
          styles = {
            comments = "italic",
            keywords = "bold",
            types = "italic,bold",
          },
        },
      })
      vim.cmd("colorscheme github_dark")
    end,
  },

  -- Configure LazyVim to use GitHub Dark
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "github_dark",
    },
  },

  -- add any additional plugins here
}