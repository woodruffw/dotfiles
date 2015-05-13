-- Copyright 2007-2015 Mitchell mitchell.att.foicica.com. See LICENSE.

local M = {}

--[[ This comment is for LuaDoc.
---
-- The python module.
-- It provides utilities for editing Python code.
--
-- ## Key Bindings
--
-- + `Shift+Enter` (`⇧↩` | `S-Enter`)
--   Add ':' to the end of the current line and insert a newline.
-- @field CHECK_SYNTAX (bool)
--   Whether or not to invoke Python to check the syntax of the current file
--   when saving it.
--   The default value is `true`.
module('_M.python')]]

M.CHECK_SYNTAX = true

-- Sets default buffer properties for Python files.
events.connect(events.LEXER_LOADED, function(lang)
  if lang == 'python' then
    buffer.use_tabs = false
    buffer.tab_width = 4
  end
end)

-- Autocompletion and documentation.

---
-- List of ctags files to use for autocompletion.
-- @class table
-- @name tags
M.tags = {_HOME..'/modules/python/tags', _USERHOME..'/modules/python/tags'}

---
-- Map of expression patterns to their types.
-- Expressions are expected to match after the '=' sign of a statement.
-- @class table
-- @name expr_types
M.expr_types = {
  ['^[\'"]'] = 'str',
  ['^%('] = 'tuple',
  ['^%['] = 'list',
  ['^{'] = 'dict',
  ['^open%s*%b()%s*$'] = 'file',
  ['^%d+%f[^%d%.]'] = 'int',
  ['^%d+%.'] = 'float'
}

local XPM = textadept.editing.XPM_IMAGES
local xpms = {
  c = XPM.CLASS, f = XPM.METHOD, m = XPM.VARIABLE, M = XPM.STRUCT,
  v = XPM.VARIABLE
}

