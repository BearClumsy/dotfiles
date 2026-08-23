-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.showtabline = 2
vim.opt.termguicolors = true
vim.opt.pumblend = 0 -- disable popup menu blend so catppuccin uses transparent Pmenu
vim.opt.winblend = 0 -- disable float window blend
-- Fallback border for floats that don't set their own. Snacks picker resolves its
-- `border = true` through this too, so keep it "rounded" to match the picker.
vim.opt.winborder = "rounded"
