#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- 1. Install stow ---
if ! command -v stow &>/dev/null; then
  echo "Installing stow..."
  sudo apt-get update && sudo apt-get install -y stow
fi

# --- 2. Symlink dotfiles ---
cd "$DOTFILES_DIR"

echo "Stowing ~/.config packages..."
stow --target="$HOME/.config" .

echo "Stowing ~/ packages..."
stow --target="$HOME" zsh p10k idea

# --- 3. Install apt packages ---
echo "Installing packages..."
sudo apt-get update
sudo apt-get install -y \
  tmux \
  zsh \
  fzf \
  bat \
  jq \
  git \
  curl \
  unzip

# bat is installed as 'batcat' on Ubuntu — alias it
if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
  export PATH="$HOME/.local/bin:$PATH"
fi

# --- 4. Install Neovim (appimage — apt version is often too old) ---
if ! command -v nvim &>/dev/null; then
  echo "Installing Neovim..."
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
  sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
  rm nvim-linux-x86_64.tar.gz
else
  echo "Neovim already installed, skipping."
fi

# --- 5. Install eza ---
if ! command -v eza &>/dev/null; then
  echo "Installing eza..."
  sudo apt-get install -y gpg
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
    | sudo tee /etc/apt/sources.list.d/gierens.list
  sudo apt-get update
  sudo apt-get install -y eza
else
  echo "eza already installed, skipping."
fi

# --- 6. Install lazygit ---
if ! command -v lazygit &>/dev/null; then
  echo "Installing lazygit..."
  LG_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
    | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo lazygit.tar.gz \
    "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LG_VERSION}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit /usr/local/bin
  rm lazygit lazygit.tar.gz
else
  echo "lazygit already installed, skipping."
fi

# --- 7. Install yazi ---
if ! command -v yazi &>/dev/null; then
  echo "Installing yazi..."
  YAZI_VERSION=$(curl -s "https://api.github.com/repos/sxyazi/yazi/releases/latest" \
    | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo yazi.zip \
    "https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip"
  unzip -q yazi.zip
  sudo install yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/yazi
  rm -rf yazi.zip yazi-x86_64-unknown-linux-gnu
else
  echo "yazi already installed, skipping."
fi

# --- 8. Install thefuck ---
if ! command -v thefuck &>/dev/null; then
  echo "Installing thefuck..."
  sudo apt-get install -y python3-pip
  pip3 install thefuck --user
  export PATH="$HOME/.local/bin:$PATH"
else
  echo "thefuck already installed, skipping."
fi

# --- 9. Install Oh My Zsh ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh already installed, skipping."
fi

# --- 10. Install Powerlevel10k ---
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
  echo "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
else
  echo "Powerlevel10k already installed, skipping."
fi

# --- 11. Install zsh-autosuggestions ---
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
  echo "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
else
  echo "zsh-autosuggestions already installed, skipping."
fi

# --- 12. Install TPM (Tmux Plugin Manager) ---
if [ ! -d "$HOME/.config/tmux/plugins/tpm" ]; then
  echo "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
else
  echo "TPM already installed, skipping."
fi

# --- 13. Set zsh as default shell ---
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "Setting zsh as default shell..."
  chsh -s "$(which zsh)"
fi

echo ""
echo "Done! Next steps:"
echo "  1. Close and reopen Alacritty"
echo "  2. Inside tmux press Ctrl+A then I to install tmux plugins"
