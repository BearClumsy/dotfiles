#!/bin/bash
# Claude Code hook -> tmux window-tab notifier.
# Invoked by ~/.claude/settings.json hooks
# (UserPromptSubmit/Stop/Notification/SessionEnd).
#
#   start   - UserPromptSubmit: mark this window "busy" (green tab, focused or not)
#   stop    - Stop: clear "busy", ring native bell (blue when unfocused, and tmux
#             clears the bell by itself once the window is focused)
#   notify  - Notification: same treatment as stop (needs-attention == finished)
#   end     - SessionEnd: clear "busy" WITHOUT ringing. Claude exiting is not a
#             completed task, so it must not raise a needs-attention notification;
#             this just stops a killed/crashed session leaving the tab stuck green.

[ -n "$TMUX" ] || exit 0

pane="${TMUX_PANE:-}"
[ -n "$pane" ] || exit 0

case "$1" in
  start)
    tmux set-window-option -t "$pane" @claude_busy 1
    ;;
  stop|notify)
    tmux set-window-option -t "$pane" @claude_busy 0
    tty=$(tmux display-message -p -t "$pane" '#{pane_tty}')
    [ -w "$tty" ] && printf '\a' > "$tty"
    ;;
  end)
    tmux set-window-option -t "$pane" @claude_busy 0
    ;;
  *)
    exit 0
    ;;
esac

# refresh-client -t needs a *client*, not a pane/window - target every client
# actually attached to this pane's session so the status bar updates instantly
# instead of waiting for the next status-interval tick.
tmux list-clients -t "$pane" -F '#{client_name}' 2>/dev/null | while IFS= read -r client; do
  tmux refresh-client -S -t "$client"
done
