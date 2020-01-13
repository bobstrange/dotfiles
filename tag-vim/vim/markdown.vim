Plug 'plasticboy/vim-markdown'
map ]] <Plug>Markdown_MoveToNextHeader
map [[ <Plug>Markdown_MoveToPreviousHeader
map ]c <Plug>Markdown_MoveToCurHeader
map ]u <Plug>Markdown_MoveToParentHeader

let g:vim_markdown_folding_disabled = 1
" let g:vim_markdown_folding_level = 2

Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & npm install'   }
