import sublime
import sublime_plugin


def plugin_loaded():
    windows = sublime.windows()

    for w in windows:
        w.set_minimap_visible(False)
        w.set_status_bar_visible(False)
        w.set_menu_visible(False)
