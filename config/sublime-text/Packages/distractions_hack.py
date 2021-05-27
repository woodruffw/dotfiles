import sublime_plugin


class DistractionsHack(sublime_plugin.ViewEventListener):
    def on_activated(self):
        window = self.view.window()
        window.set_minimap_visible(False)
        window.set_status_bar_visible(False)
        window.set_menu_visible(False)
