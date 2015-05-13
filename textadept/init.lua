if not CURSES then
	ui.set_theme('base16-monokai-dark-modified')
end

textadept.file_types.patterns['^#!/usr/bin/env bash'] = 'bash'
textadept.file_types.patterns['^#!/usr/bin/env ruby'] = 'ruby'
textadept.file_types.patterns['^#!/usr/bin/env perl'] = 'perl'
