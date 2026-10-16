#!/usr/bin/env bash
# Record Claude Code's Bash tool calls in atuin history.
#
# Claude Code runs commands in a non-interactive shell, so atuin's shell hooks
# never fire and nothing reaches the history. settings.json wires this script to
# PostToolUse and PostToolUseFailure (matcher: Bash); the hook JSON arrives on
# stdin. Each command is recorded once, after it ran, so commands that were
# blocked or denied never show up as unfinished entries. The entry timestamp is
# therefore the end of the command, not its start.
#
# Best effort: history must never block or fail a tool call, so the exit
# status is always 0 and nothing is printed.

input=$(cat)

field() { jq -r "$1 // empty" <<<"$input"; }

command=$(field .tool_input.command)
[ -n "$command" ] || exit 0

cwd=$(field .cwd)
[ -d "$cwd" ] && cd "$cwd"

# Join the atuin session of the terminal that launched Claude Code, so the
# commands sit next to the `claude` invocation. Outside such a terminal, fall
# back to Claude's own session id.
export ATUIN_SESSION=${ATUIN_SESSION:-$(field .session_id | tr -d '-')}

case $(field .hook_event_name) in
  PostToolUse)
    exit_code=0
    ;;
  PostToolUseFailure)
    if [ "$(field .is_interrupt)" = true ]; then
      exit_code=130
    else
      # `error` starts with "Exit code N" for a command that ran and failed.
      exit_code=$(field .error | sed -n '1s/^Exit code \([0-9][0-9]*\)$/\1/p')
      exit_code=${exit_code:-1}
    fi
    ;;
  *)
    exit 0
    ;;
esac

duration_ms=$(field .duration_ms)
duration_ms=${duration_ms%.*}
duration_ns=$(( ${duration_ms:-0} * 1000000 ))

# Claude's one-line summary of the command goes into atuin's `intent` field.
intent=$(field .tool_input.description)

id=$(atuin history start --author claude --author-kind agent \
  ${intent:+--intent "$intent"} -- "$command" 2>/dev/null)
[ -n "$id" ] || exit 0

atuin history end --exit "$exit_code" --duration "$duration_ns" "$id" >/dev/null 2>&1
exit 0
