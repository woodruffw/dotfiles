#!/usr/bin/env bash

installed() {
	cmd=$(command -v "${1}")

	[[ -n "${cmd}" ]] && [[ -f "${cmd}" ]]
	return ${?}
}

system=$(uname)

# set the editor depending on what's installed
if installed subl; then
	export EDITOR='subl'
elif installed gvim; then
	export EDITOR='gvim'
elif installed vim; then
	export EDITOR='vim'
elif installed nano; then
	export EDITOR='nano'
else
	export EDITOR='ed' # the universal editor!
fi

# add the rubygems bin path if installed
if installed ruby && installed gem; then
	PATH="${PATH}:$(ruby -e 'puts Gem.user_dir')/bin"
fi

# add the rakudobrew bin path if installed
if [[ -d ~/.rakudobrew ]]; then
	PATH="${PATH}:${HOME}/.rakudobrew/bin"
fi

# why does this exist?
if [[ -d ~/.local/bin ]]; then
	PATH="${PATH}:${HOME}/.local/bin"
fi

# system-independent environment variables
export VISUAL="${EDITOR}"
export LESSHISTFILE="/dev/null" # prevent less from creating ~/.lesshist
export PS2="+ "
export HISTCONTROL="ignoreboth"
export HISTIGNORE="[ \t]+" # ignore commands started with whitespace
export PROMPT_COMMAND="__generate_prompt"
export NO_AT_BRIDGE=1

# unset LESSOPEN and LESSPIPE (never used, and a security hole)
unset LESSOPEN
unset LESSPIPE

# disable new mail alerts
unset MAILCHECK

[[ -d ~/bin ]] && PATH="${HOME}/bin:${PATH}"
[[ -d ~/scripts ]] && PATH="${HOME}/scripts:${PATH}"
[[ -d ~/man ]] && MANPATH="${HOME}/man:${MANPATH}"

if [[ "${system}" = "Linux" ]]; then
	# If linuxbrew is installed, add its bin and man directories to their respective paths.
	if [[ -d /home/linuxbrew/.linuxbrew ]]; then
		# shellcheck disable=SC2046
		eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
	fi

	# If rust is installed via rustup, add it to the PATH.
	[[ -d ~/.cargo ]] && export PATH="${HOME}/.cargo/bin:${PATH}"

	# If `snap` is installed, add it to the PATH.
	[[ -d /snap/bin ]] && export PATH="/snap/bin:${PATH}"
elif [[ "${system}" = "Darwin" ]]; then
	export TERMINFO_DIRS="${HOME}/.terminfo:/usr/local/share/terminfo:${TERMINFO}:"
	export LSCOLORS='gxfxcxdxbxegedabagacad'
	PATH="${PATH}:/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11/bin"

	gpg-agent --daemon
fi

export PATH

if [[ -d ~/.opam ]]; then # if opam is installed, load the initialization script
	# shellcheck source=/dev/null
	source ~/.opam/opam-init/init.sh
fi

# shellcheck source=/dev/null
source ~/.bashrc
