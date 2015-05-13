############################
# bash_profile (or bashrc) #
############################

[[ -z "${PS1}" ]] && return

system=$(uname)
host=$(hostname)

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
alias du='du -kh'
alias pls='sudo $(tail -1 ~/.bash_history)'
alias svim='sudo vim'
alias vi='vim'
alias vmi='vim'
alias vimrc='vim ~/.vimrc'
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
alias crone='crontab -e'
alias cronl='crontab -l'
alias reboot='sudo reboot'
alias rmhk='ssh-keygen -R'
alias path='echo ${PATH}'
alias mkdir='mkdir -p'
alias getconfigs='dotfiles ; bashreload'

source ~/.git-aliases

# if colordiff is installed, alias diff to it
if [[ $(which colordiff 2> /dev/null) ]] ; then
	alias diff='colordiff'
fi

# if jekyll is installed, add its aliases
if [[ $(which jekyll 2> /dev/null) ]] ; then
	alias jb='jekyll build'
	alias jc='jekyll clean'
	alias js='jekyll serve'
fi

# if feh is installed, alias it
if [[ $(which feh 2> /dev/null) ]] ; then
	alias feh='feh --scale-down'
fi

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

	export PATH="${PATH}:/home/$USER/bin:/home/$USER/scripts"

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

###############
# ENVIRONMENT #
###############

# set the editor depending on what's installed
if [[ $(which textadept 2> /dev/null) ]] ; then
	export EDITOR=textadept
elif [[ $(which subl 2> /dev/null) ]] ; then
	export EDITOR=subl
elif [[ $(which vim 2> /dev/null) ]] ; then
	export EDITOR=vim
elif [[ $(which nano 2> /dev/null) ]] ; then
	export EDITOR=nano
else
	export EDITOR=ed # the universal editor!
fi

# system-independent environment variables
export LESSHISTFILE="/dev/null" # prevent less from creating ~/.lesshist
export PS1="\u@\h [\t] \W \[\e[1;31m\]\$(parse_git_branch)\[\e[0m\]$ " 
export HISTCONTROL="ignoredups:erasedups"
export MARKPATH="${HOME}/.marks"
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

# convenient colors
export COLOR_BLK=$(tput setaf 0)
export COLOR_RED=$(tput setaf 1)
export COLOR_GRN=$(tput setaf 2)
export COLOR_YLW=$(tput setaf 3)
export COLOR_BLU=$(tput setaf 4)
export COLOR_MAG=$(tput setaf 5)
export COLOR_CYN=$(tput setaf 6)
export COLOR_WHT=$(tput setaf 7)
export COLOR_NRM='\033[0m'

# convenient text modes
export TEXT_BOLD=$(tput bold)
export TEXT_UNDL=$(tput smul)
export TEXT_RMUL=$(tput rmul)

# load API key files if they exist
if [[ -d ~/.api-keys ]] ; then
	for keyfile in ~/.api-keys/* ; do
		source ${keyfile}
	done
fi

# unset LESSOPEN and LESSPIPE (never used, and a security hole)
unset LESSOPEN
unset LESSPIPE

# disable new mail alerts
unset MAILCHECK

#################
# SHELL OPTIONS #
#################
shopt -s histappend # don't overwrite the history file
shopt -s cdspell # fix typos in cd

################
# KEY BINDINGS #
################
bind -x '"\e[15~":ttyreset' # reset the terminal with F5

#############
# Functions #
#############

# strlen
# prints the length of all arguments, spaces included
function strlen()
{
	str="${*}"
	echo "${#str}"
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
	man "${@}"
}

# parse_git_branch
# prints the current branch in the current repo, or returns
# used in PS1
function parse_git_branch()
{
	ref=$(git symbolic-ref HEAD 2> /dev/null) || return
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
	shasum "${1}" | awk '{ print $1 }'
}

# fw, lw, ew - expand file, less, editor input from which
# useful for reading from files on the PATH without their paths
function fw()
{
	file $(which ${1})
}

function lw()
{
	less $(which ${1})
}

function ew()
{
	$EDITOR $(which ${1})
}

# jmp (jump) and friends, shamelessly taken from:
# http://jeroenjanssens.com/2013/08/16/quickly-navigate-your-filesystem-from-the-command-line.html
function jmp()
{
	cd -P "${MARKPATH}/${1}" 2> /dev/null || echo "No such mark: ${1}"
}

function mrk()
{
	mkdir -p "${MARKPATH}" ; ln -s "${PWD}" "${MARKPATH}/${1}"
}

function umrk()
{
	rm "${MARKPATH}/${1}"
}

function mrks()
{
	ls -l "${MARKPATH}" | tail -n +2 | sed 's/  / /g' | cut -d' ' -f9- | awk -F ' -> ' '{printf "%-10s -> %s\n", $1, $2}'
}


########################
# COMPLETION FUNCTIONS #
########################

function _completemarks()
{
	local curw=${COMP_WORDS[COMP_CWORD]}
	local wordlist=$(ls ${MARKPATH} 2> /dev/null)
	COMPREPLY=($(compgen -W '${wordlist[@]}' -- "${curw}"))
}

function _completeprj()
{
	local curw=${COMP_WORDS[COMP_CWORD]}
	local wordlist=$(ls ~/Dropbox/Programming 2> /dev/null)
	COMPREPLY=($(compgen -W '${wordlist[@]}' -- "${curw}"))
}

###########################
# COMPLETION ASSOCIATIONS #
###########################

complete -F _completemarks jmp umrk
complete -F _completeprj prj

# load bash completion if it exists
[[ -f /etc/bash_completion ]] && source /etc/bash_completion

