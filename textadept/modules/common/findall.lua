--------------------------------------------------------------------------------
-- The MIT License
--
-- Copyright (c) 2010 Brian Schott (Sir Alaran)
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- @return a table consisting of the start and end positions of the occurances
--     of the word at the cursor position
--------------------------------------------------------------------------------
function findAllAtCursor()
	local retVal = {}
	local position = buffer.current_pos
	-- Grab the word that was clicked on
	buffer:word_left()
	buffer:word_right_end_extend()
	needle = buffer:get_sel_text()
	-- Trim any whitespace
	needle = needle:gsub('%s', '')
	-- Escape unwanted characters
	needle = needle:gsub('([().*+?^$%%[%]-])', '%%%1')
	-- Don't look for zero-length strings
	if #needle > 0 then
		for i = 0, buffer.line_count do
			local text = buffer:get_line(i)
			if #text>0 then
				local first, last = 0, 0
				while first do
					first, last = text:find("%f[%w]"..needle.."%f[%W]",last)
					if last then
						if (first ~= nil) and (first >0) then
							first = first - 1
						end
						table.insert(retVal, {buffer:position_from_line(i) + first, buffer:position_from_line(i) + last})
						last = last + 1
					end
				end
			end
		end
	end
	buffer:set_sel(position, position)
	return retVal
end
