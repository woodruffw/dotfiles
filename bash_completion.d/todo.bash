_todo_complete() {
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	case "${prev}" in
		todo ) opts="help list prune new rm show start suspend complete" ;;
		list ) opts="--plain" ;;
		prune ) opts="--interactive" ;;
		rm|show|start|suspend|complete ) opts=$(todo list --plain) ;;
	esac

	COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
	return 0
}

complete -F _todo_complete todo
