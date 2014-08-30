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
alias cc99='gcc -O3 -std=c99 -Wall -Wno-unused-parameter -Wextra'
alias cc89='gcc -O3 -std=c89 -Wall -Wno-unused-parameter -Wextra'
alias cls='clear'
alias df='df -kh'
alias please='sudo !!'
alias svim='sudo vim'
alias vi='vim'
alias vmi='vim'
alias vimrc='vim ~/.vimrc'
alias htop='htop --sort-key PERCENT_CPU'
alias mkexec='chmod +x'
alias la='ls -a'
alias lg='ls | grep'
alias ll='ls | less'
alias del='rm -i'
alias rr='env rm -r'
alias ttyreset='echo -e \\033c'

# system-independent environment variables
export PS1="\u@\h [\t] \W \$(parse_git_branch)$ " 
export EDITOR='vim'

# load git aliases if it exists
[ -f ~/.git-aliases ] && source ~/.git-aliases
# load server aliases if it exists
[ -f ~/.server-aliases ] && source ~/.server-aliases

# system-dependent aliases and variables
if [ "$SYSTEM" = "Linux" ] ; then
  alias bashreload='source ~/.bashrc'
  alias profile='vim ~/.bashrc'
  alias ls='ls -hf --color=auto'
  if [ -f /usr/bin/apt-get ] ; then # Ubuntu, Debian systems
    alias update='sudo apt-get update ; sudo apt-get upgrade'
  elif [ -f /usr/bin/pacman ] ; then # Arch-based systems
    alias update='sudo pacman -Syyu'
  fi
elif [ "$SYSTEM" = "Darwin" ] ; then
  alias brew='brew -v'
  alias update='brew update ; brew upgrade ; brew cleanup -s'
  alias bashreload='source ~/.bash_profile'
  alias profile='vim ~/.bash_profile'
  alias ls='ls -h -G -F'

  # if homebrew's nginx is installed
  if [ -f /usr/local/bin/nginx ] ; then
    alias nginxconf='vim /usr/local/etc/nginx/nginx.conf'
    alias nginxreload='sudo nginx -s reload'
  fi

  # if homebrew's bash-completion is installed
  if [ -f /usr/local/etc/bash_completion ] ; then
    source /usr/local/etc/bash_completion
  fi

  export PATH=/usr/local/bin:/usr/local/sbin:/Users/admin/scripts:/Users/admin/bin:/usr/bin:/bin:/sbin:/usr/sbin:/usr/X11/bin
fi

#############
# Functions #
#############

# getconfigs - get all the config files
# IMPORTANT: overwrites .bash_profile/.bashrc, .vimrc, etc
function getconfigs()
{
 if [ "$SYSTEM" = "Linux" ] ; then
  curl https://www.github.com/woodruffw/dotfiles/raw/master/bash_profile -o ~/.bashrc
 elif [ "$SYSTEM" = "Darwin" ] ; then
  curl https://www.github.com/woodruffw/dotfiles/raw/master/bash_profile -o ~/.bash_profile
 fi

 curl https://www.github.com/woodruffw/dotfiles/raw/master/git-aliases -o ~/.git-aliases
 curl https://www.github.com/woodruffw/dotfiles/raw/master/gitconfig -o ~/.gitconfig
 curl https://www.github.com/woodruffw/dotfiles/raw/master/vimrc -o ~/.vimrc

 if [ `which rtorrent 2>/dev/null` ] ; then
  curl https://www.github.com/woodruffw/dotfiles/raw/master/rtorrent.rc -o ~/.rtorrent.rc
 fi

 if [ `which tmux 2>/dev/null` ] ; then
  curl https://www.github.com/woodruffw/dotfiles/raw/master/tmux.conf -o ~/.tmux.conf
 fi
}

# strlen
# prints the length of the first argument
function strlen()
{
  echo $1 | awk '{print length}'
}

# wp - working project
# cd to the working project, or set it if -s is tripped
function wp()
{
  if [ "$1" = "-s" ] ; then
    echo $2 > ~/.wp
  else
    DIR=`cat ~/.wp`
    cd $DIR
  fi
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
