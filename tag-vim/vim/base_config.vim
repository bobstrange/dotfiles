" Base settings
" refs: https://qiita.com/nrk_baby/items/154e3fa15c48a39e3375

" Encoding
set encoding=utf-8
set fileencoding=utf-8

" Python runtime
let g:python_host_prog = $HOME . '/.pyenv/versions/2.7.14/bin/python2'
let g:python3_host_prog = $HOME .'/.pyenv/versions/3.6.4/bin/python3'

" Make space as a <Leader>
let mapleader = "\<Space>"

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


