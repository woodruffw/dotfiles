############################
# bash_profile (or bashrc) #
############################

[[ -z "$PS1" ]] && return

system=`uname`
host=`hostname`

###########
# Aliases #
###########

# system-independent aliases
alias s='sudo'
alias m='man'
alias make='colormake'
alias mk='make'
alias mkc='make clean'
alias smi='sudo make install'
alias smu='sudo make uninstall'
alias cm='cmake'
alias cls='clear'
alias df='df -kh'
alias pls='sudo $(tail -1 ~/.bash_history)'
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
alias ll='ls -lh'
alias lsg='ls | grep'
alias lsl='ls | less'
alias del='rm -i'
alias rr='rm -r'
alias ttyreset='echo -e \\033c'
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
alias mkdir='mkdir -p'

# system-dependent aliases and variables
if [[ "${system}" = "Linux" ]] ; then
  alias bashreload='unalias -a ; source ~/.bashrc'
  alias profile='vim ~/.bashrc'
  alias ls='ls --color=auto'

  if [[ "${host}" = "athena" ]] ; then
    alias nginxconf='sudo vim /etc/nginx/sites-enabled/default'
    alias www='cd /usr/share/nginx/html'
  fi

  if [[ -f "/usr/bin/apt-get" ]] ; then # Ubuntu, Debian systems
    alias sagu='sudo apt-get update'
    alias sagi='sudo apt-get install'
    alias sagr='sudo apt-get remove'
    alias sagar='sudo apt-get autoremove'
  elif [[ -f "/usr/bin/pacman" ]] ; then # Arch-based systems
    alias sps='sudo pacman -S'
    alias spr='sudo pacman -R'
    alias sprs='sudo pacman -Rs'
  fi

  export PATH="$PATH:/home/$USER/bin:/home/$USER/scripts"

elif [[ "${system}" = "Darwin" ]] ; then
  alias brew='brew -v'
  alias bashreload='unalias -a ; source ~/.bash_profile'
  alias profile='vim ~/.bash_profile'
  alias ls='ls -G'

  # if homebrew's nginx is installed
  if [[ -f "/usr/local/bin/nginx" ]] ; then
    alias nginxconf='vim /usr/local/etc/nginx/nginx.conf'
    alias nginxreload='sudo nginx -s reload'
    alias www='cd /usr/local/var/www'
  fi

  # if homebrew's bash-completion is installed
  if [[ -f "/usr/local/etc/bash_completion" ]] ; then
    source /usr/local/etc/bash_completion
  fi

  export PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11/bin:/Users/$USER/bin:/Users/$USER/scripts
fi

# if colordiff is installed, alias diff to it
if [[ `which colordiff 2> /dev/null` ]] ; then
  alias diff='colordiff'
fi

###############
# ENVIRONMENT #
###############

# system-independent environment variables
export LESSHISTFILE="/dev/null" # prevent less from creating ~/.lesshist
export PS1="\u@\h [\t] \W \[\e[1;31m\]\$(parse_git_branch)\[\e[0m\]$ " 
export EDITOR='vim'
export HISTCONTROL=ignoredups:erasedups
export MARKPATH=$HOME/.marks
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

# unset LESSOPEN and LESSPIPE (never used, and a security hole)
unset LESSOPEN
unset LESSPIPE

unset MAILCHECK # disable new mail alerts

#################
# SHELL OPTIONS #
#################
shopt -s histappend # don't overwrite the history file
shopt -s cdspell # fix typos in cd

################
# KEY BINDINGS #
################
bind -x '"\e[15~":ttyreset' # reset the terminal with Fun5

