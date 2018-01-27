call plug#begin('~/.config/nvim/plugged')

source ~/.vim/ctrlp.vim
source ~/.vim/ctags.vim
source ~/.vim/ag.vim
source ~/.vim/airline.vim
source ~/.vim/completion.vim
source ~/.vim/vimdiff.vim
source ~/.vim/plugins.vim

call plug#end()

syntax enable

source ~/.vim/base_config.vim
source ~/.vim/theme.vim
source ~/.vim/keybindings.vim

