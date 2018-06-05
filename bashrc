#!/usr/bin/env bash

##########
# bashrc #
##########

[[ -z "${PS1}" ]] && return

#############
# FUNCTIONS #
#############

# __generate_prompt - generate the PS1 dynamically
__generate_prompt() {
	exitcode="${?}"
	jobcount=$(jobs | wc -l | sed -e 's/^[ \t]*//')
	branch=$(git symbolic-ref HEAD 2> /dev/null)

	if [[ "${exitcode}" -eq 0 ]]; then
		exitcode="\[${COLOR_GRN}\]${exitcode}\[${COLOR_NRM}\]"
	else
		exitcode="\[${COLOR_RED}\]${exitcode}\[${COLOR_NRM}\]"
	fi

	if [[ "${jobcount}" -eq 0 ]]; then
		jobcount="\[${COLOR_GRN}\]${jobcount}\[${COLOR_NRM}\]"
	else
		jobcount="\[${COLOR_YLW}\]${jobcount}\[${COLOR_NRM}\]"
	fi

	jobsexit="[${jobcount}:${exitcode}]"

	if [[ -n "${branch}" ]]; then
		branch="\[${COLOR_RED}\]${branch#refs/heads/}\[${COLOR_NRM}\]"
		PS1="\u@\h \W ${jobsexit} ${branch} \$ "
	else
		PS1="\u@\h \W ${jobsexit} \$ "
	fi

	# update the history and reload it
	history -a
	history -c
	history -r

	# update the terminal's title
	__generate_title
}

# __generate_title - generate the terminal emulator's title dynamically
__generate_title() {
	local title

	if [[ -n "${__MANUAL_TITLE}" ]]; then
		title=${__MANUAL_TITLE}
	elif [[ "${PWD}" = "${HOME}" ]]; then
		title="~"
	else
		title=$(basename "${PWD}")
	fi

	echo -ne "\033]0;${title}\007"
}

# title - update the terminal's title manually
title() {
	export __MANUAL_TITLE="${*}"
}

# untitle - reset the terminal's title behavior
untitle() {
	unset __MANUAL_TITLE
}

# installed - check if a program is both available and a file (no aliases/functions)
installed() {
	cmd=$(command -v "${1}")

	[[ -n "${cmd}" ]] && [[ -f "${cmd}" ]]
	return ${?}
}

# bashreload - wipe aliases and re-source from ~/.profile and ~/.bashrc
bashreload() {
	unalias -a
	# shellcheck source=/dev/null
	source ~/.profile
	# shellcheck source=/dev/null
	source ~/.bashrc
}

# allreload - send SIGURG to every bash process, which is trapped to bashreload
allreload() {
	killall -u "${USER}" -SIGURG bash
}

# strlen
# prints the length of all arguments, spaces included
strlen() {
	local str="${*}"
	echo "${#str}"
}

