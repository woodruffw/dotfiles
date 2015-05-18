colorscheme molokai
:set mouse=a
syntax on
set autoindent
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle-bootstrap.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'bling/vim-airline'
Plugin 'Valloric/YouCompleteMe'
call vundle#end()

filetype plugin indent on

set smartindent
:set backspace=indent,eol,start
set number
:set hlsearch
:set nowrap
:set colorcolumn=80
:imap jk <Esc>

inoremap <C-s> <esc>:w<cr>a
nnoremap <C-s> :w<cr>

inoremap <C-q> <esc>:q<cr>a
nnoremap <C-q> :q<cr>

cmap w!! w !sudo tee >/dev/null %

"inoremap { {<CR>}<Esc>ko
"inoremap ( ()<Esc>i
"inoremap [ []<Esc>i

silent !stty -ixon > /dev/null 2> /dev/null

:au Filetype html,xml,xsl source ~/.vim/scripts/closetag.vim

if system('uname') =~ 'Darwin'
  au BufEnter /private/tmp/crontab.* setl backupcopy=yes
endif
