_snip_complete() {
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	case "${prev}" in
		snip ) opts="help list new rm edit" ;;
		rm|edit ) opts=$(snip list) ;;
	esac

	COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
	return 0
}

complete -F _snip_complete snip
