-- A bash module.

local M = {}

snippets.bash = {
	['if'] = 'if [[ %1(cond) ]] ; then\n\t%2(body)\nfi',
	['elif'] = 'elif [[ %1(cond) ]] ; then\n\t%2(body)\n',
	['for'] = 'for %1(var) in %2(list) ; do\n\t%3(body)\ndone',
	['func'] = 'function %1(func) {\n\t%2(body)\n}'
}
