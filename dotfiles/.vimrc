set term=xterm-256color
syntax on
set tabstop=4
set shiftwidth=4
set autoindent
set number
set viminfo='100,<200,s10,h

call plug#begin()
  Plug 'prabirshrestha/vim-lsp'
  Plug 'mattn/vim-lsp-settings'
  Plug 'mattn/vim-goimports'
call plug#end()

" golang(go-vim)
" let g:goimports = 1
" let g:goimports_simplify = 1

" golang(syntastic)
" let g:syntastic_go_checkers = ['go']
