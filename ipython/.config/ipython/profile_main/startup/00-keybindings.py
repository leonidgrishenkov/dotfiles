"""Custom key bindings for IPython"""

from IPython import get_ipython
from prompt_toolkit.filters import vi_insert_mode, vi_selection_mode
from prompt_toolkit.key_binding.vi_state import InputMode


ip = get_ipython()
if ip is not None:
    registry = ip.pt_app.key_bindings

    @registry.add('j', 'f', filter=vi_insert_mode)
    def _(event):
        """Exit vi insert mode with 'jf'"""

        if event.current_buffer.cursor_position > 0:
            event.current_buffer.cursor_position -= 1
        event.app.vi_state.input_mode = InputMode.NAVIGATION

    @registry.add('j', 'f', filter=vi_selection_mode)
    def _(event):
        """Exit vi selection/visual mode with 'jf'"""

        event.current_buffer.exit_selection()
        event.app.vi_state.input_mode = InputMode.NAVIGATION


