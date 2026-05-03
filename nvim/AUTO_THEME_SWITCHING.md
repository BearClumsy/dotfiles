# Auto Theme Switching in LazyVim

This configuration enables automatic switching between dark and light themes based on your system's appearance settings.

## Features

- **Automatic detection**: Automatically switches between dark and light themes based on your macOS system appearance
- **Catppuccin theme**: Uses `catppuccin-mocha` for dark mode and `catppuccin-latte` for light mode
- **Manual toggle**: Press `<leader>ut` to manually toggle between themes
- **Real-time updates**: Checks for system theme changes every second
- **Tokyo Night fallback**: Tokyo Night theme available as alternative option

## How it works

The configuration uses the `auto-dark-mode.nvim` plugin which:
1. Monitors your system's dark/light mode setting
2. Automatically switches Neovim's colorscheme accordingly
3. Updates the `background` option to match

## Themes included

- **Dark mode**: `catppuccin-mocha` (rich, warm dark theme)
- **Light mode**: `catppuccin-latte` (soft, warm light theme)
- **Alternative**: Tokyo Night theme with `night` (dark) and `day` (light) variants

## Manual controls

- **Toggle theme**: `<leader>ut` - Manually switch between dark and light themes
- The manual toggle will temporarily override the automatic detection

## Configuration files

- `lua/plugins/colorscheme.lua` - Main theme configuration
- `lua/config/keymaps.lua` - Manual toggle keymap
- `lua/config/options.lua` - Background and color options

## Customization

To use different themes, modify the `set_dark_mode` and `set_light_mode` functions in `lua/plugins/colorscheme.lua`:

```lua
set_dark_mode = function()
  vim.api.nvim_set_option_value("background", "dark", {})
  vim.cmd("colorscheme your-preferred-dark-theme")
end,
set_light_mode = function()
  vim.api.nvim_set_option_value("background", "light", {})
  vim.cmd("colorscheme your-preferred-light-theme")
end,
```

### Available Catppuccin Flavours

- **catppuccin-latte**: Light theme (cream background)
- **catppuccin-frappe**: Dark theme (purple-ish)
- **catppuccin-macchiato**: Dark theme (darker purple)
- **catppuccin-mocha**: Dark theme (darkest, most popular)

## System requirements

- macOS (for automatic system theme detection)
- Terminal with true color support
- LazyVim setup

## Troubleshooting

If automatic switching doesn't work:
1. Ensure your terminal supports true colors
2. Check that `auto-dark-mode.nvim` is properly installed
3. Verify your macOS system appearance settings are properly configured
4. Use the manual toggle (`<leader>ut`) as a fallback

The configuration will fall back to the default Catppuccin Mocha theme if automatic detection fails.