# man - colorize man pages
# overloads the existing man command and supplements it with colors
man() {
	env \
	LESS_TERMCAP_mb="$(printf "\e[1;31m")" \
	LESS_TERMCAP_md="$(printf "\e[1;31m")" \
	LESS_TERMCAP_me="$(printf "\e[0m")" \
	LESS_TERMCAP_se="$(printf "\e[0m")" \
	LESS_TERMCAP_so="$(printf "\e[1;44;33m")" \
	LESS_TERMCAP_ue="$(printf "\e[0m")" \
	LESS_TERMCAP_us="$(printf "\e[1;32m")" \
	man "${@}"
}

# prj - cd to (personal) projects
# cds to the project folder or to a specified project
prj() {
	local prjdir
	prjdir="${HOME}/dev/self"
	projects="$(find "${prjdir}" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)"

	cd "${prjdir}/$(selecta <<< "${projects}")" || return
}

# gprj - cd to (group) projects
gprj() {
	local prjdir
	prjdir="${HOME}/dev/group"
	projects="$(find "${prjdir}" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)"

	cd "${prjdir}/$(selecta <<< "${projects}")" || return
}

# frk - cd to forks
frk() {
	local prjdir
	prjdir="${HOME}/dev/fork"
	projects="$(find "${prjdir}" -maxdepth 1 -mindepth -type d -exec basename {} \;)"

	cd "${prjdir}/$(selecta <<< "${projects}")" || return
}

# shah - get sha1 and output just the hash
shah() {
	if [[ -n "${1}" ]] ; then
		shasum "${1}" | awk '{ print $1 }'
	else
		echo "Usage: shah <file>"
	fi
}

# fw, lw, ew, rw - expand file, less, editor, realpath input from which
# useful for reading from files on the PATH without their paths
fw() {
	file "$(which "${1}")"
}

lw() {
	less "$(which "${1}")"
}

ew() {
	$EDITOR "$(which "${1}")"
}

rw() {
	realpath "$(which "${1}")"
}

# jmp (jump) and friends, shamelessly taken from:
# http://jeroenjanssens.com/2013/08/16/quickly-navigate-your-filesystem-from-the-command-line.html
jmp() {
	cd -P "${MARKPATH}/${1}" 2> /dev/null || echo "No such mark: ${1}"
}

mrk() {
	mkdir -p "${MARKPATH}" ; ln -s "${PWD}" "${MARKPATH}/${1}"
}

umrk() {
	rm "${MARKPATH}/${1}"
}

mrks() {
	# shellcheck disable=SC2012
	ls -l "${MARKPATH}" | tail -n +2 | sed 's/  / /g' | cut -d' ' -f9- | awk -F ' -> ' '{printf "%-10s -> %s\n", $1, $2}'
}

# dump the HTTP response code for a URL to stdout
http_code() {
	if [[ -n "${1}" ]] ; then
		curl -o /dev/null --silent --head --write-out '%{http_code}\n' "${1}"
	else
		echo "Usage: http_code <url>"
	fi
}

# dump the HTTP response headers for a URL to stdout
http_headers() {
	if [[ -n "${1}" ]]; then
		curl -I "${1}"
	else
		echo "Usage: http_headers <url>"
	fi
}

# make a directory and cd into it
mkcd() {
	mkdir -p "$1" && cd "$1" || return
}

# dump a manpage to stdout, with nroff formatting cruft removed
mand() {
	man "$1" | col -bx
}

# sum $1 or stdin, one number per line
# http://stackoverflow.com/a/450821
sum() {
	awk '{ sum += $1 } END { print sum }' "${1:--}"
}

# pdf wordcount
pdfwc() {
	installed pdftotext || { echo "Error: pdftotext required." ; return 1 ; }
	[[ -f "${1}" ]] || { echo "Error: '${1}' is not a file." ; return 2 ; }

	pdftotext "${1}" - | wc -w
}

# print double-sided (long edge, for portrait prints)
lpr2sle() {
	[[ -f "${1}" ]] || { echo "Missing input file."; exit 1; }

	lpr -o sides=two-sided-long-edge "${1}"
}

# print double-sided (short edge, for landscape prints)
lpr2sse() {
	[[ -f "${1}" ]] || { echo "Missing input file."; exit 1; }

	lpr -o sides=two-sided-short-edge "${1}"
}

system=$(uname)
host=$(hostname)

###############
# ENVIRONMENT #
###############

# most of the environment gets loaded from .profile, but these are
# terminal specific and need to stay here.

# convenient colors
export COLOR_BLK='\e[0;30m'
export COLOR_RED='\e[1;31m'
export COLOR_GRN='\e[0;32m'
export COLOR_YLW='\e[0;33m'
export COLOR_BLU='\e[0;34m'
export COLOR_MAG='\e[0;35m'
export COLOR_CYN='\e[0;36m'
export COLOR_WHT='\e[0;37m'
export COLOR_NRM='\033[0m'

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
alias unmount='umount'
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
alias lsl='ls | less'
alias rr='rm -r'
alias ttyreset='stty sane; tput rs1'
alias ret='echo $?'
alias ..='cd ..'
alias .2='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias crone='crontab -e'
alias cronl='crontab -l'
alias reboot='sudo reboot'
alias rmhk='ssh-keygen -R'
alias mkdir='mkdir -p'
alias getconfigs='dotfiles ; allreload'
alias ocaml='rlwrap ocaml'

# if colordiff is installed, alias diff to it
if installed colordiff ; then
	alias diff='colordiff'
fi

# if jekyll is installed, add its aliases
if installed jekyll ; then
	alias jb='jekyll build'
	alias jc='jekyll clean'
	alias js='jekyll serve --config _config.yml,_config_local.yml --force_polling'
fi

# if gnu smalltalk is installed, alias it to st (gst is a git alias)
# this is clearly becoming a problem
if installed gst ; then
	alias st='\gst'
fi

if installed matlab ; then
	alias matlab='matlab -nojvm'
fi

if installed exiftool ; then
	alias exifnuke='exiftool -all= -overwrite_original'
	alias exifmine='exiftool -all= -copyright="William Woodruff" -overwrite_original'
fi

# system-dependent aliases
if [[ "${system}" = "Linux" ]] ; then
	alias ls='ls --color=auto'
	alias perm='stat -c "%a"'
	alias ethdn='sudo ifconfig eth0 down'
	alias ethup='sudo ifconfig eth0 up'
	alias eastcoast='sudo timedatectl set-timezone America/New_York'
	alias westcoast='sudo timedatectl set-timezone America/Los_Angeles'

	if [[ "${host}" = "athena" ]] ; then
		alias nginxconf='sudo vim /etc/nginx/sites-enabled/default'
		alias www='cd /var/www/html'
	fi

	if [[ -f "/usr/bin/apt-get" ]] ; then # Ubuntu, Debian systems
		alias sagu='sudo apt update'
		alias saguu='sudo apt update ; sudo apt upgrade'
		alias sagi='sudo apt install'
		alias sagr='sudo apt remove'
		alias sagar='sudo apt autoremove'
	elif [[ -f "/usr/bin/pacman" ]] ; then # Arch-based systems
		alias sps='sudo pacman -S'
		alias spr='sudo pacman -R'
		alias sprs='sudo pacman -Rs'
	fi
elif [[ "${system}" = "Darwin" ]] ; then
	alias ls='ls -G'
	alias perm='stat -f "%Lp"'
	alias ethdn='sudo ifconfig en0 down'
	alias ethup='sudo ifconfig en0 up'

	# if homebrew's nginx is installed
	if [[ -f "/usr/local/bin/nginx" ]] ; then
		alias nginxconf='vim /usr/local/etc/nginx/nginx.conf'
		alias nginxreload='sudo nginx -s reload'
		alias www='cd /usr/local/var/www'
	fi

	# if homebrew's bash-completion is installed
	if [[ -f "/usr/local/etc/bash_completion" ]] ; then
		# shellcheck source=/dev/null
		source /usr/local/etc/bash_completion
	fi
fi

#################
# SHELL OPTIONS #
#################
shopt -s histappend # don't overwrite the history file
shopt -s cdspell # fix typos in cd
shopt -s globstar # double globs match arbitary subdirs

################
# KEY BINDINGS #
################
bind -x '"\e[14~":pcmanfm . >/dev/null 2>&1 &' # open a file manager in the CWD
bind -x '"\e[15~":ttyreset' # reset the terminal with F5
bind -x '"\eW":"who"'
bind -x '"\eU":"uptime"'
bind -x '"\eL":"ls"'

#########
# TRAPS #
#########

# reload configs when SIGURG is received
trap bashreload SIGURG

########################
# COMPLETION FUNCTIONS #
########################

_completemarks() {
	curw=${COMP_WORDS[COMP_CWORD]}
	wordlist="$(ls "${MARKPATH}" 2> /dev/null)"
	# shellcheck disable=SC2016
	COMPREPLY=($(compgen -W '${wordlist[@]}' -- "${curw}"))
}

###########################
# COMPLETION ASSOCIATIONS #
###########################

complete -F _completemarks jmp umrk
complete -F _completegvcd gvcd

# load bash completion if it exists
# shellcheck source=/dev/null
[[ -f /etc/bash_completion ]] && source /etc/bash_completion
