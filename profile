#!/usr/bin/env bash

installed() {
	cmd=$(command -v "${1}")

	[[ -n "${cmd}" ]] && [[ -f "${cmd}" ]]
	return ${?}
}

system=$(uname)

# set the editor depending on what's installed
if installed subl; then
	export EDITOR='subl -w'
elif installed gvim; then
	export EDITOR='gvim'
elif installed vim; then
	export EDITOR='vim'
elif installed textadept; then
	export EDITOR=textadept
elif installed nano; then
	export EDITOR='nano'
else
	export EDITOR='ed' # the universal editor!
fi

# add the rubygems bin path if installed
if installed ruby && installed gem; then
	PATH="${PATH}:$(ruby -rubygems -e 'puts Gem.user_dir')/bin"
fi

# why does this exist?
if [[ -d ~/.local/bin ]]; then
	PATH="${PATH}:${HOME}/.local/bin"
fi

# system-independent environment variables
export VISUAL="${EDITOR}"
export LESSHISTFILE="/dev/null" # prevent less from creating ~/.lesshist
export PS2="+ "
export HISTCONTROL="ignoredups:erasedups"
export HISTIGNORE="[ \t]*" # ignore commands started with whitespace
export MARKPATH="${HOME}/.marks"
export PROMPT_COMMAND="__generate_prompt"

# load API key files if they exist
if [[ -d ~/.api-keys ]] ; then
	for keyfile in ~/.api-keys/* ; do
		source "${keyfile}"
	done
fi

# unset LESSOPEN and LESSPIPE (never used, and a security hole)
unset LESSOPEN
unset LESSPIPE

# disable new mail alerts
unset MAILCHECK

[[ -d ~/bin ]] && PATH="${HOME}/bin:${PATH}"
[[ -d ~/scripts ]] && PATH="${HOME}/scripts:${PATH}"

if [[ "${system}" = "Linux" ]]; then
	if [[ -d ~/.linuxbrew ]]; then # if linuxbrew is installed, add it to paths
		PATH="${HOME}/.linuxbrew/bin:${PATH}"
		export MANPATH="${HOME}/.linuxbrew/share/man:${MANPATH}"
	fi

	if [[ -d ~/.cargo ]]; then # if rust is installed via rustup, add it to paths
		export PATH="${HOME}/.cargo/bin:${PATH}"
	fi
elif [[ "${system}" = "Darwin" ]]; then
	export TERMINFO_DIRS="${HOME}/.terminfo:/usr/local/share/terminfo:${TERMINFO}:"
	export LSCOLORS='gxfxcxdxbxegedabagacad'
	PATH="${PATH}:/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11/bin"

	# https://gist.github.com/bmhatfield/cc21ec0a3a2df963bffa3c1f884b676b
	if [ -f ~/.gnupg/.gpg-agent-info ] && [ -n "$(pgrep gpg-agent)" ]; then
		source ~/.gnupg/.gpg-agent-info
		export GPG_AGENT_INFO
	else
		eval "$(gpg-agent --daemon --write-env-file ~/.gnupg/.gpg-agent-info)"
	fi
fi

export PATH

if [[ -d ~/.opam ]]; then # if opam is installed, load the initialization script
	source ~/.opam/opam-init/init.sh
fi

source ~/.bashrc
