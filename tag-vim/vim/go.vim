" ref https://mattn.kaoriya.net/software/vim/20130531000559.htm
" ref https://mattn.kaoriya.net/software/vim/20200106103137.htm

set rtp+=$GOROOT/misc/vim

" `go get github.com/nsf/gocode` needed
" <c-x><c-o> で補完
exe "set rtp+=".globpath($GOPATH, "src/github.com/nsf/gocode/vim")
set completeopt=menu,preview

" enable auto format when write (default)
let g:goimports = 1


" ref https://github.com/golang/tools/blob/master/gopls/doc/vim.md#vim-lsp

augroup LspGo
  au!
  autocmd User lsp_setup call lsp#register_server({
      \ 'name': 'go-lang',
      \ 'cmd': {server_info->['gopls']},
      \ 'whitelist': ['go'],
      \ })
  autocmd FileType go setlocal omnifunc=lsp#complete
  "autocmd FileType go nmap <buffer> gd <plug>(lsp-definition)
  "autocmd FileType go nmap <buffer> ,n <plug>(lsp-next-error)
  "autocmd FileType go nmap <buffer> ,p <plug>(lsp-previous-error)
augroup END

" Available commands
" :GoImport fmt
