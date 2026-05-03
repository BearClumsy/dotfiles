-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Скролл текста без перемещения курсора относительно экрана
vim.keymap.set("n", "<C-e>", "j<C-e>", { desc = "Scroll down without moving cursor" })
vim.keymap.set("n", "<C-y>", "k<C-y>", { desc = "Scroll up without moving cursor" })

-- Manual theme toggle keymap
vim.keymap.set("n", "<leader>ut", function()
  if vim.o.background == "dark" then
    vim.api.nvim_set_option_value("background", "light", {})
    vim.cmd("colorscheme catppuccin-latte")
    vim.notify("Switched to light theme (Catppuccin Latte)", vim.log.levels.INFO)
  else
    vim.api.nvim_set_option_value("background", "dark", {})
    vim.cmd("colorscheme catppuccin-mocha")
    vim.notify("Switched to dark theme (Catppuccin Mocha)", vim.log.levels.INFO)
  end
end, { desc = "Toggle theme (dark/light)" })
