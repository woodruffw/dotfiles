-- A bash module.

local M = {}

snippets.bash = {
    ['if'] = 'if [[ %1(condition) ]] ; then\n\t%2(body)\nfi'
}
