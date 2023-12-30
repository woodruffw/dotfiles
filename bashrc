#!/usr/bin/env bash

##########
# bashrc #
##########

[[ -t 0 && "${-}" == *i* ]] || return

#############
# FUNCTIONS #
#############

# __generate_prompt - generate the PS1 dynamically
__generate_prompt() {
	local exitcode="${?}"
	if [[ "${exitcode}" -eq 0 ]]; then
		exitcode="\[${COLOR_GRN}\]${exitcode}\[${COLOR_NRM}\]"
	else
		exitcode="\[${COLOR_RED}\]${exitcode}\[${COLOR_NRM}\]"
	fi

	local jobcount
	jobcount=$(jobs | wc -l | sed -e 's/^[ \t]*//')
	if [[ "${jobcount}" -eq 0 ]]; then
		jobcount="\[${COLOR_GRN}\]${jobcount}\[${COLOR_NRM}\]"
	else
		jobcount="\[${COLOR_YLW}\]${jobcount}\[${COLOR_NRM}\]"
	fi

	jobsexit="[${jobcount}:${exitcode}]"

	PS1="\u@\h \W ${jobsexit}"

	local branch
	branch=$(git symbolic-ref HEAD 2> /dev/null)
	if [[ -n "${branch}" ]]; then
		branch="\[${COLOR_RED}\]${branch#refs/heads/}\[${COLOR_NRM}\]"
		PS1="${PS1} ${branch}"
	fi

	if [[ -v VIRTUAL_ENV ]]; then
		local virtualenv
		virtualenv="${COLOR_GRN}$(basename "${VIRTUAL_ENV}")${COLOR_NRM}"
		PS1="${PS1} ${virtualenv}"
	fi

	PS1="${PS1} \$ "

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
		title="${HOSTNAME} ~"
	else
		title="${HOSTNAME} $(basename "${PWD}")"
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
	prjdir="${HOME}/devel"
	projects="$(find "${prjdir}" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)"

	cd "${prjdir}/$(selecta <<< "${projects}")" || return
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
	[[ -f "${1}" ]] || { echo "Missing input file."; return 1; }

	lpr -o sides=two-sided-long-edge "${1}"
}

# print double-sided (short edge, for landscape prints)
lpr2sse() {
	[[ -f "${1}" ]] || { echo "Missing input file."; return 1; }

	lpr -o sides=two-sided-short-edge "${1}"
}

# dump a random n-byte long string
randstr() {
	[[ "${1}" -gt 0 ]] || { echo "Positive length required."; return 1; }

	tr -dc "A-Za-z0-9" < /dev/urandom | head -c "${1}"
}

# send someone (probably myself) a file
mailfile() {
	[[ -f "${1}" ]] || { echo "Missing input file."; return 1; }
	installed neomutt ||  { echo "Missing neomutt."; return 1; }

	neomutt -s "mailfile" -a "${1}"
}

system=$(uname)
host=$(hostname)

###############
# ENVIRONMENT #
###############

# most of the environment gets loaded from .profile, but these are
# terminal specific and need to stay here.

# convenient colors
export COLOR_BLK="$(tput setaf 0)"
export COLOR_RED="$(tput setaf 1)"
export COLOR_GRN="$(tput setaf 2)"
export COLOR_YLW="$(tput setaf 3)"
export COLOR_BLU="$(tput setaf 4)"
export COLOR_MAG="$(tput setaf 5)"
export COLOR_CYN="$(tput setaf 6)"
export COLOR_WHT="$(tput setaf 7)"
export COLOR_NRM="$(tput sgr0)"

###########
# Aliases #
###########

# system-independent aliases
alias unmount='umount'
alias df='df -kh'
alias du='du -kh'
alias htop='htop --sort-key PERCENT_CPU'
alias +r='chmod +r'
alias +w='chmod +w'
alias +x='chmod +x'
alias la='ls -a'
alias ll='ls -lh'
alias ttyreset='stty sane; tput rs1'
alias ..='cd ..'
alias crone='crontab -e'
alias cronl='crontab -l'
alias reboot='sudo reboot'
alias rmhk='ssh-keygen -R'
alias mkdir='mkdir -p'
alias getconfigs='dotfiles ; allreload'
alias jsonl2json='jq -s "."'
alias json2jsonl='jq -c ".[]"'
alias snip='kbs2 snip'

if installed exiftool ; then
	alias exifnuke='exiftool -all= -overwrite_original'
	alias exifmine='exiftool -all= -copyright="William Woodruff" -overwrite_original'
fi

if installed pledger; then
	alias pledger='PLEDGER_DIR=~/mnt/arabella/expenses pledger'
fi

# system-dependent aliases
if [[ "${system}" = "Linux" ]] ; then
	alias ls='ls --color=auto'
	alias perm='stat -c "%a"'
	alias vpndn='sudo systemctl stop wg-quick@wg0'
	alias vpnup='sudo systemctl start wg-quick@wg0'
	alias ethdn='sudo ifconfig eth0 down'
	alias ethup='sudo ifconfig eth0 up'

	if [[ "${host}" = "athena" ]] ; then
		alias nginxconf='sudo vim /etc/nginx/sites-enabled/default'
		alias www='cd /var/www/html'
	fi
elif [[ "${system}" = "Darwin" ]] ; then
	alias ls='ls -G'
	alias perm='stat -f "%Lp"'
	alias ethdn='sudo ifconfig en0 down'
	alias ethup='sudo ifconfig en0 up'

	# if homebrew's bash-completion is installed
	if [[ -f "/opt/homebrew/etc/bash_completion" ]] ; then
		# shellcheck source=/dev/null
		source /opt/homebrew/etc/bash_completion
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
bind -x '"\eOS":pcmanfm . >/dev/null 2>&1 &' # open a file manager in the CWD
bind -x '"\e[15~":ttyreset' # reset the terminal with F5

#########
# TRAPS #
#########

# reload configs when SIGURG is received
trap bashreload SIGURG

###########################
# COMPLETION ASSOCIATIONS #
###########################

complete -F _completegvcd gvcd

# load bash completion if it exists
# shellcheck source=/dev/null
[[ -f /etc/bash_completion ]] && source /etc/bash_completion

# this should have been loaded above, but i've seen some inconsistency.
# shellcheck source=/dev/null
[[ -f /usr/share/bash-completion/completions/man ]] && ! type -p _man && \
	source /usr/share/bash-completion/completions/man
