#!/bin/bash
# Drop the "finished" (blue) and "failed" (red) tab flags from pane $1 once you can
# see it: it is the active pane of the current window in an attached session. Run by
# the session-window-changed / client-session-changed / window-pane-changed hooks in
# tmux.conf. Only that pane is cleared - a neighbour split that finished stays flagged
# until you focus it, since the tab shows the focused pane's state.

pane="$1"
[ -n "$pane" ] || exit 0

state=$(tmux display-message -p -t "$pane" \
  '#{&&:#{pane_active},#{&&:#{window_active},#{session_attached}}} #{@claude_pane_done}#{@claude_pane_failed}' 2>/dev/null)
visible="${state%% *}" flags="${state#* }"
[ "$visible" = 1 ] && [ -n "$flags" ] || exit 0

tmux set-option -p -u -t "$pane" @claude_pane_done \; set-option -p -u -t "$pane" @claude_pane_failed 2>/dev/null
tmux list-clients -F '#{client_name}' 2>/dev/null | while IFS= read -r client; do
  tmux refresh-client -S -t "$client"
done
