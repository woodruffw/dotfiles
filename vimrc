:set mouse=a
syntax on
set autoindent
set smartindent
:set backspace=indent,eol,start
set number
:set hlsearch
:imap jk <Esc>

inoremap <C-s> <esc>:w<cr>a
nnoremap <C-s> :w<cr>

inoremap <C-q> <esc>:q<cr>a
nnoremap <C-q> :q<cr>

inoremap { {<CR>}<Esc>ko
inoremap ( ()<Esc>i
inoremap [ []<Esc>i

silent !stty -ixon > /dev/null 2> /dev/null

:au Filetype html,xml,xsl source ~/.vim/scripts/closetag.vim

if system('uname') =~ 'Darwin'
  au BufEnter /private/tmp/crontab.* setl backupcopy=yes
endif
