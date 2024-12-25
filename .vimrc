" Install vim plug automatically
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

source ~/.vim/plugins.vim

call plug#end()

syntax enable

source ~/.vim/base_config.vim
source ~/.vim/theme.vim
source ~/.vim/airline.vim
source ~/.vim/keybindings.vim
source ~/.vim/buffer.vim
source ~/.vim/netrw.vim
source ~/.vim/vimdiff.vim
source ~/.vim/fzf.vim
" source ~/.vim/coc.vim
" source ~/.vim/lsp.vim

" source ~/.vim/ale.vim

" Config for each languages
source ~/.vim/javascript.vim
source ~/.vim/go.vim
source ~/.vim/markdown.vim

lua << EOF
-- Masonの初期化
require("mason").setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

-- Mason-LSPconfigの設定
require("mason-lspconfig").setup({
  ensure_installed = { "ts_ls", "pyright", "solargraph" }, -- 必要なLSPサーバー
  automatic_installation = true,
})
