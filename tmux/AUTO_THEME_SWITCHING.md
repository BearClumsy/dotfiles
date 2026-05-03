# Tmux Auto Theme Switching with Catppuccin

This configuration provides automatic theme switching for tmux between Catppuccin Latte (light) and Mocha (dark) themes based on your macOS system appearance.

## 🎨 Theme Variants

- **Dark Mode**: Catppuccin Mocha - Rich, warm dark theme
- **Light Mode**: Catppuccin Latte - Soft, warm light theme

## 🚀 How It Works

The setup uses the `tmux-dark-notify` plugin which:
1. Monitors your macOS system appearance setting
2. Automatically loads the appropriate theme configuration file
3. Refreshes tmux to apply the new theme
4. Updates in real-time when you change system appearance

## 📁 File Structure

```
tmux/
├── tmux.conf                    # Main configuration file
├── themes/
│   ├── catppuccin-mocha.conf   # Dark theme configuration
│   └── catppuccin-latte.conf   # Light theme configuration
├── toggle-theme.sh             # Manual toggle script
└── README.md                   # Setup instructions
```

## ⚙️ Configuration Details

### Main Configuration (tmux.conf)

The main tmux configuration includes:
- `@dark-notify-theme-path-light` - Path to light theme config
- `@dark-notify-theme-path-dark` - Path to dark theme config
- Shared Catppuccin appearance settings

### Theme Files

Each theme file contains:
- Specific `@catppuccin_flavor` setting
- Plugin loading instruction for Catppuccin

### Plugins Required

- `catppuccin/tmux#v2.3.0` - Catppuccin theme plugin
- `erikw/tmux-dark-notify` - Auto theme switching plugin
- `tmux-plugins/tpm` - Plugin manager

## 🔧 Manual Controls

### Toggle Script

Use the provided script to manually switch themes:
```bash
~/.config/tmux/toggle-theme.sh
```

The script:
- Detects current system appearance
- Loads appropriate theme configuration
- Refreshes tmux display
- Provides feedback on theme change

### Manual Commands

You can also manually load themes:
```bash
# Load dark theme
tmux source-file ~/.config/tmux/themes/catppuccin-mocha.conf

# Load light theme  
tmux source-file ~/.config/tmux/themes/catppuccin-latte.conf
```

## 🛠️ Setup Instructions

1. **Ensure TPM is installed**:
   ```bash
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   ```

2. **Install plugins** by pressing `Ctrl+A` + `I` in tmux

3. **Reload configuration**:
   ```bash
   tmux source-file ~/.config/tmux/tmux.conf
   ```

4. **Test auto switching** by changing your macOS system appearance:
   - System Preferences → General → Appearance
   - Switch between Light and Dark

## 🎯 Customization

### Changing Themes

To use different Catppuccin flavors, edit the theme files:

**For dark mode** (edit `themes/catppuccin-mocha.conf`):
```bash
# Available dark variants: mocha, macchiato, frappe
set -g @catppuccin_flavor 'macchiato'
```

**For light mode** (edit `themes/catppuccin-latte.conf`):
```bash
# Currently latte is the only light variant
set -g @catppuccin_flavor 'latte'
```

### Custom Theme Paths

Update the paths in `tmux.conf` if you move theme files:
```bash
set -g @dark-notify-theme-path-light '/path/to/your/light-theme.conf'
set -g @dark-notify-theme-path-dark '/path/to/your/dark-theme.conf'
```

## 🐛 Troubleshooting

### Auto switching not working

1. **Check plugin installation**:
   ```bash
   ls ~/.tmux/plugins/tmux-dark-notify
   ```

2. **Verify theme files exist**:
   ```bash
   ls ~/.config/tmux/themes/
   ```

3. **Test manual switching**:
   ```bash
   ~/.config/tmux/toggle-theme.sh
   ```

4. **Check tmux logs**:
   ```bash
   tmux show-messages
   ```

### Theme not applying correctly

1. **Reload tmux configuration**:
   ```bash
   tmux source-file ~/.config/tmux/tmux.conf
   ```

2. **Kill and restart tmux**:
   ```bash
   tmux kill-server
   tmux
   ```

3. **Check Catppuccin plugin**:
   ```bash
   ls ~/.tmux/plugins/catppuccin
   ```

## 🎨 Available Catppuccin Flavors

- **latte** - Light theme (cream background)
- **frappe** - Dark theme (purple-ish)
- **macchiato** - Dark theme (darker purple)  
- **mocha** - Dark theme (darkest, most popular)

## 🔄 Integration with Other Tools

This tmux theme switching works seamlessly with:
- Neovim auto theme switching (if configured)
- Terminal theme switching
- System-wide dark/light mode

The theme will automatically sync with your system appearance for a consistent experience across all your terminal tools.
