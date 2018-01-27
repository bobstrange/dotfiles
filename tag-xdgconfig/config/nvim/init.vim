" Plugins

call plug#begin('~/.config/nvim/plugged')

source ~/.vim/ctrlp.vim
source ~/.vim/ctags.vim
source ~/.vim/ag.vim
source ~/.vim/airline.vim
source ~/.vim/completion.vim
source ~/.vim/vimdiff.vim
source ~/.vim/plugins.vim

call plug#end()


source ~/.vim/theme.vim
" Base settings
" refs: https://qiita.com/nrk_baby/items/154e3fa15c48a39e3375

set encoding=utf-8
set fileencoding=utf-8

syntax enable

" Python

let g:python_host_prog = $HOME . '/.pyenv/versions/2.7.14/bin/python2'
let g:python3_host_prog = $HOME .'/.pyenv/versions/3.6.4/bin/python3'

" color
" tabs indents
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set smartindent
set shiftround
filetype plugin indent on

" scroll
set scrolloff=5

" backup
set noswapfile
set nowritebackup

" views
set number
set showmatch
set wrap
set list
set listchars=tab:»-,trail:-,extends:»,precedes:«,nbsp:%,eol:↲
set virtualedit=onemore
set ambiwidth=double

" search
set ignorecase
set smartcase

" edit
set clipboard+=unnamedplus
set hidden
set switchbuf=useopen
set mouse=a
set sh=zsh
set formatoptions-=ro " Avoid to insert a comment on newline

" map keys
"" Off IME on pushing esc
inoremap <silent> <Esc> <Esc>:set iminsert=0<CR>

"" Assign Ctrl-c to esc
inoremap <C-c> <Esc>
nnoremap <C-c> <Esc>
vnoremap <C-c> <Esc>

"" tig
nnoremap tig :<C-u>w<CR>:te tig<CR>

"" Emacs like keybindings
inoremap <C-p> <Up>
inoremap <C-n> <Down>
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-d> <Delete>
inoremap <C-h> <Backspace>

"" Indentation
nnoremap > >>
nnoremap < <<
vnoremap > >
vnoremap < <

"" Remove highlight with Escape
nnoremap <Esc> :noh<return><Esc>
nnoremap <C-c> :noh<return><Esc>