# load git aliases if it exists
[[ -f ~/.git-aliases ]] && source ~/.git-aliases
# load API key files if they exist
if [[ -d ~/.api-keys ]] ; then
  for keyfile in ~/.api-keys/*
  do
    source ${keyfile}
  done
fi
# load bash completion if it exists
[[ -f /etc/bash_completion ]] && source /etc/bash_completion


#############
# Functions #
#############

# getconfigs - get all the config files
# IMPORTANT: overwrites .bash_profile/.bashrc, .vimrc, etc
function getconfigs()
{
  if [[ ! `which git 2> /dev/null` ]] ; then
    echo "Fatal: git required to fetch configs."
    return 1
  fi

  pushd . > /dev/null

  # make sure the dotfiles repo exists and isn't clobbered
  if [[ -d ~/.dotfiles/.git ]] ; then
    cd ~/.dotfiles
    git fetch origin --quiet > /dev/null
    git merge origin/master > /dev/null
  else
    rm -rf ~/.dotfiles
    git clone https://github.com/woodruffw/dotfiles ~/.dotfiles > /dev/null
    cd ~/.dotfiles
  fi

  printf "Reloading profile..."
  if [[ "${system}" = "Linux" ]] ; then
    cp ~/.dotfiles/bash_profile ~/.bashrc
  elif [[ "${system}" = "Darwin" ]] ; then
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

  printf "Checking for wget..."
  if [[ `which wget 2> /dev/null` ]]; then
    printf "found. Reloading wgetrc..."
    cp ~/.dotfiles/wgetrc ~/.wgetrc
    printf "done.\n"
  else
    printf "not installed. Skipping.\n"
  fi

  printf "Checking for curl..."
  if [[ `which curl 2> /dev/null` ]]; then
    printf "found. Reloading curlrc..."
    cp ~/.dotfiles/curlrc ~/.curlrc
    printf "done.\n"
  else
    printf "not installed. Skipping.\n"
  fi

  printf "Checking for rtorrent..."
  if [[ `which rtorrent 2> /dev/null` ]] ; then
    printf "found. Reloading rtorrent.rc..."
    cp ~/.dotfiles/rtorrent.rc ~/.rtorrent.rc
    printf "done.\n"
  else
    printf "not installed. Skipping.\n"
  fi

  printf "Checking for tmux..."
  if [[ `which tmux 2> /dev/null` ]] ; then
    printf "found. Reloading tmux.conf..."
    cp ~/.dotfiles/tmux.conf ~/.tmux.conf
    printf "done.\n"
  else
    printf "not installed. Skipping.\n"
  fi

  printf "Checking for xbindkeys..."
  if [[ `which xbindkeys 2> /dev/null` ]] ; then
    printf "found. Reloading xbindkeysrc..."
    if [[ -f ~/.dotfiles/xbindkeysrc-${host} ]] ; then
      cp ~/.dotfiles/xbindkeysrc-${host} ~/.xbindkeysrc
      printf "done.\n"
    else
      printf "none required.\n"
    fi
  else
    printf "not installed. Skipping.\n"
  fi

  printf "Checking for thunar..."
  if [[ `which thunar 2> /dev/null` ]]; then
    printf "found. Reloading uca.xml..."
    mkdir -p ~/.config/Thunar
    cp ~/.dotfiles/config/Thunar/uca.xml ~/.config/Thunar/uca.xml
    printf "done.\n"
  else
    printf "not installed. Skipping.\n"
  fi

  printf "Checking for hexchat..."
  if [[ `which hexchat 2> /dev/null` ]]; then
    printf "found. Reloading addons..."
    mkdir -p ~/.config/hexchat/
    cp -Rf ~/.dotfiles/config/hexchat/addons/ ~/.config/hexchat/
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
  cp ~/.dotfiles/scripts/cskel ~/scripts/cskel
  cp ~/.dotfiles/scripts/jskel ~/scripts/jskel
  cp ~/.dotfiles/scripts/linecheck ~/scripts/linecheck
  cp ~/.dotfiles/scripts/haste ~/scripts/haste
  cp ~/.dotfiles/scripts/update ~/scripts/update

  if [[ "${host}" = "mercury" ]] ; then
    cp ~/.dotfiles/scripts/poomf.sh ~/scripts/poomf.sh
  fi

  if [[ "${host}" = "athena" ]] ; then
    cp ~/.dotfiles/scripts/wwwbackup ~/scripts/wwwbackup
    cp ~/.dotfiles/scripts/dailymail.rb ~/scripts/dailymail.rb
    cp ~/.dotfiles/scripts/twitter-fortune-bot.pl ~/scripts/twitter-fortune-bot.pl
  fi

  if [[ "${host}" = "mars" ]] ; then
    cp ~/.dotfiles/scripts/dailymail.rb ~/scripts/dailymail.rb
    cp ~/.dotfiles/scripts/magnet-to-torrent.pl ~/scripts/magnet-to-torrent.pl
  fi
  chmod +x ~/scripts/*
  printf "done.\n"

  printf "Fetching cron-shunt and crontab..."
  cp ~/.dotfiles/scripts/cron-shunt ~/scripts/cron-shunt
  if [[ -f ~/.dotfiles/scripts/crontabs/${host}.cron ]] ; then
    cp ~/.dotfiles/scripts/crontabs/${host}.cron ~/scripts/${host}.cron
    crontab -r
    crontab ~/scripts/${host}.cron
    printf "done.\n"
  else
    printf "none required.\n"
  fi

  popd > /dev/null

  printf "Sync dotfiles-priv? (y/N): " && read ans
  if [[ "$ans" =~ [Yy] ]] ; then
    git clone https://github.com/woodruffw/dotfiles-priv 2> /dev/null
    pushd . > /dev/null
    cd dotfiles-priv
    ./install.sh
    popd > /dev/null
    rm -rf dotfiles-priv
  fi

  echo "All done."

  bashreload
}

# strlen
# prints the length of all arguments, spaces included
function strlen()
{
  str="${*}"
  echo "${#str}"
}

# cd - cat grep
# pipes cat into grep
function cg()
{
  cat "${1}" | grep "${2}"
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
  echo "[""${ref#refs/heads/}""] "
}

# prj - cd to projects
# cds to the project folder or to a specified project
function prj()
{
  if [[ -z "${1}" ]] ; then
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

# fw, lw, vw - expand file, less, vim input from which
# useful for reading from files on the PATH without their paths
function fw()
{
  file `which $1`
}

function lw()
{
  less `which $1`
}

function vw()
{
  vim `which $1`
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

