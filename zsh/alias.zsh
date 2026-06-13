alias lzd="lazydocker"

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
