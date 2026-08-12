alias lzd="lazydocker"

OBSIDIAN_VAULT="$HOME/Documents/Obsidian Vault"

# Open (or create) a meeting note for today, then optionally summarize with Claude
_meeting() {
  local title="${*:-Meeting}"
  local date=$(date +%Y-%m-%d)
  local time=$(date +%H:%M)
  local dir="$OBSIDIAN_VAULT/Meetings"
  local slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
  local file="$dir/${date}-${slug}.md"

  mkdir -p "$dir"

  if [ ! -f "$file" ]; then
    cat > "$file" << EOF
---
date: $date $time
tags: [meeting]
---

# $title

## Attendees


## Agenda


## Notes


## Action Items

- [ ]
EOF
  fi

  nvim "$file"
}
alias meeting='noglob _meeting'

# Summarize the most recent meeting note (or a given file) with Claude
meeting-sum() {
  local file="${1:-$(ls -t "$OBSIDIAN_VAULT/Meetings/"*.md 2>/dev/null | head -1)}"
  [ -z "$file" ] && echo "No meeting note found." && return 1
  echo "Summarizing: $file"
  claude "Summarize this meeting note into: a 1-2 sentence overview, bullet-point decisions made, and action items with owners. Output clean markdown.\n\n$(cat "$file")"
}

# nvim wrapper: after a lazygit worktree switch nvim quits and this cd's + reopens it
nvim() {
  local switch_file
  switch_file=$(mktemp)
  NVIM_WORKTREE_SWITCH_FILE="$switch_file" command nvim "$@"
  if [ -s "$switch_file" ]; then
    local target
    target=$(cat "$switch_file")
    rm -f "$switch_file"
    [ -d "$target" ] && cd "$target" && nvim
  else
    rm -f "$switch_file"
  fi
}
alias lsg="lazygit"

# lazygit with cd-on-exit (follows worktree switches)
lg() {
  local new_dir_file
  new_dir_file=$(mktemp)
  LAZYGIT_NEW_DIR_FILE="$new_dir_file" lazygit "$@"
  if [ -s "$new_dir_file" ]; then
    local target
    target=$(cat "$new_dir_file")
    [ -d "$target" ] && cd "$target"
  fi
  rm -f "$new_dir_file"
}

# --- fzf ---
# fzf has no preview by default; enable it for the CTRL-T (files) and ALT-C (dirs) widgets only.
# Bare `fzf` stays preview-free so piping arbitrary lists into it still works.
#
# --height doubles fzf's default 40%: key-bindings.zsh builds its option string as
# "--height ${FZF_TMUX_HEIGHT:-40%} ... $FZF_CTRL_T_OPTS", and the last --height wins.
# In a `right` layout the preview is as tall as fzf itself, so this is what makes the
# preview taller; the 60% in --preview-window is its *width*.
#
# fzf only binds shift-up/shift-down (one line at a time) for the preview; alt-up/alt-down
# are unbound by default, unlike ctrl-u/ctrl-d which already act on the result list.
export FZF_CTRL_T_OPTS="
  --height 80%
  --preview '[ -d {} ] && eza --tree --level=2 --color=always {} || bat --color=always --style=numbers --line-range=:500 {}'
  --preview-window 'right:60%:wrap'
  --bind 'ctrl-/:toggle-preview'
  --bind 'alt-up:preview-half-page-up,alt-down:preview-half-page-down'"

export FZF_ALT_C_OPTS="
  --height 80%
  --preview 'eza --tree --level=2 --color=always {}'
  --preview-window 'right:60%:wrap'
  --bind 'alt-up:preview-half-page-up,alt-down:preview-half-page-down'"
