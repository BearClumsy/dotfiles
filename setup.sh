#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure Homebrew is in PATH
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true

# --- 1. Install stow if not present ---
if ! command -v stow &>/dev/null; then
  echo "Installing stow..."
  brew install stow
fi

# --- 2. Symlink dotfiles ---
cd "$DOTFILES_DIR"

echo "Stowing ~/.config packages..."
stow --target="$HOME/.config" .

echo "Stowing ~/ packages..."
stow --target="$HOME" zsh p10k idea

# --- 3. Install brew packages ---
echo "Installing brew packages..."
brew tap cormacrelf/tap
brew install tmux neovim yazi fzf thefuck eza dark-notify jq bat lazygit

# --- 4. Install Nerd Font ---
echo "Installing Hack Nerd Font..."
brew install --cask font-hack-nerd-font

# --- 5. Install Oh My Zsh ---
if [ ! -d "$HOME/.config/ghostty/oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.config/ghostty/oh-my-zsh"
else
  echo "Oh My Zsh already installed, skipping."
fi

# --- 6. Install Powerlevel10k ---
if [ ! -d "$HOME/.config/ghostty/oh-my-zsh/custom/themes/powerlevel10k" ]; then
  echo "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$HOME/.config/ghostty/oh-my-zsh/custom/themes/powerlevel10k"
else
  echo "Powerlevel10k already installed, skipping."
fi

# --- 7. Install zsh-autosuggestions ---
if [ ! -d "$HOME/.config/ghostty/oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
  echo "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$HOME/.config/ghostty/oh-my-zsh/custom/plugins/zsh-autosuggestions"
else
  echo "zsh-autosuggestions already installed, skipping."
fi

# --- 8. Install TPM (Tmux Plugin Manager) ---
if [ ! -d "$HOME/.config/tmux/plugins/tpm" ]; then
  echo "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
else
  echo "TPM already installed, skipping."
fi

echo ""
echo "✓ Done! Next steps:"
echo "  1. Restart Ghostty"
echo "  2. Inside tmux press Ctrl+A then I to install tmux plugins"
