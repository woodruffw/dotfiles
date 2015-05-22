colorscheme molokai
set mouse=a
syntax on
set autoindent
set noexpandtab
set shiftwidth=4
set tabstop=4
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle-bootstrap.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'bling/vim-airline'
Plugin 'Valloric/YouCompleteMe'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-session'
call vundle#end()

filetype plugin indent on

set smartindent
set backspace=indent,eol,start
set number
set hlsearch
set nowrap
set colorcolumn=80
imap jk <Esc>

inoremap <C-s> <esc>:w<cr>a
nnoremap <C-s> :w<cr>

inoremap <C-q> <esc>:q<cr>a
nnoremap <C-q> :q<cr>

" Browse with Ctrl-O
nnoremap <C-o> <esc>:browse confirm e<cr>
inoremap <C-o> <esc>:browse confirm e<cr>

" Cut, copy, paste, yank, undo with Ctrl-{x,c,v,y,z}
vmap <C-c> y<Esc>i
vmap <C-x> d<Esc>i
imap <C-v> <Esc>pi
imap <C-y> <Esc>ddi
map <C-z> <Esc>
imap <C-z> <Esc>ui

" Firefox-like tab navigation
nnoremap <C-S-tab> :tabprevious<CR>
nnoremap <C-tab>   :tabnext<CR>
nnoremap <C-t>     :tabnew<CR>
nnoremap <C-S-w> <Esc>:tabclose<CR>
inoremap <C-S-w> <Esc>:tabclose<CR>
inoremap <C-S-tab> <Esc>:tabprevious<CR>i
inoremap <C-tab>   <Esc>:tabnext<CR>i
inoremap <C-t>     <Esc>:tabnew<CR>

" Write file as superuser with w!!
cmap w!! w !sudo tee >/dev/null %

silent !stty -ixon > /dev/null 2> /dev/null

au Filetype html,xml,xsl source ~/.vim/scripts/closetag.vim

let g:UltiSnipsExpandTrigger = "<C-e>"
let g:UltiSnipsJumpForwardTrigger = "<C-n>"
let g:UltiSnipsJumpBackwardTrigger = "<C-b>"

let g:multi_cursor_use_default_mapping = 0
let g:multi_cursor_next_key = "<C-d>"
let g:multi_cursor_skip_key = "<C-D>"
let g:multi_cursor_quit_key = "<Esc>"

let g:session_autoload = "yes"
let g:session_autosave = "yes"
let g:session_autosave_periodic = 1

if system('uname') =~ 'Darwin'
  au BufEnter /private/tmp/crontab.* setl backupcopy=yes
endif

