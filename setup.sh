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

echo "Symlinking lazygit config..."
LAZYGIT_DIR="$HOME/Library/Application Support/lazygit"
mkdir -p "$LAZYGIT_DIR"
ln -sf "$DOTFILES_DIR/lazygit/config.yml" "$LAZYGIT_DIR/config.yml"

echo "Symlinking Pi tmux extension..."
mkdir -p "$HOME/.pi/agent/extensions"
ln -sf "$DOTFILES_DIR/tmux/pi-tmux-notify.ts" "$HOME/.pi/agent/extensions/pi-tmux-notify.ts"

# Linked per file, not stowed: stow would fold ~/.pi into a directory symlink
# on a fresh machine, and Pi's auth, sessions and binaries would land in the repo.
echo "Symlinking Pi config..."
ln -sf "$DOTFILES_DIR/pi/models.json"   "$HOME/.pi/agent/models.json"
ln -sf "$DOTFILES_DIR/pi/settings.json" "$HOME/.pi/agent/settings.json"

read -r -p "Set up VS Code config? [y/N] " reply
if [[ "$reply" =~ ^[Yy]$ ]]; then
  echo "Symlinking VS Code config..."
  VSCODE_DIR="$HOME/Library/Application Support/Code/User"
  mkdir -p "$VSCODE_DIR"
  ln -sf "$DOTFILES_DIR/vscode/settings.json"    "$VSCODE_DIR/settings.json"
  ln -sf "$DOTFILES_DIR/vscode/keybindings.json" "$VSCODE_DIR/keybindings.json"
  echo "VS Code config linked."
else
  echo "Skipping VS Code setup."
fi

# --- 3. Install brew packages ---
echo "Installing brew packages..."
brew tap cormacrelf/tap
brew install tmux neovim fzf thefuck eza dark-notify jq bat lazygit lazydocker git-delta btop
# yazi and its recommended dependencies (file previews, thumbnails, archive support)
brew install ffmpegthumbnailer unar poppler fd ripgrep zoxide imagemagick exiftool
brew install yazi
# node is required by the Pi installer (>= 22.19, with npm)
brew install node ollama

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

# --- 9. Install Pi agent ---
# Must be on PATH first, or the installer offers to append to ~/.zshrc, which is tracked here
export PATH="$HOME/.local/bin:$PATH"
if [ ! -x "$HOME/.pi/agent/bin/pi" ]; then
  echo "Installing Pi agent..."
  # Non-TTY stdout skips the installer's "Start pi now?" prompt
  (set -o pipefail; curl -fsSL https://pi.dev/install.sh | sh | cat)
else
  echo "Pi agent already installed, skipping."
fi

# --- 10. Pull the local Ollama model ---
# Uses a temporary server: `brew services start` would register Ollama to run at every login.
OLLAMA_MODEL="qwen3.5:9b"
OLLAMA_TEMP_PID=""
trap '[ -z "$OLLAMA_TEMP_PID" ] || kill "$OLLAMA_TEMP_PID"' EXIT

if ! ollama list &>/dev/null; then
  ollama serve &>/dev/null &
  OLLAMA_TEMP_PID=$!
  for _ in {1..30}; do ollama list &>/dev/null && break; sleep 1; done
fi

if ollama list | awk 'NR>1 {print $1}' | grep -Fxq "$OLLAMA_MODEL"; then
  echo "$OLLAMA_MODEL already pulled, skipping."
else
  echo "Pulling $OLLAMA_MODEL..."
  ollama pull "$OLLAMA_MODEL"
fi

echo ""
echo "✓ Done! Next steps:"
echo "  1. Restart Ghostty"
echo "  2. Inside tmux press Ctrl+A then I to install tmux plugins"
