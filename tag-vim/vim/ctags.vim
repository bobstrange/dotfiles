Plug 'fntlnz/atags.vim'

autocmd BufWritePost * call atags#generate()
nnoremap <C-]> g<C-]>

