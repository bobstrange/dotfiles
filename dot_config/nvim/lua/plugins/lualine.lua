return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, 1, {
        function()
          local progress = vim.lsp.status()
          if progress and progress ~= "" then
            -- Truncate if too long
            if #progress > 40 then
              progress = progress:sub(1, 37) .. "..."
            end
            return progress
          end
          return ""
        end,
        cond = function()
          local progress = vim.lsp.status()
          return progress and progress ~= ""
        end,
      })
    end,
  },
}
