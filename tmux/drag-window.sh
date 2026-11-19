#!/bin/bash
# Move a tmux window to the slot of the tab it was dropped on, keeping focus on it.
# Bound to MouseDragEnd1Status in tmux.reset.conf: mouse-down on a tab already
# switched to it, so the active window is the dragged tab and `-t =` is the tab
# under the cursor at release.
#
# Usage: drag-window.sh <src-index> <dst-index>
#
# Adjacent swaps (rather than one swap-window src<->dst) give browser-style insert
# semantics: dragging 1 onto 4 in "1 2 3 4 5" yields "2 3 4 1 5". Explicit indexes
# only - see move-window.sh for why relative swap-window targets are avoided.
# renumber-windows is on and base-index is 1, so indexes are a contiguous 1..N.

[ -n "$TMUX" ] || exit 0

src=$1
dst=$2
{ [ -z "$src" ] || [ -z "$dst" ] || [ "$src" = "$dst" ]; } && exit 0

step=$(( dst > src ? 1 : -1 ))
i=$src
while [ "$i" != "$dst" ]; do
  tmux swap-window -d -s "$i" -t "$((i + step))"
  i=$((i + step))
done
tmux select-window -t "$dst"
