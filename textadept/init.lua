if not CURSES then
	ui.set_theme('base16-monokai-dark-modified')
end

textadept.file_types.patterns['^#!/usr/bin/env bash'] = 'bash'
textadept.file_types.patterns['^#!/usr/bin/env ruby'] = 'ruby'
textadept.file_types.patterns['^#!/usr/bin/env perl'] = 'perl'

-- Add a vertical ruler at the 80th column
buffer.edge_column = 80
buffer.edge_mode = buffer.EDGE_LINE

-- Multicursor editing
buffer.multiple_selection = true
buffer.additional_selection_typing = true
buffer.additional_carets_visible = true

local m_multiedit = _m.common.multiedit
keys.cj = { m_multiedit.add_position }
keys.cJ = { m_multiedit.add_multiple }
keys.cr = { m_multiedit.selectAll }
