Plug 'ctrlpvim/ctrlp.vim'

set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.png
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']

