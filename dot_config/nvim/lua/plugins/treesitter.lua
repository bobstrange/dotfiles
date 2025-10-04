return {
    "https://github.com/nvim-treesitter/nvim-treesitter",
    lazy = false,
    branch = "main",
    build = ':TSUpdate',
    config = function()
        -- List of parsers to support
        local parsers = {
            "bash",
            "diff",
            "editorconfig",
            "eex",
            "elixir",
            "html",
            "javascript",
            "json",
            "markdown",
            "markdown_inline",
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
    end,
}
