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
-- Code that allows for access to Textadept's multiple cursors
--
-- Changelog:
--     Version 0.2
--     * Fixed some bugs with the selectAll function.
--------------------------------------------------------------------------------

local keys = _G.keys

-- Change this if you don't put this file in a folder called "common"
module('_m.common.multiedit', package.seeall)
require 'common.findall'

local positions = {}
local restore = false

--------------------------------------------------------------------------------
-- Adds a single mark
--------------------------------------------------------------------------------
function add_position()
	table.insert(positions, buffer.current_pos)
	buffer:add_selection(buffer.current_pos, buffer.current_pos)
	restore = true
end

--------------------------------------------------------------------------------
-- Resets the cursor positions according to the positions table. This function
-- exists because Scintilla is grouchy and likes to kill the multi-selection.
--------------------------------------------------------------------------------
function set_cursor_positions()
	local prev_pos = buffer.current_pos
	for key, pos in ipairs(positions) do
		if pos ~= prev_pos then
			if key == 1 then
				buffer:clear_selections()
				buffer:set_selection(pos, pos)
			else
				buffer:add_selection(pos, pos, 0)
			end
		end
	end
	if buffer.current_pos ~= prev_pos then
		buffer:add_selection(prev_pos, prev_pos, 0)
	end
end

--------------------------------------------------------------------------------
-- Adds multiple marks, starting with the first mark in the list
-- and continuing to the current line. This function will try to match
-- the column of the initial mark. If a is not long enough for this to
-- work, the line is skipped
--------------------------------------------------------------------------------
function add_multiple()
	-- Bail out if there is no starting marker set
	if #positions == 0 then
		return
	end

	local startLine = buffer:line_from_position(positions[1])
	local startCol = buffer.column[positions[1]]

	-- Current line and position
	local endLine = buffer:line_from_position(buffer.current_pos)

	-- Cursor is reset here later
	local resetPos = buffer.current_pos

	if startLine > endLine then
		startLine, endLine = endLine, startLine
	end

	for i = startLine + 1, endLine - 1 do
		buffer:goto_line(i)
		-- true if we're going to put a caret on this line
		local useLine = true
		while buffer.column[buffer.current_pos] < startCol and useLine do
			if buffer.current_pos == buffer.line_end_position[i] then
				-- Hit the end of the line before reaching the column we wanted.
				-- Give up.
				useLine = false
			end
			buffer:char_right()
		end
		if useLine then
			add_position()
		end
	end
	buffer:add_selection(resetPos, resetPos)
end

--------------------------------------------------------------------------------
-- Multi-select all occurances of the word at the cursor position. This acts as
-- a very fast find-replace function. Use with caution, as this selects ALL
-- occurances of the word at the cursor.
--------------------------------------------------------------------------------
function selectAll()
	local startPosition = buffer.current_pos
	local occurances = findAllAtCursor()
	local mainSel = 0
	if #occurances > 1 then
		for i, j in ipairs(occurances) do
			if j[1] > startPosition or j[2] < startPosition then
				buffer:add_selection(j[1], j[2])
			else
				mainSel = i
			end
		end
		buffer:add_selection(occurances[mainSel][1], occurances[mainSel][2])
		while buffer.selection_start > startPosition
				or buffer.selection_end < startPosition do
			buffer:rotate_selection()
		end
	elseif #occurances == 1 then
		buffer:set_selection(occurances[1][1], occurances[1][2])
	end
end

events.connect('keypress',
	function(code, shift, control, alt)
		if code == 0xff1b then -- Escape key
			local prev_pos = buffer.current_pos
			buffer:clear_selections()
			buffer:set_selection(prev_pos, prev_pos)
			positions = {}
		elseif restore == true then
			set_cursor_positions()
			if code == 0xff08 or code == 0xff9f or code == 0xffff then
				restore = false
				positions = {}
			end
		end
	end
)

events.connect('char_added',
	function()
		restore = false
		positions = {}
		return true
	end
)
