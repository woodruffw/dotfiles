-- Google theme for Textadept
-- Theme author: Seth Wright (http://sethawright.com)
-- Base16 (https://github.com/chriskempson/base16)
-- Build with Base16 Builder (https://github.com/chriskempson/base16-builder)
-- Repository: https://github.com/rgieseke/ta-themes

local buffer = buffer
local property, property_int = buffer.property, buffer.property_int

property['color.base00'] = 0x211f1d
property['color.base01'] = 0x2e2a28
property['color.base02'] = 0x413b37
property['color.base03'] = 0x969896
property['color.base04'] = 0xb4b7b4
property['color.base05'] = 0xc6c8c5
property['color.base06'] = 0xe0e0e0
property['color.base07'] = 0xffffff
property['color.base08'] = 0x2B34CC
property['color.base09'] = 0x386AF9
property['color.base0A'] = 0x22A9FB
property['color.base0B'] = 0x448819
property['color.base0C'] = 0xED7139
property['color.base0D'] = 0xED7139
property['color.base0E'] = 0xC76AA3
property['color.base0F'] = 0xED7139

-- Default font.
property['font'], property['fontsize'] = 'Bitstream Vera Sans Mono', 10
if WIN32 then
  property['font'] = 'Courier New'
elseif OSX then
  property['font'], property['fontsize'] = 'Monaco', 12
end

-- Predefined styles.
property['style.default'] = 'font:%(font),size:%(fontsize),'..
                            'fore:%(color.base05),back:%(color.base00)'
property['style.linenumber'] = 'fore:%(color.base02),back:%(color.base00)'
property['style.bracelight'] = 'fore:%(color.base0C),underlined'
property['style.bracebad'] = 'fore:%(color.base08)'
property['style.controlchar'] = '%(style.nothing)'
property['style.indentguide'] = 'fore:%(color.base03)'
property['style.calltip'] = 'fore:%(color.base02),back:%(color.base07)'

-- Token styles.
property['style.class'] = 'fore:%(color.base0A)'
property['style.comment'] = 'fore:%(color.base03)'
property['style.constant'] = 'fore:%(color.base09)'
property['style.embedded'] = 'fore:%(color.base0F),back:%(color.base06)'
property['style.error'] = 'fore:%(color.base08),italics'
property['style.function'] = 'fore:%(color.base09)'
property['style.identifier'] = ''
property['style.keyword'] = 'fore:%(color.base0D)'
property['style.label'] = 'fore:%(color.base09)'
property['style.number'] = 'fore:%(color.base0C)'
property['style.operator'] = 'fore:%(color.base0E)'
property['style.preprocessor'] = 'fore:%(color.base0A)'
property['style.regex'] = 'fore:%(color.base0C)'
property['style.string'] = 'fore:%(color.base0B)'
property['style.type'] = 'fore:%(color.base0E)'
property['style.variable'] = 'fore:%(color.base0D)'
property['style.whitespace'] = ''

-- Multiple Selection and Virtual Space.
--buffer.additional_sel_alpha =
--buffer.additional_sel_fore =
--buffer.additional_sel_back =
--buffer.additional_caret_fore =

-- Caret and Selection Styles.
buffer:set_sel_fore(true, property_int['color.base00'])
buffer:set_sel_back(true, property_int['color.base05'])
--buffer.sel_alpha =
buffer.caret_fore = property_int['color.base07']
buffer.caret_line_back = property_int['color.base01']
--buffer.caret_line_back_alpha =

-- Fold Margin.
buffer:set_fold_margin_colour(true, property_int['color.base00'])
buffer:set_fold_margin_hi_colour(true, property_int['color.base00'])

-- Markers.
local MARK_BOOKMARK, t_run = textadept.bookmarks.MARK_BOOKMARK, textadept.run
--buffer.marker_fore[MARK_BOOKMARK] = property_int['color.base05']
buffer.marker_back[MARK_BOOKMARK] = property_int['color.base0D']
--buffer.marker_fore[t_run.MARK_WARNING] = property_int['color.base05']
buffer.marker_back[t_run.MARK_WARNING] = property_int['color.base0A']
--buffer.marker_fore[t_run.MARK_ERROR] = property_int['color.base05']
buffer.marker_back[t_run.MARK_ERROR] = property_int['color.base08']
for i = 25, 31 do -- fold margin markers
  buffer.marker_fore[i] = property_int['color.base00']
  buffer.marker_back[i] = property_int['color.base03']
  buffer.marker_back_selected[i] = property_int['color.base02']
end

-- Indicators.
local INDIC_BRACEMATCH = textadept.editing.INDIC_BRACEMATCH
buffer.indic_fore[INDIC_BRACEMATCH] = property_int['color.base06']
local INDIC_HIGHLIGHT = textadept.editing.INDIC_HIGHLIGHT
buffer.indic_fore[INDIC_HIGHLIGHT] = property_int['color.base0F']
buffer.indic_alpha[INDIC_HIGHLIGHT] = 255

-- Long Lines.
buffer.edge_colour = property_int['color.base01']

-- Add red and green for diff lexer.
property['color.red'] = property['color.base08']
property['color.green'] = property['color.base0B']
