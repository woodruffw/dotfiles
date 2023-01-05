#!/usr/bin/env bash

installed() {
	cmd=$(command -v "${1}")

	[[ -n "${cmd}" ]] && [[ -f "${cmd}" ]]
	return ${?}
}

system=$(uname)

# set the editor depending on what's installed
if installed code; then
	export EDITOR='code'
elif installed subl; then
	export EDITOR='subl'
elif installed vim; then
	export EDITOR='vim'
elif installed nano; then
	export EDITOR='nano'
else
	export EDITOR='ed' # the universal editor!
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

[[ -d ~/man ]] && MANPATH="${HOME}/man:${MANPATH}"

if [[ "${system}" = "Linux" ]]; then
	export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
elif [[ "${system}" = "Darwin" ]]; then
	export TERMINFO_DIRS="${HOME}/.terminfo:/usr/local/share/terminfo:${TERMINFO}:"
	export LSCOLORS='gxfxcxdxbxegedabagacad'
	PATH="${PATH}:/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11/bin"
fi

# add the rubygems bin path if installed
if installed ruby && installed gem; then
	PATH="${PATH}:$(ruby -e 'puts Gem.user_dir')/bin"
fi

# add opam if installed
if installed opam; then
	eval "$(opam env)"
fi

# everything Python related
if [[ -d ~/.local/bin ]]; then
	PATH="${PATH}:${HOME}/.local/bin"
fi

if [[ -d ~/.pyenv/bin ]]; then
	# Add both bin and shims explicitly, since we only load the latter via
	# `pyenv init` inside bashrc.
	export PATH="${HOME}/.pyenv/bin:${HOME}/.pyenv/shims:$PATH"
fi

[[ -d ~/.cargo ]] && export PATH="${HOME}/.cargo/bin:${PATH}"

if [[ -d ~/.rbenv/bin ]]; then
	# Same as pyenv.
	export PATH="${HOME}/.rbenv/bin:${HOME}/.rbenv/shims:$PATH"
fi

# these always get added last, since they may wrap other commands
[[ -d ~/bin ]] && PATH="${HOME}/bin:${PATH}"
[[ -d ~/scripts ]] && PATH="${HOME}/scripts:${PATH}"

export PATH

# shellcheck source=/dev/null
source ~/.bashrc
