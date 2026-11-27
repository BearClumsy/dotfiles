#!/bin/bash
# The "scratch" session only ever shows in a popup, and popups never stack.
#   open <client>      prefix + f (tmux.reset.conf)
#   redirect <client>  client-session-changed hook (tmux.conf): a main client that
#                      landed in scratch is sent back and gets the popup instead
# Both do nothing for the popup's own client.

mode="$1" client="$2" scratch=scratch
[ -n "$client" ] || exit 0

client_info() {
  tmux list-clients -f "#{==:#{client_name},$client}" -F "$1" 2>/dev/null
}

# The popup's client inherits the marker from display-popup -e. It stays marked
# when switched to another session, which a session name check would miss.
pid=$(client_info '#{client_pid}')
[ -n "$pid" ] || exit 0
ps eww -o command= -p "$pid" | grep -q ' TMUX_SCRATCH_POPUP=1' && exit 0

session=$(client_info '#{client_session}')

case "$mode" in
open) ;;
redirect)
  [ "$session" = "$scratch" ] || exit 0
  session=$(client_info '#{client_last_session}')
  if [ -z "$session" ] || [ "$session" = "$scratch" ] || ! tmux has-session -t "=$session" 2>/dev/null; then
    # No usable previous session (it was destroyed): take the most recent other one.
    session=$(tmux list-sessions -F '#{session_last_attached} #{session_name}' |
      sort -rn | cut -d' ' -f2- | grep -vx "$scratch" | head -n 1)
  fi
  if [ -z "$session" ]; then
    session=default
    tmux new-session -d -s "$session" -c "$HOME"
  fi
  tmux switch-client -c "$client" -t "=$session:" || exit 0
  ;;
*) exit 0 ;;
esac

path=$(tmux display-message -p -t "=$session:" '#{pane_current_path}')

# -d is format-expanded, so a literal "#" has to be doubled. The popup's exit status
# is ignored: run-shell would otherwise report it over the pane.
tmux display-popup -c "$client" -E -w 80% -h 80% -d "${path//\#/##}" \
  -e TMUX_SCRATCH_POPUP=1 "tmux new-session -As $scratch"
exit 0
