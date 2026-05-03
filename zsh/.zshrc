# Ensure Homebrew and system binaries are found immediately
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
export EDITOR="nvim"

# This must stay at the top to ensure a fast startup experience
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [ "$GHOSTTY_USE_OMZ" = "1" ]; then
    # Oh My Zsh Paths
    export ZSH="$HOME/.config/ghostty/oh-my-zsh"
    ZSH_THEME="powerlevel10k/powerlevel10k"
    
    # Plugins list (verified syntax)
    plugins=(git z docker fzf thefuck zsh-autosuggestions history)

    # Initialize Oh My Zsh
    source $ZSH/oh-my-zsh.sh

    # Source environment variables
    [ -f ~/.dotfiles/zsh/claude_config.zsh ] && source ~/.dotfiles/zsh/claude_config.zsh

    # --- Aliases & Custom Functions ---
    # eza for a modern ls experience
    alias ls="eza --tree --level=1 --icons=always --no-time --no-user --no-permissions"
    
    # yazi wrapper to change directory on exit
    function yy() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            cd -- "$cwd"
        fi
        rm -f -- "$tmp"
    }

    # httpyac wrapper for API testing
    function htt() {
        httpyac $1 --json -a | jq -r ".requests[0].response.body" | jq | bat --language=json
    }

    # --- Theme & Cache ---
    # Source P10K configuration ONLY ONCE here
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    export ZSH_CACHE_DIR="$HOME/.config/ghostty/oh-my-zsh/cache"

    # Verified fix for "open terminal failed: not a terminal"
    if [[ -o interactive ]] && [[ -t 0 ]] && [[ -z "$TMUX" ]]; then
        tmux attach-session -t default || tmux new-session -s default
    fi

else
    # Clean setup for when you aren't using Ghostty
    autoload -Uz compinit && compinit
    PROMPT='%n@%m %1~ %# '
fi
