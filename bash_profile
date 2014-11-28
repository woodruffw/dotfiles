############################
# bash_profile (or bashrc) #
############################

system=`uname`
host=`hostname`

############################
# Aliases and Enivironment #
############################

# system-independent aliases
alias s='sudo'
alias m='man'
alias make='colormake'
alias mk='make'
alias mkc='make clean'
alias smi='sudo make install'
alias smu='sudo make uninstall'
alias cm='cmake'
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
alias +r='chmod +r'
alias +w='chmod +w'
alias +x='chmod +x'
alias la='ls -a'
alias ll='ls -l'
alias lsg='ls | grep'
alias lsl='ls | less'
alias del='rm -i'
alias rr='rm -r'
alias ttyreset='echo -e \\033c'
alias ssh='ssh -o VisualHostKey=yes -X'
alias ret='echo $?'
alias ..='cd ..'
alias .2='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias cronedit='crontab -e'
alias cronls='crontab -l'
alias reboot='sudo reboot'
alias rmhk='ssh-keygen -R'
alias path='echo $PATH'

# if colordiff is installed, alias diff to it
if [ `which colordiff 2> /dev/null` ] ; then
  alias diff='colordiff'
fi

# system-independent environment variables
export PS1="\u@\h [\t] \W \[\e[1;31m\]\$(parse_git_branch)\[\e[0m\]$ " 
export EDITOR='vim'
export MARKPATH=$HOME/.marks

# unset LESSOPEN and LESSPIPE (never used, and a security hole)
unset LESSOPEN
unset LESSPIPE

# load git aliases if it exists
[ -f ~/.git-aliases ] && source ~/.git-aliases
# load server aliases if it exists
[ -f ~/.server-aliases ] && source ~/.server-aliases
# load API key files if they exist
if [ -d ~/.api-keys ] ; then
  for f in `ls ~/.api-keys`
  do
    source $f
  done
fi
# load bash completion if it exists
[ -f /etc/bash_completion ] && source /etc/bash_completion

# system-dependent aliases and variables
if [ "$system" = "Linux" ] ; then
  alias bashreload='unalias -a ; source ~/.bashrc'
  alias profile='vim ~/.bashrc'
  alias ls='ls --color=auto'

  if [ "$host" = "athena" ] ; then
    alias nginxconf='sudo vim /etc/nginx/sites-enabled/default'
    alias www='cd /usr/share/nginx/html'
  fi

  if [ -f /usr/bin/apt-get ] ; then # Ubuntu, Debian systems
    alias update='sudo apt-get update ; sudo apt-get upgrade ; sudo apt-get clean'
    alias sagu='sudo apt-get update'
    alias sagi='sudo apt-get install'
    alias sagr='sudo apt-get remove'
    alias sagar='sudo apt-get autoremove'
  elif [ -f /usr/bin/pacman ] ; then # Arch-based systems
    alias update='sudo pacman -Syyu'
    alias sps='sudo pacman -S'
    alias spr='sudo pacman -R'
    alias sprs='sudo pacman -Rs'
  fi

  export PATH="$PATH:/home/$USER/bin:/home/$USER/scripts"

