-- bootstrap lazy.nvim, LazyVim and your plugins
vim.cmd("source ~/.vim/base_config.vim")
vim.cmd("source ~/.vim/keybindings.vim")
require("config.lazy")

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.conceallevel = 0 -- backtickを表示
	end,
})
