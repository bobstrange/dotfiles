" Base settings
" refs: https://qiita.com/nrk_baby/items/154e3fa15c48a39e3375

set modifiable
" Encoding
set encoding=utf-8
set fileencoding=utf-8

" Python runtime
let g:python3_host_prog = $HOME .'/.pyenv/versions/3.9.4/bin/python3'

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
set colorcolumn=80

" highlight Zenkaku space
" https://gist.github.com/pgtwitter/cb31d497aa02f221164fc2dd846d24dc
function! ZenkakuSpace()
    highlight ZenkakuSpace cterm=reverse ctermfg=DarkMagenta gui=reverse guifg=DarkMagenta
endfunction

if has('syntax')
  augroup ZenkakuSpace
    autocmd!
    autocmd ColorScheme       * call ZenkakuSpace()
    autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
  augroup END
  call ZenkakuSpace()
endif

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

" clipboard ref: https://blog.himanoa.net/entries/20/

if has('wsl') && exectable('win32yank.exe')
  nnoremap <silent>yy :.w !win32yank.exe -i<CR><CR>
  vnoremap <silent>y :w !win32yank.exe -i<CR><CR>
  nnoremap <silent>dd :.w !win32yank.exe -i<CR>dd
  vnoremap <silent>d x:let pos = getpos(".")<CR>GpVG:w !win32yank.exe -i<CR>VGx:call setpos(".", pos)<CR>
  nnoremap <silent>p :r !win32yank.exe -o<CR>
  vnoremap <silent>p :r !win32yank.exe -o<CR>
endif