elif [ "$system" = "Darwin" ] ; then
  alias brew='brew -v'
  alias update='brew update ; brew upgrade ; brew cleanup -s'
  alias bashreload='unalias -a ; source ~/.bash_profile'
  alias profile='vim ~/.bash_profile'
  alias ls='ls -G'

  # if homebrew's nginx is installed
  if [ -f /usr/local/bin/nginx ] ; then
    alias nginxconf='vim /usr/local/etc/nginx/nginx.conf'
    alias nginxreload='sudo nginx -s reload'
    alias www='cd /usr/local/var/www'
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
  if [ ! `which git 2> /dev/null` ] ; then
    echo "Fatal: git required to fetch configs."
    exit 1
  fi

  pushd . > /dev/null

  # make sure the dotfiles repo exists and isn't clobbered
  if [[ ! -d ~/.dotfiles/.git ]] ; then
    rm -rf ~/.dotfiles
    git clone https://github.com/woodruffw/dotfiles ~/.dotfiles > /dev/null
    cd ~/.dotfiles
  else
    cd ~/.dotfiles
    git fetch origin --quiet > /dev/null
    git merge origin/master > /dev/null
  fi

  printf "Reloading profile..."
  if [ "$system" = "Linux" ] ; then
    cp ~/.dotfiles/bash_profile ~/.bashrc
  elif [ "$system" = "Darwin" ] ; then
    cp ~/.dotfiles/bash_profile ~/.bash_profile
  fi
  printf "done.\n"

  printf "Reloading git-aliases and gitconfig..."
  cp ~/.dotfiles/git-aliases ~/.git-aliases
  cp ~/.dotfiles/gitconfig ~/.gitconfig
  printf "done.\n"

  printf "Reloading vimrc and vim scripts..."
  cp ~/.dotfiles/vimrc ~/.vimrc
  mkdir -p ~/.vim/scripts/
  cp ~/.dotfiles/vim/scripts/closetag.vim ~/.vim/scripts/closetag.vim
  printf "done.\n"

  printf "Checking for rtorrent..."
  if [ `which rtorrent 2> /dev/null` ] ; then
    printf "found.\nReloading rtorrent.rc..."
    cp ~/.dotfiles/rtorrent.rc ~/.rtorrent.rc
    printf "done.\n"
  else
    printf "not installed. Skipping.\n"
  fi

  printf "Checking for tmux..."
  if [ `which tmux 2> /dev/null` ] ; then
    printf "found.\nReloading tmux.conf..."
    cp ~/.dotfiles/tmux.conf ~/.tmux.conf
    printf "done.\n"
  else
    printf "not installed. Skipping.\n"
  fi

  printf "Fetching scripts..."
  mkdir -p ~/scripts
  cp ~/.dotfiles/scripts/$ ~/scripts/$
  cp ~/.dotfiles/scripts/% ~/scripts/%
  cp ~/.dotfiles/scripts/colorscheme ~/scripts/colorscheme
  cp ~/.dotfiles/scripts/colorscheme2 ~/scripts/colorscheme2
  cp ~/.dotfiles/scripts/colormake ~/scripts/colormake
  # afs-umd is only required on mercury
  if [ "$host" = "mercury" ] ; then
    cp ~/.dotfiles/scripts/afs-umd ~/scripts/afs-umd
  fi
  # wwwbackup is only required on athena
  if [ "$host" = "athena" ] ; then
    cp ~/.dotfiles/scripts/wwwbackup ~/scripts/wwwbackup
  fi
  # dailymail is only required on mars
  if [ "$host" = "mars" ] ; then
    cp ~/.dotfiles/scripts/dailymail.rb ~/scripts/dailymail.rb
  fi
  chmod +x ~/scripts/*
  printf "done.\n"

  printf "Fetching crontab..."
  if [ -f ~/.dotfiles/scripts/crontabs/$host.cron ] ; then
    cp ~/.dotfiles/scripts/crontabs/$host.cron ~/scripts/$host.cron
    crontab -r
    crontab ~/scripts/$host.cron
    printf "done.\n"
  else
    printf "none required.\n"
  fi

  popd > /dev/null

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

# jmp (jump) and friends, shamelessly taken from:
# http://jeroenjanssens.com/2013/08/16/quickly-navigate-your-filesystem-from-the-command-line.html
function jmp()
{
  cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
}

function mark()
{
  mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"
}

function unmark()
{
  rm -i "$MARKPATH/$1"
}

function marks()
{
  ls -l "$MARKPATH" | tail -n +2 | sed 's/  / /g' | cut -d' ' -f9- | awk -F ' -> ' '{printf "%-10s -> %s\n", $1, $2}'
}


########################
# COMPLETION FUNCTIONS #
########################

function _completemarks()
{
  local curw=${COMP_WORDS[COMP_CWORD]}
  local wordlist=$(ls $MARKPATH 2> /dev/null)
  COMPREPLY=($(compgen -W '${wordlist[@]}' -- "$curw"))
}

function _completeprj()
{
  local curw=${COMP_WORDS[COMP_CWORD]}
  local wordlist=$(ls ~/Dropbox/Programming 2> /dev/null)
  COMPREPLY=($(compgen -W '${wordlist[@]}' -- "$curw"))
}

###########################
# COMPLETION ASSOCIATIONS #
###########################

complete -F _completemarks jmp unmark
complete -F _completeprj prj

