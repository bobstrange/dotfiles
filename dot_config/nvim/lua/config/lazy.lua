local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({"git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath})
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({{"Failed to clone lazy.nvim:\n", "ErrorMsg"}, {out, "WarningMsg"},
                           {"\nPress any key to exit..."}}, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

local defaults = {
    lazy = false,
    version = false -- always use the latest git commit
}

local install = {
    colorscheme = {"tokyonight", "habamax"}
}

local checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false -- notify on update
}

local performance = {
    rtp = {
        disabled_plugins = {"gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin"}
    }
}

local spec = { -- add LazyVim and import its plugins
{
    "LazyVim/LazyVim",
    import = "lazyvim.plugins"
}, -- import/override with your plugins
{
    import = "plugins"
}}

require("lazy").setup({
    spec = spec,
    defaults = defaults,
    install = install,
    checker = checker,
    performance = performance
})
