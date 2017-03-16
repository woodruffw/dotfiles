-- Fetch the path of the currently playing media and pipe it into xclip.
-- Needs xclip, obviously.

require "os"

-- nabbed from https://github.com/lua-shellscript/lua-shellscript/wiki/shell.string
-- is this sufficient?
local function escape(...)
 local command = type(...) == 'table' and ... or { ... }
 for i, s in ipairs(command) do
  s = (tostring(s) or ''):gsub('"', '\\"')
  if s:find '[^A-Za-z0-9_."/-]' then
   s = '"' .. s .. '"'
  elseif s == '' then
   s = '""'
  end
  command[i] = s
 end
 return table.concat(command, ' ')
end

function do_xclip()
	local path = escape(mp.get_property_native("path"))
	mp.osd_message("xclip: " .. path, 1)
	os.execute("echo " .. path .. " | xclip")
end

mp.add_key_binding("X", "xclip", do_xclip)
