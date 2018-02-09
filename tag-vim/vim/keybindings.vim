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

"" Use display lines upward and downward
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
