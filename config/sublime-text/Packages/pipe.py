import sublime_plugin
import shlex
from subprocess import Popen, DEVNULL, PIPE


class PipeCommand(sublime_plugin.TextCommand):
    def run(self, _edit):
        self.view.window().show_input_panel("Pipe:", "", self.pipe_command,
                                            None, None)

    def pipe_command(self, command):
        args = shlex.split(command)
        if not args:
            return
        popen = Popen(args, stdin=DEVNULL, stdout=PIPE, stderr=DEVNULL)
        output = popen.communicate()[0].decode("utf-8").rstrip()
        self.view.run_command("insert", {"characters": output})
