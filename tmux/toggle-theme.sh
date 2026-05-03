#!/bin/bash

# Manual tmux theme toggle script
# Usage: ./toggle-theme.sh

# Get current appearance
current_theme=$(defaults read -g AppleInterfaceStyle 2>/dev/null || echo "Light")

if [[ "$current_theme" == "Dark" ]]; then
    # Switch to light theme
    tmux source-file ~/.config/tmux/themes/catppuccin-latte.conf
    echo "Switched tmux to light theme (Catppuccin Latte)"
else
    # Switch to dark theme
    tmux source-file ~/.config/tmux/themes/catppuccin-mocha.conf
    echo "Switched tmux to dark theme (Catppuccin Mocha)"
fi

# Refresh tmux
tmux refresh-client
