############################
# bash_profile (or bashrc) #
############################

SYSTEM=`uname`

############################
# Aliases and Enivironment #
############################

# system-independent aliases
alias s='sudo'
alias mk='make'
alias mkc='make clean'
alias smi='sudo make install'
alias smu='sudo make uninstall'
alias cc99='gcc -O3 -std=c99 -Wall -Wno-unused-parameter -Wextra'
alias cc89='gcc -O3 -std=c89 -Wall -Wno-unused-parameter -Wextra'
alias cls='clear'
alias df='df -kh'
alias please='sudo !!'
alias svim='sudo vim'
alias vi='vim'
alias vmi='vim'
alias vimrc='vim ~/.vimrc'
alias gitconf='vim ~/.gitconfig'
alias htop='htop --sort-key PERCENT_CPU'
alias mkexec='chmod +x'
alias la='ls -a'
alias ll='ls -l'
alias lsg='ls | grep'
alias lsl='ls | less'
alias del='rm -i'
alias rr='rm -r'
alias ttyreset='echo -e \\033c'
alias ssh='ssh -o VisualHostKey=yes'
alias ret='echo $?'
alias ..='cd ..'
alias .2='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'

# if colordiff is installed, alias diff to it
if [ `which colordiff` ] ; then
  alias diff='colordiff'
fi

# system-independent environment variables
export PS1="\u@\h [\t] \W \[\e[1;31m\]\$(parse_git_branch)\[\e[0m\]$ " 
export EDITOR='vim'

# load git aliases if it exists
[ -f ~/.git-aliases ] && source ~/.git-aliases
# load server aliases if it exists
[ -f ~/.server-aliases ] && source ~/.server-aliases

# system-dependent aliases and variables
if [ "$SYSTEM" = "Linux" ] ; then
  alias bashreload='unalias -a ; source ~/.bashrc'
  alias profile='vim ~/.bashrc'
  alias ls='ls --color=auto'
  if [ -f /usr/bin/apt-get ] ; then # Ubuntu, Debian systems
    alias update='sudo apt-get update ; sudo apt-get upgrade ; sudo apt-get clean'
    alias sagi='sudo apt-get install'
    alias sagr='sudo apt-get remove'
  elif [ -f /usr/bin/pacman ] ; then # Arch-based systems
    alias update='sudo pacman -Syyu'
    alias sps='sudo pacman -S'
    alias spr='sudo pacman -R'
    alias sprs='sudo pacman -Rs'
  fi
elif [ "$SYSTEM" = "Darwin" ] ; then
  alias brew='brew -v'
  alias update='brew update ; brew upgrade ; brew cleanup -s'
  alias bashreload='unalias -a ; source ~/.bash_profile'
  alias profile='vim ~/.bash_profile'
  alias ls='ls -G'

  # if homebrew's nginx is installed
  if [ -f /usr/local/bin/nginx ] ; then
    alias nginxconf='vim /usr/local/etc/nginx/nginx.conf'
    alias nginxreload='sudo nginx -s reload'
  fi

  # if homebrew's bash-completion is installed
  if [ -f /usr/local/etc/bash_completion ] ; then
    source /usr/local/etc/bash_completion
  fi

  export PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11/bin:/Users/$USER/bin:/Users/$USER/scripts
fi

#############
# Functions #
#############

# getconfigs - get all the config files
# IMPORTANT: overwrites .bash_profile/.bashrc, .vimrc, etc
function getconfigs()
{
  printf "Fetching profile..."
  if [ "$SYSTEM" = "Linux" ] ; then
    curl -s https://raw.githubusercontent.com/woodruffw/dotfiles/master/bash_profile -o ~/.bashrc
  elif [ "$SYSTEM" = "Darwin" ] ; then
    curl -s https://raw.githubusercontent.com/woodruffw/dotfiles/master/bash_profile -o ~/.bash_profile
  fi
  printf "done\n"

  printf "Fetching git-aliases and gitconfigs..."
  curl -s https://raw.githubusercontent.com/woodruffw/dotfiles/master/git-aliases -o ~/.git-aliases
  curl -s https://raw.githubusercontent.com/woodruffw/dotfiles/master/gitconfig -o ~/.gitconfig
  printf "done\n"

  printf "Fetching vimrc and vim scripts..."
  curl -s https://raw.githubusercontent.com/woodruffw/dotfiles/master/vimrc -o ~/.vimrc
  mkdir -p ~/.vim/scripts/
  curl -s https://raw.githubusercontent.com/woodruffw/dotfiles/master/vim/scripts/closetag.vim -o ~/.vim/scripts/closetag.vim
  printf "done\n"

  printf "Checking for rtorrent..."
  if [ `which rtorrent 2>/dev/null` ] ; then
    printf "found.\nFetching rtorrent.rc..."
    curl -s https://raw.githubusercontent.com/woodruffw/dotfiles/master/rtorrent.rc -o ~/.rtorrent.rc
    printf "done\n"
  else
    printf "not installed. Skipping.\n"
  fi

  printf "Checking for tmux..."
  if [ `which tmux 2>/dev/null` ] ; then
    printf "found.\nFetching tmux.conf..."
    curl -s https://raw.githubusercontent.com/woodruffw/dotfiles/master/tmux.conf -o ~/.tmux.conf
    printf "done.\n"
  else
    printf "not installed. Skipping.\n"
  fi

  bashreload
}

# strlen
# prints the length of the first argument
function strlen()
{
  echo ${#1}
}

# cd - cat grep
# pipes cat into grep
function cg()
{
  cat $1 | grep $2
}

# qc - quick compile
# compiles with cc99 (see alias above) and outputs to a file with a "good" name
function qc()
{
  FILE=$1
  BASE=${FILE%%.*}
  cc99 $FILE -o $BASE
  unset FILE BASE
}

# man - colorize man pages
# overloads the existing man command and supplements it with colors
function man()
{
  env \
  LESS_TERMCAP_mb=$(printf "\e[1;31m") \
  LESS_TERMCAP_md=$(printf "\e[1;31m") \
  LESS_TERMCAP_me=$(printf "\e[0m") \
  LESS_TERMCAP_se=$(printf "\e[0m") \
  LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
  LESS_TERMCAP_ue=$(printf "\e[0m") \
  LESS_TERMCAP_us=$(printf "\e[1;32m") \
  man "$@"
}

# parse_git_branch
# prints the current branch in the current repo, or returns
# used in PS1
function parse_git_branch()
{
  ref=$(git symbolic-ref HEAD 2>/dev/null) || return
  echo "["${ref#refs/heads/}"] "
}

# prj - cd to projects
# cds to the project folder or to a specified project
function prj()
{
  if [[ -z "$1" ]]
  then
    cd ~/Dropbox/Programming/
  else
    cd ~/Dropbox/Programming/$1*
  fi
}

# shah - get sha1 and output just the hash
function shah()
{
  shasum $1 | awk '{ print $1 }'
}

# cleanup
unset SYSTEM
