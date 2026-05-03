export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"

# This must stay at the top to ensure a fast startup experience
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [ "$ALACRITTY_USE_OMZ" = "1" ]; then
    export ZSH="$HOME/.oh-my-zsh"
    export ZSH_CACHE_DIR="$HOME/.oh-my-zsh/cache"
    ZSH_THEME="powerlevel10k/powerlevel10k"
    plugins=(git z docker fzf thefuck zsh-autosuggestions history)

    source $ZSH/oh-my-zsh.sh

    [ -f ~/.dotfiles/zsh/claude_config.zsh ] && source ~/.dotfiles/zsh/claude_config.zsh

    alias ls="eza --tree --level=1 --icons=always --no-time --no-user --no-permissions"

    function yy() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            cd -- "$cwd"
        fi
        rm -f -- "$tmp"
    }

    function htt() {
        httpyac $1 --json -a | jq -r ".requests[0].response.body" | jq | bat --language=json
    }

    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

    if [[ -o interactive ]] && [[ -t 0 ]] && [[ -z "$TMUX" ]]; then
        tmux attach-session -t default || tmux new-session -s default
    fi

else
    autoload -Uz compinit && compinit
    PROMPT='%n@%m %1~ %# '
fi
