alias lzd="lazydocker"
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
