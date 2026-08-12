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
export FZF_CTRL_T_OPTS="
  --preview '[ -d {} ] && eza --tree --level=2 --color=always {} || bat --color=always --style=numbers --line-range=:500 {}'
  --preview-window 'right:60%:wrap'
  --bind 'ctrl-/:toggle-preview'"

export FZF_ALT_C_OPTS="
  --preview 'eza --tree --level=2 --color=always {}'
  --preview-window 'right:60%:wrap'"
