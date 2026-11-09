#!/usr/bin/env bash
# Runs dark-notify for one tmux server and exits when that server is gone.
set -u

SERVER_PID="$(cut -d, -f2 <<<"${TMUX:?must run inside tmux}")"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/tmux"
PID_FILE="$STATE_DIR/dark-notify-$SERVER_PID.pid"
mkdir -p "$STATE_DIR"

# Config reloads start this again. Bail before installing the trap so a
# duplicate never removes the live runner's PID file.
if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  exit 0
fi
echo $$ > "$PID_FILE"

eval "$(/opt/homebrew/bin/brew shellenv)"

child=
cleanup() {
  rm -f "$PID_FILE"
  [[ -n "$child" ]] && kill "$child" 2>/dev/null
}
trap cleanup EXIT
trap 'exit 0' TERM HUP INT

# tmux has no server-exit hook, so poll. Also restarts dark-notify if it dies.
while kill -0 "$SERVER_PID" 2>/dev/null; do
  if [[ -z "$child" ]] || ! kill -0 "$child" 2>/dev/null; then
    dark-notify -c "$HOME/.config/tmux/set-theme-mode.sh" &
    child=$!
  fi
  sleep 5
done
