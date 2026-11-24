# ~/.config/tmux/tmux.conf

## Install
Once everything has been installed it's time to run TPM, install first:
```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

## Run
`Ctrl+I`

## Tab States

Window tabs show the state of Claude Code, Pi and watched shell commands. Like the tab
name, the colour follows the window's focused pane:

| Colour | Meaning |
|--------|---------|
| green | working (agent turn, or a watched command running) |
| blue | finished while you were elsewhere; clears once you see that pane |
| red | a watched shell command exited non-zero; clears once you see that pane |

Watched commands are listed in `TMUX_NOTIFY_COMMANDS` in `~/.dotfiles/zsh/tmux-notify.zsh`
(make, gmake, gnumake, brew upgrade/update/install/reinstall/bundle). Ctrl-C clears the
tab without a bell. `touch ~/.cache/claude-notify.log` to log transitions.

## Auto Theme Switching

This tmux configuration includes automatic theme switching between Catppuccin Latte (light) and Mocha (dark) based on your macOS system appearance.

### Features

- **Automatic Detection**: `dark-notify-runner.sh` runs `dark-notify` to monitor system appearance changes, and exits with the tmux server
- **Catppuccin Themes**:
  - Dark mode: Catppuccin Mocha
  - Light mode: Catppuccin Latte
- **Manual Toggle**: Script available for manual theme switching
- **Real-time Updates**: Automatically switches when you change system appearance

### Setup

1. **Install TPM** (if not already installed):
   ```bash
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   ```

2. **Install plugins** by pressing `Ctrl+A` + `I` in tmux

3. **Restart tmux** or reload configuration:
   ```bash
   tmux source-file ~/.config/tmux/tmux.conf
   ```

### Manual Theme Toggle

You can manually toggle themes using the provided script:
```bash
~/.config/tmux/toggle-theme.sh
```

### Theme Files

- `themes/catppuccin-mocha.conf` - Dark theme configuration
- `themes/catppuccin-latte.conf` - Light theme configuration

### Troubleshooting

If automatic switching doesn't work:
1. Ensure `dark-notify` is installed (`brew install dark-notify`) and `pgrep -fl dark-notify` shows it running
2. Check that the theme files exist in the `themes/` directory
3. Verify your macOS system appearance settings
4. Use the manual toggle script as a fallback

The configuration will automatically detect your system theme and apply the appropriate Catppuccin variant.
