:set mouse=a
syntax on
:set autoindent
:set backspace=indent,eol,start
set number
:au Filetype html,xml,xsl source ~/.vim/scripts/closetag.vim 
:imap jk <Esc>

inoremap <C-s> <esc>:w<cr>a
nnoremap <C-s> :w<cr>

inoremap <C-q> <esc>:q<cr>a
nnoremap <C-q> :q<cr>

silent !stty -ixon > /dev/null 2> /dev/null
colorscheme industry

