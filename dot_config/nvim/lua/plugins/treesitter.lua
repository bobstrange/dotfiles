return {
    "https://github.com/nvim-treesitter/nvim-treesitter",
    lazy = false,
    branch = "main",
    build = ':TSUpdate',
    config = function()
        -- List of parsers to support
        local parsers = {
            -- Essential for Noice.nvim
            "vim",
            "regex",
            "lua",
            "bash",
            "markdown",
            "markdown_inline",
            -- User requested languages
            "diff",
            "editorconfig",
            "eex",
            "elixir",
            "html",
            "javascript",
            "json",
            "ruby",
            "scss",
            "sql",
            "terraform",
            "toml",
            "typescript",
            "vue",
            "yaml",
        }

        -- Auto-install parsers when entering buffer
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("nvim-treesitter-auto-install", {}),
            callback = function(event)
                local ft = event.match
                local parser_name = ft

                -- Map some filetypes to parser names
                local ft_to_parser = {
                    tf = "terraform",
                    yml = "yaml",
                    js = "javascript",
                    ts = "typescript",
                    rb = "ruby",
                }

                if ft_to_parser[ft] then
                    parser_name = ft_to_parser[ft]
                end

                -- Check if parser should be installed
                if vim.tbl_contains(parsers, parser_name) then
                    local ok = pcall(vim.treesitter.get_parser, event.buf, parser_name)
                    if not ok then
                        vim.schedule(function()
                            vim.cmd("TSInstall " .. parser_name)
                        end)
                    end
                end

                -- Start treesitter highlighting
                pcall(vim.treesitter.start)
            end,
        })

        -- Install essential parsers on startup for Noice.nvim
        vim.schedule(function()
            local essential_parsers = { "vim", "regex", "lua", "bash", "markdown", "markdown_inline" }
            for _, parser in ipairs(essential_parsers) do
                local ok = pcall(vim.treesitter.get_parser, 0, parser)
                if not ok then
                    -- Try TSInstall command (works with newer nvim-treesitter)
                    local success = pcall(vim.cmd, "TSInstall " .. parser)
                    if not success then
                        -- If TSInstall doesn't exist, try using the API directly
                        pcall(function()
                            local configs = require("nvim-treesitter.configs")
                            configs.commands.TSInstall.run(parser)
                        end)
                    end
                end
            end
        end)
    end,
}
