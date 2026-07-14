-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Скролл текста без перемещения курсора относительно экрана
vim.keymap.set("n", "<C-e>", "j<C-e>", { desc = "Scroll down without moving cursor" })
vim.keymap.set("n", "<C-y>", "k<C-y>", { desc = "Scroll up without moving cursor" })

-- Send delete/change to black hole register (don't pollute clipboard)
vim.keymap.set({ "n", "v" }, "d", '"_d', { desc = "Delete to black hole" })
vim.keymap.set({ "n", "v" }, "D", '"_D', { desc = "Delete to end to black hole" })
vim.keymap.set({ "n", "v" }, "c", '"_c', { desc = "Change to black hole" })
vim.keymap.set({ "n", "v" }, "C", '"_C', { desc = "Change to end to black hole" })
vim.keymap.set({ "n", "v" }, "x", '"_x', { desc = "Delete char to black hole" })

-- Follow lazygit worktree switches back into Neovim.
-- LAZYGIT_NEW_DIR_FILE is the official lazygit mechanism: lazygit writes the
-- new working directory to this file when the user switches worktrees.
if vim.fn.executable("lazygit") == 1 then
  local function open_lazygit(cwd)
    local new_dir_file = vim.fn.tempname()
    -- lazygit writes LAZYGIT_NEW_DIR_FILE on every quit (its generic cd-on-exit
    -- mechanism), not only when a worktree switch happened. Compare against the
    -- starting dir so a plain `q` doesn't trigger the qa/reopen flow below.
    local start_dir = vim.fn.fnamemodify(cwd or vim.fn.getcwd(), ":p:h")
    Snacks.lazygit({
      cwd = cwd,
      env = { LAZYGIT_NEW_DIR_FILE = new_dir_file },
      win = {
        on_close = function()
          local ok, lines = pcall(vim.fn.readfile, new_dir_file)
          vim.fn.delete(new_dir_file)
          if ok and lines and #lines > 0 then
            local target = vim.trim(table.concat(lines, ""))
            if target ~= "" and vim.fn.isdirectory(target) == 1 and vim.fn.fnamemodify(target, ":p:h") ~= start_dir then
              local switch_file = vim.env.NVIM_WORKTREE_SWITCH_FILE
              if switch_file and switch_file ~= "" then
                -- Shell wrapper will cd + reopen nvim after we quit
                vim.fn.writefile({ target }, switch_file)
                vim.schedule(function()
                  pcall(vim.cmd, "wa")
                  vim.cmd("qa")
                end)
              else
                vim.cmd("cd " .. vim.fn.fnameescape(target))
              end
            end
          end
        end,
      },
    })
  end
  local function lazygit_root()
    -- After a worktree switch, on_close updates vim.fn.getcwd() to the new worktree root.
    -- LazyVim.root.git() uses the current buffer's path and still returns the old worktree root.
    -- Prefer getcwd() when it's a git root itself (has .git dir or file); otherwise fall back.
    local cwd = vim.fn.getcwd()
    local marker = cwd .. "/.git"
    if vim.fn.isdirectory(marker) == 1 or vim.fn.filereadable(marker) == 1 then
      return cwd
    end
    return LazyVim.root.git()
  end
  vim.keymap.set("n", "<leader>gg", function() open_lazygit(lazygit_root()) end, { desc = "Lazygit (Root Dir)" })
  vim.keymap.set("n", "<leader>gG", function() open_lazygit(nil) end, { desc = "Lazygit (cwd)" })
end

Snacks.toggle({
  name = "Auto Theme",
  get = function()
    return vim.fn.filereadable(vim.fn.stdpath("data") .. "/auto-theme-disabled") == 0
  end,
  set = function(state)
    local t = require("config.auto-theme")
    if state then t.start() else t.stop() end
  end,
}):map("<leader>um")
