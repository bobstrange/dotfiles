" https://github.com/dense-analysis/ale

" Fixing
let g:ale_fixers = {
      \'javascript': ['prettier', 'eslint'],
      \'typescript': ['prettier', 'eslint'],
      \'typescriptreact': ['prettier', 'eslint']
      \}
let g:ale_fix_on_save = 1

" Linters

let g:ale_linters = {
      \'javascript': ['eslint'],
      \'typescript': ['eslint'],
      \'typescriptreact': ['eslint']
      \}

"" Only run linters named in ale_linters
let g:ale_linters_explicit = 1

" whereever the cursor currently lies on show errors or warnings
let g:ale_virtualtext_cursor = 'all'

" customize signs
let g:ale_sign_error = '>>'
let g:ale_sign_warning = '--'
