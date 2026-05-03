# fzf plugin for oh-my-zsh
if ! command -v fzf &> /dev/null; then
    return 1
fi

# Try brew path first
FZF_PATH="${FZF_PATH:-$(brew --prefix)/opt/fzf}"

if [ -f "$FZF_PATH/shell/completion.zsh" ]; then
    source "$FZF_PATH/shell/completion.zsh"
fi

if [ -f "$FZF_PATH/shell/key-bindings.zsh" ]; then
    source "$FZF_PATH/shell/key-bindings.zsh"
fi

# Fallback
eval "$(fzf --zsh)"
