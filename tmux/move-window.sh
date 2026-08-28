#!/bin/bash
# Move a tmux window one slot left or right in the tab bar, keeping focus on it.
# Bound to prefix + Shift-Left / Shift-Right in tmux.reset.conf.
#
# Usage: move-window.sh left|right <current-index> <window-count>
# The two numbers are filled in by the binding via #{window_index} /
# #{session_windows}; they fall back to a live query when run by hand.
#
# Why a script instead of `swap-window -t -1/+1` in the binding: this tmux
# (3.7c) silently no-ops `swap-window` with a relative target (`-t -1`,
# `-t {previous}`) - it only honours an explicit source/target pair. And
# swap-window never moves the active-window pointer, so focus has to be pulled
# to the new slot with a follow-up select-window. renumber-windows is on and
# base-index is 1, so the windows are always a contiguous 1..N and the
# neighbour slot is just index +/- 1. At the ends this is a no-op (no wrap).

[ -n "$TMUX" ] || exit 0

dir=$1
cur=${2:-$(tmux display-message -p '#{window_index}')}
count=${3:-$(tmux display-message -p '#{session_windows}')}

case "$dir" in
  left)
    [ "$cur" -le 1 ] && exit 0
    target=$((cur - 1))
    ;;
  right)
    [ "$cur" -ge "$count" ] && exit 0
    target=$((cur + 1))
    ;;
  *)
    echo "usage: move-window.sh left|right [current-index] [window-count]" >&2
    exit 1
    ;;
esac

tmux swap-window -d -s "$cur" -t "$target"
tmux select-window -t "$target"
