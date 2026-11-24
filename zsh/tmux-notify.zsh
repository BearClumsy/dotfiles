# Shell-command -> tmux window-tab notifier. The zsh counterpart to the Claude Code
# hooks and pi-tmux-notify.ts: same script (~/.config/tmux/claude-notify.sh), same tab
# colours. Commands matching TMUX_NOTIFY_COMMANDS turn the tab green while running;
# on exit it goes blue (success, bell), red (failure, bell) or back to normal (Ctrl-C).
#
# Only the first command of a line is matched: `make && brew upgrade` matches on make,
# and the colour reflects the exit status of the whole line.

[[ -n "$TMUX" && -n "$TMUX_PANE" ]] || return 0

# Entries match the leading words of a command line, so 'brew upgrade' also covers
# `brew upgrade --cask foo`. Append in claude_config.zsh for machine-local extras.
typeset -ga TMUX_NOTIFY_COMMANDS=(
  make gmake gnumake
  'brew upgrade' 'brew update' 'brew install' 'brew reinstall' 'brew bundle'
)

typeset -g _tmux_notify_script=~/.config/tmux/claude-notify.sh
typeset -g _tmux_notify_active=

_tmux_notify_preexec() {
  local -a words=(${(z)1})
  # Skip env assignments and precommand modifiers to reach the real command.
  while (( $#words )) && [[ $words[1] == *=* || $words[1] == (sudo|time|command|noglob|nocorrect|builtin|exec) ]]; do
    shift words
  done
  (( $#words )) || return
  # Expand one level of alias so e.g. `alias bu='brew upgrade'` still matches.
  if (( $+aliases[$words[1]] )); then
    words=(${(z)aliases[$words[1]]} $words[2,-1])
  fi

  local line="${(j: :)words}" entry
  for entry in $TMUX_NOTIFY_COMMANDS; do
    if [[ $line == "$entry" || $line == "$entry "* ]]; then
      _tmux_notify_active=1
      bash $_tmux_notify_script start preexec
      return
    fi
  done
}

_tmux_notify_precmd() {
  local st=$?
  [[ -n $_tmux_notify_active ]] || return
  _tmux_notify_active=
  case $st in
    0) bash $_tmux_notify_script stop precmd ;;
    130) bash $_tmux_notify_script end precmd ;; # Ctrl-C: you were there, no bell
    *) bash $_tmux_notify_script fail precmd ;;
  esac
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _tmux_notify_preexec
# Must run first: later precmd functions (p10k etc.) would clobber $?.
precmd_functions=(_tmux_notify_precmd ${precmd_functions:#_tmux_notify_precmd})
