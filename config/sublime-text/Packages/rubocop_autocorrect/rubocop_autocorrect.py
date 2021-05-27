import sublime_plugin
from subprocess import call
import os

# Filenames that contain Ruby code, even without a normal Ruby suffix.
RUBY_FILENAMES = [
    "Gemfile",
    "Rakefile",
]

# File suffixes that are expected to contain Ruby code.
RUBY_SUFFIXES = [
    ".rb",
    ".gemspec",
]


class RubocopAutoCorrectCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        filename = self.view.file_name()
        if not filename and not self.likely_ruby_source(filename):
            return
        call(["rubocop", "-a", filename])

    def likely_ruby_source(self, filename):
        basename = os.path.basename(filename)
        extension = os.path.splitext(filename)[1]
        if basename in RUBY_FILENAMES or extension in RUBY_SUFFIXES:
            return True
        return False
