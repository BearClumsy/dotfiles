#!/bin/bash
# Claude Code hook -> tmux window-tab notifier.
# Invoked by ~/.claude/settings.json hooks.
#
#   start   - mark this pane "busy" (green tab, focused or not). Wired to every
#             event that means work is underway or has resumed: UserPromptSubmit,
#             PreToolUse, PostToolUse. Stop fires at the end of every main-agent
#             turn, including one that only dispatches background subagents, so
#             green MUST be re-armable from something other than a fresh prompt
#             or the tab latches grey while the work continues.
#             NOT wired to SubagentStop: post-turn background work (the recap
#             generator) fires that AFTER Stop, which re-armed green on a finished
#             turn and left the tab stuck. A real resumption re-arms via its own
#             tool calls; one that only writes text ends in another Stop anyway.
#   stop    - Stop: clear "busy", ring native bell (blue when unfocused, and tmux
#             clears the bell by itself once the window is focused)
#   notify  - Notification: same treatment as stop (needs-attention == finished).
#             A permission prompt lands here too; the next PreToolUse/PostToolUse
#             after you approve puts the tab back to green.
#   end     - SessionEnd: clear "busy" WITHOUT ringing. Claude exiting is not a
#             completed task, so it must not raise a needs-attention notification;
#             this just stops a killed/crashed session leaving the tab stuck green.
#
# State is a PANE option, and a pane only ever writes its own. The tab colour is a
# window-wide question, but answering it with a window option meant read-modify-write
# on a shared list of busy pane ids - two Claude sessions split into one window could
# interleave and lose an update, and a pane that died without SessionEnd left a stale
# id behind. tmux.conf aggregates instead: @claude_busy expands #{P:} across the
# rendered window's own panes, so there is nothing shared to race on and a dead pane
# takes its state with it.

[ -n "$TMUX" ] || exit 0

pane="${TMUX_PANE:-}"
[ -n "$pane" ] || exit 0

case "$1" in
  start) busy=1 ;;
  stop | notify | end) busy=0 ;;
  *) exit 0 ;;
esac

# $2 is the Claude Code event name, for the log only. `touch ~/.cache/claude-notify.log`
# to record which event drove each transition - the cheapest way to catch an event
# firing at an unexpected point in the turn. Delete the file to switch logging off.
log=~/.cache/claude-notify.log
[ -f "$log" ] && printf '%s %s %-12s %s\n' \
  "$(date '+%H:%M:%S')" "$pane" "${2:-?}" "$1" >> "$log"

# start is wired to every tool call, so make the already-busy case a single tmux
# roundtrip rather than a set plus a refresh-client fan-out. Only start short-circuits:
# a repeat stop still has a bell to ring.
if [ "$1" = start ] &&
  [ "$(tmux display-message -p -t "$pane" '#{@claude_pane_busy}' 2>/dev/null)" = 1 ]; then
  exit 0
fi

tmux set-option -p -t "$pane" @claude_pane_busy "$busy" 2>/dev/null

case "$1" in
  stop | notify)
    tty=$(tmux display-message -p -t "$pane" '#{pane_tty}')
    [ -w "$tty" ] && printf '\a' > "$tty"
    ;;
esac

# refresh-client -t needs a *client*, not a pane/window - target every client
# actually attached to this pane's session so the status bar updates instantly
# instead of waiting for the next status-interval tick.
tmux list-clients -t "$pane" -F '#{client_name}' 2>/dev/null | while IFS= read -r client; do
  tmux refresh-client -S -t "$client"
done
