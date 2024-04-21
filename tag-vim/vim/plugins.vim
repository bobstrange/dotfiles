" For intellisence
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'mattn/vim-lsp-icons'
Plug 'dense-analysis/ale'
Plug 'rhysd/vim-lsp-ale'

" Snippet engine
" Plug 'SirVer/ultisnips'
" Snippet definitions
" Plug 'honza/vim-snippets'

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'editorconfig/editorconfig-vim'
Plug 'chrisbra/vim-diff-enhanced'

" Plug 'tomasr/molokai'
" Plug 'altercation/vim-colors-solarized'
Plug 'sainnhe/everforest'

Plug 'godlygeek/tabular'
Plug 'tpope/vim-surround'
" Plug 'cohama/lexima.vim'
Plug 'tmux-plugins/vim-tmux'

" Create a directory on save if needed
Plug 'pbrisbin/vim-mkdir'

" Git
Plug 'tpope/vim-fugitive'

" LSP
" Plug 'neoclide/coc.nvim', { 'branch': 'release' }

" Markdown
Plug 'plasticboy/vim-markdown'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & npm install' }

" JavaScript
Plug 'pangloss/vim-javascript', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'othree/yajs.vim', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'othree/es.next.syntax.vim', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'othree/javascript-libraries-syntax.vim', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'mxw/vim-jsx'
Plug 'posva/vim-vue'
" Plug 'digitaltoad/vim-pug'

" TypeScript
Plug 'HerringtonDarkholme/yats.vim'

" Ruby
Plug 'vim-ruby/vim-ruby', { 'for': ['ruby', 'haml', 'eruby'] }
Plug 'tpope/vim-rake', { 'for': 'ruby' }
Plug 'tpope/vim-rails', { 'for': ['ruby', 'eruby', 'haml', 'coffee', 'javascript'] }
Plug 'tpope/vim-rbenv', { 'for': 'ruby' }

" Elixir
" Plug 'elixir-editors/vim-elixir'

" Go
Plug 'mattn/vim-goimports'

" Zig
Plug 'ziglang/zig.vim'
