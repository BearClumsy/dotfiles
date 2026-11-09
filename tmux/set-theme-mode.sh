#!/usr/bin/env bash
case "$1" in
  dark)  flavor=mocha ;;
  light) flavor=latte ;;
  *) echo "usage: ${0##*/} light|dark" >&2; exit 2 ;;
esac
exec tmux source-file "$HOME/.config/tmux/themes/catppuccin-$flavor.conf"
