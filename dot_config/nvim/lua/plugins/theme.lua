local is_neovide = vim.g.neovide

return {
  -- GitHub Dark theme (terminal)
  {
    "projekt0n/github-nvim-theme",
    lazy = is_neovide,
    priority = 1000,
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
      if not is_neovide then
        vim.cmd("colorscheme github_dark")
      end
    end,
  },

  -- Catppuccin theme (Neovide)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = not is_neovide,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
      })
      if is_neovide then
        vim.cmd("colorscheme catppuccin")
      end
    end,
  },

  -- Configure LazyVim colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = is_neovide and "catppuccin" or "github_dark",
    },
  },
}
