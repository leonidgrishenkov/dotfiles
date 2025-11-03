# Configuration file for ipython.

c = get_config()  # noqa

## Automatically add/delete closing bracket or quote when opening bracket or
#  quote is entered/deleted. Brackets: (), [], {} Quotes: '', ""
#  Default: False
c.TerminalInteractiveShell.auto_match = True

## The part of the banner to be printed before the profile
#  See also: InteractiveShell.banner1
c.TerminalInteractiveShell.banner1 = "Type '?' for help.\n"

## Set to confirm when you try to exit IPython with an EOF (Control-D in Unix,
#  Control-Z/Enter in Windows). By typing 'exit' or 'quit', you can force a
#  direct exit without any confirmation.
#  Default: True
c.TerminalInteractiveShell.confirm_exit = False

## Shortcut style to use at the prompt. 'vi' or 'emacs'.
#  Default: 'emacs'
c.TerminalInteractiveShell.editing_mode = "vi"

## Add shortcuts from 'emacs' insert mode to 'vi' insert mode.
#  Default: True
c.TerminalInteractiveShell.emacs_bindings_in_vi_insert_mode = False

## Enable vi (v) or Emacs (C-X C-E) shortcuts to open an external editor. This is
#  in addition to the F2 binding, which is always enabled.
#  Default: False
c.TerminalInteractiveShell.extra_open_editor_shortcuts = False

## Class used to generate Prompt token for prompt_toolkit
#  Default: 'IPython.terminal.prompts.Prompts'
# c.TerminalInteractiveShell.prompts_class = 'IPython.terminal.prompts.Prompts'
from IPython.terminal.prompts import Prompts, Token


class SimplePrompt(Prompts):
    def in_prompt_tokens(self):
        return [(Token.Prompt, ">>> ")]

    def continuation_prompt_tokens(self, width=None):
        return [(Token.Prompt, "... ")]

    def out_prompt_tokens(self):
        return [(Token.Prompt, "")]


c.TerminalInteractiveShell.prompts_class = SimplePrompt

from IPython.utils.PyColorize import linux_theme, theme_table
from copy import deepcopy

theme = deepcopy(linux_theme)

theme_name = "nord-darker"
theme.base = theme_name
theme_table[theme_name] = theme

c.TerminalInteractiveShell.true_color = True
c.TerminalInteractiveShell.colors = theme_name
