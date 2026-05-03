-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Скролл текста без перемещения курсора относительно экрана
vim.keymap.set("n", "<C-e>", "j<C-e>", { desc = "Scroll down without moving cursor" })
vim.keymap.set("n", "<C-y>", "k<C-y>", { desc = "Scroll up without moving cursor" })
