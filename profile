function installed() {
	local cmd=$(command -v "${1}")

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
	export PATH="${PATH}:$(ruby -rubygems -e 'puts Gem.user_dir')/bin"
fi

# system-independent environment variables
export VISUAL="${EDITOR}"
export LESSHISTFILE="/dev/null" # prevent less from creating ~/.lesshist
export PS2="+ "
export HISTCONTROL="ignoredups:erasedups"
export MARKPATH="${HOME}/.marks"
export PROMPT_COMMAND="__generate_prompt"

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

if [[ "${system}" = "Linux" ]]; then
	export PATH="${PATH}:/home/${USER}/bin:/home/${USER}/scripts"
elif [[ "${system}" = "Darwin" ]]; then
	export LSCOLORS='gxfxcxdxbxegedabagacad'
	export PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11/bin:/Users/${USER}/bin:/Users/${USER}/scripts
fi
