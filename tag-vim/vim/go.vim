" ref https://mattn.kaoriya.net/software/vim/20130531000559.htm
" ref https://mattn.kaoriya.net/software/vim/20200106103137.htm

set rtp+=$GOROOT/misc/vim

" `go get github.com/nsf/gocode` needed
" <c-x><c-o> で補完
exe "set rtp+=".globpath($GOPATH, "src/github.com/nsf/gocode/vim")
set completeopt=menu,preview

" Available commands
" :Import fmt
" :Godoc net/http
" :Fmt