textadept.editing.autocompleters.python = function()
  local list = {}
  -- Retrieve the symbol behind the caret.
  local line, pos = buffer:get_cur_line()
  local symbol, op, part = line:sub(1, pos):match('([%w_%.]-)(%.?)([%w_]*)$')
  if symbol == '' and part == '' and op == '.' then return nil end -- lone .
  -- Attempt to identify the symbol type.
  -- TODO: identify literals like "'foo'." and "[1, 2, 3].".
  local buffer = buffer
  local assignment = '%f[%w_]'..symbol:gsub('(%p)', '%%%1')..'%s*=%s*(.*)$'
  for i = buffer:line_from_position(buffer.current_pos) - 1, 0, -1 do
    local expr = buffer:get_line(i):match(assignment)
    if expr then
      for patt, type in pairs(M.expr_types) do
        if expr:find(patt) then symbol = type break end
      end
      if expr:find('^[%u][%w_.]*%s*%b()%s*$') then
        symbol = expr:match('^([%u][%w_.]+)%s*%b()%s*$') -- e.g. a = Foo()
        break
      end
    end
  end
  -- Search through ctags for completions for that symbol.
  local name_patt = '^'..part
  local sep = string.char(buffer.auto_c_type_separator)
  for i = 1, #M.tags do
    if lfs.attributes(M.tags[i]) then
      for line in io.lines(M.tags[i]) do
        local name = line:match('^%S+')
        if name:find(name_patt) and not list[name] then
          local fields = line:match(';"\t(.*)$')
          local k, class = fields:sub(1, 1), fields:match('class:(%S+)') or ''
          if class == symbol and (op ~= ':' or k == 'f') then
            list[#list + 1] = ("%s%s%d"):format(name, sep, xpms[k])
            list[name] = true
          end
        end
      end
    end
  end
  return #part, list
end

textadept.editing.api_files.python = {
  _HOME..'/modules/python/api', _USERHOME..'/modules/python/api'
}

-- Commands.

-- Indent on 'Enter' after a ':' or auto-indent on ':'.
events.connect(events.CHAR_ADDED, function(ch)
  if buffer:get_lexer() ~= 'python' or (ch ~= 10 and ch ~= 58) then return end
  local buffer = buffer
  local l = buffer:line_from_position(buffer.current_pos)
  if l > 0 then
    local line = buffer:get_line(l - (ch == 10 and 1 or 0))
    if ch == 10 and line:find(':%s+$') then
      buffer.line_indentation[l] = buffer.line_indentation[l - 1] +
                                   buffer.tab_width
      buffer:goto_pos(buffer.line_indent_position[l])
    elseif ch == 58 and (line:find('^%s*else%s*:') or
                         line:find('^%s*elif[^:]+:') or
                         line:find('^%s*except[^:]*:') or
                         line:find('^%s*finally%s*:')) then
      local try = not line:find('^%s*el')
      for i = l - 1, 0, -1 do
        line = buffer:get_line(i)
        if buffer.line_indentation[i] <= buffer.line_indentation[l] and
           (not try and (line:find('^%s*if[^:]+:%s+$') or
                         line:find('^%s*while[^:]+:%s+$') or
                         line:find('^%s*for[^:]+:%s+$')) or
            line:find('^%s*try%s*:%s+$')) then
          local pos, s = buffer.current_pos, buffer.line_indent_position[l]
          buffer.line_indentation[l] = buffer.line_indentation[i]
          buffer:goto_pos(pos + buffer.line_indent_position[l] - s)
          break
        end
      end
    end
  end
end)

-- Show syntax errors as annotations.
events.connect(events.FILE_AFTER_SAVE, function()
  if buffer:get_lexer() ~= 'python' or not M.CHECK_SYNTAX then return end
  buffer:annotation_clear_all()
  local python = textadept.run.run_commands.python:match('^%S+')
  local p = io.popen(python..' -V 2>&1')
  local version = p:read('*a'):match('^Python ([%d.]+)')
  local python3 = version >= '2.7.4' -- 2.7.4 has backported Python3 message
  p:close()
  p = io.popen(python..' -m py_compile "'..buffer.filename..'" 2>&1')
  local out = p:read('*a')
  p:close()
  if out:match(python3 and '^%s*File' or '^SyntaxError') then
    local line = out:match(python3 and '^%s*File ".-", line (%d+)' or
                           buffer.filename..'\',%s+(%d+)')
    if line and tonumber(line) > 0 then
      line = tonumber(line) - 1
      local msg = python3 and out:match('^[^\r\n]+[\r\n]+(.-)%s*$') or
                  'SyntaxError: invalid syntax'
      -- If the error line is not onscreen, annotate the current line.
      if (line < buffer.first_visible_line or
          line > buffer.first_visible_line + buffer.lines_on_screen) then
        msg = 'line '..(line + 1)..'\n'..msg
        line = buffer:line_from_position(buffer.current_pos)
      end
      buffer.annotation_visible = 2
      buffer.annotation_text[line] = msg
      buffer.annotation_style[line] = 8 -- error style number
      buffer:goto_line(line)
    end
  end
end)

---
-- Container for Python-specific key bindings.
-- @class table
-- @name _G.keys.python
keys.python = {
  ['s\n'] = function()
    buffer:line_end()
    buffer:add_text(':')
    buffer:new_line()
  end,
}

-- Snippets.

if type(snippets) == 'table' then
---
-- Container for Python-specific snippets.
-- @class table
-- @name _G.snippets.python
  snippets.python = {
    ['.'] = 'self.',
    __ = '__%1(init)__',
    def = 'def %1(name)(%2(arg)):\n\t%3("""%4\n\t"""\n\t)',
    defs = 'def %1(name)(self%2(, %3(arg))):\n\t%4("""%5\n\t"""\n\t)',
    ifmain = 'if __name__ == "__main__":\n\t%1(main())',
    class = [[
class %1(ClassName)(%2(object)):
	"""%3(documentation)
	"""
	def __init__(self%4(, %5(arg))):
		%6(super(%1, self).__init__())]],
    try = [[
try:
	%0
except %2(Exception), %3(e):
	%4(pass)%5(
finally:
	%6(pass))]]
  }
end

return M
